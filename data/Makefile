SERVICE_NAME = data
include ../declarations.mk

install:
	install -d $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 etc-wireguard.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 var-lib-containers-storage-secrets.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
