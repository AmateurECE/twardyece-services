#!/usr/bin/env bash

rsync -rv --progress --delete \
  /mnt/Library/{Archives,AudiobooksByChapter,Music,Photos,Audiobooks,E-Books,Movies,Notes,SavedWork,Shows} \
  /mnt/Backup/ \
  >/var/log/backup/backup-$(date +%Y%m%d).log 2>&1
