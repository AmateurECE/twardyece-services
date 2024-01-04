# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=jenkins
include ../declarations.mk

install:
	install -Dm644 jenkins-controller.yaml -t $(DESTDIR)$(SERVICEDIR)
	install -Dm644 jenkins-agent.yaml -t $(DESTDIR)$(SERVICEDIR)
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).yaml
	install -Dm644 jenkins-builder.service \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/jenkins-builder.service
	$(call addRequiresTemplate,containers-up.target,container@twardyece_jenkins-agent.service)
	$(call addRequiresTemplate,services-up.target,container@twardyece_jenkins-controller.service)
	$(call addRequires,container@twardyece_jenkins-agent.service,reverse-proxy.target)
