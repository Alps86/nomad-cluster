FROM composer as vendor
WORKDIR /code

COPY ./composer.json .
COPY ./composer.lock .

RUN composer install

FROM busybox
WORKDIR /tmp

COPY --from=vendor /code /tmp/code

CMD cp -R /tmp/code /
