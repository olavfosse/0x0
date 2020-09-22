#!/bin/sh
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

usage() {
	echo 'usage: 0x0.sh file [file | -]'
	echo '       0x0.sh url [url]'
	echo '       0x0.sh shorten [url]'
	echo '       0x0.sh [-h | --help | help]'
}

# ---Tests---
# Test 1
assertion='Error message is printed when too few arguments are passed'
command='./0x0.sh file'
expected_output="$(usage)"
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
expected_output="$(usage)"
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

# ---Report---
if [ "$ALL_GREEN" = true ]; then
	echo 'All tests passed'
fi
