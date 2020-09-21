#!/bin/sh
# Copyright (c) 2020 Olav Fosse
#
# Permission to use, copy, modify, and distribute this software for any purpose
# with or without fee is hereby granted, provided that the above copyright
# notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

# ---Settings---
set -e

# ---Helpers---
print_usage() {
	printf 'usage: %s file [file | -]\n' "$0"
	printf '       %s url [url]\n' "$0"
	printf '       %s shorten [url]\n' "$0"
	printf '       %s [-h | --help | help]\n' "$0"
}

# ---Dispatch handlers---
dispatch_file() {
	[ ! "$#" = 2 ] && print_usage 1>&2 && exit 1

	file="$2"
	if [ "$file" = "-" ]; then
		curl "-Ffile=@-" "http://0x0.st" # Read file from stdin
	else
		[ ! -e "$file" ] && printf 'error: "%s" does not exist\n' "$file" && exit 1
		[ -d "$file" ] && printf 'error: "%s" is a directory\n' "$file" && exit 1

		curl "-Ffile=@$file" "http://0x0.st"
	fi
}

dispatch_url() {
	[ ! "$#" = 2 ] && print_usage 1>&2 && exit 1

	url="$2"
	curl "-Furl=$url" "https://0x0.st"
}

dispatch_shorten() {
	[ ! "$#" = 2 ] && print_usage 1>&2 && exit 1

	url="$2"
	curl "-Fshorten=$url" "https://0x0.st"
}

# ---Dispatcher---
case "$1" in
	file)
		dispatch_file "$@"
		;;
	url)
		dispatch_url "$@"
		;;
	shorten)
		dispatch_shorten "$@"
		;;
	-h | --help | help)
		print_usage
		;;
	*)
		print_usage 1>&2
		exit 1
esac
