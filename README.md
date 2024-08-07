## usage

The image supports setting your UID and GID (to an extent, system-IDs are protected) and timezone.

You can create as many webdav shares as you want, the script checks the environment variables for anything beginning with DAV_, if it's empty, creates a share without authorization, if it contains a string, that's used for htpasswd. $-symbols need to be escaped with another $.

For environment variables beginning with DAV_, the rest of the string is used to:

  * Create /dav/<sharename>
  * Create nginx-location /<sharename>, including authentication if chosen

By default, the container blocks localhost/ and returns a 204. This can be turned into a share by setting `DAV_root_enable`, as well as `DAV_root_name` if you want to name it anything other than `root` (only relevant for storage). If you want to enable authentication, use `DAV_root_auth`.

## docker-compose
```yaml
services:
  webdav:
    build: https://github.com/du5tball/docker-webdav.git#main
    ports:
      - 9000:80
    volumes:
      - webdav:/dav
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
      - DAV_public=""
      - DAV_private=user:$$apr1$$QP3iuIwL$$jVUes5S3Mf4NHDnOW28Lr1      # user / password
      - DAV_root_enable=""
      - DAV_root_name=steve
      - DAV_root_auth=admin:$$apr1$$5KAARrpl$$TlHIXRceiZjH0LoKD9616.   # admin / pass
volumes:
    webdav: {}
```
