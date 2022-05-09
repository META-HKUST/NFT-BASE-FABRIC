NFT_BASE_FABRIC=~/02_meta/NFT-BASE-FABRIC
cd ${NFT_BASE_FABRIC}
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi -f $(docker images -q)
bash tools/2ysbOFE.sh 2.2.5 1.5.2