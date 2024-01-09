# Created: 08/25/2021

SERVICE_NAME=twardyece-vps

BUILD_TARGETS += $(B)/firewall.nft
BUILD_TARGETS += $(B)/hosts
BUILD_TARGETS += $(B)/wireguard-client.conf
BUILD_TARGETS += $(B)/wireguard-server.conf
include ../declarations.mk

SERVICEDIR=$(DATADIR)/$(SERVICE_NAME)

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

install: build
	install -Dm444 $(B)/hosts $(DESTDIR)/etc/ansible/hosts
	install -Dm444 $(B)/firewall.nft $(DESTDIR)$(SERVICEDIR)/firewall.nft
	install -Dm444 $(B)/wireguard-client.conf \
		$(DESTDIR)$(SERVICEDIR)/wireguard-client.conf
	install -Dm444 $(B)/wireguard-server.conf \
		$(DESTDIR)$(SERVICEDIR)/wireguard-server.conf
	install -Dm444 ansible-playbook.yml \
		$(DESTDIR)$(SERVICEDIR)/ansible-playbook.yml
	install -Dm444 vps-keys.conf $(DESTDIR)$(SERVICEDIR)/vps-keys.conf
	install -Dm666 twardyece-vps.bash $(DESTDIR)$(BINDIR)/twardyece-vps
	: # services-pre.target requires wg0 to come up
	$(call addRequiresTemplate,services-pre.target,wg-quick@wg0.service)
