# Adding New Applications

#. Create a PostgreSQL database and user for this application. I usually also
store the password in Bitwarden with a name like
`ethantwardy.com/internal_postgresql/tandoor`.

```
[edtwardy@edtwardy ~]$ sudo podman exec -it internal_postgresql /bin/bash
root@23d1e74b62d3:/# psql -U postgres
psql (16.1 (Debian 16.1-1.pgdg120+1))
Type "help" for help.

postgres=# CREATE USER tandoor WITH PASSWORD '************';
CREATE ROLE
postgres=# CREATE DATABASE tandoor WITH OWNER=tandoor ENCODING='UTF-8';
CREATE DATABASE
postgres=# GRANT ALL PRIVILEGES ON DATABASE tandoor TO tandoor;
GRANT
```

#. Create application secrets:

```
[edtwardy@edtwardy Mount]$ printf '**********' | sudo podman secret create tandoor-postgresql-password -
```

#. Create btrfs subvolumes for persisting data:

```
[edtwardy@edtwardy ~]$ sudo mount /dev/sda4 /mnt/Mount/
[edtwardy@edtwardy ~]$ cd /mnt/Mount/
[edtwardy@edtwardy Mount]$ sudo btrfs subvolume create @tandoor_staticfiles
Create subvolume './@tandoor_staticfiles'
```

#. Create Quadlet volume unit files for the persistent volumes

```patch
diff --git a/tandoor/tandoor-staticfiles.volume b/tandoor/tandoor-staticfiles.volume
index e69de29..55b2e23 100644
--- a/tandoor/tandoor-staticfiles.volume
+++ b/tandoor/tandoor-staticfiles.volume
@@ -0,0 +1,5 @@
+[Volume]
+PodmanArgs=--driver=local
+Type=btrfs
+Options=subvol=@tandoor_staticfiles
+Device=/dev/disk/by-label/services
```

#. Create the Quadlet container unit file

```patch
diff --git a/tandoor/tandoor.container b/tandoor/tandoor.container
index e69de29..951012f 100644
--- a/tandoor/tandoor.container
+++ b/tandoor/tandoor.container
@@ -0,0 +1,39 @@
+[Container]
+ContainerName=public_tandoor
+Image=docker.io/vabene1111/recipes
+Network=public-services.network
+
+Volume=tandoor-staticfiles.volume:/opt/recipes/staticfiles
+Volume=tandoor-mediafiles.volume:/opt/recipes/mediafiles
+
+Secret=tandoor-postgresql-password,target=/run/secrets/postgresql-password
+Secret=tandoor-key,target=/run/secrets/tandoor-key
+
+# Secret key
+Environment=SECRET_KEY=/run/secrets/tandoor-key
+
+# Database configuration
+Environment=DB_ENGINE=django.db.backends.postgresql
+Environment=POSTGRES_HOST=internal_postgresql
+Environment=POSTGRES_PORT=5432
+Environment=POSTGRES_USER=tandoor
+Environment=POSTGRES_PASSWORD_FILE=/run/secrets/postgresql-password
+Environment=POSTGRES_DB=tandoor
+
+# LDAP Configuration
+Environment=LDAP_AUTH=1
+Environment=AUTH_LDAP_SERVER_URI=ldap://internal_ldap
+Environment=AUTH_LDAP_BIND_DN=
+Environment=AUTH_LDAP_BIND_PASSWORD=
+Environment=AUTH_LDAP_USER_SEARCH_BASE_DN=ou=people,dc=edtwardy,dc=hopto,dc=org
+
+[Service]
+Restart=always
+TimeoutStartSec=300
+
+[Unit]
+After=services-pre.target
+Requires=services-pre.target
+
+[Install]
+RequiredBy=reverse-proxy-pre.target
```

#. Create the Nginx configuration

