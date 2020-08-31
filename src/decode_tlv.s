;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author:  Bill Sella <bill.sella@gmail.com>
; Updated: 2020-08-30
; License: GPL 2.0
;
; Define global exports for public function calls in this module.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global  decode_tlv
section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to decode a BER encoded TLV stored in a buffer and trigger a callback
; function.
;
; Prototype
;    int decode_tlv(const char * buffer, ssize_t length, int callback(
;       const char * buffer, ssize_t length, uint8_t type, uint64_t tag
;    ));
;
; Parameters
;    (rdi) buffer   - The payload buffer to decode.
;    (rsi) length   - The length of the payload buffer.
;
;    (rdx) callback - The callback function address to call once decoded.
;       (rdi) buffer   - The value buffer.
;       (rsi) length   - The length of the value buffer.
;       (rdx) type     - The first byte of the type.
;       (rcx) tag      - The full type tag identifier.
;
; Returns the result of callback on success, or negative error code on failure.
;    -1 - Insufficient data in buffer to decode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
decode_tlv:
   mov     r8, rdx        ; Make room for callback parameters.
   xor    rcx, rcx        ; Zero the tag parameter for the callback.
   xor    rdx, rdx        ; Zero the type parameter for the callback.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Validate the length of the supplied buffer is greater than zero.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   cmp    rsi, 0          ; Determine if the supplied length is <= 0.
   jle    .e_buffer       ; Return from the call if buffer is empty.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decode the type from the buffer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   movzx  rdx, byte [rdi] ; Move the type byte of the buffer into register and
                          ; zero extend into all high order bits.
   dec    rsi             ; Decrement the buffer length.
   mov    rcx, rdx        ; Copy the first byte into the tag field.
   inc    rdi             ; Increment the buffer offset.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine if long tag encoding was used.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   and    rcx, 0x001f     ; Mask the tag component of the first byte to 0x1f.
   cmp    rcx, 0x001f     ; Compare the tag component of the first byte to 0x1f.
   jnz    .length         ; If not a long mode, jump to length decoder.
   xor    rcx, rcx        ; Zero the tag identifier.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decode the long format type tag from the buffer one byte at a time.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.t_long:
   cmp    rsi, 0
   jle    .e_buffer       ; Return from the call if buffer is empty.
   shl    rcx, 7          ; Shift the tag identifier by 7 bits.

   movzx  rbx, byte [rdi] ; Move the next long mode type tag byte into register.
   dec    rsi             ; Decrement the buffer length.
   mov    rax, rbx        ; Copy the tag byte for reading the more indicator bit.
   inc    rdi             ; Increment the buffer offset.

   and    rbx, 0x007f     ; Mask off the high order, more indicator bit.
   or     rcx, rbx        ; Merge into the tag identifier.

   and    rax, 0x0080     ; Determine if more bytes are used for encoding.
   jnz    .t_long

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decode the length from the buffer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.length:
   cmp    rsi, 0
   jle    .e_buffer       ; Return from the call if buffer is empty.

   movzx  rbx, byte [rdi] ; Move the first length byte into register.
   dec    rsi             ; Decrement the buffer length.
   mov    rax, rbx        ; Copy the tag byte for reading the mode indicator bit.
   inc    rdi             ; Increment the buffer offset.

   and    rax, 0x0080     ; Determine if more bytes are used for encoding.
   jnz    .length_long

   cmp    rsi, rbx        ; Determine if the value length puts off end.
   jle    .e_buffer       ; Insufficient data in buffer for value.

   mov    rsi, rbx        ; Set the value length.
   call   r8              ; Execute the callback function.
   retn                   ; Return to caller with callback return value (rax).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decode long mode length from the buffer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.length_long:
   xor    rax, rax        ; Zero the length;

   mov    rsi, rbx        ; Set the value length.
   call   r8              ; Execute the callback function.

   xor    rax, rax        ; Set return code to success (0).
   retn                   ; Return to caller.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return from the function call
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.e_buffer:
   mov    rax, -1         ; Set the error code for insufficient buffer data.
   retn                   ; Return to caller.
