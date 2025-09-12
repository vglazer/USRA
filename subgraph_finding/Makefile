.PHONY: all clean

CC = gcc
CFLAGS = -ansi -pedantic -Wall -Werror -O3 -march=native
APPS = bin/sub_search bin/asub_search bin/wsub_search bin/reg_search bin/ereg_search bin/ggen bin/wggen

all: $(APPS) graphs

bin:
	mkdir -p $@

bin/sub_search: src/sub_search.c bin
	$(CC) $(CFLAGS) $< -o $@

bin/asub_search: src/asub_search.c bin
	$(CC) $(CFLAGS) $< -o $@

bin/wsub_search: src/wsub_search.c bin
	$(CC) $(CFLAGS) $< -o $@

bin/reg_search: src/reg_search.c bin
	$(CC) $(CFLAGS) $< -o $@

bin/ereg_search: src/ereg_search.c bin
	$(CC) $(CFLAGS) $< -o $@

bin/ggen: src/ggen.c bin
	$(CC) $(CFLAGS) $< -o $@

bin/wggen: src/wggen.c bin
	$(CC) $(CFLAGS) $< -o $@

graphs:
	etc/graphgen.sh

clean:
	rm -rf bin graphs
