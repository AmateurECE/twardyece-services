###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Makefile for the DNS package
#
# CREATED:	    01/16/2022
#
# LAST EDITED:	    01/16/2022
###

bind.tar.gz: $(shell find bind)
	tar czvf $@ -C bind/ .

install: bind.tar.gz docker-compose.yml edtwardy-dns.service
	: # systemd service
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 edtwardy-dns.service $(DESTDIR)/lib/systemd/system

	: # Bind configuration volume image, docker-compose file
	install -d $(DESTDIR)/usr/share/edtwardy-dns
	install -m644 bind.tar.gz $(DESTDIR)/usr/share/edtwardy-dns
	install -m644 docker-compose.yml $(DESTDIR)/usr/share/edtwardy-dns

###############################################################################
