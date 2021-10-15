# 0x0
A portable POSIX shell CLI to the https://0x0.st file sharing and URL shortening service.

The main documentation is the man page which you can view at [0x0(1)](https://github.com/fossegrim/0x0/raw/master/doc/0x0.1.pdf) or with `man 0x0`.

---

0x0 is written in portable shell and should run anywhere cURL is installed. You most likely already have cURL, otherwise you should install it. It's in your repositories.

`make install` installs the executable to `$(PREFIX)/bin` and the manual to `$(PREFIX)/man/man1`, `$(PREFIX)` defaulting to `/usr/local`. For most Unix-likes this is the correct locations. The notable exception is MacOS. It does not search `/usr/local/man` for manuals by default. Instead they go in `/usr/share/man` or `/usr/local/share/man`. Deal with it.