```patch
diff --git a/tandoor/nginx.srv b/tandoor/nginx.srv
index e69de29..44c817b 100644
--- a/tandoor/nginx.srv
+++ b/tandoor/nginx.srv
@@ -0,0 +1,27 @@
+upstream tandoor {
+    keepalive 32;
+    server public_tandoor:8080;
+}
+
+server {
+    if ($host = recipes.ethantwardy.com) {
+        return 301 https://$host$request_uri;
+    }
+
+    server_name recipes.ethantwardy.com;
+    listen 80;
+    return 404;
+}
+
+server {
+    listen 443 ssl http2;
+    listen [::]:443 ssl http2;
+    server_name recipes.ethantwardy.com;
+
+    location / {
+        proxy_set_header Host $http_host;
+        proxy_set_header X-Forwarded-Proto $scheme;
+        proxy_pass http://tandoor;
+        proxy_redirect http://tandoor https://recipes.ethantwardy.com;
+      }
+}
```

#. Add the subdirectory to the top-level `Makefile`

```patch
diff --git a/Makefile b/Makefile
index 8eff1e8..abb4e7a 100644
--- a/Makefile
+++ b/Makefile
@@ -28,6 +28,7 @@ SUBDIRS += redirect
 SUBDIRS += blog
 SUBDIRS += docs
 SUBDIRS += postgresql
+SUBDIRS += tandoor
 
 # Mask these packages for now. The applications don't work for one reason or
 # another.
```

#. Add the package to `debian/control`

```patch
diff --git a/debian/control b/debian/control
index 265a16c..e4b972c 100644
--- a/debian/control
+++ b/debian/control
@@ -49,6 +49,11 @@ Architecture: all
 Depends: twardyece-common, golang-github-containernetworking-plugin-dnsname, squashfs-tools, squashfuse ${misc:Depends}
 Description: Nginx instance for reverse-proxy to other applications
 
+Package: twardyece-tandoor
+Architecture: all
+Depends: twardyece-common, twardyece-nginx, twardyece-postgresql ${misc:Depends}
+Description: An instance of tandoor
+
 Package: twardyece-jellyfin
 Architecture: all
 Depends: twardyece-common, twardyece-nginx, ${misc:Depends}
```

#. Create the install file for `dpkg`

```patch
diff --git a/debian/twardyece-tandoor.install b/debian/twardyece-tandoor.install
index e69de29..88d2137 100644
--- a/debian/twardyece-tandoor.install
+++ b/debian/twardyece-tandoor.install
@@ -0,0 +1,4 @@
+usr/share/containers/systemd/tandoor.container
+usr/share/containers/systemd/tandoor-staticfiles.volume
+usr/share/containers/systemd/tandoor-mediafiles.volume
+usr/share/twardyece/routes/tandoor.conf
```

#. Create the `Makefile` for the package

```patch
diff --git a/tandoor/Makefile b/tandoor/Makefile
index e69de29..68d068e 100644
--- a/tandoor/Makefile
+++ b/tandoor/Makefile
@@ -0,0 +1,11 @@
+# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
+# Created: 12/25/2022
+
+SERVICE_NAME=tandoor
+include ../declarations.mk
+
+install:
+	install -Dm644 tandoor.container -t $(DESTDIR)$(QUADLETDIR)
+	install -Dm644 tandoor-staticfiles.volume -t $(DESTDIR)$(QUADLETDIR)
+	install -Dm644 tandoor-mediafiles.volume -t $(DESTDIR)$(QUADLETDIR)
+	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
```

#. Install package and start service

```
[edtwardy@edtwardy ~]$ make && make package
[root@edtwardy ~]$ dpkg -i ../twardece-tandoor_1-1_all.deb
[root@edtwardy ~]$ systemctl daemon-reload
[root@edtwardy ~]$ systemctl start tandoor.service

# Needed if this service include Nginx configuration
[root@edtwardy ~]$ systemctl stop nginx.service
[root@edtwardy ~]$ podman volume rm systemd-siteconf
[root@edtwardy ~]$ systemctl restart siteconf-volume.service && sleep 1
[root@edtwardy ~]$ systemctl restart nginx.service
```
