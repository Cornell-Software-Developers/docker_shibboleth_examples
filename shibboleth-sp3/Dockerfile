FROM ubuntu:latest

RUN \
  apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="America/New_York" && apt-get install -y tzdata && \
  apt-get install -y shibboleth-sp-utils python3-pip odbc-mariadb &&\
  pip3 install supervisor awscli --upgrade  \
  && apt-get clean

  # If you want mysql instead of maria, you're on your own.  MySql is now oracle-lite.


#shib
# Be explicit because shibboleth
COPY files/shibboleth-defaults/* /etc/shibboleth/
COPY files/attribute-map.xml /etc/shibboleth/
COPY files/shibd.logger /etc/shibboleth/


COPY supervisord.conf /etc/supervisor/supervisord.conf

COPY secrets-entrypoint.sh /usr/bin/
ENTRYPOINT ["/usr/bin/secrets-entrypoint.sh"]
CMD ["supervisord"]
EXPOSE 80 443
