SOURCES := $(wildcard *.c)
BINARIES := $(SOURCES:%.c=%)
CC=gcc

all: aslr _bof1 _bof2 _bof3 _bof4 _bof5 _bof6 _bof7 _bof8 _bof9 _bof10 _bof11
aslr: aslr.c
	$(CC) $< -o $@
_bof1: _bof1.c
	$(CC) -fno-stack-protector $< -o $@
_bof2: _bof2.c
	$(CC) -fno-stack-protector $< -o $@
_bof3: _bof3.c
	$(CC) -fno-stack-protector $< -o $@
_bof4: _bof4.c
	$(CC) -fno-stack-protector $< -o $@
_bof5: _bof5.c
	$(CC) -fno-stack-protector $< -o $@
_bof6: _bof6.c
	$(CC) -z execstack -fno-stack-protector $< -o $@
_bof7: _bof7.c
	$(CC) -z execstack -fno-stack-protector $< -o $@
_bof8: _bof8.c
	$(CC) -z execstack -fno-stack-protector $< -o $@
_bof9: _bof9.c older-glibc 
	make -C older-glibc
	cp older-glibc/compile_older_glibc.sh .
	./compile_older_glibc.sh 2.23 $< $@ -fno-stack-protector
_bof10: _bof10.c
	./compile_older_glibc.sh 2.23 $< $@ -fno-stack-protector
_bof11: _bof11.c 
	$(CC) -m32 -z execstack -fno-stack-protector $< -o $@
_bof12: _bof12.c 
	./compile_older_glibc.sh 2.23 $< $@ -fno-stack-protector
older-glibc:
	git clone https://github.com/ccss17/older-glibc
clean:
	rm -f $(BINARIES) 
	rm -rf older-glibc 2.23 compile_older_glibc.sh
