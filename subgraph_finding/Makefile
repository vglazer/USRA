CC=gcc
CFLAGS=-ansi -pedantic -Wall -Werror -O3 -march=native
APPS=sub_search asub_search wsub_search reg_search ereg_search ggen wggen

all: $(APPS) graphs

sub_search: src/sub_search.c bin_dir
	$(CC) $(CFLAGS) $< -o bin/$@

asub_search: src/asub_search.c bin_dir
	$(CC) $(CFLAGS) $< -o bin/$@

wsub_search: src/wsub_search.c bin_dir
	$(CC) $(CFLAGS) $< -o bin/$@

reg_search: src/reg_search.c bin_dir
	$(CC) $(CFLAGS) $< -o bin/$@

ereg_search: src/ereg_search.c bin_dir
	$(CC) $(CFLAGS) $< -o bin/$@

ggen: src/ggen.c bin_dir
	$(CC) $(CFLAGS) $< -o bin/$@

wggen: src/wggen.c bin_dir
	$(CC) $(CCFLAGS) $< -o bin/$@

.PHONY: bin_dir
bin_dir:
	mkdir -p bin

.PHONY: graphs
graphs:
	etc/graphgen.sh

.PHONY: clean
clean:
	rm -rf bin graphs
