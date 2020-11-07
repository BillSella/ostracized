SOURCE=main.c test.c test.h decode_tlv.h decode_tlv.s unpack_int.s unpack_str.s
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
#	qemu-system-x86_64 -drive file=ostracized.bin,format=raw,index=0,media=disk
	dd if=/dev/zero of=floppy.img bs=512 count=2880
	dd if=ostracized.bin of=floppy.img bs=512 conv=notrunc
	rm -f emptydisk.img.lock
	bochs -q -f bochsrc

boot: boot.s second_stage.s debug.s log.s
	$(ASM) -g -fbin -o ostracized.bin boot.s

$(TARGET): $(OBJECT)
	$(CC) -o $@ $^

clean:
	rm -f $(TARGET)
	rm -f *.img
	rm -f *.bin
	rm -f *.o
