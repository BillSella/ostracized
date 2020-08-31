SOURCE=test.c decode_tlv.h decode_tlv.s
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

all: $(TARGET)

clean:
	rm -f $(TARGET)
	rm -f *.o
