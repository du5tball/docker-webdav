FROM alpine

RUN apk add nginx nginx-mod-http-dav-ext shadow tzdata curl
RUN mkdir /etc/nginx/htpasswd

COPY ./dav.sh /dav.sh

VOLUME /dav
EXPOSE 80

HEALTHCHECK CMD [ "curl", "-fs", "http://localhost" ]

CMD /dav.sh && nginx -g "daemon off;"
