#!/bin/sh

set -e

for f in $(/usr/bin/find /entrypoint.d/ -type f -name "*.sh"); do
    "$f"
done

exec "$@"