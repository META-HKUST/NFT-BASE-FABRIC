cd /tmp/hyperledger
org=org1
port=7044
user_name=zzding

#tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/tls-ca/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client register -d --id.name ${user_name}.${org}.example.com --id.secret ${user_name}PW --id.type client -u https://0.0.0.0:7042

export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${user_name}
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
fabric-ca-client enroll -d -u https://${user_name}.${org}.example.com:${user_name}PW@0.0.0.0:7042 --enrollment.profile tls --csr.hosts ${user_name}.${org}.example.com


#ca
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/ca/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client register -d --id.name ${user_name}.${org}.example.com --id.secret ${user_name}PW --id.type client -u https://0.0.0.0:${port}

export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${user_name}
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://${user_name}.${org}.example.com:${user_name}PW@0.0.0.0:${port}
# sk=`ls ${org}/${user_name}/msp/keystore/ | grep -v priv` 
# mv ${org}/${user_name}/msp/keystore/$sk ${org}/${user_name}/msp/keystore/priv_sk

# mkdir -p ${org}/${user_name}/msp/admincerts/
# cp /tmp/hyperledger/${org}/admin/msp/signcerts/cert.pem /tmp/hyperledger/${org}/${user_name}/msp/admincerts/${org}-admin-cert.pem

#整理msp
mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com
    mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/msp
        cp -r ${org}/${user_name}/msp/* crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/msp/ 
        mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/msp/admincerts 
            # cp ${org}/${user_name}/msp/signcerts/cert.pem crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/msp/admincerts/${org}-admin-cert.pem
        mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/msp/tlscacerts
            cp ./tls-ca/crypto/tls-ca-cert.pem crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/msp/tlscacerts/tlsca.${org}.example.com-cert.pem
        cat config.yaml | sed "s/xxxxxxxx/cacerts\/0-0-0-0-${port}.pem/g" > crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/msp/config.yaml

mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/tls
    cp ${org}/${user_name}/tls-msp/tlscacerts/* crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/tls/ca.crt
    cp ${org}/${user_name}/tls-msp/signcerts/* crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/tls/client.crt
    cp ${org}/${user_name}/tls-msp/keystore/* crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com/tls/client.key


realpath crypto-config/peerOrganizations/${org}.example.com/users/${user_name}.${org}.example.com