FROM nginx:alpine

LABEL maintainer="quoaum@gmail.com"

ENV INITSYSTEM=on

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
    nginx \
    unzip \
    wget \
    ca-certificates \
    supervisor \
    php7 \
    php7-bcmath \
    php7-dom \
    php7-ctype \
    php7-curl \
    php7-fpm \
    php7-gd \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqlnd \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-phar \
    php7-posix \
    php7-session \
    php7-soap \
    php7-xml \
    php7-zip \
    php7-tokenizer \
    php7-cli \
    php7-simplexml

RUN rm -rf \
    /var/cache/apk/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /usr/share/man

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf    

# Create a group and user
RUN adduser -D -g 'www' www

# create working directory
RUN mkdir -p /www
WORKDIR /www

# temporary
RUN mkdir -p /tmp

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R www:www /run && \    
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /var/tmp/nginx && \
    chown -R www:www /var/log/nginx && \
    chown -R www:www /var/lib/nginx/logs && \
    chown -R www:www /www  && \
    chown -R www:www /tmp

# Executable
COPY config/start.sh /usr/bin/start
RUN chown -R www:www /usr/bin/start
RUN chmod 777 /usr/bin/start

# Switch to use a non-root user from here on
USER www

EXPOSE 8080

VOLUME ["/www"]

ENTRYPOINT [ "/bin/sh" ]
CMD ["/usr/bin/start"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
