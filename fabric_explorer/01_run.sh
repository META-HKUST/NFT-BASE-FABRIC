FABRIC_CODE=/home/fabric_release/01_Fabric/NFT-BASE-FABRIC
FABRIC_ENV=~/01_Fabric/hyperledger/

cd $FABRIC_ENV/
rm fabric_explorer -r
mkdir fabric_explorer
cd fabric_explorer

rm crypto-config -r
cp -r $FABRIC_ENV/crypto-config/ .
cd crypto-config/peerOrganizations/org1.unifit.com/users/fabric_explorer.org1.unifit.com/msp/keystore/
sk=`ls .`
cp $sk priv_sk
cd -

cd crypto-config/peerOrganizations/org2.unifit.com/users/fabric_explorer.org2.unifit.com/msp/keystore/
sk=`ls .`
cp $sk priv_sk
cd -

mkdir walletstore
mkdir pgdata
cp -r $FABRIC_CODE/fabric_explorer/connection-profile/ .
cp $FABRIC_CODE/fabric_explorer/docker-compose.yaml .
cp $FABRIC_CODE/fabric_explorer/config.json .

docker stop explorerdb.mynetwork.com explorer.mynetwork.com
docker rm explorerdb.mynetwork.com explorer.mynetwork.com
docker-compose -f docker-compose.yaml up -d