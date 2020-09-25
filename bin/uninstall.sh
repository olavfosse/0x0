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

if [ "$(whoami)" != root ]; then
	echo 'error: must be root' 2>&1 
	exit 1
fi

if [ "$(uname)" = Darwin ]; then
	man1='/usr/local/share/man/man1'
else
	man1='/usr/local/man/man1'
fi
rm "$man1/0x0.1" || exit 1

bin='/usr/local/bin'
rm "$bin/0x0" || exit 1

if [ "$(uname)" = OpenBSD ]; then 
	makewhatis '/usr/local/man' || exit 1
fi
