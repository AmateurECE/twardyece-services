###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Makefile for the DNS package
#
# CREATED:	    01/16/2022
#
# LAST EDITED:	    06/26/2022
###

BUILD_TARGETS += $(B)/bind-volume.tar.gz
include ../declarations.mk

$(B)/bind-volume.tar.gz: $(shell find bind)
	tar czvf $@ -C $< .

dependencies = \
	edtwardy-dns.service \
	docker-compose.yml \
	edtwardy-dns.yaml

install: $(B)/bind-volume.tar.gz $(dependencies)
	: # systemd service
	install -d $(DESTDIR)/lib/systemd/system
	: # install -m644 edtwardy-dns.service $(DESTDIR)/lib/systemd/system
	cd $(DESTDIR)/lib/systemd/system \
		&& ln -s /dev/null edtwardy-dns.service

	: # Bind configuration volume image, docker-compose file
	install -d $(DESTDIR)/usr/share/edtwardy-dns
	install -m644 $(B)/bind-volume.tar.gz $(DESTDIR)/usr/share/edtwardy-dns
	install -m644 docker-compose.yml $(DESTDIR)/usr/share/edtwardy-dns

	: # Volumetric project file
	install -d $(DESTDIR)/etc/volumetric/volumes.d
	install -m644 edtwardy-dns.yaml $(DESTDIR)/etc/volumetric/volumes.d

###############################################################################
