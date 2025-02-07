#!/usr/bin/env bash

set -x

# Ignore the snapshots directory and the @postgresql_data subvolume
# (this volume has a different backup strategy)
subvolumes=$(ls /mnt/Mount | grep -v 'snapshots\|@postgresql_data')
most_recent_snapshot=snapshots/$(ls /mnt/Mount/snapshots | tail -n1)

date=$(date +%Y-%m-%d)
snapshot=snapshots/$date
mkdir -p /mnt/Mount/$snapshot

for subvolume in $subvolumes; do
  btrfs subvolume snapshot \
    -r /mnt/Mount/$subvolume \
    /mnt/Mount/$snapshot/$subvolume
done

for subvolume in $subvolumes; do
  if [ -e $most_recent_snapshot/$subvolume ]; then
    btrfs send \
      -p /mnt/Mount/$most_recent_snapshot/$subvolume \
      /mnt/Mount/$snapshot/$subvolume \
      | btrfs receive /mnt/Backup/snapshots
  else
    btrfs send \
      /mnt/Mount/$snapshot/$subvolume \
      | btrfs receive /mnt/Backup/snapshots
  fi
done

# Backup the podman database
mkdir /mnt/Backup/postgresql/$(date +%Y-%m-%d)
podman exec -it internal_postgresql \
  pg_dump -U postgres miniflux \
  >/mnt/Backup/postgresql/$date/miniflux.sql
podman exec -it internal_postgresql \
  pg_dump -U postgres tandoor \
  >/mnt/Backup/postgresql/$date/tandoor.sql
podman exec -it internal_postgresql \
  pg_dump -U postgres gnucash \
  >/mnt/Backup/postgresql/$date/gnucash.sql
