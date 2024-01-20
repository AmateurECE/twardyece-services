SERVICE=docs
include ../declarations.mk

all:

install:
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/docs.yaml
	install -Dm644 jenkins-job.groovy $(DESTDIR)$(JENKINSDIR)/docs.groovy
