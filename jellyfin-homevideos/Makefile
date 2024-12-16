# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=jellyfin-homevideos
include ../declarations.mk

install:
	install -Dm644 jellyfin-homevideos.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 jellyfin-homevideos-config.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
