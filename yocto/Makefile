# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 10/25/2021

SERVICE_NAME = yocto
include ../declarations.mk

install:
	install -d $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-tftp.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-yocto-deploy.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 mnt-Serve-yocto-sstate\\x2dcache.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	: # TODO: Need podman v4.8.1 for drop-in support, but debian/testing only
	: # has v4.7.2. This service isn't used very often, so I'm going to leave it
	: # as-is, and it should start working again when I get the latest version.
	install -Dm644 tftp.conf $(DESTDIR)$(QUADLETDIR)/tftp.container.d/yocto.conf
