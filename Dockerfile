FROM alpine:3.4
MAINTAINER Samuel Colvin <s@muelcolvin.com>

ENV NGINX_VERSION nginx-1.10.1
ENV GEOIP_VERSION 1.6.9
RUN build_packages="wget build-base ca-certificates linux-headers openssl-dev pcre-dev zlib-dev" \
 && runtime_packages="openssl pcre zlib" \
 && apk --update add ${build_packages} ${runtime_packages} \
 && apk add --update --no-cache wget build-base ca-certificates \
 && mkdir -p /tmp/src \
 && cd /tmp/src \
    # install GeoIP:
 && wget  https://github.com/maxmind/geoip-api-c/releases/download/v${GEOIP_VERSION}/GeoIP-${GEOIP_VERSION}.tar.gz \
 && tar -zxvf GeoIP-${GEOIP_VERSION}.tar.gz \
 && cd /tmp/src/GeoIP-${GEOIP_VERSION} \
 && ./configure \
 && make \
 && make check \
 && make install \
    # get GeoIP.dat database
 && cd /tmp/src \
 && wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz \
 && gunzip GeoIP.dat.gz \
 && mkdir /usr/local/share/GeoIP/ \
 && mv GeoIP.dat /usr/local/share/GeoIP/ \
 && echo 'adding /usr/local/share/GeoIP/GeoIP.dat database' \
    # install nginx:
 && wget http://nginx.org/download/${NGINX_VERSION}.tar.gz \
 && tar -zxvf ${NGINX_VERSION}.tar.gz \
 && cd /tmp/src/${NGINX_VERSION} \
 && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --pid-path=/run/nginx.pid \
        --lock-path=/run/nginx.lock \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --with-pcre-jit \
        --with-http_ssl_module \
        --with-stream_ssl_module \
        --with-http_stub_status_module \
        --with-http_gzip_static_module \
        --with-http_v2_module \
        --with-http_auth_request_module \
        --with-http_geoip_module \
 && make \
 && make install \
 && apk del ${build_packages} \
 && rm /usr/local/lib/libGeoIP.a \
 && rm -rf /tmp/src \
 && rm -rf /var/cache/apk/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-enabled/
ADD default.html /var/www/html/index.html

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
