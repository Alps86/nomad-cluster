FROM nginx

COPY ./symfony.conf /etc/nginx/conf.d/mysite.template

CMD /bin/bash -c "envsubst '\$FPM_UPSTREAM'< /etc/nginx/conf.d/mysite.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"