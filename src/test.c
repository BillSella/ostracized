#include "decode_tlv.h"

#include <sys/time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static int callback(const char * value, ssize_t length, uint8_t type, uint64_t tag) {
	return 0;
}

static int parse(char * buffer, int length, const char * string) {
	int n = strlen(string);
	int i = 0;
	int o = 0;

	for (i = 0; i < n; i++) {
		if (i < length) {
			switch (string[i]) {
				case ' ':
					break;
	
				case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
					buffer[o >> 1] = (o & 0x01) ? (buffer[o >> 1] | (string[i] - '0')) : ((string[i] - '0') << 4);
					o += 1;
					break;
	
				case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
					buffer[o >> 1] = (o & 0x01) ? (buffer[o >> 1] | (10 + string[i] - 'A')) : ((10 + string[i] - 'A') << 4);
					o += 1;
					break;
	
				case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
					buffer[o >> 1] = (o & 0x01) ? (buffer[o >> 1] | (10 + string[i] - 'a')) : ((10 + string[i] - 'a') << 4);
					o += 1;
					break;
	
				default:
					return -1;
			}
		} else {
			return -1;
		}
	}
	return 1 + (o >> 1);
}

int test(const char * description, const char * encoded) {
	char buffer[4096];
	int  n;

	if ((n = parse(buffer, sizeof(buffer), encoded)) > 0) {
		return decode_tlv(buffer, n, callback);
	}
	printf("INVALID TEST: %s (%s)\n", description, encoded);
	abort();
}
