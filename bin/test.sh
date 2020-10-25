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
usage:	0x0 file [-nv] filename
	0x0 url [-nv] URL
	0x0 shorten [-nv] URL
EOF
)"
 
PATH0X0="./src/0x0"

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
command="$PATH0X0 file"
expected_output="$USAGE"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 2
assertion='Error when too many arguments are passed'
command="$PATH0X0 file file1 file2"
expected_output="$USAGE"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 3
# HACK I was not able to escape the command properly, so the test helpers cannot be used
assertion='File is uploaded from stdin'
expected_output_pattern='https://0x0.st/*.txt'
expected_exit_code=0
actual_output="$(echo "I want to share this with my friends on irc" | $PATH0X0 file - 2>&1)"
actual_exit_code="$?"

local_fail() {
	echo '---ASSERTION---'
	printf '"%s"\n' "$assertion"
	echo '---COMMAND---'
	printf '"%s"\n' "echo "I want to share this with my friends on irc" | $PATH0X0 file -"
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
file_name='/tmp/0x0.temp'
command="$PATH0X0 file $file_name"
expected_output_pattern='https://0x0.st/*.temp'
expected_exit_code=0

echo '#!/bin/sh' >> "$file_name"
echo 'echo hello, world' >> "$file_name"

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 5
assertion='File is uploaded from URL'
command="$PATH0X0 url https://fossegr.im"
expected_output_pattern='https://0x0.st/*.html'
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 6
assertion='URL is shortened'
command="$PATH0X0 shorten https://fossegr.im/"
expected_output_pattern='https://0x0.st/*'
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 7
assertion='Error when attempt to upload non-existant file'
file="/tmp/non-existant-file"
command="$PATH0X0 file $file"
expected_output="error: $file does not exist"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 8
assertion='Directory is uploaded as a tarball'
directory='/tmp/directory-to-tarball.temp'
mkdir -p "$directory"
echo 'Welcome to my tarball' > "$directory/README"
echo 'lorem ipsum dolor sit amet' > "$directory/lorem"
command="$PATH0X0 file $directory"
expected_output_pattern='https://0x0.st/*.tar'
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 9
assertion='Error when attempt to upload url with no protocol'
command="$PATH0X0 url fossegr.im"
expected_output="error: invalid url"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 10
assertion='Error when attempt to upload url without domain extension'
command="$PATH0X0 url https://fossegr"
expected_output="error: invalid url"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 11
assertion='500 Internal Server Error when non existant, but valid url is uploaded'
command="$PATH0X0 url https://non.existant.website"
expected_output='error: 500 Internal Server Error'
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 12
# curl -F treats commas and semicolons differently
# this makes sure it is escaped properly
assertion='Uploads file with semicolon and comma in filename'
filename='/tmp/,dont;name,your;files,like;this,'
echo 'Bad file name' > "$filename"
command="$PATH0X0 file $filename"
expected_output_pattern='https://0x0.st/*'
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 13
assertion='Usage is printed when invoked with no arguments'
command="$PATH0X0"
expected_output="$USAGE"
expected_exit_code=1

test_exact "$assertion" "$command" "$expected_output" "$expected_exit_code"

# Test 14
assertion='Print curl commands when -v option is passed'
file_name='/tmp/0x0.temp'
command="$PATH0X0 file -v $file_name"
expected_output_pattern="$ curl -Ss -w 'status_code=%{http_code}' https://0x0.st -Ffile=@\"$file_name\")
https://0x0.st/*.temp"
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 15
assertion='Print tar and curl commands when -v option is passed'
directory='/tmp/directory-to-tarball.temp'
mkdir -p "$directory"
echo 'Welcome to my tarball' > "$directory/README"
echo 'lorem ipsum dolor sit amet' > "$directory/lorem"
command="$PATH0X0 file -v $directory"
expected_output_pattern="$ tar cf - /tmp/directory-to-tarball.temp 2> /dev/null
$ curl -Ss -w 'status_code=%{http_code}' https://0x0.st -Ffile=@\"-\")
https://0x0.st/*.tar"
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 16
assertion='Print curl commands when -v option is passed but should not execute curl commands when -n is passed'
file_name='/tmp/0x0.temp'
command="$PATH0X0 file -v -n $file_name"
expected_output_pattern="$ curl -Ss -w 'status_code=%{http_code}' https://0x0.st -Ffile=@\"$file_name\")"
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# Test 17
assertion='Print tar and curl commands when -v option is passed but should not execute tar or curl commands when -n is passed'
directory='/tmp/directory-to-tarball.temp'
mkdir -p "$directory"
echo 'Welcome to my tarball' > "$directory/README"
echo 'lorem ipsum dolor sit amet' > "$directory/lorem"
command="$PATH0X0 file  -v -n $directory"
expected_output_pattern="$ tar cf - /tmp/directory-to-tarball.temp 2> /dev/null
$ curl -Ss -w 'status_code=%{http_code}' https://0x0.st -Ffile=@\"-\")"
expected_exit_code=0

test_pattern "$assertion" "$command" "$expected_output_pattern" "$expected_exit_code"

# ---Report---
if [ "$ALL_GREEN" = true ]; then
	echo 'All tests passed'
fi
