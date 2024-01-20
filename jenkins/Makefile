# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 12/25/2022

SERVICE_NAME=jenkins
include ../declarations.mk

install:
	install -Dm644 jenkins-controller.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 jenkins-controller-config.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 jenkins-controller-secrets.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 jenkins-agent.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 jenkins-agent-secret.volume -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 config.yaml -t $(DESTDIR)/usr/share/twardyece-jenkins
	: # Nginx configuration
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
	: # Builder service
	install -Dm644 jenkins-builder.service \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/jenkins-builder.service
