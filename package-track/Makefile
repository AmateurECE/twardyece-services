SERVICE_NAME=package-track
include ../declarations.mk

install:
	install -Dm644 package-track.container -t $(DESTDIR)$(QUADLETDIR)
	install -Dm644 package-track.timer -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
