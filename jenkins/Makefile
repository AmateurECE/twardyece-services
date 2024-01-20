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
	: # Nginx configuration
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/$(SERVICE_NAME).conf
	: # Jenkins configuration
	install -Dm644 config.yaml -t $(DESTDIR)$(JENKINSDIR)
	install -Dm644 blog.groovy -t $(DESTDIR)$(JENKINSDIR)
	install -Dm644 repository.groovy -t $(DESTDIR)$(JENKINSDIR)
