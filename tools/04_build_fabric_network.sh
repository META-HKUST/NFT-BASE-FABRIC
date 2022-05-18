# vi /etc/hosts
# 47.98.184.198 orderer1.org0.example.com
# 47.98.184.198 orderer2.org0.example.com
# 47.98.184.198 peer0.org1.example.com
# 47.98.184.198 peer0.org2.example.com

docker stop orderer1.org0.example.com orderer2.org0.example.com peer0.org1.example.com peer0.org2.example.com cli0.org1 cli0.org2
docker rm orderer1.org0.example.com orderer2.org0.example.com peer0.org1.example.com peer0.org2.example.com cli0.org1 cli0.org2

NFT_BASE_FABRIC=~/02_meta/NFT-BASE-FABRIC

#org1
cd ${NFT_BASE_FABRIC}
rm -r workspace/multiple-deployment-org1
mkdir -p workspace/multiple-deployment-org1
cd workspace/multiple-deployment-org1

cp -r /tmp/hyperledger/crypto-config .

cp ../../tools/configtx.yaml .
configtxgen -configPath ./ -profile SampleMultiNodeEtcdRaft -channelID multiple-deployment-channel -outputBlock ./channel-artifacts/genesis.block
configtxgen -configPath ./ -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
configtxgen -configPath ./ -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
configtxgen -configPath ./ -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

cp ../../tools/docker-compose-up_org1.yaml .
docker-compose -f ./docker-compose-up_org1.yaml up -d


#org2
cd ${NFT_BASE_FABRIC}
rm -r workspace/multiple-deployment-org2
mkdir workspace/multiple-deployment-org2
cd workspace/multiple-deployment-org2

cp ../multiple-deployment-org1/channel-artifacts -r .
cp ../multiple-deployment-org1/crypto-config -r .

cp ../../tools/docker-compose-up_org2.yaml .
docker-compose -f ./docker-compose-up_org2.yaml up -d

cd ${NFT_BASE_FABRIC}