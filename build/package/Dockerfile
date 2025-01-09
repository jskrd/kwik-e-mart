FROM php:8.4-fpm-alpine AS base
RUN apk add --no-cache linux-headers postgresql-dev $PHPIZE_DEPS && \
    docker-php-ext-install pdo_pgsql && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    apk del $PHPIZE_DEPS
RUN apk add --no-cache nginx postgresql-dev supervisor
COPY build/package/nginx.conf /etc/nginx/http.d/default.conf
COPY build/package/supervisor.conf /etc/supervisord.conf

FROM composer:2 AS composer-packages
WORKDIR /app
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY . ./
RUN composer install --no-dev

FROM node:22-alpine AS static-assets
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY resources ./resources
COPY postcss.config.js tailwind.config.js vite.config.js ./
RUN npm run build

FROM base
WORKDIR /srv/www
COPY . ./
COPY --from=composer-packages /app/vendor ./vendor
COPY --from=static-assets /app/public/build ./public/build
RUN php artisan optimize
RUN chown -R www-data:www-data bootstrap/cache storage
EXPOSE 8000
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
