# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 05/03/2022

SERVICE_NAME=common
include ../declarations.mk

install:
	install -Dm644 pre-containers.target -t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 containers-up.target -t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 containers-down.target -t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 reverse-proxy-pre.target \
		-t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addWants,multi-user.target,containers-up.target)
	install -Dm644 public-services.network -t $(DESTDIR)$(QUADLETDIR)
