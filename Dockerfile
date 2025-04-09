FROM nginx:alpine AS builder

ENV NGINX_VERSION 1.25.3

RUN apk add --no-cache --virtual .build-deps \
    git \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    libedit-dev \
    bash \
    alpine-sdk \
    findutils \
    automake \
    autoconf \
    libtool 

RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz

RUN mkdir -p /usr/src && \
    tar -zxC /usr/src -f nginx.tar.gz && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    ./configure --with-compat --with-http_image_filter_module --without-http_gzip_module && \
    make && make install

FROM nginx:alpine

COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sites-enabled /etc/nginx/sites-enabled
COPY data /data

RUN mkdir -p /etc/nginx/certificates
RUN chown -R nginx:nginx /etc/nginx && chown nginx:nginx /etc/nginx/nginx.conf \
    && chmod -R 700 /etc/nginx && chmod 700 /etc/nginx/nginx.conf && chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/run/

USER nginx

EXPOSE 80 443
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
