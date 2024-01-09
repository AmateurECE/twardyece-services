# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=openldap
include ../declarations.mk

install:
	install -Dm644 openldap.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 openldap-ldap-data.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 openldap-slapd-config.volume -t $(DESTDIR)$(QUADLETDIR)
