SERVICE=docs
include ../declarations.mk

all:

install:
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/docs.conf
	install -Dm644 jenkins-job.groovy $(DESTDIR)$(JENKINSDIR)/docs.groovy
