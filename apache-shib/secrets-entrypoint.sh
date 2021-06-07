#!/bin/bash

# advanced bash trickery:
# http://wiki.bash-hackers.org/syntax/pe

# Check that environment variables have been set correctly
HTTPD_PATH=${HTTPD_PATH:=/etc/httpd}

# get keytab and base64 decode it to output


# Allow for more than one cuwa keytab if desired
for i in ${!SSM_ADDITIONAL_KEYTAB_*}; do
  # indirection (use the value of i as a variable name)
  config_name=${i#SSM_ADDITIONAL_KEYTAB_}
  output_file=${config_name,,} # to lower
  output_file=${output_file//_/.} # replace underscore with dots
  output_file=$HTTPD_PATH/conf/$output_file.keytab # concatenate fullpath.
  ssm_path=${!i}

  aws ssm get-parameter \
  --region us-east-1 \
  --with-decryption \
  --name "${ssm_path}" \
  --output text --query 'Parameter.Value' \
  | base64 -d \
  > $output_file

# change perms to what cuwebauth wants
  chmod 600 $output_file
  chown www-data:root $output_file
done


if [ -v SECRETS_HTTPD_VHOSTS ]
then
    aws ssm get-parameter \
    --region us-east-1 \
    --name "${SECRETS_HTTPD_VHOSTS}" \
    --output text --query 'Parameter.Value' \
    > $HTTPD_PATH/conf.sites.d/vhosts.conf
fi


# variable name expansion (get all set variables with prefix)
for i in ${!ADDITIONAL_CONF_*}; do
  config_name=${i#ADDITIONAL_CONF_}
  output_file=$HTTPD_PATH/conf.d/${config_name,,}.conf
  # indirection (use the value of i as a variable name)
  echo ${!i} > $output_file
  echo "Include $output_file">> $HTTPD_PATH/conf/httpd.conf
done

for i in ${!SSM_ADDITIONAL_CONF_*}; do
  # indirection (use the value of i as a variable name)
  config_name=${i#SSM_ADDITIONAL_CONF_}
  output_file=$HTTPD_PATH/conf.d/${config_name,,}.conf
  ssm_path=${!i}

  aws ssm get-parameter \
  --region us-east-1 \
  --name "${ssm_path}" \
  --output text --query 'Parameter.Value' \
  > $output_file
  echo "Include $output_file">> $HTTPD_PATH/conf/httpd.conf
done


# change perms to what cuwebauth wants
# chmod 600 $HTTPD_PATH/conf/cuwa.keytab
# if dont change owner, get error 5107 from CUWA
# chown www-data:root $HTTPD_PATH/conf/cuwa.keytab

# Call command
exec "$@"
