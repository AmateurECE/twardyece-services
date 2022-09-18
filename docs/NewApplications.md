# Adding New Applications

## Integrating Volumes with Volumetric

The following steps allow the user to add a new service to the deployment. The
commit #6734c607 is a relatively pure commit that shows how this is done for a
simple service.

1. Create a new volume in the service's Volumetric configuration:

```
diff --git a/edtwardy-webservices/edtwardy-webservices.yaml b/edtwardy-webservices/edtwardy-webservices.yaml
index abbc893..0b4a721 100644
--- a/edtwardy-webservices/edtwardy-webservices.yaml
+++ b/edtwardy-webservices/edtwardy-webservices.yaml
@@ -42,3 +42,9 @@ volumes:
       name: compilations-secret
       url: /mnt/Library/DockerVolumes/compilations-secret-volume.tar.gz
       md5: 87c31943a122d39b642f80d12c48edd6
+
+  postgres-data:
+    archive:
+      name: postgres-data
+      url: /mnt/Library/DockerVolumes/postgres-data-volume.tar.gz
+      md5: null
```

2. Create the volume with Podman:

```
#  podman volume create postgres-data
```

3. Add the volume and container to the docker-compose service definition:

```
diff --git a/edtwardy-webservices/docker-compose.yml b/edtwardy-webservices/docker-compose.yml
index 09aa137..d2894ae 100644
--- a/edtwardy-webservices/docker-compose.yml
+++ b/edtwardy-webservices/docker-compose.yml
@@ -67,12 +67,24 @@ services:
     environment:
       - TZ=America/Chicago
 
+  postgres:
+    image: docker.io/library/postgres:14.2
+    restart: always
+    environment:
+      POSTGRES_PASSWORD: example
+    ports:
+      - "127.0.0.1:5432:5432"
+    volumes:
+      - "postgres:/var/lib/postgresql/data"
+
 networks:
   default:
     external:
       name: edtwardy-webservices_front_net
 
 volumes:
+  postgres-data:
+    external: true
   siteconf:
     external: true
   letsencrypt:
```

4. Populate the volume with data:

```
# podman info postgres-data
# echo 'secret' > /var/lib/containers/storage/postgres-data/_data/secret.json
```

5. Add the service to the Nginx configuration (if necessary)

```
diff --git a/edtwardy-webservices/siteconf/default.conf b/edtwardy-webservices/siteconf/default.conf
index 77ed723..fbdc926 100755
--- a/edtwardy-webservices/siteconf/default.conf
+++ b/edtwardy-webservices/siteconf/default.conf
@@ -13,6 +13,11 @@ upstream compilations {
     server edtwardy-webservices_compilations_1:3000;
 }
 
+upstream budget {
+    keepalive 32;
+    server edtwardy-webservices_budget-tool_1:3000;
+}
+
 server {
     port_in_redirect on;
     listen 443 ssl;
@@ -159,4 +164,15 @@ server {
         root /data/yocto;
         autoindex on;
     }
+
+    location /budget/ {
+        proxy_pass http://budget;
+        proxy_pass_request_headers on;
+        proxy_set_header Host $host;
+
+        proxy_set_header X-Real-IP $remote_addr;
+        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
+        proxy_set_header X-Forwarded-Proto $scheme;
+        proxy_set_header X-Forwarded-Host $http_host;
+    }
 }
```

6. Update the package:

```
make package && sudo make reinstall
```
7. Create the volume backup

```
# mount -o remount,rw /mnt/Library
# DOCKER_HOST=unix:///var/run/podman/podman.sock volumetric-commit postgres-data
# mount -o remount,ro /mnt/Library
```

8. Update the hash in `edtwardy-webservices.yaml` from the output of
volumetric-commit:

```
[edtwardy@edtwardy build]$ sudo DOCKER_HOST=unix:///var/run/podman/podman.sock ./volumetric-commit/volumetric-commit postgres-data
postgres-data: Renaming /mnt/Library/DockerVolumes/postgres-data-volume.tar.gz to /mnt/Library/DockerVolumes/postgres-data-volume-20220918-173051.tar.gz
Volume file /mnt/Library/DockerVolumes/postgres-data-volume.tar.gz doesn't appear to exist. Assuming this is an initial commit.
Pausing any containers that have this volume mounted...
Archiving entry 1320 of 1320
md5: 755604b0a05c2625095c1384258aa9b0
Unpausing containers
```
