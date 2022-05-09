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
docker exec -it cli0.org1 bash
peer channel create -o orderer1.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer channel join -b mychannel.block
peer channel update -o orderer1.example.com:7050 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit

#org2
docker cp cli0.org1:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block ./
docker cp mychannel.block  cli0.org2:/opt/gopath/src/github.com/hyperledger/fabric/peer/mychannel.block 
docker exec -it cli0.org2 bash
peer channel join -b mychannel.block
peer channel update -o orderer1.example.com:7050 -c mychannel -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
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
peer lifecycle chaincode approveformyorg --channelID mychannel --name mycc --version 1.0 --init-required --package-id mycc_1:a32d28b2655bf31a6d39fe36d32f37147b33dc566d153f2a2ec6827a55477087 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
exit


#org1
docker exec -it cli0.org1 bash
peer lifecycle chaincode approveformyorg --channelID mychannel --name mycc --version 1.0 --init-required --package-id mycc_1:a32d28b2655bf31a6d39fe36d32f37147b33dc566d153f2a2ec6827a55477087 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name mycc --version 1.0 --init-required --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
peer lifecycle chaincode commit -o orderer1.example.com:7050 --channelID mychannel --name mycc --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
exit




docker exec -it cli0.org1 bash
peer chaincode invoke -o orderer1.example.com:7050 \
    --isInit  \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
    -C mychannel -n mycc \
    --peerAddresses peer0.org1.example.com:7051 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
    --peerAddresses peer0.org2.example.com:8051 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \
    -c '{"Args":["MintWithTokenURI","102","http:example/com"]}' --waitForEvent 
exit


# docker-compose -f ../docker-compose-up_org1.yaml down -v
# docker-compose -f ../docker-compose-up_org2.yaml down -v

