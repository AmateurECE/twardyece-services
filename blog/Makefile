SERVICE=blog
include ../declarations.mk

all:

install:
	install -Dm644 nginx.srv $(DESTDIR)$(NGINXDIR)/blog.conf
	install -Dm644 jenkins-job.groovy $(DESTDIR)$(JENKINSDIR)/blog.groovy
