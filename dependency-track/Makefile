# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 21 Jun 2025

SERVICE_NAME=dependency-track
include ../declarations.mk

install:
	install -Dm644 dependency-track-api.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 dependency-track-frontend.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 dependency-track.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 nginx.conf $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
