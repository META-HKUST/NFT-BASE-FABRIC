tools=`dirname $0`
source ${tools}/basic_fabric_ca.sh
enroll_org1_user_msp $1
enroll_org2_user_msp $1
