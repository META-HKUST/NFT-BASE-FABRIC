FABRIC_CODE=/home/fabric_release/01_Fabric/NFT-BASE-FABRIC
FABRIC_ENV=~/01_Fabric/hyperledger/

cd $FABRIC_ENV/
rm fabric_exlporer -r
mkdir fabric_exlporer
cd fabric_exlporer

rm crypto-config -r
cp -r $FABRIC_ENV/crypto-config/ .
cd crypto-config/peerOrganizations/org1.unifit.com/users/fabric_exlporer.org1.unifit.com/msp/keystore/
sk=`ls .`
cp $sk priv_sk
cd -

cd crypto-config/peerOrganizations/org2.unifit.com/users/fabric_exlporer.org2.unifit.com/msp/keystore/
sk=`ls .`
cp $sk priv_sk
cd -

mkdir walletstore
mkdir pgdata
cp -r $FABRIC_CODE/fabric_exlporer/connection-profile/ .
cp $FABRIC_CODE/fabric_exlporer/docker-compose.yaml .
cp $FABRIC_CODE/fabric_exlporer/config.json .

docker stop explorerdb.mynetwork.com explorer.mynetwork.com
docker rm explorerdb.mynetwork.com explorer.mynetwork.com
docker-compose -f docker-compose.yaml up -d