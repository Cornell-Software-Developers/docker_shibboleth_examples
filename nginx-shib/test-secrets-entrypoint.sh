#!/bin/bash

export NGINX_PATH=$PWD/tmp
export NGINX_PATH=$PWD/tmp
export SSM_NGINX_CONF=/custom-apps/culift/test/nginx.conf
export SSM_NGINX_CONF_D__site_conf=/custom-apps/culift/test/site.conf
export SSM_SSLCERTS_keyfile_key=/custom-apps/culift/test/keyfile.key
export SSM_SSLCERTS_keyfile_crt=/custom-apps/culift/test/keyfile.crt

function reset () {
  mkdir -p $NGINX_PATH/conf.d
  mkdir -p $NGINX_PATH/certs

  rm -f $NGINX_PATH/certs/*
  rm -f $NGINX_PATH/conf.d/*
  rm -f $NGINX_PATH/nginx.conf
}

reset

echo -e "secrets-entrypoint should be testable locally \n"
./secrets-entrypoint.sh

if [[ ! -f $NGINX_PATH/nginx.conf ]]; then
  echo "Didn't write nginx.conf"
fi

if [[ ! -f $NGINX_PATH/conf.d/site.conf ]]; then
  echo "Didn't write conf.d/site.conf"
fi

if [[ ! -f $NGINX_PATH/certs/keyfile.crt ]]; then
  echo "Didn't write conf.d/keyfile.crt"
fi
if [[ ! -f $NGINX_PATH/certs/keyfile.key ]]; then
  echo "Didn't write conf.d/keyfile.key"
fi

reset

echo -e "It should pull files from ssm and write them correctly \n"
touch $PWD/tmp/nginx.conf # Needs to be a file or docker will make it a directory
docker run -v $PWD/tmp/certs:/etc/nginx/certs \
  -v $PWD/tmp/conf.d:/etc/nginx/conf.d \
  -v $PWD/tmp/nginx.conf:/etc/nginx/nginx.conf \
  -e NGINX_PATH=/etc/nginx \
  -v ~/.aws/credentials:/root/.aws/credentials \
  -e AWS_PROFILE=$AWS_PROFILE \
  -e SSM_NGINX_NGINX_CONF=/custom-apps/culift/test/nginx.conf \
  -e SSM_NGINX_CONF_D__site_conf=/custom-apps/culift/test/site.conf \
  -e SSM_SSLCERTS_keyfile_key=/custom-apps/culift/test/keyfile.key \
  -e SSM_SSLCERTS_keyfile_crt=/custom-apps/culift/test/keyfile.crt \
 nginx-shib

if [[ ! -f $NGINX_PATH/nginx.conf ]]; then
  echo "Didn't write nginx.conf"
fi

if [[ ! -f $NGINX_PATH/conf.d/site.conf ]]; then
  echo "Didn't write conf.d/site.conf"
fi

if [[ ! -f $NGINX_PATH/certs/keyfile.crt ]]; then
  echo "Didn't write conf.d/keyfile.crt"
fi
if [[ ! -f $NGINX_PATH/certs/keyfile.key ]]; then
  echo "Didn't write conf.d/keyfile.key"
fi

reset

echo -e "It should run without env vars \n"
docker run -v $PWD/tmp/certs:/etc/nginx/certs \
  -v $PWD/tmp/conf.d:/etc/nginx/conf.d \
  -e NGINX_PATH=/etc/nginx \
  -v ~/.aws/credentials:/root/.aws/credentials \
  nginx-shib

reset

echo -e "It should generate self signed ssl certs when requested\n"
docker run -v $PWD/tmp/certs:/etc/nginx/certs \
  -v $PWD/tmp/conf.d:/etc/nginx/conf.d \
  -e GENERATE_SELFSIGNED_SSL=true \
  -e NGINX_PATH=/etc/nginx \
  -v ~/.aws/credentials:/root/.aws/credentials \
  nginx-shib

if [[ ! -f $NGINX_PATH/certs/keyfile.crt ]]; then
  echo "Didn't write conf.d/keyfile.crt"
fi
if [[ ! -f $NGINX_PATH/certs/keyfile.key ]]; then
  echo "Didn't write conf.d/keyfile.key"
fi
