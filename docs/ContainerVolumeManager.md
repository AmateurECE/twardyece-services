# How Tags Work

Tags lock downstream repositories to named versions--this way, they can still
change (e.g. a database may include more instances of a model between two
revisions, but it's only important to prevent loading a database with a
different schema), but they can be roughly versioned to named revisions. In
volumes.dvm.lock, the downstream volume's options field specifies a tag:

    my-volume   downstream  tag:<any-text-here>

When the docker-volume-manager loads the lock file and discovers that the
volume is versioned to a tag, it:

1. Looks for a volume image in `VOLPATH`. If one cannot be found, it stops
   processing this volume and reports an error
2. When it finds one, it looks for a file named `tags` in the same
   directory as the volume image. This file contains entries of the form:

        <volumeName>   <tagName>

   The docker-volume-manager interprets `tagName` to be the current version
   of `volumeName`. If the tags file cannot be found, but the image is
   versioned to a tag, it stops processing and reports an error. If the tags
   file is found, but the tag does not match the one in volumes.dvm.lock, it
   stops processing and reports an error.

# Use Case: Populate a `downstream` Volume by a Container

1. Add the volume to the docker-compose.yml. In this case, we're adding the
   apps-* volumes. Specifying the volumes as external causes Docker to create
   them, but they aren't populated (since I don't have them listed in the
   Containerfile).
```
services:
  apps:
    image: "edtwardy/apps:latest"
    volumes:
      - "apps-database:/data/database"
      - "apps-media:/data/media"
      - "apps-static:/data/static:ro"
...
volumes:
  apps-database:
    external: true
  apps-media:
    external: true
  apps-static:
    external: true
```

2. Update the volumes.dvm.lock.in. We don't specify a tag right now because
   the volume images don't exist.
```
...
apps-database       downstream
apps-static         downstream
apps-media          downstream
```

When we run the Container Volume Manager binary, it will warn us that it can't
find volume images for these. But, it will succeed. Now, we need to populate
the volume:

```
host$ docker cp manage.py edtwardy-webservices_apps_1:/root/
host$ docker exec -it edtwardy-webservices_apps_1 /bin/sh
/ $ # Since I'm running in my uWSGI/Django container, I have to do some setup:
/ $ export $(tr '\0' '\n' </proc/$(pgrep uwsgi)/environ)
/ $ # Populate the container volumes
/ $ python3 manage.py
```

3. Back the volumes up to disk:
```
host$ edtwardy-webservices backup \
    --tag myTag-$(echo myTag-$(date +%Y%m%d%H%M%S) | sha256sum | head -c 8) \
    --location /var/my/location \
    apps-database,apps-static,apps-media
```
