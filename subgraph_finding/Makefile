.PHONY: all clean graphs

CC = gcc
CFLAGS = -ansi -pedantic -Wall -Werror -O3 -march=native
APPS = bin/sub_search bin/asub_search bin/wsub_search bin/reg_search bin/ereg_search bin/ggen bin/wggen

all: $(APPS) graphs

bin:
	mkdir -p $@

bin/sub_search: src/sub_search.c bin
	$(CC) $(CFLAGS) $< -o $@
sub_search: bin/sub_search

bin/asub_search: src/asub_search.c bin
	$(CC) $(CFLAGS) $< -o $@
asub_search: bin/asub_search

bin/wsub_search: src/wsub_search.c bin
	$(CC) $(CFLAGS) $< -o $@
wsub_search: bin/wsub_search

bin/reg_search: src/reg_search.c bin
	$(CC) $(CFLAGS) $< -o $@
reg_search: bin/reg_search

bin/ereg_search: src/ereg_search.c bin
	$(CC) $(CFLAGS) $< -o $@
ereg_search: bin/ereg_search

bin/ggen: src/ggen.c bin
	$(CC) $(CFLAGS) $< -o $@
ggen: bin/ggen

bin/wggen: src/wggen.c bin
	$(CC) $(CFLAGS) $< -o $@
wggen: bin/wggen

graphs: bin/ggen bin/wggen
	etc/graphgen.sh

clean:
	rm -rf bin graphs
