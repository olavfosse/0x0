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

# ---Tests---
# Test 1
assertion='Error message is printed when too few arguments are passed'
command='./0x0.sh file'
expected_output="$USAGE"
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

# Test 2
assertion='Error message is printed when too many arguments are passed'
command='./0x0.sh file file1 file2'
expected_output="$USAGE"
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

# Test 3
# HACK I was not able to escape the command properly, so the literal command is repeated in two lines
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
echo '#!/bin/sh' >> "$file_name"
echo 'echo hello, world' >> "$file_name"
command="./0x0.sh file $file_name"
expected_output_pattern='http://0x0.st/*.temp'
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

# Test 5
assertion='File is uploaded from URL'
url='https://fossegr.im/'
command="./0x0.sh url $url"
expected_output_pattern='https://0x0.st/*.html'
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

# Test 6
assertion='URL is shortened'
url='https://fossegr.im/'
command="./0x0.sh shorten $url"
expected_output_pattern='https://0x0.st/*'
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

# Test 7
assertion='Error message is printed when attempt to upload non-existant file'
file="/tmp/non-existant-file"
command="./0x0.sh file $file"
expected_output="error: $file does not exist"
actual_output="$($command 2>&1)"

case "$actual_output" in
	$expected_output)
		;;
	*)
		echo '---ASSERTION---'
		echo "$assertion"
		echo '---COMMAND---'
		echo "$command"
		echo '---EXPECTED OUTPUT---'
		echo "$expected_output"
		echo '---ACTUAL OUTPUT---'
		echo "$actual_output"
		fail
esac

# Test 8
assertion='Error message is printed when attempt to upload directory'
directory="/tmp/"
command="./0x0.sh file $directory"
expected_output="error: $directory is a directory"
actual_output="$($command 2>&1)"

case "$actual_output" in
	$expected_output)
		;;
	*)
		echo '---ASSERTION---'
		echo "$assertion"
		echo '---COMMAND---'
		echo "$command"
		echo '---EXPECTED OUTPUT---'
		echo "$expected_output"
		echo '---ACTUAL OUTPUT---'
		echo "$actual_output"
		fail
esac

# Test 9
# HACK I was not able to escape the command properly, so the literal command is repeated in two lines
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

# ---Report---
if [ "$ALL_GREEN" = true ]; then
	echo 'All tests passed'
fi
