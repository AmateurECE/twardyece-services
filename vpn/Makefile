# Created: 09/21/2023

SERVICE_NAME=twardyece-vpn

include ../declarations.mk

install:
	: # pre-containers.target requires wg1 to come up
	$(call addRequiresTemplate,pre-containers.target,wg-quick@wg1.service)
