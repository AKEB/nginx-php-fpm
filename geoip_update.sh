#!/bin/bash

### Download GeoLite2 MMDB databases for nginx geoip2 module
### - Adjust DBDIR and FILES below
### - Copy script to /etc/cron.weekly or similar for your OS,
###   note that /etc/cron.* filename MUST NOT HAVE .sh extension,
###   rename to /etc/cron.weekly/geoip_update
### Mirror: https://github.com/P3TERX/GeoLite.mmdb

# Database directory
DBDIR=/usr/share/GeoIP
# Files to download
FILES="GeoLite2-Country.mmdb GeoLite2-City.mmdb GeoLite2-ASN.mmdb"
BASE_URL="https://github.com/P3TERX/GeoLite.mmdb/raw/download"

# If http proxy needed
#https_proxy="http://foo.bar:3128"

# DB directory
test -w $DBDIR && cd $DBDIR 2>/dev/null || { echo "Invalid directory: $DBDIR"; exit 1; }

# Sleep 0-600 sec if started from cron
# if [ ! -t 0 ]; then sleep $((RANDOM/54)); fi

export https_proxy
for f in $FILES; do
	echo "downloading $f"
	if wget -nv -T 60 -O "$f.tmp" "$BASE_URL/$f"; then
		size=$(wc -c < "$f.tmp")
		if [ "$size" -lt 100000 ]; then
			echo "$f looks invalid (${size} bytes), keeping previous" >&2
			rm -f "$f.tmp"
			continue
		fi
		if [ -f "$f" ] && diff "$f" "$f.tmp" >/dev/null 2>&1; then
			echo "$f is up to date"
			rm -f "$f.tmp"
		else
			echo "updating $f"
			chmod 644 "$f.tmp"
			/bin/mv -f "$f.tmp" "$f"
		fi
	else
		echo "wget $f failed" >&2
		rm -f "$f.tmp"
	fi
done
