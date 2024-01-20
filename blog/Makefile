SERVICE=blog
include ../declarations.mk

all:

install:
	install -Dm644 nginx.yaml $(DESTDIR)$(NGINXDIR)/blog.yaml
	install -Dm644 jenkins-job.groovy $(DESTDIR)$(JENKINSDIR)/blog.groovy
