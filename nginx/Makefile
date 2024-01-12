# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=nginx
BUILD_TARGETS += make-nginx-conf-release
include ../declarations.mk

make-nginx-conf-release:
	(cd make-nginx-conf && cargo build --release)
	strip $@

install:
	: # Quadlet units
	install -Dm644 nginx.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 acme-challenge.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 blog.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 repository.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 siteconf.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 ssl-letsencrypt.volume -t $(DESTDIR)$(QUADLETDIR)
	: # Nginx configuration
	install -Dm644 ssl.conf -t $(DESTDIR)$(NGINXDIR)/common
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	install -Dm644 ethantwardy.conf -t $(DESTDIR)$(NGINXDIR)
	: # Nginx configuration build tool
	install -Dm755 make-nginx-conf/target/release/make-nginx-conf \
		-t $(DESTDIR)$(BINDIR)
	: # systemd target to ensure reverse-proxy.target is required for
	: # services-up.target.
	install -Dm644 reverse-proxy.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addRequires,services-up.target,reverse-proxy.target)
	: # Certificate renewal
	install -Dm744 webservices-certbot.bash \
		$(DESTDIR)$(BINDIR)/webservices-certbot
	install -Dm644 renew-certificates.service \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 renew-certificates.timer \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)

clean:
	rm -rf make-nginx-conf/target
