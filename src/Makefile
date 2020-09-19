SOURCE=main.c test.c test.h decode_tlv.h decode_tlv.s
OBJECT=$(patsubst %.c, %.o, $(filter %.c, $(SOURCE))) $(patsubst %.s, %.o, $(filter %.s, $(SOURCE)))
TARGET=test

CFLAGS=-O0 -ggdb
LFLAGS=

ASM=nasm
CC=gcc

.PHONY: clean all

%.o : %.s
	$(ASM) -g -felf64 -o $@ $<

%.o : %.c
	$(CC) -c $(CFLAGS) -o $@ $<

$(TARGET): $(OBJECT)
	$(CC) -o $@ $^

boot: boot.s
	$(ASM) -g -fbin -o boot.bin $<

all: $(TARGET) boot

run: boot
	qemu-system-x86_64 boot.bin

clean:
	rm -f $(TARGET)
	rm -f *.bin
	rm -f *.o
