install:
	install -o root 0x0.sh /usr/local/bin/0x0

lint:
	shellcheck test.sh
	shellcheck 0x0.sh

test:
	./test.sh

doc:
	mandoc -Tlint -Wstyle 0x0.1
	mandoc -Thtml 0x0.1 > index.html
	mandoc 0x0.1 | less
