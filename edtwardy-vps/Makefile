###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Makefile for the edtwardy-vps package
#
# CREATED:	    08/25/2021
#
# LAST EDITED:	    01/23/2022
###

PACKAGE_NAME=edtwardy-vps

BUILD_TARGETS += $(B)/firewall.nft
BUILD_TARGETS += $(B)/hosts
BUILD_TARGETS += $(B)/wireguard-client.conf
BUILD_TARGETS += $(B)/wireguard-server.conf
include ../declarations.mk

$(B)/firewall.nft: firewall.template.nft vps-keys.conf
	renderbars -f vps-keys.conf $< $@

$(B)/hosts: hosts.template.yml vps-keys.conf
	renderbars -f vps-keys.conf $< $@

$(B)/wireguard-client.conf: wireguard-client.template.conf vps-keys.conf
	renderbars -f vps-keys.conf \
		-c client_private_key="\{{client_private_key}}" \
		-c server_public_key="\{{server_public_key}}" \
		$< $@

$(B)/wireguard-server.conf: wireguard-server.template.conf vps-keys.conf
	renderbars -f vps-keys.conf \
		-c server_private_key="\{{server_private_key}}" \
		-c client_public_key="\{{client_public_key}}" \
		$< $@

install: shareDir=$(DESTDIR)/usr/share/$(PACKAGE_NAME)
install: binDir=$(DESTDIR)/bin
install: build
	install -d $(DESTDIR)/etc/ansible
	install -m444 $(B)/hosts $(DESTDIR)/etc/ansible
	install -d $(shareDir)
	install -m444 $(B)/firewall.nft $(shareDir)
	install -m444 $(B)/wireguard-client.conf $(shareDir)
	install -m444 $(B)/wireguard-server.conf $(shareDir)
	install -m444 ansible-playbook.yml $(shareDir)
	install -m444 vps-keys.conf $(shareDir)
	install -d $(binDir)
	install -m666 edtwardy-vps.bash $(binDir)/edtwardy-vps
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 edtwardy-vps.target $(DESTDIR)/lib/systemd/system

###############################################################################
