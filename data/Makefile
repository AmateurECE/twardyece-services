SERVICE_NAME = data
include ../declarations.mk

install:
	install -d $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/local-fs.target.wants
	install -m644 etc-wireguard.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addWants,local-fs.target,etc-wireguard.mount)
	install -m644 mnt-library.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addWants,local-fs.target,mnt-library.mount)
	install -m644 mnt-volatile.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addWants,local-fs.target,mnt-volatile.mount)
	install -m644 mnt-dataset.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addWants,local-fs.target,mnt-dataset.mount)
	install -m644 mnt-services.mount $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addWants,local-fs.target,mnt-services.mount)
	install -m644 var-lib-containers-storage-secrets.mount \
		$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	$(call addWants,local-fs.target,var-lib-containers-storage-secrets.mount)
