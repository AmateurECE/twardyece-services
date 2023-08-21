# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 05/03/2022

SERVICE_NAME=common
include ../declarations.mk

install:
	install -Dm755 start-container.bash $(DESTDIR)/usr/bin/start-container
	install -Dm644 pre-containers.target -t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 containers-up.target -t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 containers-down.target -t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 services-up.target -t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 container@.service -t $(DESTDIR)/$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addWants,multi-user.target,containers-up.target)
	: # CNI network configuration file for the webservices
	install -Dm644 twardyece_front_net.conflist -t $(DESTDIR)/etc/cni/net.d
