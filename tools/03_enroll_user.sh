tools=`dirname $0`
creator=${2:-"notcreator"}
source ${tools}/basic_fabric_ca.sh
enroll_org1_user_msp $1 $creator
enroll_org2_user_msp $1 $creator
