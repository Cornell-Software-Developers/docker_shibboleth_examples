FROM nginx AS builder
MAINTAINER tad merchant <wm284@cornell.edu>


RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        ca-certificates git wget
        # Builder.  No reason to clean up.
# There's an occasional fail related to xslscript.pl that should be handled elsewhere.
ENV XSLS true
RUN mkdir -p /build/shib-output && cd /build && wget https://hg.nginx.org/pkg-oss/raw-file/default/build_module.sh && \
      chmod a+x build_module.sh && \
      ./build_module.sh -y -o /build/shib-output https://github.com/nginx-shib/nginx-http-shibboleth.git

RUN mkdir -p /build/more-output && cd /build && wget https://hg.nginx.org/pkg-oss/raw-file/default/build_module.sh && \
      chmod a+x build_module.sh && \
      ./build_module.sh -y -o /build/more-output https://github.com/openresty/headers-more-nginx-module.git && ls

FROM nginx
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    python3-pip && \
    pip3 install awscli --upgrade  \
    && apt-get clean


COPY --from=builder /build/shib-output/nginx-module-shibboleth_${NGINX_VERSION}-1~buster_amd64.deb /build/output/nginx-shibboleth.deb
COPY --from=builder /build/more-output/nginx-module-headersmore_${NGINX_VERSION}-1~buster_amd64.deb /build/output/nginx-headersmore.deb
RUN dpkg -i /build/output/nginx-shibboleth.deb /build/output/nginx-headersmore.deb

COPY etc/nginx/nginx.conf /etc/nginx/
COPY etc/nginx/shib_* /etc/nginx/


# Nginx container has provisions for init scripts when put in this directory and set as executable
COPY secrets-entrypoint.sh /docker-entrypoint.d/
COPY genSelfSignedCerts.sh /usr/bin/


EXPOSE 80 443



