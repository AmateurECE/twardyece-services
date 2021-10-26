###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    Rules for the edtwardy-tftp service.
#
# CREATED:	    10/25/2021
#
# LAST EDITED:	    10/25/2021
###

compose=docker-compose.yml

install:
	install -m444 $(compose) $(shareDirectory)/tftp.$(compose)
	install -m644 edtwardy-tftp.service $(DESTDIR)/lib/systemd/system

###############################################################################
