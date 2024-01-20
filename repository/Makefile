SERVICE=repository
include ../declarations.mk

all:

install:
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/repository.yaml
	install -Dm644 jenkins-job.groovy $(DESTDIR)$(JENKINSDIR)/repository.groovy
