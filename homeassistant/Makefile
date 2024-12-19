# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 17 Oct 2024

SERVICE_NAME=homeassistant
include ../declarations.mk

install:
	install -Dm644 homeassistant.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 homeassistant-config.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
	: # Z-Wave JS service files
	install -Dm644 zwavejs.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 zwavejs-store.volume -t $(DESTDIR)$(QUADLETDIR)
