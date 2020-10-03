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

all: boot $(TARGET)
	qemu-system-x86_64 -drive file=ostracized.bin,format=raw,index=0,media=disk

boot: boot.s second_stage.s
	$(ASM) -g -fbin -o boot.bin boot.s
	$(ASM) -g -fbin -o second_stage.bin second_stage.s

	cat boot.bin > ostracized.bin
	cat second_stage.bin >> ostracized.bin

$(TARGET): $(OBJECT)
	$(CC) -o $@ $^

clean:
	rm -f $(TARGET)
	rm -f *.bin
	rm -f *.o
