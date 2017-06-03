NAME := libcs50
VERSION := 8.0.2
UPSTREAM := $(NAME)-$(VERSION)

.PHONY: build
build: clean
	gcc -c -fPIC -std=gnu99 -Wall -o cs50.o src/cs50.c
	gcc -shared -Wl,-soname,libcs50.so.8 -o libcs50.so.$(VERSION) cs50.o
	rm -f cs50.o
	ln -s libcs50.so.$(VERSION) libcs50.so.8
	ln -s libcs50.so.8 libcs50.so
	install -D -m 644 src/cs50.h build/usr/include/cs50.h
	mkdir -p build/usr/lib
	mv libcs50.so* build/usr/lib

.PHONY: install
install: build
	cp -r build/* /

.PHONY: clean
clean:
	rm -rf build debian/docs/ libcs50-* libcs50_*

.PHONY: docs
docs:
	asciidoctor -d manpage -b manpage -D debian/docs/ docs/*.adoc

.PHONY: package
deb: build docs
	rsync -a build/* $(UPSTREAM)/
	tar -cvzf $(NAME)_$(VERSION).orig.tar.gz $(UPSTREAM)
	cp -r debian $(UPSTREAM)
	cd $(UPSTREAM) && debuild -S -sa --lintian-opts --info --display-info --show-overrides
