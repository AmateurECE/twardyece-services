# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=nginx
include ../declarations.mk

install:
	: # Quadlet units
	install -Dm644 nginx.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 sitedata.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 siteconf.volume -t $(DESTDIR)$(QUADLETDIR)
	: # Nginx configuration
	install -Dm644 ethantwardy.conf -t $(DESTDIR)$(NGINXDIR)
	: # systemd target to ensure reverse-proxy.target is required for
	: # services-up.target.
	install -Dm644 reverse-proxy.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addRequires,services-up.target,reverse-proxy.target)
