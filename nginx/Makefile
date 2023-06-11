###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Makefile for the nginx application package.
#
# CREATED:	    12/25/2022
#
# LAST EDITED:	    06/10/2023
#
####

SERVICE_NAME=nginx
BUILD_TARGETS += make-nginx-conf-release
include ../declarations.mk

make-nginx-conf-release:
	(cd make-nginx-conf && cargo build --release)
	strip $@

install:
	install -Dm644 docker-compose.yaml \
		$(DESTDIR)$(SERVICEDIR)/$(SERVICE_NAME).yaml
	install -Dm644 volumetric.yaml \
		$(DESTDIR)$(VOLUMETRICDIR)/$(SERVICE_NAME).yaml
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	install -Dm755 twardyece-services.bash \
		$(DESTDIR)$(BINDIR)/twardyece-services
	install -Dm755 make-nginx-conf/target/release/make-nginx-conf \
		-t $(DESTDIR)$(BINDIR)
	: # Certificate renewal
	install -Dm544 renew-certificates.bash \
		-t $(DESTDIR)/usr/bin
	install -Dm644 renew-certificates.service \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 renew-certificates.timer \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	: # CNI network configuration file for the webservices
	install -Dm644 edtwardy-webservices_front_net.conflist \
		-t $(DESTDIR)/etc/cni/net.d
	: # systemd service file
	install -Dm644 twardyece.com.service \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 twardyece.target \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)

###############################################################################
