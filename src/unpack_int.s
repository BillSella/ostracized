;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author:  Bill Sella <bill.sella@gmail.com>
; Updated: 2020-08-30
; License: GPL 2.0
;
; Define global exports for public function calls in this module.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global  unpack_s08
global  unpack_s16
global  unpack_s32
global  unpack_s64
global  unpack_u08
global  unpack_u16
global  unpack_u32
global  unpack_u64
section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions to unpack a sequence of bytes into integers of various lengths.
;
; Prototypes
;    int unpack_s08(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, int8_t * result
;    );
;    int unpack_s16(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, int16_t * result
;    );
;    int unpack_s32(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, int32_t * result
;    );
;    int unpack_s64(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, int64_t * result
;    );
;    int unpack_u08(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, uint8_t * result
;    );
;    int unpack_u16(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, uint16_t * result
;    );
;    int unpack_u32(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, uint32_t * result
;    );
;    int unpack_u64(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, uint64_t * result
;    );
;
; Parameters
;    (rdi) value    - The sequence of bytes to upack.
;    (rsi) length   - The length of the value buffer.
;
;    (rdx) type     - The first byte of the BER encoded TLV type field.
;    (rcx) tag      - The tag field of the TLV type.
;     (r8) result   - A pointer to the integer to unpack the value into.
;
; Returns zero on success or a negative error code on failure.
;    -1 - Insufficient data in buffer to decode.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
unpack_s08:
unpack_u08:
   cmp    rsi,   1        ; Ensure the length is not more than 8 bits.
   js     error.e_length  ;

   mov    rdx,  exit.i08  ; Set the function exit point and jump to the main
   jmp    unpack_int      ; code block.

unpack_s16:
unpack_u16:
   cmp    rsi,   2        ; Ensure the length is not more than 16 bits.
   js     error.e_length  ;

   mov    rdx,  exit.i16  ; Set the function exit point and jump to the main
   jmp    unpack_int      ; code block.

unpack_s32:
unpack_u32:
   cmp    rsi,   4        ; Ensure the length is not more than 32 bits.
   js     error.e_length  ;

   mov    rdx,  exit.i32  ; Set the function exit point and jump to the main
   jmp    unpack_int      ; code block.

unpack_s64:
unpack_u64:
   cmp    rsi,   8        ; Ensure the length is not more than 64 bits.
   js     error.e_length  ;

   mov    rdx,  exit.i64  ; Set the function exit point and jump to the main

unpack_int:
   or      r8,  r8        ; Ensure the supplied value is not NULL.
   jz     error.e_result  ;

   add    rdi, rsi        ; Advance to the last byte.
   xor    rax, rax        ; Zero the result value.

   .loop:
   cmp    rdi, rsi        ;
   jz     exit            ; Determine if all bytes are copied.

   shl    rax, 8          ; Shift the next byte into the result.

   mov     al, [rdi]      ; Copy the byte and loop.
   dec    rdi             ; Advanced to next byte.

   jmp    .loop           ;

exit:
   jmp    rdx             ; Jump to the appropriate exit block.

   .i08:
   mov   [r8], al         ;
   retn                   ;

   .i16:
   mov   [r8], ax         ;
   retn                   ;

   .i32:
   mov   [r8], eax        ;
   retn                   ;

   .i64:
   mov   [r8], rax        ;
   retn                   ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Error condition table.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
error:
   .e_length:
   mov    rax, -1         ; Set the error code for insufficient output length.
   retn                   ; Return to caller.

   .e_result:
   mov    rax, -2         ; Set the error code for NULL result pointer.
   retn                   ; Return to caller.
