###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Supporting build script for fundamental webservices
#		    infrastructure
#
# CREATED:	    10/25/2021
#
# LAST EDITED:	    10/25/2021
###

install:
	install -d $(DESTDIR)/lib/systemd/system
	install -m644 mnt-Serve-yocto-sstate\\x2dcache.mount \
		$(DESTDIR)/lib/systemd/system
	install -m644 mnt-Serve-yocto-esdk.mount $(DESTDIR)/lib/systemd/system

###############################################################################
