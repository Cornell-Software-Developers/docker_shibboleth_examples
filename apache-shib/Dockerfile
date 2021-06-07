FROM debian

# if running locally, this can fix timeouts.
# we need modern awscli installed in order to use aws ssm
RUN \
  apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="America/New_York" && apt-get install -y apache2 && \
  apt-get install -y libapache2-mod-shib2 python3-pip  &&\
  pip3 install awscli --upgrade && \
  apt-get clean && \
  a2enmod shib && a2enmod ssl

# configuration
COPY conf/* /etc/httpd/conf/
COPY conf.d/* /etc/httpd/conf.d/
COPY conf.sites.d/* /etc/httpd/conf.sites.d/
COPY conf.modules.d/* /etc/httpd/conf.modules.d/

# CUWebAuth Module
COPY modules/mod_cuwebauth.so /etc/httpd/modules/mod_cuwebauth.so


# entry point will be used to create out config file and load our keytab
COPY secrets-entrypoint.sh /secrets-entrypoint.sh

# Overwrite the entry-point script
ENTRYPOINT ["/secrets-entrypoint.sh"]

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
