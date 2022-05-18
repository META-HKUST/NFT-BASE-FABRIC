#重置数据库
mysql -u root -h localhost -p -P 3306 -pmetaust -e "
SHOW DATABASES;
DROP DATABASE fabric_ca_org0;
DROP DATABASE fabric_tlsca_org0;
CREATE DATABASE fabric_ca_org0 CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE DATABASE fabric_tlsca_org0 CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

DROP DATABASE fabric_ca_org1;
DROP DATABASE fabric_tlsca_org1;
CREATE DATABASE fabric_ca_org1 CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE DATABASE fabric_tlsca_org1 CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

DROP DATABASE fabric_ca_org2;
DROP DATABASE fabric_tlsca_org2;
CREATE DATABASE fabric_ca_org2 CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE DATABASE fabric_tlsca_org2 CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
SHOW DATABASES;
quit"
service mysql restart