#!/bin/bash

MONTH=$1

if [ -n "$MONTH" ]; then
  grep http ${MONTH}*_esv.html | sed 's/href\=/\n/g' | cut -d\" -f2 | \
  grep http | sort | sed 's/^/<a href="/g;s/$/">test link<\/a><br>/g' \
  > ~/${MONTH}_links.html
else
  echo "please supply a month on the command line"
  exit 1
fi

exit 0
