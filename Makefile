DC = $(shell command -v ldc2 || command -v dmd)

CFLAGS = -O2
DFLAGS = -O2 -Iserver-src

all: server/index.html server/cgi-bin/send server/cgi-bin/watch server/cgi-bin/recv

server:
	mkdir -p $@

server/cgi-bin:
	mkdir -p $@

server/index.html: server-src/index.html | server
	cp $< $@

server/cgi-bin/send: server-src/send.sh | server/cgi-bin
	cp $< $@
	chmod +x $@

server/cgi-bin/watch: server-src/utils.o server-src/watcher.o server-src/watch.o | server/cgi-bin
	$(DC) $(DFLAGS) $^ -of=$@

server/cgi-bin/recv: server-src/utils.o server-src/recv.o | server/cgi-bin
	$(DC) $(DFLAGS) $^ -of=$@

%.o: %.d
	$(DC) $(DFLAGS) -c $< -of=$@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf server
	find server-src -iname '*.o' -delete

.PHONY: all clean
