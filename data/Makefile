SERVICE_NAME = data
include ../declarations.mk

install:
	install -d $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 etc-wireguard.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -m644 var-lib-containers-storage-secrets.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	mkdir -p $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/local-fs.target.wants
	ln -s \
		$(SYSTEMD_SYSTEM_UNITDIR)/etc-wireguard.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/local-fs.target.wants/etc-wireguard.mount
	ln -s \
		$(SYSTEMD_SYSTEM_UNITDIR)/var-lib-containers-storage-secrets.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/local-fs.target.wants/var-lib-containers-storage-secrets.mount
