#!/bin/bash

iterate_envvar_prefix(){
  prefix="$1"
  echo ${!prefix}
  for i in "${!prefix}"; do
    echo $i
    # indirection (use the value of i as a variable name)
    config_name=${i#$1}
    output_file=${config_name,,} # to lower
    output_file=${output_file//_/.} # replace underscore with dots
    output_file=$HTTPD_PATH/conf/$output_file.keytab # concatenate fullpath.
    ssm_path=${!i}
    echo $output_file
  done
}
SSM_X=x
SSM_Y=y
iterate_envvar_prefix "SSM_*"
