#!/bin/bash

NGINX_PATH=${NGINX_PATH:-/etc/nginx}
SSLCERTS_PATH=${SSLCERTS_PATH:-$NGINX_PATH/certs}

# set region for AWS calls
export AWS_DEFAULT_REGION=us-east-1



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
# string_split string separator [result var name]
function string_split() {
  local IFS
  local  __resultvar=${3:-string_split_results_var}
  # https://www.linuxjournal.com/content/return-values-bash-functions
  # Because bash is so broken, we need to eval to assign a value to the variable stored in $__resultsvar
  IFS=$2 eval read -ra $__resultvar <<< "$1"
  if [[ ! $3 ]]; then
    eval "echo \"\${$__resultvar[@]}\""
  fi

}

#use the word SSM_ as a key for grouping any of these.
#use the word SSMT_ for a template if implemented like this. Or SSMTPL
#use the following word as the path specifier.
#  **  If the X_PATH var is not set,  ** What do?
#use the remainder as file name.
#replace double underscore with slash.
#replace single underscore with dot.
function debug_print(){
  if [[ "$_DEBUG" ]]; then
    echo "$1"
  fi
}
function get_file_path() {
  local IFS
  declare -a parts
  file_path=/dev/null # if an env var doesn't match, we'll bin it to /dev/null and probably hard error.
  string_split $1 '_' parts
  debug_print "${parts[*]}"
  if [[ "${parts[0]}" == "SSM" ]]; then
    path_identifier="${parts[1]}_PATH"
    debug_print "$path_identifier"
    if [[ -v "$path_identifier" ]]; then
      file_path="${!path_identifier}"
      debug_print "file_path: $file_path"
    fi
    declare -a remaining_parts=(${parts[@]:2})
    # this is join.  it works, but to keep double underscore...
    # IFS='_' remainder="${remaining_parts[*]:-}"
    prefix="${parts[0]}_${parts[1]}_"
    remainder=`eval echo \""\${1#$prefix}"\"`
    debug_print "remainder: $remainder"
    # From here on, we're formatting the remaining path..
    output_file=${remainder//__//} # replace double underscore with /
    output_file=${output_file//_/.} # # replace underscore with dots
    output_file=${output_file,,} # to lower
    echo "${file_path}/${output_file}"
  fi
}
# in the end, we'd want to set SSM_NGINX_NGINX_CONF=/ssm/path.file
# with NGINX_PATH=/etc/nginx
# and have it write out /etc/nginx/nginx.conf with the value stored in ssm parameter /ssm/path.file


# These params are optional.  If not used, it's up to the user to ensure configs are in place.
# Probably by volume mounting or something.
if [[ -v "SSM_NGINX_CONF" ]]; then

  path=`write_ssm_to_file "${SSM_NGINX_CONF}" "$NGINX_PATH/nginx.conf"`

fi

# This is the replacement for all the customized ssm entrypoints.
for i in ${!SSM_*}; do
  # indirection (use the value of i as a variable name)
  ssm_path=${!i}
  output_file=`get_file_path "$i"`
  path=`write_ssm_to_file "${ssm_path}" "$output_file"`
done

for i in ${!SSM_ADDITIONAL_CONF_*}; do
  # indirection (use the value of i as a variable name)
  config_name=${i#SSM_ADDITIONAL_CONF_}
  output_file=${config_name,,} # to lower
  output_file=${output_file//_/.} # replace underscore with dots
  output_file=$NGINX_PATH/conf.d/$output_file # concatenate fullpath.
  ssm_path=${!i}
  path=`write_ssm_to_file "${ssm_path}" "$output_file"`
done

for i in ${!SSM_SSL_CERTS_*}; do
  # indirection (use the value of i as a variable name)
  config_name=${i#SSM_SSL_CERTS_}
  output_file=${config_name,,} # to lower
  output_file=${output_file//_/.} # replace underscore with dots
  output_file=$NGINX_PATH/certs/$output_file # concatenate fullpath.
  ssm_path=${!i}
  path=`write_ssm_to_file "${ssm_path}" "$output_file"`
done

if [[ -v GENERATE_SELFSIGNED_SSL ]]; then
  if [[ ! -v SELFSIGNED_SSL_DOMAIN ]]; then
    SELFSIGNED_SSL_DOMAIN=localhost
  fi

  /usr/bin/genSelfSignedCerts.sh $SELFSIGNED_SSL_DOMAIN /etc/nginx/certs
fi

