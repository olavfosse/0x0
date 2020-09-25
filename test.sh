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

# ---Globals---
ALL_GREEN=true

# ---Helpers---
fail() {
	[ "$FAIL_FAST" = true ] && exit 1

	ALL_GREEN=false
	echo
}

test_exact () {
	assertion="$1"
	command="$2"
	expected_output="$3"
	expected_exit_code="$4"

	actual_output="$($command 2>&1)"
	actual_exit_code="$?"

	[ "$actual_output" = "$expected_output" ] && [ "$actual_exit_code" = "$expected_exit_code" ] && return

	echo '---ASSERTION---'
	printf '"%s"\n' "$assertion"
	echo '---COMMAND---'
	printf '"%s"\n' "$command"
	echo '---EXPECTED OUTPUT---'
	printf '"%s"\n' "$expected_output"
	echo '---ACTUAL OUTPUT---'
	printf '"%s"\n' "$actual_output"
	echo '---EXPECTED EXIT CODE---'
	printf '"%s"\n' "$expected_exit_code"
	echo '---ACTUAL EXIT CODE---'
	printf '"%s"\n' "$actual_exit_code"
	fail
}

test_pattern () {
	assertion="$1"
	command="$2"
	expected_output_pattern="$3"
	expected_exit_code="$4"

	actual_output="$($command 2>&1)"
	actual_exit_code="$?"

	# shellcheck disable=SC2254
	case "$actual_output" in
		$expected_output_pattern)
			[ "$actual_exit_code" = "$expected_exit_code" ] && return
			;;
		*)
	esac

	echo '---ASSERTION---'
	printf '"%s"\n' "$assertion"
	echo '---COMMAND---'
	printf '"%s"\n' "$command"
	echo '---EXPECTED OUTPUT PATTERN---'
	printf '"%s"\n' "$expected_output_pattern"
	echo '---ACTUAL OUTPUT---'
	printf '"%s"\n' "$actual_output"
	echo '---EXPECTED EXIT CODE---'
	printf '"%s"\n' "$expected_exit_code"
	echo '---ACTUAL EXIT CODE---'
	printf '"%s"\n' "$actual_exit_code"
	fail
}

# ---Tests---
# Test 1
assertion='Error when too few arguments are passed'
command='./0x0.sh file'
expected_output="$USAGE"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 2
assertion='Error when too many arguments are passed'
command='./0x0.sh file file1 file2'
expected_output="$USAGE"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 3
# HACK I was not able to escape the command properly, so the test helpers cannot be used
assertion='File is uploaded from stdin'
expected_output_pattern='https://0x0.st/*.txt'
expected_exit_code=0
actual_output="$(echo "I want to share this with my friends on irc" | ./0x0.sh file - 2>&1)"
actual_exit_code="$?"

local_fail() {
	echo '---ASSERTION---'
	printf '"%s"\n' "$assertion"
	echo '---COMMAND---'
	printf '"%s"\n' 'echo "I want to share this with my friends on irc" | ./0x0.sh file -'
	echo '---EXPECTED OUTPUT PATTERN---'
	printf '"%s"\n' "$expected_output_pattern"
	echo '---ACTUAL OUTPUT---'
	printf '"%s"\n' "$actual_output"
	echo '---EXPECTED EXIT CODE---'
	printf '"%s"\n' "$expected_exit_code"
	echo '---ACTUAL EXIT CODE---'
	printf '"%s"\n' "$actual_exit_code"
	fail
}

# shellcheck disable=SC2254
case "$actual_output" in
	$expected_output_pattern)
		[ "$actual_exit_code" != "$expected_exit_code" ] && local_fail
		;;
	*)
		local_fail
esac

# Test 4
assertion='File is uploaded from disk'
file_name='/tmp/0x0.sh.temp'
command="./0x0.sh file $file_name"
expected_output_pattern='https://0x0.st/*.temp'
expected_exit_code=0

echo '#!/bin/sh' >> "$file_name"
echo 'echo hello, world' >> "$file_name"

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 5
assertion='File is uploaded from URL'
command="./0x0.sh url https://fossegr.im"
expected_output_pattern='https://0x0.st/*.html'
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 6
assertion='URL is shortened'
command="./0x0.sh shorten https://fossegr.im/"
expected_output_pattern='https://0x0.st/*'
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 7
assertion='Error when attempt to upload non-existant file'
file="/tmp/non-existant-file"
command="./0x0.sh file $file"
expected_output="error: $file does not exist"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 8
assertion='Error when attempt to upload directory'
directory="/tmp/"
command="./0x0.sh file $directory"
expected_output="error: $directory is a directory"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 9
# HACK I was not able to escape the command properly, so the test helpers cannot be used
assertion='Error when curl not in PATH'
expected_output='error: curl: not found'
expected_exit_code=1
actual_output="$(SIMULATE_CURL_NOT_IN_PATH=true ./0x0.sh 2>&1)"
actual_exit_code="$?"

if [ ! "$actual_output" = "$expected_output" ] || [ ! "$actual_exit_code" = "$expected_exit_code" ]; then
		echo '---ASSERTION---'
		printf '"%s"\n' "$assertion"
		echo '---COMMAND---'
		# shellcheck disable=SC2016
		printf '"%s"\n' '$SIMULATE_CURL_NOT_IN_PATH=true ./0x0.sh'
		echo '---EXPECTED OUTPUT---'
		printf '"%s"\n' "$expected_output"
		echo '---ACTUAL OUTPUT---'
		printf '"%s"\n' "$actual_output"
		echo '---EXPECTED EXIT CODE---'
		printf '"%s"\n' "$expected_exit_code"
		echo '---ACTUAL EXIT CODE---'
		printf '"%s"\n' "$actual_exit_code"
		fail
fi

# Test 10
assertion='Error when attempt to upload url with no protocol'
command="./0x0.sh url fossegr.im"
expected_output="error: invalid url"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 11
assertion='Error when attempt to upload url without domain extension'
command="./0x0.sh url https://fossegr"
expected_output="error: invalid url"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 12
assertion='500 Internal Server Error when non existant, but valid url is uploaded'
command='./0x0.sh url https://non.existant.website'
expected_output='error: 500 Internal Server Error'
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# ---Report---
if [ "$ALL_GREEN" = true ]; then
	echo 'All tests passed'
fi
