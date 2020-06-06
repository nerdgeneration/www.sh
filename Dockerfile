FROM alpine:latest

RUN apk add apache2 bash supervisor

COPY docker/httpd.conf /etc/apache2/httpd.conf
COPY docker/supervisord.conf /etc/supervisord.conf

COPY code /srv/code
COPY www /srv/www

RUN chown -R apache:apache /var/www /var/log/apache2 /run/apache2

EXPOSE 8080
CMD /usr/bin/supervisord -c /etc/supervisord.conf
