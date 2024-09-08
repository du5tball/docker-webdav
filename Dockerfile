FROM opensuse/leap:15

RUN source /etc/os-release \
  && zypper ar https://download.opensuse.org/repositories/server:/http/${VERSION}/server:http.repo \
  && zypper --gpg-auto-import-keys ref \
  && zypper -n in nginx-module-dav-ext \
  && zypper cc \
  && mkdir /etc/nginx/htpasswd
COPY ./dav.sh /dav.sh

VOLUME /dav
EXPOSE 80

HEALTHCHECK CMD [ "curl", "-so", "nul", "http://localhost" ]

CMD /dav.sh && nginx -g "daemon off;"
