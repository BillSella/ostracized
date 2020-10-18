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

	  callback  - The callback function to execute after decoding.
	    value   - The value buffer.
	    length  - The decoded value length.
	    type    - The data type.
	    tag     - The data type tag.
	    context - A generic context pointer.

	  context   - A generic context pointer to pass to the callback.

	Returns the result of callback on success or a negative value on error.
	  -1 - Buffer contained insufficient bytes to decode.
*/
int decode_tlv(const char * buffer, ssize_t length, int callback(const char * value, ssize_t length, uint8_t type, uint64_t tag, void * context), void * context);

/*
	Unpacks a sequence of bytes into a signed 8-bit value.

	Parameters
	  value    - The supplied buffer holding the sequence of bytes to unpack.
	  length   - The supplied buffer length.

	  type     - The TLV type.
	  tag      - The TLV tag.

	  result   - A pointer to the variable into which to write the unpacked value.

	Returns zero on success or a negative error code on failure.
	  -1 - Buffer contains too many bytes to upack into the supplied result buffer.
	  -2 - The supplied result buffer is NULL.
*/
int unpack_s08(const char * value, ssize_t length, uint8_t type, uint64_t tag, int8_t * result);

/*
	Unpacks a sequence of bytes into a signed 16-bit value.

	Parameters
	  value    - The supplied buffer holding the sequence of bytes to unpack.
	  length   - The supplied buffer length.

	  type     - The TLV type.
	  tag      - The TLV tag.

	  result   - A pointer to the variable into which to write the unpacked value.

	Returns zero on success or a negative error code on failure.
	  -1 - Buffer contains too many bytes to upack into the supplied result buffer.
	  -2 - The supplied result buffer is NULL.
*/
int unpack_s16(const char * value, ssize_t length, uint8_t type, uint64_t tag, int16_t * result);

/*
	Unpacks a sequence of bytes into a signed 32-bit value.

	Parameters
	  value    - The supplied buffer holding the sequence of bytes to unpack.
	  length   - The supplied buffer length.

	  type     - The TLV type.
	  tag      - The TLV tag.

	  result   - A pointer to the variable into which to write the unpacked value.

	Returns zero on success or a negative error code on failure.
	  -1 - Buffer contains too many bytes to upack into the supplied result buffer.
	  -2 - The supplied result buffer is NULL.
*/
int unpack_s32(const char * value, ssize_t length, uint8_t type, uint64_t tag, int32_t * result);

/*
	Unpacks a sequence of bytes into a signed 64-bit value.

	Parameters
	  value    - The supplied buffer holding the sequence of bytes to unpack.
	  length   - The supplied buffer length.

	  type     - The TLV type.
	  tag      - The TLV tag.

	  result   - A pointer to the variable into which to write the unpacked value.

	Returns zero on success or a negative error code on failure.
	  -1 - Buffer contains too many bytes to upack into the supplied result buffer.
	  -2 - The supplied result buffer is NULL.
*/
int unpack_s64(const char * value, ssize_t length, uint8_t type, uint64_t tag, int64_t * result);

/*
	Unpacks a sequence of bytes into a unsigned 8-bit value.

	Parameters
	  value    - The supplied buffer holding the sequence of bytes to unpack.
	  length   - The supplied buffer length.

	  type     - The TLV type.
	  tag      - The TLV tag.

	  result   - A pointer to the variable into which to write the unpacked value.

	Returns zero on success or a negative error code on failure.
	  -1 - Buffer contains too many bytes to upack into the supplied result buffer.
	  -2 - The supplied result buffer is NULL.
*/
int unpack_u08(const char * value, ssize_t length, uint8_t type, uint64_t tag, uint8_t * result);

/*
	Unpacks a sequence of bytes into a unsigned 16-bit value.

	Parameters
	  value    - The supplied buffer holding the sequence of bytes to unpack.
	  length   - The supplied buffer length.

	  type     - The TLV type.
	  tag      - The TLV tag.

	  result   - A pointer to the variable into which to write the unpacked value.

	Returns zero on success or a negative error code on failure.
	  -1 - Buffer contains too many bytes to upack into the supplied result buffer.
	  -2 - The supplied result buffer is NULL.
*/
int unpack_u16(const char * value, ssize_t length, uint8_t type, uint64_t tag, uint16_t * result);

/*
	Unpacks a sequence of bytes into a unsigned 32-bit value.

	Parameters
	  value    - The supplied buffer holding the sequence of bytes to unpack.
	  length   - The supplied buffer length.

	  type     - The TLV type.
	  tag      - The TLV tag.

	  result   - A pointer to the variable into which to write the unpacked value.

	Returns zero on success or a negative error code on failure.
	  -1 - Buffer contains too many bytes to upack into the supplied result buffer.
	  -2 - The supplied result buffer is NULL.
*/
int unpack_u32(const char * value, ssize_t length, uint8_t type, uint64_t tag, uint32_t * result);

/*
	Unpacks a sequence of bytes into a unsigned 64-bit value.

	Parameters
	  value    - The supplied buffer holding the sequence of bytes to unpack.
	  length   - The supplied buffer length.

	  type     - The TLV type.
	  tag      - The TLV tag.

	  result   - A pointer to the variable into which to write the unpacked value.

	Returns zero on success or a negative error code on failure.
	  -1 - Buffer contains too many bytes to upack into the supplied result buffer.
	  -2 - The supplied result buffer is NULL.
*/
int unpack_u64(const char * value, ssize_t length, uint8_t type, uint64_t tag, uint64_t * result);

#endif

