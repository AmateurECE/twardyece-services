# Created: 09/21/2023

SERVICE_NAME=twardyece-vpn

include ../declarations.mk

install:
	: # services-pre.target requires wg1 to come up
	$(call addRequiresTemplate,services-pre.target,wg-quick@wg1.service)
