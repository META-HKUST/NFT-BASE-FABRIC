vi /etc/hosts
47.98.184.198 orderer0.example.com
47.98.184.198 orderer1.example.com
47.98.184.198 orderer2.example.com
47.98.184.198 peer0.org1.example.com
47.98.184.198 peer1.org1.example.com
47.98.184.198 peer0.org2.example.com
47.98.184.198 peer1.org2.example.com

cd ~/02_meta/NFT-BASE-FABRIC

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
# docker rmi -f $(docker images -q)

# 准备fabric docker images
# bash tools/2ysbOFE.sh 2.2.5 1.5.2

#org1
rm -r workspace/multiple-deployment-org1
mkdir -p workspace/multiple-deployment-org1
cd workspace/multiple-deployment-org1

cp -r /tmp/hyperledger/crypto-config .
# cp ../crypto-config.yaml .
# cryptogen generate --config=./crypto-config.yaml

cp ../../tools/configtx.yaml .
configtxgen -configPath ./ -profile SampleMultiNodeEtcdRaft -channelID multiple-deployment-channel -outputBlock ./channel-artifacts/genesis.block
configtxgen -configPath ./ -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
configtxgen -configPath ./ -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
configtxgen -configPath ./ -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

mkdir -p chaincode/go
cp -r ../../tools/go/* chaincode/go/
cd chaincode/go
go env -w GOPROXY=https://goproxy.io,direct
go env -w GO111MODULE=on
go mod vendor
cd ../../

cp ../../tools/docker-compose-up_org1.yaml .
docker-compose -f ./docker-compose-up_org1.yaml up -d


#org2
cd ~/02_meta/NFT-BASE-FABRIC
rm -r workspace/multiple-deployment-org2
mkdir workspace/multiple-deployment-org2
cd workspace/multiple-deployment-org2

cp ../multiple-deployment-org1/channel-artifacts -r .
cp ../multiple-deployment-org1/crypto-config -r .

cp ../../tools/docker-compose-up_org2.yaml .
docker-compose -f ./docker-compose-up_org2.yaml up -d


#org1
docker exec -it cli0.org1 bash
peer channel create -o orderer0.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer channel join -b mychannel.block
peer channel update -o orderer0.example.com:7050 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit

#org2
docker cp cli0.org1:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block ./
docker cp mychannel.block  cli0.org2:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block 
docker exec -it cli0.org2 bash
peer channel join -b mychannel.block
peer channel update -o orderer0.example.com:7050 -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit


#org1
docker exec -it cli0.org1 bash
go env -w GOPROXY=https://goproxy.io,direct
go env -w GO111MODULE=on
peer lifecycle chaincode package mycc.tar.gz --path /opt/gopath/src/github.com/hyperledger/multiple-deployment/chaincode/go --lang golang --label mycc_1
peer lifecycle chaincode install mycc.tar.gz
exit


#org2
docker cp cli0.org1:/opt/gopath/src/github.com/hyperledger/fabric/peer/mycc.tar.gz ./
docker cp mycc.tar.gz  cli0.org2:/opt/gopath/src/github.com/hyperledger/fabric/peer/
docker exec -it cli0.org2 bash
peer lifecycle chaincode install mycc.tar.gz
peer lifecycle chaincode approveformyorg --channelID mychannel --name mycc --version 1.0 --init-required --package-id mycc_1:768e9682a2a8016649369a5c8f32acfe56da2f9f1f11565f7bd8cf97e4abce46 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit

#org1
docker exec -it cli0.org1 bash
peer lifecycle chaincode approveformyorg --channelID mychannel --name mycc --version 1.0 --init-required --package-id mycc_1:768e9682a2a8016649369a5c8f32acfe56da2f9f1f11565f7bd8cf97e4abce46 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name mycc --version 1.0 --init-required --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
peer lifecycle chaincode commit -o orderer0.example.com:7050 --channelID mychannel --name mycc --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
peer chaincode invoke -o orderer0.example.com:7050 --isInit --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["Init","a","100","b","100"]}' --waitForEvent
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
peer chaincode invoke -o orderer0.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}' --waitForEvent
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
exit

# docker-compose -f ../docker-compose-up_org1.yaml down -v
# docker-compose -f ../docker-compose-up_org2.yaml down -v

