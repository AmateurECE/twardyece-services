#!/bin/bash
CONTAINER=apps_populator
podman run -d --name $CONTAINER \
       -v apps-secrets:/data/secrets \
       -v apps-database:/data/database \
       -v apps-static:/data/static \
       -e DJANGO_HOSTNAME=twardyece.com \
       -e SCRIPT_NAME=/apps \
       --network edtwardy-webservices_default \
       edtwardy/apps:latest
podman cp apps/manage.py $CONTAINER:/root/

read -r -d '' NO_SCRIPT<<'EOF'
export $(tr "\0" "\n" </proc/$(pgrep uwsgi | head -n1)/environ); cd && sh
EOF

read -r -d '' SCRIPT<<'EOF'
export $(tr "\0" "\n" </proc/$(pgrep uwsgi | head -n1)/environ);
cd;
EOF
if [[ -z "$1" ]]; then
    podman exec -it $CONTAINER /bin/sh -c "$NO_SCRIPT"
else
    podman exec -it $CONTAINER /bin/sh -c "$SCRIPT $1"
fi
