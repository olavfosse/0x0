#!/bin/sh
#
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
#

# ---Constants---
USAGE="$(cat << EOF
usage:	0x0 file FILE
	0x0 url URL
	0x0 shorten URL
EOF
)"

# ---Helpers---
is_in_path() {
	file="$1"

	which "$file" > /dev/null 2> /dev/null
	return "$?"
}

is_valid_url() {
	url="$1"

	case "$url" in
		http://*.* | https://*.* )
			;;
		* )
			return 1
	esac
}

exit_with_error() {
	message="$1"

	printf '%s\n' "$message" 1>&2
	exit 1
}

get_full_status_code() {
	numeral_status_code="$1"

	case "$numeral_status_code" in
		400)
			printf '400 Bad Request'
			;;
		403)
			printf '403 Forbidden'
			;;
		500)
			printf '500 Internal Server Error'
			;;
		*)
			# Fallback to numeral status code
			printf '%s' "$1"
	esac
}

request() {
	form_string="$1" # -Fkey=[@]value

	output="$(curl -Ss -w 'status_code=%{http_code}' https://0x0.st "$form_string")"
	code="$(echo "$output" | tail -n 1 |  sed s/status_code=//g)"
	response="$(echo "$output" | grep -vE 'status_code=.*')" # Remove status_code line

	case "$code" in
		4** | 5**)
			exit_with_error "error: $(get_full_status_code "$code")"
			;;
		*)
			echo "$response"
	esac
}

# ---Dispatch handlers---
dispatch_file() {
	file="$2"

	[ ! "$#" = 2 ] && exit_with_error "$USAGE"

	if [ "$file" = "-" ]; then
		request "-Ffile=@-" # Read file from stdin
	else
		[ ! -e "$file" ] && exit_with_error "error: $file does not exist"
		[ -d "$file" ] && exit_with_error "error: $file is a directory"

		request "-Ffile=@$file"
	fi
}

dispatch_url() {
	url="$2"

	[ ! "$#" = 2 ] && exit_with_error "$USAGE"
	is_valid_url "$url" || exit_with_error 'error: invalid url'

	request "-Furl=$url"
}

dispatch_shorten() {
	url="$2"

	[ ! "$#" = 2 ] && exit_with_error "$USAGE"
	is_valid_url "$url" || exit_with_error 'error: invalid url'

	request "-Fshorten=$url"
}

# ---Dispatcher---
dispatch() {
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
		*)
			exit_with_error "$USAGE"
	esac
}

# ---Entry point---
if ! is_in_path curl || [ "$SIMULATE_CURL_NOT_IN_PATH" = true ]; then
	exit_with_error 'error: curl: not found'
fi

dispatch "$@"
