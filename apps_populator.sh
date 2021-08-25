#!/bin/bash
CONTAINER=apps_populator
docker run -d --name $CONTAINER \
       -v apps-database:/data/database \
       -v apps-static:/data/static \
       -e DJANGO_HOSTNAME=edtwardy.hopto.org \
       -e SCRIPT_NAME=/apps \
       --network edtwardy-webservices_default \
       edtwardy/apps:latest
docker cp apps/manage.py $CONTAINER:/root/

read -r -d '' NO_SCRIPT<<'EOF'
export $(tr "\0" "\n" </proc/$(pgrep uwsgi | head -n1)/environ); cd && sh
EOF

read -r -d '' SCRIPT<<'EOF'
export $(tr "\0" "\n" </proc/$(pgrep uwsgi | head -n1)/environ);
cd;
EOF
if [[ -z "$1" ]]; then
    docker exec -it $CONTAINER /bin/sh -c "$NO_SCRIPT"
else
    docker exec -it $CONTAINER /bin/sh -c "$SCRIPT $1"
fi
