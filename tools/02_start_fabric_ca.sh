#user相关
start_fabric_ca() 
{
    #config
    org=$1
    NFT_BASE_FABRIC=~/02_meta/NFT-BASE-FABRIC

    #init
    docker stop ca-${org} tlsca-${org}
    docker rm ca-${org} tlsca-${org}
    rm /tmp/hyperledger/${org} -r

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
    cd /tmp/hyperledger
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/${ca}/crypto/${ca}-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${ca}/admin
    export FABRIC_CA_CLIENT_MSPDIR=msp
    cp /tmp/hyperledger/${org}/${ca}/crypto/ca-cert.pem /tmp/hyperledger/${org}/${ca}/crypto/${ca}-cert.pem
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

    #init

    #run
    #注册user
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/${ca}/crypto/${ca}-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${ca}/admin
    export FABRIC_CA_CLIENT_MSPDIR=msp
    fabric-ca-client register -d --id.name ${user}.${org}.example.com --id.secret ${user}PW --id.type ${type} -u https://0.0.0.0:${port}
    
    #登记user
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/${ca}/crypto/${ca}-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${ca}/${user}
    export FABRIC_CA_CLIENT_MSPDIR=msp
    # fabric-ca-client enroll -d -u https://${user}.${org}.example.com:${user}PW@0.0.0.0:${port} --enrollment.profile tls --csr.hosts ${user}.example.com
    fabric-ca-client enroll -d -u https://${user}.${org}.example.com:${user}PW@0.0.0.0:${port}
}

get_user_msp()
{
    org=$1
    user=$2
    user_msp=${3}/${2}.${1}.example.com

    mkdir -p ${user_msp}
        mkdir -p ${user_msp}/msp/
            mkdir -p ${user_msp}/msp/admincerts; cp -r ${org}/ca/${user}/msp/signcerts/* ${user_msp}/msp/admincerts
            mkdir -p ${user_msp}/msp/cacerts; cp -r ${org}/ca/${user}/msp/cacerts/* ${user_msp}/msp/cacerts/ca.${org}.example.com-cert.pem
            mkdir -p ${user_msp}/msp/keystore; cp -r ${org}/ca/${user}/msp/keystore/* ${user_msp}/msp/keystore
            mkdir -p ${user_msp}/msp/signcerts; cp -r ${org}/ca/${user}/msp/signcerts/* ${user_msp}/msp/signcerts
            mkdir -p ${user_msp}/msp/tlscacerts; cp ${org}/tlsca/${user}/msp/cacerts/* ${user_msp}/msp/tlscacerts/tlsca.${org}.example.com-cert.pem

        mkdir -p ${user_msp}/tls/
            cp ${org}/tlsca/${user}/msp/cacerts/*  ${user_msp}/tls/ca.crt
            cp ${org}/tlsca/${user}/msp/signcerts/*  ${user_msp}/tls/client.crt
            cp ${org}/tlsca/${user}/msp/keystore/*  ${user_msp}/tls/client.key

        cat config.yaml | sed "s/xxxxxxxx/cacerts\/ca.${org}.example.com-cert.pem/g" > ${user_msp}/msp/config.yaml

        realpath ${user_msp}
}

get_org_msp()
{
    org=$1
    org_msp=$2/${1}.example.com

    mkdir -p ${org_msp}
        mkdir -p ${org_msp}/ca/ #TODO
        mkdir -p ${org_msp}/msp/
            mkdir -p ${org_msp}/msp/admincerts; cp ${org}/ca/admin/msp/signcerts/* ${org_msp}/msp/admincerts
            mkdir -p ${org_msp}/msp/cacerts;  cp -r ${org}/ca/admin/msp/cacerts/* ${org_msp}/msp/cacerts/ca.${org}.example.com-cert.pem
            mkdir -p ${org_msp}/msp/keystore; cp ${org}/ca/admin/msp/keystore/* ${org_msp}/msp/keystore
            mkdir -p ${org_msp}/msp/signcerts; cp ${org}/ca/admin/msp/signcerts/* ${org_msp}/msp/signcerts
            mkdir -p ${org_msp}/msp/tlscacerts; cp ${org}/tlsca/admin/msp/cacerts/*   ${org_msp}/msp/tlscacerts/tlsca.${org}.example.com-cert.pem
        mkdir -p ${org_msp}/tlsca/ #TODO
        # mkdir -p ${org_msp}/orderers/
        # mkdir -p ${org_msp}/peers/
        # mkdir -p ${org_msp}/users/ 
        cat config.yaml | sed "s/xxxxxxxx/cacerts\/ca.${org}.example.com-cert.pem/g" > ${org_msp}/msp/config.yaml
        realpath ${org_msp}
}

init_crypto_config() {
    cd /tmp/hyperledger
    rm crypto-config -r

    start_fabric_ca org0
    start_fabric_ca org1
    start_fabric_ca org2

    enroll_admin org0 tlsca 11051
    enroll_admin org0 ca 11052
    get_org_msp org0 crypto-config/ordererOrganizations

    enroll_admin org1 tlsca 11053
    enroll_admin org1 ca 11054
    get_org_msp org1 crypto-config/peerOrganizations

    enroll_admin org2 tlsca 11055
    enroll_admin org2 ca 11056
    get_org_msp org2 crypto-config/peerOrganizations

    enroll_user org0 tlsca 11051 orderer1 orderer
    enroll_user org0 ca 11052 orderer1 orderer
    get_user_msp org0 orderer1 crypto-config/ordererOrganizations/org0.example.com/orderers/

    enroll_user org0 tlsca 11051 orderer2 orderer
    enroll_user org0 ca 11052 orderer2 orderer
    get_user_msp org0 orderer2 crypto-config/ordererOrganizations/org0.example.com/orderers/


    enroll_user org1 tlsca 11053 peer0 peer
    enroll_user org1 ca 11054 peer0 peer
    get_user_msp org1 peer0 crypto-config/peerOrganizations/org1.example.com/peers/

    enroll_user org1 tlsca 11053 peer1 peer
    enroll_user org1 ca 11054 peer1 peer
    get_user_msp org1 peer1 crypto-config/peerOrganizations/org1.example.com/peers/

    enroll_user org2 tlsca 11055 peer0 peer
    enroll_user org2 ca 11056 peer0 peer
    get_user_msp org2 peer0 crypto-config/peerOrganizations/org2.example.com/peers/

    enroll_user org2 tlsca 11055 peer1 peer
    enroll_user org2 ca 11056 peer1 peer
    get_user_msp org2 peer1 crypto-config/peerOrganizations/org2.example.com/peers/

    # enroll_user org1 tlsca 11053 Admin admin
    # enroll_user org1 ca 11054 Admin admin
    # get_user_msp org1 Admin crypto-config/peerOrganizations/org1.example.com/users/
}

enroll_org1_user_msp() {
    user=$1
    enroll_user org1 tlsca 11053 ${user} client
    enroll_user org1 ca 11054 ${user} client
    get_user_msp org1 ${user} crypto-config/peerOrganizations/org1.example.com/users/
}