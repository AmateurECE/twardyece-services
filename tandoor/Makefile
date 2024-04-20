# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=tandoor
include ../declarations.mk

install:
	install -Dm644 tandoor.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 tandoor-staticfiles.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 tandoor-mediafiles.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
