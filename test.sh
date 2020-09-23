#!/bin/sh
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
	if [ "$FAIL_FAST" = true ]; then
		exit 1
	else
		ALL_GREEN=false
		echo
	fi
}

test_exact () {
	assertion="$1"
	command="$2"
	expected_output="$3"
	actual_output="$($command 2>&1)"

	if [ ! "$actual_output" = "$expected_output" ]; then
		echo '---ASSERTION---'
		echo "$assertion"
		echo '---COMMAND---'
		echo "$command"
		echo '---EXPECTED OUTPUT---'
		echo "$expected_output"
		echo '---ACTUAL OUTPUT---'
		echo "$actual_output"
		fail
	fi
}

test_pattern () {
	assertion="$1"
	command="$2"
	expected_output_pattern="$3"
	actual_output="$($command 2>&1)"

	case "$actual_output" in
		$expected_output_pattern)
			;;
		*)
			echo '---ASSERTION---'
			echo "$assertion"
			echo '---COMMAND---'
			echo "$command"
			echo '---EXPECTED OUTPUT PATTERN---'
			echo "$expected_output_pattern"
			echo '---ACTUAL OUTPUT---'
			echo "$actual_output"
			fail
	esac
}

# ---Tests---
# Test 1
assertion='Error message is printed when too few arguments are passed'
command='./0x0.sh file'
expected_output="$USAGE"

test_exact "$assertion" "$command" "$expected_output"

# Test 2
assertion='Error message is printed when too many arguments are passed'
command='./0x0.sh file file1 file2'
expected_output="$USAGE"

test_exact "$assertion" "$command" "$expected_output"

# Test 3
# HACK I was not able to escape the command properly, so the test helpers cannot be used
assertion='File is uploaded from stdin'
expected_output_pattern='http://0x0.st/*.txt'
actual_output="$(echo "I want to share this with my friends on irc" | ./0x0.sh file - 2>&1)"

case "$actual_output" in
	$expected_output_pattern)
		;;
	*)
		echo '---ASSERTION---'
		echo "$assertion"
		echo '---COMMAND---'
		echo 'echo "I want to share this with my friends on irc" | ./0x0.sh file -'
		echo '---EXPECTED OUTPUT PATTERN---'
		echo "$expected_output_pattern"
		echo '---ACTUAL OUTPUT---'
		echo "$actual_output"
		fail
esac

# Test 4
assertion='File is uploaded from disk'
file_name='/tmp/0x0.sh.temp'
command="./0x0.sh file $file_name"
expected_output_pattern='http://0x0.st/*.temp'

echo '#!/bin/sh' >> "$file_name"
echo 'echo hello, world' >> "$file_name"

test_pattern "$assertion" "$command" "$expected_output_pattern"

# Test 5
assertion='File is uploaded from URL'
command="./0x0.sh url https://fossegr.im"
expected_output_pattern='https://0x0.st/*.html'

test_pattern "$assertion" "$command" "$expected_output_pattern"

# Test 6
assertion='URL is shortened'
command="./0x0.sh shorten https://fossegr.im/"
expected_output_pattern='https://0x0.st/*'

test_pattern "$assertion" "$command" "$expected_output_pattern"

# Test 7
assertion='Error message is printed when attempt to upload non-existant file'
file="/tmp/non-existant-file"
command="./0x0.sh file $file"
expected_output="error: $file does not exist"

test_exact "$assertion" "$command" "$expected_output"

# Test 8
assertion='Error message is printed when attempt to upload directory'
directory="/tmp/"
command="./0x0.sh file $directory"
expected_output="error: $directory is a directory"

test_exact "$assertion" "$command" "$expected_output"

# Test 9
# HACK I was not able to escape the command properly, so the test helpers cannot be used
assertion='Error message is printed when curl not in PATH'
expected_output='error: curl: not found'
actual_output="$(SIMULATE_CURL_NOT_IN_PATH=true ./0x0.sh 2>&1)"

if [ ! "$actual_output" = "$expected_output" ]; then
		echo '---ASSERTION---'
		echo "$assertion"
		echo '---COMMAND---'
		echo "$command"
		echo "SIMULATE_CURL_NOT_IN_PATH=true ./0x0.sh"
		echo '---EXPECTED OUTPUT---'
		echo "$expected_output"
		echo '---ACTUAL OUTPUT---'
		echo "$actual_output"
		fail
fi

# Test 10
assertion='Error message is printed when attempt to upload url with no protocol'
command="./0x0.sh url fossegr.im"
expected_output="error: invalid url"

test_exact "$assertion" "$command" "$expected_output"

# Test 11
assertion='Error message is printed when attempt to upload url with domain extension'
command="./0x0.sh url https://fossegr"
expected_output="error: invalid url"

test_exact "$assertion" "$command" "$expected_output"

# ---Report---
if [ "$ALL_GREEN" = true ]; then
	echo 'All tests passed'
fi
