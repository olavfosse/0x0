#!/bin/sh
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
	printf "dummy dispatch handler\\n"
}

dispatch_url() {
	printf "dummy dispatch handler\\n"
}

dispatch_shorten() {
	printf "dummy dispatch handler\\n"
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
