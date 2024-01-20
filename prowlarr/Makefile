# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 09/25/2023

SERVICE_NAME=prowlarr
include ../declarations.mk

install:
	install -Dm644 prowlarr.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 prowlarr-config.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
