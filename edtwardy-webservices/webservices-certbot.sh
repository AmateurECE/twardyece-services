#!/bin/sh
###############################################################################
# NAME:             webservices-certbot.sh
#
# AUTHOR:           Ethan D. Twardy <ethan.twardy@gmail.com>
#
# DESCRIPTION:      Convenience script for running containerized certbot with
#                   all relevant volumes mounted.
#
# CREATED:          02/26/2022
#
# LAST EDITED:      02/26/2022
###

PACKAGE_NAME=edtwardy-webservices
docker run -t --rm --name ${PACKAGE_NAME}_certbot_1 \
       -e 'TZ=America/Chicago' \
       -v letsencrypt:/etc/letsencrypt \
       -v ${PACKAGE_NAME}_acme-challenge:/var/www/certbot \
       -v ${PACKAGE_NAME}_letsencrypt-logs:/var/log/letsencrypt \
       certbot/certbot $@

###############################################################################
