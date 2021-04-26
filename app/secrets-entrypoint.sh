#!/bin/bash
CONFIG_PATH=/etc/php/
APP_CONFIG_PATH=/app/config/

# set region for AWS calls
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
export AWS_REGION=${AWS_REGION:-us-east-1}

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
  echo "${output_file_path}"

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
if [[ -v "SSM_APP_CONFIG_INC" ]]; then
  path=`write_ssm_to_file "${SSM_APP_CONFIG_INC}" "$APP_CONFIG_PATH/config.inc.php"`
fi

# Loop through environmental variables with matching prefix.
for i in ${!SSM_ADDITIONAL_CONF_*}; do
  # ! is for indirection (use the value of i as a variable name)
  # in $i, strip the prefix `SSM_ADDITIONAL_CONF_` leaving whatever follows in config_name
  config_name=${i#SSM_ADDITIONAL_CONF_}
  output_file=${config_name,,} # to lower
  output_file=${output_file//_/.} # replace underscore with dots
  output_file=$CONFIG_PATH/conf.d/$output_file # concatenate fullpath.

  # ssm_path is the value of the environmental variable
  ssm_path=${!i}
  path=`write_ssm_to_file "${ssm_path}" "$output_file"`
done

exec "$@"
