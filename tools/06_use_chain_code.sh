
docker exec -it cli0.org1 bash

peer chaincode invoke -o orderer1.org0.example.com:7060 \
    --isInit  \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem \
    -C mychannel -n erc721cc \
    -c '{"Args":["SetChainCodeOwner","x509::CN=Admin.org1.example.com,OU=admin,O=Hyperledger,ST=North Carolina,C=US::CN=ca-org1,OU=Fabric,O=Hyperledger,ST=North Carolina,C=US"]}'  --waitForEvent \
    --peerAddresses peer0.org1.example.com:7061 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt 

peer chaincode invoke -o orderer1.org0.example.com:7060 \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem \
    -C mychannel -n erc721cc \
    -c '{"Args":["GetChainCodeOwner"]}' --waitForEvent \
    --peerAddresses peer0.org1.example.com:7061 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt


peer chaincode invoke -o orderer1.org0.example.com:7060 \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem \
    -C mychannel -n erc721cc \
    -c '{"Args":["SetBaseURI","http://www.try1try.com//"]}' --waitForEvent \
    --peerAddresses peer0.org1.example.com:7061 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt 

peer chaincode invoke -o orderer1.org0.example.com:7060 \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem \
    -C mychannel -n erc721cc \
    -c '{"Args":["ClientAccountID"]}' --waitForEvent \
    --peerAddresses peer0.org1.example.com:7061 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt 

user_name=zzding
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/${user_name}.org1.example.com/tls/client.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/${user_name}.org1.example.com/tls/client.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/${user_name}.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/${user_name}.org1.example.com/msp

peer chaincode invoke -o orderer1.org0.example.com:7060 \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp/tlscacerts/tlsca.org0.example.com-cert.pem \
    -C mychannel -n erc721cc \
    -c '{"Args":["PublicMint"]}' --waitForEvent \
    --peerAddresses peer0.org1.example.com:7061 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt 
    # --peerAddresses peer0.org2.example.com:8051 \
    # --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \


export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
exit