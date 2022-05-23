FABRIC_CODE=~/01_Fabric/NFT-BASE-FABRIC/
FABRIC_ENV=~/01_Fabric/hyperledger/

cd ${FABRIC_ENV}/workspace/multiple-deployment-org1

mkdir -p chaincode/go
cp -r ~/01_Fabric/NFT-BASE-CONTRACT/chaincode-go/* chaincode/go/
cd chaincode/go
go env -w GOPROXY=https://goproxy.io,direct
go env -w GO111MODULE=on
go mod vendor
cd ../../



#org1
docker exec -it cli0.org1 bash
peer channel create -o orderer1.org0.example.com:7060 -c mychannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem
peer channel join -b mychannel.block
peer channel update -o orderer1.org0.example.com:7060 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem
exit


#org2
docker cp cli0.org1:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block ./
docker cp mychannel.block  cli0.org2:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block 
docker exec -it cli0.org2 bash
peer channel join -b mychannel.block
peer channel update -o orderer1.org0.example.com:7060 -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem
exit

#org1
docker exec -it cli0.org1 bash
go env -w GOPROXY=https://goproxy.io,direct
go env -w GO111MODULE=on
mkdir -p .cache/go-build
mkdir -p .config/go
go env -w GOENV=`pwd`/.config/go/env
go env -w GOCACHE=`pwd`/.cache/go-build
peer lifecycle chaincode package erc721cc.tar.gz --path /opt/gopath/src/github.com/hyperledger/multiple-deployment/chaincode/go --lang golang --label erc721cc_1
peer lifecycle chaincode install erc721cc.tar.gz
exit

#org2
docker cp cli0.org1:/opt/gopath/src/github.com/hyperledger/fabric/peer/erc721cc.tar.gz ./
docker cp erc721cc.tar.gz  cli0.org2:/opt/gopath/src/github.com/hyperledger/fabric/peer/
docker exec -it cli0.org2 bash
peer lifecycle chaincode install erc721cc.tar.gz
package_id=`peer lifecycle chaincode queryinstalled | grep erc721cc | cut -f 3 -d " " | sed "s/,//g"`
peer lifecycle chaincode approveformyorg --channelID mychannel --name erc721cc --version 1.0 --init-required --package-id ${package_id} --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem
exit


#org1
docker exec -it cli0.org1 bash
package_id=`peer lifecycle chaincode queryinstalled | grep erc721cc | cut -f 3 -d " " | sed "s/,//g"`
peer lifecycle chaincode approveformyorg --channelID mychannel --name erc721cc --version 1.0 --init-required --package-id ${package_id} --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name erc721cc --version 1.0 --init-required --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem --output json
peer lifecycle chaincode commit -o orderer1.org0.example.com:7060 --channelID mychannel --name erc721cc --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem --peerAddresses peer0.org1.example.com:7061 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:8061 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
exit



cd ${FABRIC_CODE}