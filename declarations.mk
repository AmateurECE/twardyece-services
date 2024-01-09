# Author: Ethan D. Twardy <ethan.twardy@gmail.com>
# Created: 01/22/2022

SHELL := /bin/bash

PREFIX=/usr
BINDIR=$(PREFIX)/bin
LIBDIR=$(PREFIX)/lib
DATADIR=$(PREFIX)/share
SYSTEMD_SYSTEM_UNITDIR=$(LIBDIR)/systemd/system
QUADLETDIR=$(DATADIR)/containers/systemd

VOLUMETRICDIR=/etc/volumetric/volumes.d
ROOTDIR=$(DATADIR)/twardyece

SERVICEDIR=$(ROOTDIR)
NGINXDIR=$(ROOTDIR)/routes

###############################################################################
# Utilities and universal rules
###

$(shell mkdir -p $(B))

#: Build package resources
$(B)/build.lock: $(BUILD_TARGETS)
	touch $@

build: $(B)/build.lock

define subdirInvoke
$(MAKE) -C $(1) B=$(B)/$(1) $(2);
endef

#: Build package resources in subdirectories
build-subdirs: build
	$(foreach subdir,$(SUBDIRS),$(call subdirInvoke,$(subdir),build))

#: Install package files
install-subdirs: build
	$(foreach subdir,$(SUBDIRS),$(call subdirInvoke,$(subdir),install))

#: Clean build files
clean-subdirs:
	$(foreach subdir,$(SUBDIRS),$(call subdirInvoke,$(subdir),clean))

install:
clean:

# Creates a symlink from foo.target.requires/bar@baz.service to ../bar@.service
define addRequiresTemplate
mkdir -p $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(1).requires; \
ln -s ../$$(perl -pe 's/(?<=@)[^.]+//' <<<"$(2)") \
    $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(1).requires/$(2);
endef

# Creates a symlink from foo.target.requires/bar.service to ../barservice
define addRequires
mkdir -p $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(1).requires; \
ln -s ../$(2) $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(1).requires/$(2);
endef

# Create a symlink from foo.target.wants/bar.service to ../bar.service
define addWants
mkdir -p $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(1).wants; \
ln -s ../$(2) $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(1).wants/$(2);
endef

# Create a drop-in file that specifies a Before dependency on foo for bar
define dropinBefore
mkdir -p $(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(1).d; \
printf '%s\n' "[Unit]" "Before=$(2)" \
	>$(DESTDIR)$(SYSTEMD_SYSTEM_UNITDIR)/$(1).d/$(2).conf;
endef
