#!/bin/bash
# SHIB_FILE_PATH="apache-shib/files/shib-keys"

if [[ ! -f .env ]]; then
  echo "No .env found.  Copy .env.dist to .env and update parameters"
  exit 1
fi

source .env

SHIB_FILE_PATH="shibboleth-sp3/files/shib-keys"
if [[ $1 == "reset-certs" ]]; then
  rm nginx-shib/certs/*
  rm shibboleth-sp3/files/shib-keys/*

elif [[ $1 == "init" ]]; then
  mkdir -p $SHIB_FILE_PATH

  if [[ ! -f "${SHIB_FILE_PATH}/sp.encrypt.cert.pem" ]]; then 
    # I don't want to rely on shib-keygen being installed, so we'll use docker since we're already in for docker.
    docker run --rm -it -v $PWD/$SHIB_FILE_PATH:/data/:rw -e  DEBIAN_FRONTEND="noninteractive" -e TZ="America/New_York" ubuntu bash -c "\
      apt-get update && \
      apt-get install -y shibboleth-sp2-utils && \
      cd /data && \
      shib-keygen -n sp-signing -f -h $Domain_Name -y 10 -o \$PWD && \
      shib-keygen -n sp-encrypt -f -h $Domain_Name -y 10 -o \$PWD"
    # Shib-keygen doesn't let you change the `-cert` and `-key` suffix.  move files because I'd like them to match secrets-entrypoint convention
    mv $SHIB_FILE_PATH/sp-signing-cert.pem $SHIB_FILE_PATH/sp.signing.cert.pem
    mv $SHIB_FILE_PATH/sp-signing-key.pem $SHIB_FILE_PATH/sp.signing.key.pem

    mv $SHIB_FILE_PATH/sp-encrypt-cert.pem $SHIB_FILE_PATH/sp.encrypt.cert.pem
    mv $SHIB_FILE_PATH/sp-encrypt-key.pem $SHIB_FILE_PATH/sp.encrypt.key.pem
  fi

# This is a useful step if your app should actually do something.
# if [[ ! -f "app/config/config.inc.php" ]]; then
#   echo "WARN: config.inc.php not found; copying placeholder.  Please edit before running"
#   cp app/config/config.sample.inc.php app/config/config.inc.php
# fi
  if [[ ! -f "nginx-shib/certs/keyfile.crt" ]]; then
    cd nginx-shib/
    ./genSelfSignedCerts.sh $Domain_Name
    cd -
  fi
  echo "Done"

elif [[ $1 == "build" ]]; then
  docker-compose build

elif [[ $1 == "run" ]]; then 
  shift
  docker-compose up $@

elif [[ $1 == "logs" ]]; then 
  shift
  docker-compose logs $@

elif [[ $1 == "reset" ]]; then 
  docker-compose stop
  docker-compose rm -f

else
    echo "options: init, build, run, reset, reset-certs, clean"
fi


# Above command should generate these files
# sp-encrypt-cert.pem
# sp-encrypt-key.pem
# sp-signing-cert.pem
# sp-signing-key.pem
