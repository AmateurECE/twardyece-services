# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=nginx
BUILD_TARGETS += make-nginx-conf-release
include ../declarations.mk

make-nginx-conf-release:
	(cd make-nginx-conf && cargo build --release)
	strip $@

install:
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
	install -Dm644 volumetric.yaml \
		$(DESTDIR)$(VOLUMETRICDIR)/$(SERVICE_NAME).yaml
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	install -Dm755 make-nginx-conf/target/release/make-nginx-conf \
		-t $(DESTDIR)$(BINDIR)
	install -Dm644 reverse-proxy.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addRequiresTemplate,containers-up.target,container@twardyece_nginx.service)
	$(call addRequires,containers-up.target,reverse-proxy.target)
	: # Certificate renewal
	install -Dm744 renew-certificates.bash \
		$(DESTDIR)$(BINDIR)/renew-certificates
	install -Dm644 renew-certificates.service \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 renew-certificates.timer \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)

clean:
	rm -rf make-nginx-conf/target
