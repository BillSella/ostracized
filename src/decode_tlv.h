/*
	Author:  Bill Sella <bill.sella@gmail.com>
	Updated: 2020-08-30
	License: GPL 2.0
*/
#ifndef __decode_tlv_h__
#define __decode_tlv_h__

#include <stdint.h>
#include <unistd.h>

/*
	Decode a BER encoded TLV.

	Parameters
	  buffer   - The supplied buffer holding the TLV to decode.
	  length   - The supplied buffer length.

	  callback - The callback function to execute after decoding.
	    value  - The value buffer.
	    length - The decoded value length.
	    type   - The data type.
	    tag    - The data type tag.

	Returns the result of callback on success or a negative value on error.
	  -1 - Buffer contained insufficient bytes to decode.
*/
int decode_tlv(const char * buffer, ssize_t length, int callback(const char * value, ssize_t length, uint8_t type, uint64_t tag));

#endif
