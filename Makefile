install:
	install -o root 0x0.sh /usr/local/bin/0x0

lint:
	shellcheck test.sh
	shellcheck 0x0.sh

test:
	./test.sh
