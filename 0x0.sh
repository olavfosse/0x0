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
