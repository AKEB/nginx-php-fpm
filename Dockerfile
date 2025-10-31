ARG PHP_VERSION="8.3"

FROM akeb/php-fpm-${PHP_VERSION}:latest AS final

ENV PHP_VERSION=${PHP_VERSION}

COPY nginx.conf default.conf geoip_update.sh logrotate-nginx GeoIP.dat GeoIPCity.dat GeoIPOrg.dat /tmp/

RUN apt-get update -y --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        nginx \
        libnginx-mod-http-geoip \
    && rm -rf /var/lib/apt/lists/* \
    # Создаем директории
    && mkdir -p /app /etc/cron.weekly /usr/share/GeoIP /var/log/nginx \
    && touch /var/log/nginx/error.log /var/log/nginx/access.log \
    && chmod -R 0777 /var/log/nginx/ \
    # Размещаем файлы из /tmp
    && mv /tmp/nginx.conf /etc/nginx/nginx.conf \
    && mv /tmp/default.conf /etc/nginx/conf.d/default.conf \
    && mv /tmp/geoip_update.sh /root/geoip_update.sh \
    && mv /tmp/GeoIP.dat /tmp/GeoIPCity.dat /tmp/GeoIPOrg.dat /usr/share/GeoIP/ \
    && mv /tmp/logrotate-nginx /etc/logrotate.d/nginx \
    # Устанавливаем права на исполнение
    && chmod +x /root/geoip_update.sh \
    # Очищаем временные файлы
    && rm -f /tmp/nginx.conf /tmp/default.conf /tmp/geoip_update.sh /tmp/logrotate-nginx /tmp/GeoIP.dat /tmp/GeoIPCity.dat /tmp/GeoIPOrg.dat

CMD ["/bin/bash", "-c", "cron;nginx -g 'daemon on;';/run_on_start.sh;php-fpm${PHP_VERSION} -F"]

EXPOSE 80
EXPOSE 443
