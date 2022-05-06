cd ~/02_meta/NFT-BASE-FABRIC

#重置数据库
mysql -u root -h localhost -p -P 3306
SHOW DATABASES;
DROP DATABASE `fabric_rca_org0`;
DROP DATABASE `fabric_rca_org1`;
DROP DATABASE `fabric_rca_org2`;
DROP DATABASE `fabric_ca_tls`;
SHOW DATABASES;
CREATE DATABASE `fabric_rca_org0` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE DATABASE `fabric_rca_org1` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE DATABASE `fabric_rca_org2` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE DATABASE `fabric_ca_tls` CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
SHOW DATABASES;
exit;
service mysql restart

#重置docker
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
# docker rmi -f $(docker images -q)
rm /tmp/hyperledger/ -r
docker-compose -f tools/docker-compose-ca.yaml up -d

cd /tmp/hyperledger
# cp /root/02_meta/workspace/fabric-ca-client .
ln -s /root/02_meta/workspace/see_crt.sh .
ln -s /root/02_meta/workspace/config.yaml .

#初始参数
orgs="org1_7044 org2_7045"
peers="peer0 peer1"
orders="orderer0 orderer1 orderer2"

#注册 TLS CA 管理员，注册节点身份
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/tls-ca/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
cp tls-ca/crypto/ca-cert.pem tls-ca/crypto/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-AdminPW@0.0.0.0:7042



#order相关
org=org0
port=7043
for order in $orders
do
    #注册order
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/tls-ca/admin
    export FABRIC_CA_CLIENT_MSPDIR=msp
    fabric-ca-client register -d --id.name ${order}.example.com --id.secret ${order}PW --id.type orderer -u https://0.0.0.0:7042
    
    #登记order
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${order}
    export FABRIC_CA_CLIENT_MSPDIR=tls-msp
    fabric-ca-client enroll -d -u https://${order}.example.com:${order}PW@0.0.0.0:7042 --enrollment.profile tls --csr.hosts ${order}.example.com
    # sk=`ls ${org}/${order}/tls-msp/keystore/ | grep -v key`     
    # mv ${org}/${order}/tls-msp/keystore/$sk ${org}/${order}/tls-msp/keystore/key.pem
done

org=org0
port=7043
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/ca/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://rca-${org}-admin:rca-${org}-AdminPW@0.0.0.0:${port}

#注册admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/ca/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client register -d --id.name admin-${org} --id.secret ${org}AdminPW --id.type admin --id.attrs "hf.Registrar.Roles=*,hf.Registrar.DelegateRoles=*,hf.AffiliationMgr=true,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert" -u https://0.0.0.0:${port}
#登记admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/admin
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-${org}:${org}AdminPW@0.0.0.0:${port}

#注册order
for order in $orders
do
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/ca/admin
    export FABRIC_CA_CLIENT_MSPDIR=msp
    fabric-ca-client register -d --id.name ${order}.example.com --id.secret ${order}PW --id.type orderer -u https://0.0.0.0:${port}
    
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${order}
    export FABRIC_CA_CLIENT_MSPDIR=msp
    fabric-ca-client enroll -d -u https://${order}.example.com:${order}PW@0.0.0.0:${port}
    # sk=`ls ${org}/admin/msp/keystore/ | grep -v priv` 
    # mv ${org}/admin/msp/keystore/$sk /tmp/hyperledger/org0/admin/msp/keystore/priv_sk

    mkdir /tmp/hyperledger/${org}/${order}/msp/admincerts
    # cp /tmp/hyperledger/${org}/admin/msp/signcerts/cert.pem /tmp/hyperledger/${org}/${order}/msp/admincerts/orderer-admin-cert.pem

done




#peer相关
for org_port in $orgs
do
    org=`echo ${org_port} | cut -f 1 -d _`
    port=`echo ${org_port} | cut -f 2 -d _`

    for peer in $peers
    do
        export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
        export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/tls-ca/admin
        export FABRIC_CA_CLIENT_MSPDIR=msp
        fabric-ca-client register -d --id.name ${peer}.${org}.example.com --id.secret ${peer}PW --id.type peer -u https://0.0.0.0:7042
    
        export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
        export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${peer}
        export FABRIC_CA_CLIENT_MSPDIR=tls-msp
        fabric-ca-client enroll -d -u https://${peer}.${org}.example.com:${peer}PW@0.0.0.0:7042 --enrollment.profile tls --csr.hosts ${peer}.${org}.example.com
        # sk=`ls ${org}/${peer}/tls-msp/keystore/ | grep -v key` 
        # mv ${org}/${peer}/tls-msp/keystore/$sk ${org}/${peer}/tls-msp/keystore/key.pem
    done
