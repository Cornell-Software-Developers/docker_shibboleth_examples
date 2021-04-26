#!/bin/bash


if [[ -z $1 ]]; then 
  echo "Usage: $0 FakeQDN [output_path]"
  echo "where FakeQDN is the Fully Qualified Domain Name you will use to test."
  echo "you will want to add this to your hostfile for testing"
  echo "if output_path not given, will write to $PWD/certs/"
  exit 1
fi

if [[ ! -z $2 ]]; then
  output_path=$2
  mkdir -p $2
  cd $2
else
  mkdir -p certs
  output_path=$PWD/certs
fi

cn=$1


(
cat <<'CONFIGFILECONTENTS'
[ req ]
prompt = no
default_bits = 2048
default_keyfile = keyfile.key
encrypt_key = no
distinguished_name = req_distinguished_name

string_mask = utf8only

req_extensions = v3_req

[ req_distinguished_name ]
O=Cornell University - Dev
L=Ithaca
ST=NY
C=US
CN={cn}

[ v3_req ]

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
CONFIGFILECONTENTS
) > $output_path/config

## Sometimes, you just need to get things done.  use sed to do variable substitution.
sed -i "s/{cn}/$cn/g" $output_path/config

openssl req -new -x509 -config $output_path/config -keyout $output_path/keyfile.key -out $output_path/keyfile.crt

openssl dhparam -out $output_path/dhparam.pem 2048
