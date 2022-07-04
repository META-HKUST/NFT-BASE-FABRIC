#user相关
tools=`dirname $0`
source ${tools}/config.sh
start_fabric_ca() 
{
    #config
    org=$1
    NFT_BASE_FABRIC=/home/fabric_release/01_Fabric/NFT-BASE-FABRIC

    #init
    docker stop ca-${org} tlsca-${org}
    docker rm ca-${org} tlsca-${org}
    rm ~/01_Fabric/hyperledger/${org} -r
    mkdir -p ~/01_Fabric/hyperledger/${org}/ca
    mkdir -p ~/01_Fabric/hyperledger/${org}/tlsca
    #run
    docker-compose -f ${NFT_BASE_FABRIC}/tools/docker-compose-ca_${org}.yaml up -d
}

enroll_admin()
{
    #config
    org=$1
    ca=$2
    port=$3
    #init
    #run
    cd ~/01_Fabric/hyperledger
    export FABRIC_CA_CLIENT_TLS_CERTFILES=~/01_Fabric/hyperledger/${org}/${ca}/crypto/ca-cert.pem
    export FABRIC_CA_CLIENT_HOME=~/01_Fabric/hyperledger/${org}/${ca}/admin
    export FABRIC_CA_CLIENT_MSPDIR=msp
    cp ~/01_Fabric/hyperledger/${org}/${ca}/crypto/ca-cert.pem ~/01_Fabric/hyperledger/${org}/${ca}/crypto/${ca}-cert.pem
    fabric-ca-client enroll -d -u https://${ca}-${org}-admin:${ca}-${org}-AdminPW@0.0.0.0:${port} 
}

enroll_user()
{
    #config
    org=$1
    ca=$2
    port=$3
    user=$4
    type=$5
    creator=${6:-'notcreator'}

    #init

    #run
    #注册user
    export FABRIC_CA_CLIENT_TLS_CERTFILES=~/01_Fabric/hyperledger/${org}/${ca}/crypto/${ca}-cert.pem
    export FABRIC_CA_CLIENT_HOME=~/01_Fabric/hyperledger/${org}/${ca}/admin
    export FABRIC_CA_CLIENT_MSPDIR=msp

    echo "xxxxxxx" $creator ${org}
    if [ $creator == creator ]
    then
        fabric-ca-client register -d --id.name ${user}.${org}.unifit.com --id.secret ${user}PW --id.type ${type} --id.attrs 'unifit.creator=true:ecert' -u https://0.0.0.0:${port}
    else
        fabric-ca-client register -d --id.name ${user}.${org}.unifit.com --id.secret ${user}PW --id.type ${type} -u https://0.0.0.0:${port}
    fi

    #登记user
    export FABRIC_CA_CLIENT_TLS_CERTFILES=~/01_Fabric/hyperledger/${org}/${ca}/crypto/${ca}-cert.pem
    export FABRIC_CA_CLIENT_HOME=~/01_Fabric/hyperledger/${org}/${ca}/${user}
    export FABRIC_CA_CLIENT_MSPDIR=msp

    if [ -d  ~/01_Fabric/hyperledger/${org}/${ca}/${user} ]; then
        rm -r ~/01_Fabric/hyperledger/${org}/${ca}/${user}
    fi

    if [ $ca == ca ]
    then
        fabric-ca-client enroll -d -u https://${user}.${org}.unifit.com:${user}PW@0.0.0.0:${port} 
    elif [ $ca == tlsca ]
    then
        fabric-ca-client enroll -d -u https://${user}.${org}.unifit.com:${user}PW@0.0.0.0:${port} --enrollment.profile tls --csr.hosts ${user}.${org}.unifit.com
    fi    
}

