#include "decode_tlv.h"

#include <stdio.h>
#include <string.h>

static int callback(const char * value, ssize_t length, uint8_t type, uint64_t tag) {
	ssize_t i;

	printf("Type:   %02x\n", (unsigned char)(type));
	printf("Tag:    %lu\n", tag);
	printf("Length: %ld\n", length);
	printf("Value:  ");

	for (i = 0; i < length; i++) {
		printf("%02x ", (unsigned char)(value[i]));
	}
	printf("\n");

	return 0;
}

int main(int argc, char ** argv) {
	char buffer[4096];
	int  i, j, n, o;

	for (i = 1; i < argc; i++) {
		n = strlen(argv[i]);
		o = 0;

		for (j = 0; j < n; j++) {
			switch (argv[i][j]) {
				case ' ':
					break;

				case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
					buffer[o >> 1] = (o & 0x01) ? (buffer[o >> 1] | (argv[i][j] - '0')) : ((argv[i][j] - '0') << 4);
					o += 1;
					break;

				case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
					buffer[o >> 1] = (o & 0x01) ? (buffer[o >> 1] | (10 + argv[i][j] - 'A')) : ((10 + argv[i][j] - 'A') << 4);
					o += 1;
					break;

				case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
					buffer[o >> 1] = (o & 0x01) ? (buffer[o >> 1] | (10 + argv[i][j] - 'a')) : ((10 + argv[i][j] - 'a') << 4);
					o += 1;
					break;

				default:
					printf("test %d: invalid character '%c'\n", i, argv[i][j]);
					return -1;
			}
		}
		printf("test %d: %s\n", i, argv[i]);
		printf(" + %s\n", decode_tlv(buffer, 1 + (o >> 1), callback) ? "FAIL" : "PASS");
	}
	return 0;
}
