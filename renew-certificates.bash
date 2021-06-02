#!/bin/bash
###############################################################################
# NAME:             renew-certificates.bash
#
# AUTHOR:           Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:      Script (executed by cron) to renew SSL certificates.
#
# CREATED:          05/31/2021
#
# LAST EDITED:      06/01/2021
###

set -e

# Make sure nginx is running
systemctl is-active --quiet edtwardy-webservices.service ||
    {>&2 printf '%s\n' "edtwardy-webservices is not running."; exit 1;}

CERT_PATH=/etc/letsencrypt/live/edtwardy.hopto.org/cert.pem
# Check certificate renewal status, renew if necessary
docker run -t --rm --name edtwardy-webservices_certbot_1 \
       -v letsencrypt:/etc/letsencrypt \
       -v acme-challenge:/var/www/certbot \
       certbot/certbot certonly \
       -d edtwardy.hopto.org \
       --webroot \
       -w /var/www/certbot \
       -n \
       --renew-hook "date +%s -r $CERT_PATH" |
    tail -n1 |
    read certLastModTime

currentDate=$(date +%s)
timeDelta=$((currentDate-certLastModTime))
tenMinutes=600
if [[ $timeDelta -le $tenMinutes ]]; then
    # Certificate has been renewed, so reload Nginx
    docker exec -t edtwardy-webservices_nginx_1 nginx -s reload
fi

###############################################################################
