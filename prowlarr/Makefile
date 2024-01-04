# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 09/25/2023

SERVICE_NAME=prowlarr
include ../declarations.mk

install:
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	$(call addRequiresTemplate,services-up.target,container@twardyece_prowlarr.service)
