# Nginx + shibboleth

This repo is a light weight nginx container with some batteries included.  The goal is to run nginx with shibboleth plugins so that you can connect to a fastcgi-shibd container.

If you want an All In One, this container is used for the heavier nginx-shib-aio container.  It's your preference which you use.


# Environment
12 factor point 3: https://12factor.net/config

This image builds on https://hub.docker.com/_/nginx and maintains the same options it does.  This image includes the AWS CLI to pull configuration from SSM Param Store.  Which parameters get pulled is controlled by these variables:
## TODO.  Environment has been reworked.  Documentation below may be out of data.  2021-04-26 - wm284

 - SSM_NGINX_CONF: ssm path written as /etc/nginx/nginx.conf
 - SSM_ADDITIONAL_CONF_site_conf: ssm path written as /etc/nginx/conf.d/site.conf
   - `SSM_ADDITIONAL_CONF_` prefix is removed from the variable name and the rest is used for the output file name.
   - underscore `_` is replaced with `.`. `site_conf` becomes `site.conf`
 - SSM_SSL_CERTS_keyfile_key: like SSM_ADDITIONAL_CONF_ but writes to /etc/nginx/certs/keyfile.key
 - SSM_SSL_CERTS_keyfile_crt: like SSM_ADDITIONAL_CONF_ but writes to /etc/nginx/certs/keyfile.crt
 - GENERATE_SELFSIGNED_SSL
   - create self signed SSL certs on start; written to:
   - /etc/nginx/certs/keyfile.key
   - /etc/nginx/certs/keyfile.crt
 - SELFSIGNED_SSL_DOMAIN: If generating selfsigned ssl certs, use this domain name.

If none of these are set, nothing will be done and the container will work normally.  While these environmental variables will let you pull in config files, they will not change them.  If you use GENERATE_SELFSIGNED_SSL, you will need to ensure those certificates are loaded in your configuration.

# Paths

Paths should be the same as the standard nginx config.  For local development, you may want to use these container paths:
 - /etc/nginx/nginx.conf - main nginx conf, usually sets up server but not site.
 - /etc/nginx/conf.d/ - folder containing site specific configuration; usually loaded by nginx.conf
   - similar to /etc/httpd/conf.sites.d/ or /etc/apache2/sites-enabled/
 - /etc/nginx/certs/ - path used by default when creating ssl certs. If using your own, you may want to load them here.
   - if generating self signed certs with the environmental variable, mounting this path in your local file system will persist them between runs.  However, the files will be owned as root and you will need to fix any permission issues caused by that.
