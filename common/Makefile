# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 05/03/2022

SERVICE_NAME=common
include ../declarations.mk

install:
	: # Job control targets
	install -Dm644 services-pre.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 services-up.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 services-down.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 reverse-proxy-pre.target \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	: # Start services-up.target on boot
	$(call addWants,multi-user.target,services-up.target)
	: # Create a container network for all services.
	install -Dm644 public-services.network -t $(DESTDIR)$(QUADLETDIR)
