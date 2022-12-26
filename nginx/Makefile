###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Makefile for the nginx application package.
#
# CREATED:	    12/25/2022
#
# LAST EDITED:	    12/25/2022
#
####

SERVICE_NAME=nginx
include ../declarations.mk

install:
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
	install -Dm644 volumetric.yaml \
		$(DESTDIR)$(VOLUMETRICDIR)/$(SERVICE_NAME).yaml
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	: # Certificate renewal cron
	install -Dm544 renew-certificates.bash \
		$(DESTDIR)/etc/cron.daily/renewcertificates
	: # Utility script for certbot debugging
	install -Dm755 webservices-certbot.sh \
		$(DESTDIR)$(BINDIR)/webservices-certbot
	: # CNI network configuration file for the webservices
	install -d $(DESTDIR)/etc/cni/net.d
	install -m644 edtwardy-webservices_front_net.conflist \
		$(DESTDIR)/etc/cni/net.d
	: # systemd service file
	install -Dm644 twardyece-services.service \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/twardyece-services.service

###############################################################################
