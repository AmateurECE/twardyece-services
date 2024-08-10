# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 30 Jun 2024

SERVICE_NAME=miniflux
include ../declarations.mk

install:
	install -Dm644 miniflux.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
