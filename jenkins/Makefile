###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Makefile for the jenkins application package.
#
# CREATED:	    12/25/2022
#
# LAST EDITED:	    12/25/2022
#
####

SERVICE_NAME=jenkins
include ../declarations.mk

install:
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
	install -Dm644 volumetric.yaml \
		$(DESTDIR)$(VOLUMETRICDIR)/$(SERVICE_NAME).yaml
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	install -Dm644 jenkins-builder.service \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/jenkins-builder.service

###############################################################################
