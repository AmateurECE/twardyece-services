# Adding New Applications

## Integrating Volumes with Volumetric

The following steps allow the user to add a new service to the deployment. The
commit #6734c607 is a relatively pure commit that shows how this is done for a
simple service.

1. Create a new application directory with service files:

```bash-session
git touch prowlarr/Makefile
git touch prowlarr/docker-compose.yaml
git touch prowlarr/nginx.yaml
git touch prowlarr/volumetric.yaml
```

2. Add the new directory to the top-level Makefile:

```
diff --git a/Makefile b/Makefile
index 98bf6eb..1475546 100644
--- a/Makefile
+++ b/Makefile
@@ -16,6 +16,7 @@ $(shell mkdir -p $(B))
 SUBDIRS += common
 SUBDIRS += nginx
 SUBDIRS += jellyfin
+SUBDIRS += prowlarr
 SUBDIRS += tftp
 SUBDIRS += yocto
 SUBDIRS += vps
```

3. Create the service Makefile:

```
diff --git a/prowlarr/Makefile b/prowlarr/Makefile
new file mode 100644
index 0000000..bd2a19c
--- /dev/null
+++ b/prowlarr/Makefile
@@ -0,0 +1,13 @@
+# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
+# Created: 12/25/2022
+
+SERVICE_NAME=prowlarr
+include ../declarations.mk
+
+install:
+	install -Dm644 docker-compose.yaml \
+		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
+	install -Dm644 volumetric.yaml \
+		$(DESTDIR)$(VOLUMETRICDIR)/$(SERVICE_NAME).yaml
+	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
+	$(call addRequiresTemplate,services-up.target,container@twardyece_prowlarr.service)
```

4. Create the docker-compose file:

```
diff --git a/prowlarr/docker-compose.yaml b/prowlarr/docker-compose.yaml
new file mode 100644
index 0000000..4dc0dc3
--- /dev/null
+++ b/prowlarr/docker-compose.yaml
@@ -0,0 +1,20 @@
+---
+version: "2.1"
+services:
+  prowlarr:
+    image: lscr.io/linuxserver/prowlarr:latest
+    environment:
+      - TZ=America/Chicago
+    volumes:
+      - prowlarr:/config
+    restart: unless-stopped
+
+# Must connect to the container network to communicate with slapd
+networks:
+  default:
+    external:
+      name: twardyece_front_net
+
+volumes:
+  prowlarr:
+    external: true
```

5. Create the Nginx service configuration file:

```
diff --git a/prowlarr/nginx.yaml b/prowlarr/nginx.yaml
new file mode 100644
index 0000000..fc8185a
--- /dev/null
+++ b/prowlarr/nginx.yaml
@@ -0,0 +1,35 @@
+---
+version: 1.0
+configuration:
+  - !top |
+    upstream prowlarr {
+        keepalive 32;
+        server twardyece_prowlarr_1:9696;
+    }
+
+  - !server
+    name: twardyece
+    configuration:
+      - !location |
+        location /prowlarr {
+            return 302 $scheme://$host/prowlarr/;
+        }
+
+      - !location |
+        location /prowlarr/ {
+            proxy_pass http://prowlarr;
+            proxy_pass_request_headers on;
+            proxy_set_header Host $host;
+
+            proxy_set_header X-Real-IP $remote_addr;
+            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
+            proxy_set_header X-Forwarded-Proto $scheme;
+            proxy_set_header X-Forwarded-Host $http_host;
+
+            proxy_set_header Upgrade $http_upgrade;
+            proxy_set_header Connection $http_connection;
+
+            # Disable buffering when the nginx proxy gets very busy during
+            # streaming
+            proxy_buffering off;
+        }
```

6. Create the volumetric configuration file:

```
diff --git a/prowlarr/volumetric.yaml b/prowlarr/volumetric.yaml
new file mode 100644
index 0000000..1f2cff2
--- /dev/null
+++ b/prowlarr/volumetric.yaml
@@ -0,0 +1,8 @@
+version: 1.0
+volumes:
+
+  prowlarr:
+    archive:
+      name: prowlarr
+      url: /mnt/Library/DockerVolumes/prowlarr-volume.tar.gz
+      md5: null
```

7. Add the package to `debian/control`:

```
diff --git a/debian/control b/debian/control
index aeccc43..6e4af77 100644
--- a/debian/control
+++ b/debian/control
@@ -39,6 +39,11 @@ Architecture: all
 Depends: twardyece-common, ${misc:Depends}
 Description: An instance of jellyfin
 
+Package: twardyece-prowlarr
+Architecture: all
+Depends: twardyece-common, twardyece-vpn, ${misc:Depends}
+Description: An instance of Prowlarr
+
 # Package: twardyece-dns
 # Architecture: all
 # Depends: twardyece-common, twardyece-nginx, ${misc:Depends}
```

8. Add a debian install file:

```
diff --git a/debian/twardyece-prowlarr.install b/debian/twardyece-prowlarr.install
new file mode 100644
index 0000000..089ee24
--- /dev/null
+++ b/debian/twardyece-prowlarr.install
@@ -0,0 +1,4 @@
+etc/volumetric/volumes.d/prowlarr.yaml
+usr/lib/systemd/system/services-up.target.requires/container@twardyece_prowlarr.service
+usr/share/twardyece/prowlarr.yaml
+usr/share/twardyece/routes/prowlarr.yaml
```

9. Create the volume with Podman:

```
$ sudo podman volume create prowlarr
```

10. Populate the volume with data (if necessary):

```
$ sudo podman info prowlarr
$ echo 'secret' | sudo tee /var/lib/containers/storage/prowlarr/_data/secret.json
```

11. Make and install, restart the services:

```
$ make clean && make && make package && sudo make reinstall PACKAGE=prowlarr
$ sudo systemctl start containers-down.target
$ sudo systemctl restart volumetric.service
$ sudo systemctl start containers-up.target
```

12. Create the volume backup

```
$ sudo mount -o remount,rw /mnt/Library
$ sudo DOCKER_HOST=unix:///var/run/podman/podman.sock volumetric-commit prowlarr
$ sudo mount -o remount,ro /mnt/Library
```

13. Update the hash in the volumetric configuration file from the output of
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
