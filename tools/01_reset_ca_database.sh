#重置数据库
mysql -u fabric_ca_org_admin -h pascal.ieda.ust.hk -P 3306 -p -e "
SHOW DATABASES;
DROP DATABASE fabric_ca_org;
DROP DATABASE fabric_tlsca_org;
CREATE DATABASE fabric_ca_org CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE DATABASE fabric_tlsca_org CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
quit"
# service mysql restart