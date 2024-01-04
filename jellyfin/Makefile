# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=jellyfin
include ../declarations.mk

install:
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	$(call addRequiresTemplate,services-up.target,container@twardyece_jellyfin.service)
