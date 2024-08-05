FROM alpine

RUN apk add nginx nginx-mod-http-dav-ext shadow tzdata
RUN mkdir /etc/nginx/htpasswd

COPY ./dav.sh /dav.sh

VOLUME /dav
EXPOSE 80

CMD /dav.sh && nginx -g "daemon off;"
