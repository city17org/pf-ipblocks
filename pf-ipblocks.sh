#!/bin/sh
#
# Copyright (c) 2022 Sean Davies <sean@city17.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

set -e

die()
{
	echo "$1" 1>&2
	exit 1
}

usage()
{
	die "usage: ${0##*/} [-x] cctld"
}

droproot()
{
	local _user=_ftp

	eval su -s /bin/sh "${_user}" -c "'$*'" || exit 1
}

fetchzonedata()
{
	if [ "${xflag}" -eq 0 ] || [ "$(id -u)" -eq 0 ]; then
		output=$(droproot ftp -MVo - "${url}")
	else
		output=$(ftp -Vo - "${url}") || exit 1
	fi

	if [ -z "${output}" ]; then
		die "${0##*/}: failed to fetch zone file data"
	fi
}

xflag=0
while getopts x arg; do
	case ${arg} in
	x)	xflag=1 ;;
	*)	usage ;;
	esac
done
shift $((OPTIND - 1))
[ "$#" -eq 1 ] || usage

case $1 in
[A-Z][A-Z]) cctld=$(echo "$1" | tr '[:upper:]' '[:lower:]') ;;
[a-z][a-z]) cctld=$1 ;;
*) usage ;;
esac
url=http://www.ipdeny.com/ipblocks/data/aggregated/${cctld}-aggregated.zone

if [ "${xflag}" -eq 0 ] && [ "$(id -u)" -ne 0 ]; then
	die "${0##*/}: needs root privileges"
fi

fetchzonedata
[ -n "${output}" ] || exit 0

if [ "${xflag}" -eq 0 ]; then
	outfile=/etc/pf-$1.zone
	pftable=$1.zone

	if [ ! -f "${outfile}" ] || [ "${output}" != "$(cat "${outfile}")" ]; then
		echo "${output}" >"${outfile}"
		pfctl -t "${pftable}" -T replace -f "${outfile}"
	fi
else
	echo "${output}"
fi
