###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Makefile for the DNS package
#
# CREATED:	    01/16/2022
#
# LAST EDITED:	    12/25/2022
###

SERVICE_NAME = twardyece-dns
BUILD_TARGETS += $(B)/bind-volume.tar.gz
include ../declarations.mk

SERVICEDIR=$(DATADIR)/$(SERVICE_NAME)

$(B)/bind-volume.tar.gz: $(shell find bind)
	tar czvf $@ -C $< .

install: $(B)/bind-volume.tar.gz
	install -Dm644 $(SERVICE_NAME).service \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(SERVICE_NAME).service
	install -Dm644 $(B)/bind-volume.tar.gz \
		$(DESTDIR)$(SERVICEDIR)/bind-volume.tar.gz
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/docker-compose.yaml
	install -Dm644 volumetric.yaml \
		$(DESTDIR)$(VOLUMETRICDIR)/$(SERVICE_NAME).yaml

###############################################################################
