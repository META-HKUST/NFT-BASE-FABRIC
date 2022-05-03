cert=$1
echo $1
openssl x509 -in $1 -noout -issuer -subject

# -text
