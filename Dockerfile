ARG PHP_VERSION="8.3"

FROM akeb/php-fpm-${PHP_VERSION}:v1.0.0

ENV PHP_VERSION=${PHP_VERSION}

RUN mkdir -p /app \
  && mkdir -p /etc/cron.weekly \
  && mkdir -p /usr/share/GeoIP

RUN apt-get update -y --allow-insecure-repositories \
    && apt-get install -y --allow-unauthenticated \
    nginx \
    libnginx-mod-http-geoip \
    && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY geoip_update.sh /etc/cron.weekly/geoip_update
COPY geoip_update.sh /root/geoip_update.sh

RUN mkdir -p /var/log/nginx/ && touch /var/log/nginx/error.log && touch /var/log/nginx/access.log
RUN mkdir -p /var/log/php/

RUN chmod +x /root/geoip_update.sh \
  && chmod +x /etc/cron.weekly/geoip_update \
  && /root/geoip_update.sh

CMD ["/bin/bash", "-c", "nginx -g 'daemon on;';/run_on_start.sh;php-fpm${PHP_VERSION} -F"]

EXPOSE 80
EXPOSE 443
