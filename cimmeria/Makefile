# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 10 Aug 2024

SERVICE_NAME=cimmeria
include ../declarations.mk

install:
	install -Dm644 cimmeria.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 cimmeria-db.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
