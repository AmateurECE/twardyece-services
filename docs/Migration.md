# Migrating to a New Machine

# Migrating to a New Hostname

#. The [MkDocs Repository](https://github.com/AmateurECE/MkDocsRepository)
   makes use of a GitHub webhook to trigger the Jenkins CI build.
#. The OpenLDAP database root DN should contain the server domain name. The
   value of the root DN is hardcoded into the Jenkins Global Security
   configuration, as well as the Django `apps` LDAP settings. It's reasonable
   to assume that any client of the OpenLDAP server will have the root DN
   hardcoded, so this will naturally need to be changed in multiple places.
#. A thorough `grep` of the repository should identify other places where the
   hostname needs to be changed.

# Expanding the Certificate

Certbot is not a particularly obvious tool to navigate. To expand a
certificiate with a new hostname, ensure that Nginx has been configured with a
virtual host that's set up to serve "acme-challenge" files placed in the
webroot by certbot. If I'm adding the domain ethantwardy.com, that looks
something like this:

```
diff --git a/nginx/ethantwardy.conf b/nginx/ethantwardy.conf
index e69de29..2ddef60 100644
--- a/nginx/ethantwardy.conf
+++ b/nginx/ethantwardy.conf
@@ -0,0 +1,10 @@
+server {
+    listen 80;
+    listen [::]:80;
+    server_name ethantwardy.com www.ethantwardy.com;
+
+    location ^~ /.well-known/acme-challenge/ {
+        root /var/www/certbot;
+        allow all;
+    }
+}
```

When this is up and running, we can tell certbot to expand our certificate by
instructing it to obtain a certificate without installing it (`certonly`) and
using the name of our existing certificate (`--cert-name twardyece.com`, the
name was taken from the output of `certbot certificates`). I have a handy
script to run certbot in a container that knows exactly which volumes to mount
and where, so that invocation looks like this:

```
sudo webservices-certbot cmd certonly \
    --cert-name twardyece.com \
    -d twardyece.com,www.twardyece.com,ethantwardy.com,www.ethantwardy.com \
    --webroot -w /var/www/certbot -n
```

The [certbot docs][1] from EFF may be useful here.

[1]: https://certbot.eff.org/instructions?ws=nginx&os=debiantesting
