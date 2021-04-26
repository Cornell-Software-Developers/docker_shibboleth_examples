#!/bin/bash


# Shibboleth needs the main config.xml, probably some signing keys, and extra conf.
# there's not a lot of organization in file structure.
export SHIBBOLETH_PATH=$PWD/tmp
export SSM_SHIBBOLETH2_XML=/custom-apps/culift/test/shibboleth2.xml
export SSM_ADDITIONAL_CONF_requestmap_xml=/custom-apps/culift/test/requestmap.xml

export SSM_CERTS_sp_encrypt_key_pem=/custom-apps/culift/test/sp_encrypt_key.pem
export SSM_CERTS_sp_encrypt_cert_pem=/custom-apps/culift/test/sp_encrypt_cert.pem
export SSM_CERTS_sp_signing_key_pem=/custom-apps/culift/test/sp_signing_key.pem
export SSM_CERTS_sp_signing_cert_pem=/custom-apps/culift/test/sp_signing_cert.pem

function reset () {
  mkdir -p $SHIBBOLETH_PATH/
  rm -f $SHIBBOLETH_PATH/*
  rm -f $SHIBBOLETH_PATH/*
}

reset

echo -e "secrets-entrypoint should be testable locally \n"
./secrets-entrypoint.sh

if [[ ! -f $SHIBBOLETH_PATH/shibboleth2.xml ]]; then
  echo "Didn't write shibboleth2.xml"
fi
if [[ -z `wc -c $SHIBBOLETH_PATH/shibboleth2.xml` ]]; then
  echo "Didn't write shibboleth2.xml"
fi

if [[ ! -f $SHIBBOLETH_PATH/requestmap.xml ]]; then
  echo "Didn't write requestmap.xml"
fi

if [[ ! -f $SHIBBOLETH_PATH/sp.signing.cert.pem ]]; then
  echo "Didn't write sp.signing.cert.pem"
fi
if [[ ! -f $SHIBBOLETH_PATH/sp.signing.key.pem ]]; then
  echo "Didn't write sp.signing.key.pem"
fi

if [[ ! -f $SHIBBOLETH_PATH/sp.encrypt.cert.pem ]]; then
  echo "Didn't write sp.encrypt.cert.pem"
fi
if [[ ! -f $SHIBBOLETH_PATH/sp.encrypt.key.pem ]]; then
  echo "Didn't write sp.encrypt.key.pem"
fi


reset
# NOTE: mounting a directory over /etc/shibboleth will break shibd because files will be missing.
# This works for testing because we just want to know that files are written, but it's not good for exec'ing.
echo -e "It should pull files from ssm and write them correctly \n"
touch $PWD/tmp/shibboleth2.xml # Needs to be a file or docker will make it a directory
docker run -v $PWD/tmp/shibboleth2.xml:/etc/shibboleth/shibboleth2.xml \
  --rm --name shibd-fastcgi -d \
  -v $PWD/tmp/:/etc/shibboleth/ \
  -e SHIBBOLETH_PATH=/etc/shibboleth \
  -v ~/.aws/credentials:/root/.aws/credentials \
  -e AWS_PROFILE=ssit-sb \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e  SSM_SHIBBOLETH2_XML=/custom-apps/culift/test/shibboleth2.xml \
  -e  SSM_ADDITIONAL_CONF_requestmap_xml=/custom-apps/culift/test/requestmap.xml \
  -e  SSM_CERTS_sp_encrypt_key_pem=/custom-apps/culift/test/sp_encrypt_key.pem \
  -e  SSM_CERTS_sp_encrypt_cert_pem=/custom-apps/culift/test/sp_encrypt_cert.pem \
  -e  SSM_CERTS_sp_signing_key_pem=/custom-apps/culift/test/sp_signing_key.pem \
  -e  SSM_CERTS_sp_signing_cert_pem=/custom-apps/culift/test/sp_signing_cert.pem \
 shibd-fastcgi

sleep 5

docker stop shibd-fastcgi


if [[ ! -f $SHIBBOLETH_PATH/shibboleth2.xml ]]; then
  echo "Didn't write shibboleth2.xml"
fi
if [[ -z `wc -c $SHIBBOLETH_PATH/shibboleth2.xml` ]]; then
  echo "Didn't write shibboleth2.xml"
fi

if [[ ! -f $SHIBBOLETH_PATH/requestmap.xml ]]; then
  echo "Didn't write requestmap.xml"
fi

if [[ ! -f $SHIBBOLETH_PATH/sp.signing.cert.pem ]]; then
  echo "Didn't write sp.signing.cert.pem"
fi
if [[ ! -f $SHIBBOLETH_PATH/sp.signing.key.pem ]]; then
  echo "Didn't write sp.signing.key.pem"
fi

if [[ ! -f $SHIBBOLETH_PATH/sp.encrypt.cert.pem ]]; then
  echo "Didn't write sp.encrypt.cert.pem"
fi
if [[ ! -f $SHIBBOLETH_PATH/sp.encrypt.key.pem ]]; then
  echo "Didn't write sp.encrypt.key.pem"
fi



reset

echo -e "It should run without env vars \n"

touch $PWD/tmp/shibboleth2.xml # Needs to be a file or docker will make it a directory
docker run -v $PWD/tmp/shibboleth2.xml:/etc/shibboleth/shibboleth2.xml \
  --rm --name shibd-fastcgi -d \
  -v $PWD/tmp/:/etc/shibboleth/ \
  -e SHIBBOLETH_PATH=/etc/shibboleth \
  -v ~/.aws/credentials:/root/.aws/credentials \
shibd-fastcgi

sleep 5
docker stop shibd-fastcgi

reset

# echo -e "It should generate self signed ssl certs when requested\n"
# docker run -v $PWD/tmp/certs:/etc/nginx/certs \
#   -v $PWD/tmp/conf.d:/etc/nginx/conf.d \
#   -e GENERATE_SELFSIGNED_SSL=true \
#   -e SHIBBOLETH_PATH=/etc/nginx \
#   -v ~/.aws/credentials:/root/.aws/credentials \
#   nginx-shib

# if [[ ! -f $SHIBBOLETH_PATH/certs/keyfile.crt ]]; then
#   echo "Didn't write conf.d/keyfile.crt"
# fi
# if [[ ! -f $SHIBBOLETH_PATH/certs/keyfile.key ]]; then
#   echo "Didn't write conf.d/keyfile.key"
# fi
