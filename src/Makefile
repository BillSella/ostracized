SOURCE=test.c decode_tlv.h decode_tlv.a
OBJECT=$(patsubst %.c, %.o, $(filter %.c, $(SOURCE))) $(patsubst %.a, %.o, $(filter %.a, $(SOURCE)))
TARGET=test

CFLAGS=-O0
LFLAGS=

ASM=nasm
CC=gcc

.PHONY: clean all

%.o : %.a
	$(ASM) -felf64 -o $@ $<

%.o : %.c
	$(CC) -c $(CFLAGS) -o $@ $<

$(TARGET): $(OBJECT)
	$(CC) -o $@ $^

all: $(TARGET)

clean:
	rm -f $(TARGET)
	rm -f *.o
