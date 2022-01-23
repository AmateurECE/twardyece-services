###############################################################################
# NAME:		    declarations.mk
#
# AUTHOR:	    Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:	    Declarations of universal rules.
#
# CREATED:	    01/22/2022
#
# LAST EDITED:	    01/23/2022
###

###############################################################################
# Container stuff
###

ifdef SQUASH
squash=--squash
endif

define buildahBud
cd $(B) && buildah bud --layers $(squash) -f $(1) -t "$(2):latest"
endef

#: Generate docker image
# $(B)/%-build.lock: Containerfile.%
# 	$(call buildahBud,$<,$(suffix $<))
# 	touch $@

###############################################################################
# Utilities and universal rules
###

$(shell mkdir -p $(B))

#: Build package resources
$(B)/build.lock: $(BUILD_TARGETS)
	touch $@

build: $(B)/build.lock

define subdirInvoke
$(MAKE) -C edtwardy-$(1) B=$(B)/$(1) $(2);
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

#: Build container images in the local cache (for all subdirs)
containers-subdirs: build
	$(foreach subdir,$(SUBDIRS),$(call subdirInvoke,$(subdir),containers))

containers:
install:

###############################################################################
