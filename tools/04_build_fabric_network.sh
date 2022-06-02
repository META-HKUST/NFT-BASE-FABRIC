tools=`dirname $0`
source ${tools}/config.sh
# FABRIC_CODE=~/01_Fabric/NFT-BASE-FABRIC/
# FABRIC_ENV=~/01_Fabric/hyperledger/

docker stop orderer1.org0.example.com orderer2.org0.example.com peer0.org1.example.com peer0.org2.example.com cli0.org1 cli0.org2
docker rm orderer1.org0.example.com orderer2.org0.example.com peer0.org1.example.com peer0.org2.example.com cli0.org1 cli0.org2

mkdir -p ${FABRIC_ENV}/workspace

#org1
cd ${FABRIC_ENV}/workspace
rm -r ${FABRIC_ENV}/workspace/multiple-deployment-org1
mkdir -p ${FABRIC_ENV}/workspace/multiple-deployment-org1
cd ${FABRIC_ENV}/workspace/multiple-deployment-org1
cp ${FABRIC_ENV}/crypto-config -r .

cp ${FABRIC_CODE}/tools/configtx.yaml .
configtxgen -configPath ./ -profile SampleMultiNodeEtcdRaft -channelID multiple-deployment-channel -outputBlock ./channel-artifacts/genesis.block
configtxgen -configPath ./ -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
configtxgen -configPath ./ -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
configtxgen -configPath ./ -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP


mkdir -p ./orderer/var/hyperledger/orderer
cp channel-artifacts/genesis.block ./orderer/var/hyperledger/orderer/orderer.genesis.block
cp -r ./crypto-config/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/msp ./orderer/var/hyperledger/orderer/msp
cp -r ./crypto-config/ordererOrganizations/org0.example.com/orderers/orderer1.org0.example.com/tls ./orderer/var/hyperledger/orderer/tls
mkdir -p ./peer/etc/hyperledger/fabric
cp -r ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp ./peer/etc/hyperledger/fabric/msp
cp -r ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls ./peer/etc/hyperledger/fabric/tls
mkdir -p ./peer/var/hyperledger/
mkdir -p ./chaincode/go/
mkdir -p ./cli
mkdir -p ./cli/channel-artifacts
mkdir -p ./cli/crypto
cp -r ./channel-artifacts/* ./cli/channel-artifacts/
cp -r ./crypto-config/* ./cli/crypto/

cp ${FABRIC_CODE}/tools/docker-compose-up_org1.yaml .
docker-compose -f ./docker-compose-up_org1.yaml up -d


#org2
cd ${FABRIC_ENV}/workspace
rm -r ${FABRIC_ENV}/workspace/multiple-deployment-org2
mkdir ${FABRIC_ENV}/workspace/multiple-deployment-org2
cd ${FABRIC_ENV}/workspace/multiple-deployment-org2
cp ${FABRIC_ENV}/crypto-config -r .
cp -r ${FABRIC_ENV}/workspace/multiple-deployment-org1/channel-artifacts .

mkdir -p ./orderer/var/hyperledger/orderer
cp channel-artifacts/genesis.block ./orderer/var/hyperledger/orderer/orderer.genesis.block
cp -r ./crypto-config/ordererOrganizations/org0.example.com/orderers/orderer2.org0.example.com/msp ./orderer/var/hyperledger/orderer/msp
cp -r ./crypto-config/ordererOrganizations/org0.example.com/orderers/orderer2.org0.example.com/tls ./orderer/var/hyperledger/orderer/tls
mkdir -p ./peer/etc/hyperledger/fabric
cp -r ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp ./peer/etc/hyperledger/fabric/msp
cp -r ./crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls ./peer/etc/hyperledger/fabric/tls
mkdir -p ./peer/var/hyperledger/
mkdir -p ./chaincode/go/
mkdir -p ./cli
mkdir -p ./cli/channel-artifacts
mkdir -p ./cli/crypto
cp -r ./channel-artifacts/* ./cli/channel-artifacts/
cp -r ./crypto-config/* ./cli/crypto/

cp ${FABRIC_CODE}/tools/docker-compose-up_org2.yaml .
docker-compose -f ./docker-compose-up_org2.yaml up -d

cd ${FABRIC_ENV}/workspace