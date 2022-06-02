#v1 0328d427e82cdb30bbcf17b0e11a0b30520ab438
#v2 fb10875d3b19a9b152e7fdd0671bcc466f94ccae

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
docker exec -it cli0.org1 bash -c "
peer channel create -o orderer1.org0.unifit.com:7060 -c unifitchannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem
peer channel join -b unifitchannel.block
peer channel update -o orderer1.org0.unifit.com:7060 -c unifitchannel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem
"


#org2
docker cp cli0.org1:/opt/gopath/src/github.com/hyperledger/fabric/peer/unifitchannel.block ./
docker cp unifitchannel.block  cli0.org2:/opt/gopath/src/github.com/hyperledger/fabric/peer/unifitchannel.block 
docker exec -it cli0.org2 bash -c "
peer channel join -b unifitchannel.block
peer channel update -o orderer1.org0.unifit.com:7060 -c unifitchannel -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem
"


#org1
docker exec -it cli0.org1 bash -c "
mkdir -p .cache/go-build
mkdir -p .config/gzo
export GOENV=\`pwd\`/.config/go/env
export GOCACHE=\`pwd\`/.cache/go-build
export GOPROXY=https://goproxy.io,direct
export GO111MODULE=on
peer lifecycle chaincode package unifitPublicNFT.tar.gz --path /opt/gopath/src/github.com/hyperledger/multiple-deployment/chaincode/go --lang golang --label unifitPublicNFT_1
peer lifecycle chaincode install unifitPublicNFT.tar.gz
"

#org2
docker cp cli0.org1:/opt/gopath/src/github.com/hyperledger/fabric/peer/unifitPublicNFT.tar.gz ./
docker cp unifitPublicNFT.tar.gz  cli0.org2:/opt/gopath/src/github.com/hyperledger/fabric/peer/
docker exec -it cli0.org2 bash -c "
peer lifecycle chaincode install unifitPublicNFT.tar.gz
package_id=\`peer lifecycle chaincode queryinstalled | grep unifitPublicNFT | cut -f 3 -d ' ' | sed 's/,//g'\`
peer lifecycle chaincode approveformyorg --channelID unifitchannel --name unifitPublicNFT --version 1.0 --init-required --package-id \${package_id} --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem
"


#org1
docker exec -it cli0.org1 bash -c "
package_id=\`peer lifecycle chaincode queryinstalled | grep unifitPublicNFT | cut -f 3 -d ' ' | sed 's/,//g'\`
peer lifecycle chaincode approveformyorg --channelID unifitchannel --name unifitPublicNFT --version 1.0 --init-required --package-id \${package_id} --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem
peer lifecycle chaincode checkcommitreadiness --channelID unifitchannel --name unifitPublicNFT --version 1.0 --init-required --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem --output json
peer lifecycle chaincode commit -o orderer1.org0.unifit.com:7060 --channelID unifitchannel --name unifitPublicNFT --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem --peerAddresses peer0.org1.unifit.com:7061 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/peers/peer0.org1.unifit.com/tls/ca.crt --peerAddresses peer0.org2.unifit.com:8061 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.unifit.com/peers/peer0.org2.unifit.com/tls/ca.crt
"



cd ${FABRIC_CODE}