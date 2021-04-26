#!/bin/bash
export AWS_DEFAULT_REGION=us-east-1
SHIBBOLETH_PATH=${SHIBBOLETH_PATH:-/etc/shibboleth}
ODBC_PATH=${ODBC_PATH:-/etc}
# MYSQL_PATH=${MYSQL_PATH:-/etc/mysql/conf.d}



function fetch_ssm_param_value() {
  param_value=$(aws ssm get-parameter \
  --with-decryption \
  --name "${ssm_path}" \
  --output text --query 'Parameter.Value' )
  echo "${param_value}"
}

function write_ssm_to_file() { 
  ssm_path=$1
  output_file_path=$2
  ## TODO
  fetch_ssm_param_value $ssm_path > $output_file_path
  echo $output_file_path

}
function write_base64_ssm_to_file() { 
  ssm_path=$1
  output_file_path=$2
  echo $(fetch_ssm_param_value $ssm_path) \
  | base64 -d \
  > $output_file_path
  echo $output_file_path

}

# These params are optional.  If not used, it's up to the user to ensure configs are in place.
# Probably by volume mounting or something.
if [[ -v "SSM_SHIBBOLETH2_XML" ]]; then
  path=`write_ssm_to_file "${SSM_SHIBBOLETH2_XML}" "$SHIBBOLETH_PATH/shibboleth2.xml"`

fi

for i in ${!SSM_ADDITIONAL_CONF_*}; do
  # indirection (use the value of i as a variable name)
  config_name=${i#SSM_ADDITIONAL_CONF_}
  output_file=${config_name,,} # to lower
  output_file=${output_file//_/.} # replace underscore with dots
  output_file=$SHIBBOLETH_PATH/$output_file # concatenate fullpath.
  ssm_path=${!i}
  path=`write_ssm_to_file "${ssm_path}" "$output_file"`
done

for i in ${!SSM_CERTS_*}; do
  # indirection (use the value of i as a variable name)
  config_name=${i#SSM_CERTS_}
  output_file=${config_name,,} # to lower
  output_file=${output_file//_/.} # replace underscore with dots
  output_file=$SHIBBOLETH_PATH/$output_file # concatenate fullpath.
  ssm_path=${!i}
  path=`write_ssm_to_file "${ssm_path}" "$output_file"`
done

for i in ${!SSM_ODBC_*}; do
  # indirection (use the value of i as a variable name)
  config_name=${i#SSM_ODBC_}
  output_file=${config_name,,} # to lower
  output_file=${output_file//_/.} # replace underscore with dots
  output_file=$ODBC_PATH/$output_file # concatenate fullpath.
  ssm_path=${!i}
  path=`write_ssm_to_file "${ssm_path}" "$output_file"`
done

if [[ -v GENERATE_SELFSIGNED_SSL ]]; then
  if [[ ! -v SELFSIGNED_DOMAIN ]]; then
    SELFSIGNED_DOMAIN=localhost
  fi

  /usr/bin/genSelfSignedCerts.sh $SELFSIGNED_DOMAIN /etc/shibboleth/certs
fi

exec "$@"
