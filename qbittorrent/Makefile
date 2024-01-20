# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 09/25/2023

SERVICE_NAME=qbittorrent
include ../declarations.mk

install:
	install -Dm644 qbittorrent-config.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 qbittorrent.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
