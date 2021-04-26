# Shibboleth + shibboleth

This repo is a light weight shibboleth/shibd container with some batteries included.  The goal is to run shibd in a container using fastcgi connectors so that you can connect shibboleth.

Further work might allow shibd to be exposed directly for use with apache


# Environment
12 factor point 3: https://12factor.net/config

This image includes the AWS CLI to pull configuration from SSM Param Store.  Which parameters get pulled is controlled by these variables:

 - SSM_SHIBBOLETH2_CONF: ssm path written as /etc/shibboleth/shibboleth2.xml
 - SSM_ADDITIONAL_CONF_site_conf: ssm path written as /etc/shibboleth/conf.d/site.conf
   - `SSM_ADDITIONAL_CONF_` prefix is removed from the variable name and the rest is used for the output file name.
   - underscore `_` is replaced with `.`. `site_conf` becomes `site.conf`
     ## TODO
 - SSM_SSL_CERTS_keyfile_key: like SSM_ADDITIONAL_CONF_ but writes to /etc/shibboleth/certs/keyfile.key
 - SSM_SSL_CERTS_keyfile_crt: like SSM_ADDITIONAL_CONF_ but writes to /etc/shibboleth/certs/keyfile.crt
 - GENERATE_SELFSIGNED_SSL
   - create self signed SSL certs on start; written to:
   - /etc/shibboleth/certs/keyfile.key
   - /etc/shibboleth/certs/keyfile.crt
 - SELFSIGNED_SSL_DOMAIN: If generating selfsigned ssl certs, use this domain name.

If none of these are set, nothing will be done and the container will work normally.  While these environmental variables will let you pull in config files, they will not change them.  If you use GENERATE_SELFSIGNED_SSL, you will need to ensure those certificates are loaded in your configuration.

# Paths

Paths should be the same as the standard shibboleth config.  For local development, you may want to use these container paths:
 - /etc/shibboleth/shibboleth.conf - main shibboleth conf, usually sets up server but not site.
 - /etc/shibboleth/conf.d/ - folder containing site specific configuration; usually loaded by shibboleth.conf
   - similar to /etc/httpd/conf.sites.d/ or /etc/apache2/sites-enabled/
 - /etc/shibboleth/certs/ - path used by default when creating ssl certs. If using your own, you may want to load them here.
   - if generating self signed certs with the environmental variable, mounting this path in your local file system will persist them between runs.  However, the files will be owned as root and you will need to fix any permission issues caused by that.
