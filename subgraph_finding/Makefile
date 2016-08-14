CC=gcc
CFLAGS=-ansi -pedantic -Wall -O3
APPS=sub_search asub_search wsub_search reg_search ereg_search ggen wggen

all: $(APPS)

sub_search: src/sub_search.c
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o bin/$@

asub_search: src/asub_search.c
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o bin/$@

wsub_search: src/wsub_search.c
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o bin/$@

reg_search: src/reg_search.c
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o bin/$@

ereg_search: src/ereg_search.c
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o bin/$@

ggen: src/ggen.c
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o bin/$@

wggen: src/wggen.c
	mkdir -p bin
	$(CC) $(CCFLAGS) $< -o bin/$@

clean:
	rm -rf bin