get_user_msp()
{
    org=$1
    user=$2
    user_msp=${3}/${2}.${1}.unifit.com
    if [ -d  ${user_msp} ]; then
        rm -r ${user_msp}
    fi
    mkdir -p ${user_msp}
        mkdir -p ${user_msp}/msp/
            mkdir -p ${user_msp}/msp/admincerts; cp -r ${org}/ca/Admin/msp/signcerts/* ${user_msp}/msp/admincerts
            mkdir -p ${user_msp}/msp/cacerts; cp -r ${org}/ca/${user}/msp/cacerts/* ${user_msp}/msp/cacerts/ca.${org}.unifit.com-cert.pem
            mkdir -p ${user_msp}/msp/keystore; cp -r ${org}/ca/${user}/msp/keystore/* ${user_msp}/msp/keystore
            mkdir -p ${user_msp}/msp/signcerts; cp -r ${org}/ca/${user}/msp/signcerts/* ${user_msp}/msp/signcerts
            mkdir -p ${user_msp}/msp/tlscacerts; cp ${org}/tlsca/${user}/msp/tlscacerts/* ${user_msp}/msp/tlscacerts/tlsca.${org}.unifit.com-cert.pem

        mkdir -p ${user_msp}/tls/
            cp ${org}/tlsca/${user}/msp/tlscacerts/*  ${user_msp}/tls/ca.crt
            cp ${org}/tlsca/${user}/msp/signcerts/*  ${user_msp}/tls/server.crt
            cp ${org}/tlsca/${user}/msp/keystore/*  ${user_msp}/tls/server.key

        cat config.yaml | sed "s/xxxxxxxx/cacerts\/ca.${org}.unifit.com-cert.pem/g" > ${user_msp}/msp/config.yaml

        # realpath ${user_msp}
}

get_org_msp()
{
    org=$1
    org_msp=$2

    mkdir -p ${org_msp}
        mkdir -p ${org_msp}/ca/ #TODO
        mkdir -p ${org_msp}/msp/
            mkdir -p ${org_msp}/msp/admincerts; cp ${org}/ca/Admin/msp/signcerts/* ${org_msp}/msp/admincerts
            mkdir -p ${org_msp}/msp/cacerts;  cp -r ${org}/ca/admin/msp/cacerts/* ${org_msp}/msp/cacerts/ca.${org}.unifit.com-cert.pem
            mkdir -p ${org_msp}/msp/keystore; cp ${org}/ca/admin/msp/keystore/* ${org_msp}/msp/keystore
            mkdir -p ${org_msp}/msp/signcerts; cp ${org}/ca/admin/msp/signcerts/* ${org_msp}/msp/signcerts
            mkdir -p ${org_msp}/msp/tlscacerts; cp ${org}/tlsca/crypto/tlsca-cert.pem   ${org_msp}/msp/tlscacerts/tlsca.${org}.unifit.com-cert.pem
        mkdir -p ${org_msp}/tlsca/ #TODO
        # mkdir -p ${org_msp}/orderers/
        # mkdir -p ${org_msp}/peers/
        # mkdir -p ${org_msp}/users/ 
        cat config.yaml | sed "s/xxxxxxxx/cacerts\/ca.${org}.unifit.com-cert.pem/g" > ${org_msp}/msp/config.yaml
}

get_connection()
{
    org=$1
    port=$2
    ca_port=$3
    org_msp=$4/org${org}.unifit.com
    tls_ca=${org_msp}/msp/tlscacerts/tlsca.org${org}.unifit.com-cert.pem
    pem=`cat ${tls_ca} | sed "s/ /@@@@/g" | xargs | sed "s/ /####/g" | sed "s/\//%%%%/g"`
    cat connection.yaml | sed "s/\${ORG}/${org}/g" | sed "s/\${P0PORT}/${port}/g" | sed "s/\${CAPORT}/${ca_port}/g" | sed "s/\${PEERPEM}/${pem}/g" | sed "s/\${CAPEM}/${pem}/g" | sed "s/@@@@/ /g" | sed "s/####/\n\          /g" | sed "s/%%%%/\//g" > ${org_msp}/connection-org${org}.yaml
}


init_crypto_config() {
    cd ~/01_Fabric/hyperledger
    rm crypto-config -r
    rm config.yaml
    ln -s ~/01_Fabric/NFT-BASE-FABRIC/tools/config.yaml ~/01_Fabric/hyperledger/
    ln -s ~/01_Fabric/NFT-BASE-FABRIC/tools/connection.yaml ~/01_Fabric/hyperledger/


    start_fabric_ca org0
    sleep 5

    #获得tlsca ca的admin
    enroll_admin org0 tlsca 6050
    enroll_admin org0 ca 6051

    # #创建Admin用户
    enroll_user org0 tlsca 6050 Admin admin  #会有冲突
    enroll_user org0 ca 6051 Admin admin #会有冲突
    get_user_msp org0 Admin crypto-config/ordererOrganizations/org0.unifit.com/users/
    get_user_msp org0 Admin crypto-config/peerOrganizations/org0.unifit.com/users/

    # #获得org用户
    get_org_msp org0 crypto-config/ordererOrganizations/org0.unifit.com
    get_org_msp org0 crypto-config/peerOrganizations/org0.unifit.com

    # #获得order用户
    enroll_user org0 tlsca 6050 orderer1 orderer
    enroll_user org0 ca 6051 orderer1 orderer
    get_user_msp org0 orderer1 crypto-config/ordererOrganizations/org0.unifit.com/orderers/

    enroll_user org0 tlsca 6050 orderer2 orderer
    enroll_user org0 ca 6051 orderer2 orderer
    get_user_msp org0 orderer2 crypto-config/ordererOrganizations/org0.unifit.com/orderers/


#======================================

    start_fabric_ca org1
    sleep 5

    #获得tlsca ca的admin
    enroll_admin org1 tlsca 7050
    enroll_admin org1 ca 7051

    # #创建Admin用户
    enroll_user org1 tlsca 7050 Admin admin creator #会有冲突
    enroll_user org1 ca 7051 Admin admin creator #会有冲突
    get_user_msp org1 Admin crypto-config/ordererOrganizations/org1.unifit.com/users/
    get_user_msp org1 Admin crypto-config/peerOrganizations/org1.unifit.com/users/

    # #获得org用户
    get_org_msp org1 crypto-config/ordererOrganizations/org1.unifit.com
    get_org_msp org1 crypto-config/peerOrganizations/org1.unifit.com

    # #获得order用户
    enroll_user org1 tlsca 7050 orderer0 orderer
    enroll_user org1 ca 7051 orderer0 orderer
    get_user_msp org1 orderer0 crypto-config/ordererOrganizations/org1.unifit.com/orderers/

    # #获得peer用户
    enroll_user org1 tlsca 7050 peer0 peer
    enroll_user org1 ca 7051 peer0 peer
    get_user_msp org1 peer0 crypto-config/peerOrganizations/org1.unifit.com/peers/
    get_connection 1 7070 7051 crypto-config/peerOrganizations


#======================================
    start_fabric_ca org2
    sleep 5

    #获得tlsca ca的admin
    enroll_admin org2 tlsca 8050
    enroll_admin org2 ca 8051

    # #创建Admin用户
    enroll_user org2 tlsca 8050 Admin admin creator #会有冲突
    enroll_user org2 ca 8051 Admin admin creator #会有冲突
    get_user_msp org2 Admin crypto-config/ordererOrganizations/org2.unifit.com/users/
    get_user_msp org2 Admin crypto-config/peerOrganizations/org2.unifit.com/users/

    # #获得org用户
    get_org_msp org2 crypto-config/ordererOrganizations/org2.unifit.com
    get_org_msp org2 crypto-config/peerOrganizations/org2.unifit.com

    # #获得order用户
    enroll_user org2 tlsca 8050 orderer0 orderer
    enroll_user org2 ca 8051 orderer0 orderer
    get_user_msp org2 orderer0 crypto-config/ordererOrganizations/org2.unifit.com/orderers/

    # #获得peer用户
    enroll_user org2 tlsca 8050 peer0 peer
    enroll_user org2 ca 8051 peer0 peer
    get_user_msp org2 peer0 crypto-config/peerOrganizations/org2.unifit.com/peers/
    get_connection 2 8070 8051 crypto-config/peerOrganizations




    #获得org用户
    # get_org_msp org crypto-config/ordererOrganizations/org2.unifit.com
    # get_org_msp org crypto-config/peerOrganizations/org2.unifit.com

    # #获得order用户
    # enroll_user org tlsca 7051 orderer2 orderer
    # enroll_user org ca 7052 orderer2 orderer
    # get_user_msp org orderer0 crypto-config/ordererOrganizations/org1.unifit.com/orderers/

    # #获得peer用户
    # enroll_user org tlsca 7051 peer2 peer
    # enroll_user org ca 7052 peer2 peer
    # get_user_msp org peer2 crypto-config/peerOrganizations/org1.unifit.com/peers/
    # get_connection 1 7061 7052 crypto-config/peerOrganizations


    # enroll_admin org1 tlsca 7050
    # enroll_admin org1 ca 7051

    # enroll_admin org2 tlsca 8050
    # enroll_admin org2 ca 8051
    
    # enroll_user org1 tlsca 7050 Admin admin
    # enroll_user org1 ca 7051 Admin admin
    # get_user_msp org1 Admin crypto-config/peerOrganizations/org1.unifit.com/users/

    # enroll_user org2 tlsca 8050 Admin admin
    # enroll_user org2 ca 8051 Admin admin
    # get_user_msp org2 Admin crypto-config/peerOrganizations/org2.unifit.com/users/

    # get_org_msp org0 crypto-config/ordererOrganizations
    # get_org_msp org1 crypto-config/peerOrganizations
    # get_org_msp org2 crypto-config/peerOrganizations

    # enroll_user org0 tlsca 7051 orderer2 orderer
    # enroll_user org0 ca 7052 orderer2 orderer
    # get_user_msp org0 orderer2 crypto-config/ordererOrganizations/org0.unifit.com/orderers/

    # enroll_user org1 tlsca 7050 peer0 peer
    # enroll_user org1 ca 7051 peer0 peer
    # get_user_msp org1 peer0 crypto-config/peerOrganizations/org1.unifit.com/peers/
    # get_connection 1 7061 7051 crypto-config/peerOrganizations

    # # enroll_user org1 tlsca 7050 peer1 peer
    # # enroll_user org1 ca 7051 peer1 peer
    # # get_user_msp org1 peer1 crypto-config/peerOrganizations/org1.unifit.com/peers/

    # enroll_user org2 tlsca 8050 peer0 peer
    # enroll_user org2 ca 8051 peer0 peer
    # get_user_msp org2 peer0 crypto-config/peerOrganizations/org2.unifit.com/peers/
    # get_connection 2 8061 8051 crypto-config/peerOrganizations

    # # enroll_user org2 tlsca 8050 peer1 peer
    # # enroll_user org2 ca 8051 peer1 peer
    # # get_user_msp org2 peer1 crypto-config/peerOrganizations/org2.unifit.com/peers/

    cd ~/01_Fabric/NFT-BASE-FABRIC
}

enroll_org1_user_msp() {
    cd ~/01_Fabric/hyperledger
    user=$1
    creator=${2:-'notcreator'}
    enroll_user org1 tlsca 7050 ${user} client $creator
    enroll_user org1 ca 7051 ${user} client $creator
    get_user_msp org1 ${user} crypto-config/peerOrganizations/org1.unifit.com/users/
    realpath crypto-config/peerOrganizations/org1.unifit.com/users/${user}.org1.unifit.com/msp/
    cd ~/01_Fabric/NFT-BASE-FABRIC
}


enroll_org2_user_msp() {
    cd ~/01_Fabric/hyperledger
    user=$1
    creator=${2:-'notcreator'}
    enroll_user org2 tlsca 8050 ${user} client $creator
    enroll_user org2 ca 8051 ${user} client $creator
    get_user_msp org2 ${user} crypto-config/peerOrganizations/org2.unifit.com/users/
    realpath crypto-config/peerOrganizations/org2.unifit.com/users/${user}.org2.unifit.com/msp/
    cd ~/01_Fabric/NFT-BASE-FABRIC
}
