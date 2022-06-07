docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# tools=`dirname $0`
# source ${tools}/config.sh
# cd ${FABRIC_CODE}
# docker rmi -f $(docker images -q)
# bash ${FABRIC_CODE}/tools/docker_images_2ysbOFE.sh 2.2.5 1.5.2