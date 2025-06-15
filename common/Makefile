# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 05/03/2022

SERVICE_NAME=common
include ../declarations.mk

install:
	: # Job control targets
	install -Dm644 services-pre.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 services-up.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 services-down.target -t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	install -Dm644 reverse-proxy-pre.target \
		-t $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)
	: # Start services-up.target on boot
	$(call addWants,multi-user.target,services-up.target)
	: # Create a container network for all services.
	install -Dm644 public-services.network -t $(DESTDIR)$(QUADLETDIR)
	: # SSH configuration
	install -Dm644 sshd.conf \
		$(DESTDIR)/etc/ssh/sshd_config.d/ethantwardy.com.conf
	: # services-pre.target requires wg0 to come up
	$(call addRequiresTemplate,services-pre.target,wg-quick@wg0.service)
	: # Ensure that wg0 comes up before services-pre.target is reached.
	$(call dropinBefore,wg-quick@wg0.service,services-pre.target)