done

for org_port in $orgs
do
    org=`echo ${org_port} | cut -f 1 -d _`
    port=`echo ${org_port} | cut -f 2 -d _`
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/ca/admin
    export FABRIC_CA_CLIENT_MSPDIR=msp
    fabric-ca-client enroll -d -u https://rca-${org}-admin:rca-${org}-AdminPW@0.0.0.0:${port}

    fabric-ca-client register -d --id.name admin-${org} --id.secret ${org}AdminPW --id.type admin --id.attrs "hf.Registrar.Roles=*,hf.Registrar.DelegateRoles=*,hf.AffiliationMgr=true,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert" -u https://0.0.0.0:${port}
    # fabric-ca-client register -d --id.name user-${org} --id.secret ${org}UserPW --id.type user -u https://0.0.0.0:${port}
    
    export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
    export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/admin
    export FABRIC_CA_CLIENT_MSPDIR=msp
    fabric-ca-client enroll -d -u https://admin-${org}:${org}AdminPW@0.0.0.0:${port}
    # sk=`ls  ${org}/admin/msp/keystore/ | grep -v priv` 
    # mv ${org}/admin/msp/keystore/$sk /tmp/hyperledger/${org}/admin/msp/keystore/priv_sk
done

for org_port in $orgs
do
    org=`echo ${org_port} | cut -f 1 -d _`
    port=`echo ${org_port} | cut -f 2 -d _`

    for peer in $peers
    do
        export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
        export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/ca/admin
        export FABRIC_CA_CLIENT_MSPDIR=msp
        fabric-ca-client register -d --id.name ${peer}.${org}.example.com --id.secret ${peer}PW --id.type peer -u https://0.0.0.0:${port}
        
        export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/${org}/ca/crypto/ca-cert.pem
        export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/${org}/${peer}
        export FABRIC_CA_CLIENT_MSPDIR=msp
        fabric-ca-client enroll -d -u https://${peer}.${org}.example.com:${peer}PW@0.0.0.0:${port}
        # sk=`ls ${org}/${peer}/msp/keystore/ | grep -v priv` 
        # mv ${org}/${peer}/msp/keystore/$sk ${org}/${peer}/msp/keystore/priv_sk

        mkdir -p ${org}/${peer}/msp/admincerts/
        cp /tmp/hyperledger/${org}/admin/msp/signcerts/cert.pem /tmp/hyperledger/${org}/${peer}/msp/admincerts/${org}-admin-cert.pem
    done
done






#整理MSP 
orders="orderer0 orderer1 orderer2"

