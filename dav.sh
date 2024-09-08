#!/bin/sh

PUID=${PUID:-"100"}
PGID=${PGID:-"100"}
usermod -u "$PUID" nginx
groupmod -g "$PGID" nginx
echo "load_module /usr/lib64/nginx/modules/ngx_http_dav_ext_module.so;" | cat - /etc/nginx/nginx.conf >> /tmp/nginx.conf; mv /tmp/nginx.conf /etc/nginx/nginx.conf

DAV=$(printenv | grep ^DAV | grep -v ^DAV_root | sort)
CONFFILE=/etc/nginx/conf.d/default.conf
truncate -s 0 $CONFFILE
DAV_root_name=${DAV_root_name:-root}

template_location="  location /NAME {
    dav_methods PUT DELETE MKCOL COPY MOVE;
    dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK;
    dav_ext_lock zone=default;
    client_max_body_size 0;
    client_body_temp_path /tmp/;"

template_auth="    dav_access user:rw group:r;
    auth_basic \"WebDAV NAME\";
    auth_basic_user_file /etc/nginx/htpasswd/NAME;"

echo "dav_ext_lock_zone zone=default:10m;
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  http2 on;
  root /dav;
  index index.html index.htm;
  server_name _;
  access_log /dev/stdout;
  error_log stderr;
  create_full_put_path on;
" >>$CONFFILE

if [ -n "$DAV_root_enable" ]; then
  echo "$template_location" | sed "s/NAME/$DAV_root_name/" >>$CONFFILE
  if [ -n "$DAV_root_auth" ]; then
    echo "$each" | sed 's/^.*=//' >/etc/nginx/htpasswd/"${mount}"
    echo "$template_auth" | sed "s/NAME/$DAV_root_name/" >>$CONFFILE
  else
    echo "    dav_access all:rw;" >>$CONFFILE
  fi
else
  printf "  location / {\n    return 204;\n" >>$CONFFILE
fi
printf "  }\n\n" >>$CONFFILE

for each in $DAV; do
  mount=$(echo "$each" | tr -d DAV_ | cut -f1 -d"=")
  htline=$(echo "$each" | sed 's/^.*=//')
  echo "$template_location" | sed "s/NAME/$mount/" >>$CONFFILE
  if echo "$htline" | grep -q "apr1"; then
    echo "$htline" >/etc/nginx/htpasswd/"${mount}"
    echo "$template_auth" | sed "s/NAME/$mount/" >>$CONFFILE
  else
    echo "    index on;" >> $CONFFILE
    echo "    dav_access all:rw;" >>$CONFFILE
  fi
  printf "  }\n\n" >>$CONFFILE
done
echo "}" >>$CONFFILE

nginx -T

