# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=openldap
include ../declarations.mk

install:
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
	install -Dm644 volumetric.yaml \
		$(DESTDIR)$(VOLUMETRICDIR)/$(SERVICE_NAME).yaml
	$(call templateRequiredBy,containers-up.target,container@twardyece_openldap.service)
