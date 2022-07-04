
docker exec -it cli0.org1 bash 

peer chaincode invoke -o orderer1.org0.unifit.com:7060 \
    --isInit \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem \
    -C unifitchannel -n unifitPublicNFT \
    -c '{"Args":["ClientAccountID"]}' --waitForEvent \
    --peerAddresses peer0.org1.unifit.com:7070 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/peers/peer0.org1.unifit.com/tls/ca.crt 

peer chaincode invoke -o orderer1.org0.unifit.com:7060 \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem \
    -C unifitchannel -n unifitPublicNFT \
    -c '{"Args":["SetBaseURI","http://www.unifit.ust.hk/"]}' --waitForEvent \
    --peerAddresses peer0.org1.unifit.com:7070 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/peers/peer0.org1.unifit.com/tls/ca.crt 


user_name=zzding
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/users/${user_name}.org1.unifit.com/tls/client.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/users/${user_name}.org1.unifit.com/tls/client.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/users/${user_name}.org1.unifit.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/users/${user_name}.org1.unifit.com/msp

peer chaincode invoke -o orderer1.org0.unifit.com:7060 \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem \
    -C unifitchannel -n unifitPublicNFT \
    -c '{"Args":["PublicMint"]}' --waitForEvent \
    --peerAddresses peer0.org2.unifit.com:8070 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.unifit.com/peers/peer0.org2.unifit.com/tls/ca.crt

peer chaincode invoke -o orderer1.org0.unifit.com:7060 \
    --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org0.unifit.com/orderers/orderer1.org0.unifit.com/msp/tlscacerts/tlsca.org0.unifit.com-cert.pem \
    -C unifitchannel -n unifitPublicNFT \
    -c '{"Args":["PublicMint"]}' --waitForEvent \
    --peerAddresses peer0.org1.unifit.com:7070 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/peers/peer0.org1.unifit.com/tls/ca.crt 


export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/peers/peer0.org1.unifit.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/peers/peer0.org1.unifit.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/peers/peer0.org1.unifit.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unifit.com/users/Admin@org1.unifit.com/msp

exit