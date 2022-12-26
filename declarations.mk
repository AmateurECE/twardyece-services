###############################################################################
# NAME:		    declarations.mk
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Declarations of universal rules.
#
# CREATED:	    01/22/2022
#
# LAST EDITED:	    12/25/2022
###

PREFIX=/usr
BINDIR=$(PREFIX)/bin
LIBDIR=$(PREFIX)/lib
DATADIR=$(PREFIX)/share
SYSTEMD_SYSTEM_UNITDIR=$(LIBDIR)/systemd/system

VOLUMETRICDIR=$(DATADIR)/volumetric/volumetric.d
ROOTDIR=$(DATADIR)/twardyece

SERVICEDIR=$(ROOTDIR)/services
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

###############################################################################
