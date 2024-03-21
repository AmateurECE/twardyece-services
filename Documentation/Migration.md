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

## With a Wildcard Domain Name

Wildcard domain names require special treatment. Unfortunately, they require
"manual" authentication, because the EFF apparently does not accept challenges
made using the webroot authenticator.

As of right now, certificates that are made using a manual authenticator cannot
be automatically renewed.

To obtain a certificate (using an existing certificate file as the starting
point) for a wildcard domain, the following command can be used. Certbot will
ask you to add some TXT records through your DNS provider to complete the
challenge.

```
sudo webservices-certbot cmd certonly \
    --cert-name twardyece.com \
    -d twardyece.com,*.twardyece.com,ethantwardy.com,*.ethantwardy.com \
    --server https://acme-v02.api.letsencrypt.org/directory \
    --manual \
    --preferred-challenges=dns \
    --email ethan.twardy@gmail.com
```

For my DNS provider, domain.com, there is no API that provides seamless
integration with Certbot. Linode, on the other hand, does. Certbot will ask you
to deploy a TXT record to your DNS provider with a given key.

To verify that the DNS record is live, use `dig`:

```bash-session
$ dig -t TXT _acme-challenge.ethantwardy.com
; <<>> DiG 9.19.19-1-Debian <<>> -t TXT _acme-challenge.ethantwardy.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54251
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;_acme-challenge.ethantwardy.com. IN	TXT

;; ANSWER SECTION:
_acme-challenge.ethantwardy.com. 1703 IN TXT	"pkX2Wc2HbTKv3PrQzhuFoC-yoKFqJSP2K7BrqNEnsAY"

;; Query time: 19 msec
;; SERVER: 10.2.0.1#53(10.2.0.1) (UDP)
;; WHEN: Sat Feb 10 08:29:06 CST 2024
;; MSG SIZE  rcvd: 116

```

[1]: https://certbot.eff.org/instructions?ws=nginx&os=debiantesting
