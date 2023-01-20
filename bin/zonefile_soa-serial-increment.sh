#!/bin/sh
#
# increment serial number of SOA RR
#
# see $ZONEFILE_SOA_SERIAL_INCREMENT for details
#
#
# jukka@salmi.ch 2019-11-12
#

: ${ZONEFILE_SOA_SERIAL_INCREMENT:=zonefile_soa-serial-increment} \
  ${RFC1912_SERIAL_FORMAT:=0}

PROG=${0##*/}

err()
{
	echo "$PROG: $*" >&2
	exit 1
}

case $# in
	1|2)
		zonefile="$1"
		serial="$2"
		;;
	*)
		echo "usage: $PROG zonefile [serial]" >&2
		exit 1
		;;
esac

[ -e "$zonefile" ] || err "$zonefile: no such file"
zonefile_new=$(mktemp $zonefile.XXXXXXXXXX) || err 'mktemp(1) failed'
cp -a "$zonefile" "$zonefile_new" || err 'cp(1) failed'

"$ZONEFILE_SOA_SERIAL_INCREMENT" \
	-v new_serial="$serial" \
	-v rfc1912_serial_format="$RFC1912_SERIAL_FORMAT" \
	"$zonefile" >"$zonefile_new"

if [ $? -ne 0 ]; then
	err "failed to increment serial (check $zonefile_new)"
else
	mv -f "$zonefile_new" "$zonefile"
fi
