NFT_BASE_FABRIC=~/02_meta/NFT-BASE-FABRIC

cd ${NFT_BASE_FABRIC}/workspace/multiple-deployment-org1

mkdir -p chaincode/go
cp -r ~/02_meta/NFT-BASE-CONTRACT/chaincode-go/* chaincode/go/
cd chaincode/go
go env -w GOPROXY=https://goproxy.io,direct
go env -w GO111MODULE=on
go mod vendor
cd ../../



#org1
docker exec -it cli0.org1_2 bash
peer channel create -o orderer1.example.com:7060 -c mychannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer channel join -b mychannel.block
peer channel update -o orderer1.example.com:7060 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit

#org2
docker cp cli0.org1_2:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block ./
docker cp mychannel.block  cli0.org2_2:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block 
docker exec -it cli0.org2_2 bash
peer channel join -b mychannel.block
peer channel update -o orderer1.example.com:7060 -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit


#org1
docker exec -it cli0.org1_2 bash
go env -w GOPROXY=https://goproxy.io,direct
go env -w GO111MODULE=on
peer lifecycle chaincode package erc721cc.tar.gz --path /opt/gopath/src/github.com/hyperledger/multiple-deployment/chaincode/go --lang golang --label erc721cc_1
peer lifecycle chaincode install erc721cc.tar.gz
exit

#org2
docker cp cli0.org1_2:/opt/gopath/src/github.com/hyperledger/fabric/peer/erc721cc.tar.gz ./
docker cp erc721cc.tar.gz  cli0.org2_2:/opt/gopath/src/github.com/hyperledger/fabric/peer/
docker exec -it cli0.org2_2 bash
peer lifecycle chaincode install erc721cc.tar.gz
package_id=`peer lifecycle chaincode queryinstalled | grep erc721cc | cut -f 3 -d " " | sed "s/,//g"`
peer lifecycle chaincode approveformyorg --channelID mychannel --name erc721cc --version 1.0 --init-required --package-id ${package_id} --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit


#org1
docker exec -it cli0.org1_2 bash
package_id=`peer lifecycle chaincode queryinstalled | grep erc721cc | cut -f 3 -d " " | sed "s/,//g"`
peer lifecycle chaincode approveformyorg --channelID mychannel --name erc721cc --version 1.0 --init-required --package-id ${package_id} --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name erc721cc --version 1.0 --init-required --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
peer lifecycle chaincode commit -o orderer1.example.com:7060 --channelID mychannel --name erc721cc --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7061 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:8061 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
exit