org=org0
port=7043
mkdir -p crypto-config/ordererOrganizations/example.com

    # mkdir -p crypto-config/ordererOrganizations/example.com/ca
        # ca.example.com-cert.pem
        # priv_sk
    
    mkdir -p crypto-config/ordererOrganizations/example.com/msp
        mkdir -p crypto-config/ordererOrganizations/example.com/msp/admincerts
            cp ${org}/admin/msp/signcerts/cert.pem crypto-config/ordererOrganizations/example.com/msp/admincerts/orderer-admin-cert.pem
        mkdir -p crypto-config/ordererOrganizations/example.com/msp/cacerts
            cp ${org}/ca/crypto/ca-cert.pem crypto-config/ordererOrganizations/example.com/msp/cacerts/ca.example.com-cert.pem
        mkdir -p crypto-config/ordererOrganizations/example.com/msp/tlscacerts
            cp ./tls-ca/crypto/tls-ca-cert.pem crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem
        cat config.yaml | sed "s/xxxxxxxx/cacerts\/ca.example.com-cert.pem/g" > crypto-config/ordererOrganizations/example.com/msp/config.yaml
    
    mkdir -p crypto-config/ordererOrganizations/example.com/orderers  
        for order in $orders
        do
            mkdir -p crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/
                cp -r ${org}/${order}/msp/* crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/
                # mv crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/cacerts/0-0-0-0-${port}.pem crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/cacerts/ca.example.com-cert.pem
                
                mkdir -p crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/admincerts
                    cp ${org}/admin/msp/signcerts/cert.pem crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/admincerts/orderer-admin-cert.pem
                mkdir -p crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/tlscacerts 
                    cp ./tls-ca/crypto/tls-ca-cert.pem crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


            #tls
            mkdir -p crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/tls
                cp ${org}/${order}/tls-msp/tlscacerts/* crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/tls/ca.crt
                cp ${org}/${order}/tls-msp/signcerts/* crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/tls/server.crt
                cp ${org}/${order}/tls-msp/keystore/* crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/tls/server.key

            mv crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/cacerts/* crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/cacerts/ca.example.com-cert.pem
            cat config.yaml | sed "s/xxxxxxxx/cacerts\/ca.example.com-cert.pem/g" >  crypto-config/ordererOrganizations/example.com/orderers/${order}.example.com/msp/config.yaml
        done

    # mkdir -p crypto-config/ordererOrganizations/example.com/tlsca

    # mkdir -p crypto-config/ordererOrganizations/example.com/users

mkdir -p crypto-config/peerOrganizations
orgs="org1_7044 org2_7045"
peers="peer0 peer1"
for org_port in $orgs
do
    org=`echo ${org_port} | cut -f 1 -d _`
    port=`echo ${org_port} | cut -f 2 -d _`

    mkdir -p crypto-config/peerOrganizations/${org}.example.com/ca
    mkdir -p crypto-config/peerOrganizations/${org}.example.com/msp
        mkdir -p crypto-config/peerOrganizations/${org}.example.com/msp/admincerts
            cp ${org}/admin/msp/signcerts/cert.pem crypto-config/peerOrganizations/${org}.example.com/msp/admincerts/${org}-admin-cert.pem
        mkdir -p crypto-config/peerOrganizations/${org}.example.com/msp/cacerts
            cp ${org}/admin/msp/cacerts/0-0-0-0-${port}.pem crypto-config/peerOrganizations/${org}.example.com/msp/cacerts/ca.${org}.example.com-cert.pem
        mkdir -p crypto-config/peerOrganizations/${org}.example.com/msp/tlscacerts
            cp ./tls-ca/crypto/tls-ca-cert.pem crypto-config/peerOrganizations/${org}.example.com/msp/tlscacerts/tlsca.${org}.example.com-cert.pem
        cat config.yaml | sed "s/xxxxxxxx/cacerts\/ca.${org}.example.com-cert.pem/g" > crypto-config/peerOrganizations/${org}.example.com/msp/config.yaml

    mkdir -p crypto-config/peerOrganizations/${org}.example.com/peers
        for peer in $peers
        do
            #peers
            mkdir -p crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/ 
                mkdir -p crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/msp
                    cp -r ${org}/${peer}/msp/ crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com
                
                    # mkdir -p crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/msp/admincerts
                    # mkdir -p crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/msp/tlscacerts 
                    cat config.yaml | sed "s/xxxxxxxx/cacerts\/0-0-0-0-${port}.pem/g" > crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/msp/config.yaml

                mkdir -p crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/tls

                    cp ${org}/${peer}/tls-msp/tlscacerts/* crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/tls/ca.crt
                    cp ${org}/${peer}/tls-msp/signcerts/* crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/tls/server.crt
                    cp ${org}/${peer}/tls-msp/keystore/* crypto-config/peerOrganizations/${org}.example.com/peers/${peer}.${org}.example.com/tls/server.key
        done

    mkdir -p crypto-config/peerOrganizations/${org}.example.com/tlsca

    mkdir -p crypto-config/peerOrganizations/${org}.example.com/users
        mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com
            mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp
                cp -r ${org}/admin/msp/* crypto-config/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp/ 
                mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp/admincerts 
                    cp ${org}/admin/msp/signcerts/cert.pem crypto-config/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp/admincerts/${org}-admin-cert.pem
                mkdir -p crypto-config/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp/tlscacerts
                    cp ./tls-ca/crypto/tls-ca-cert.pem crypto-config/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp/tlscacerts/tlsca.${org}.example.com-cert.pem
                cat config.yaml | sed "s/xxxxxxxx/cacerts\/0-0-0-0-${port}.pem/g" > crypto-config/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp/config.yaml


done

# cd ~/02_meta/NFT-BASE-FABRIC
# docker-compose -f docker-compose-ca.yaml down -v