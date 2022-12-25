###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Makefile for the postgres application package.
#
# CREATED:	    12/25/2022
#
# LAST EDITED:	    12/25/2022
#
####

SERVICE_NAME=postgres

PREFIX=/usr
DATADIR=$(PREFIX)/share
VOLUMETRICDIR=$(DATADIR)/volumetric/volumetric.d

ROOTDIR=$(DATADIR)/twardyece
SERVICEDIR=$(ROOTDIR)/services

include ../declarations.mk

build:

install:
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
	install -Dm644 volumetric.yaml \
		$(DESTDIR)$(VOLUMETRICDIR)/$(SERVICE_NAME).yaml

###############################################################################
