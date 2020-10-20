;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author:  Bill Sella <bill.sella@gmail.com>
; Updated: 2020-10-20
; License: GPL 2.0
;
; Define global exports for public function calls in this module.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global  unpack_str
section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions to unpack a sequence of bytes into a string buffer.
;
; Prototypes
;    struct string_t {
;       uint16_t length;
;       char     buffer[0];
;    }
;
;    int unpack_str(const char * value, ssize_t length, uint8_t type,
;       uint64_t tag, string_t * result
;    );
;
; Parameters
;    (rdi) value    - The sequence of bytes to upack.
;    (rsi) length   - The length of the value buffer.
;
;    (rdx) type     - The first byte of the BER encoded TLV type field.
;    (rcx) tag      - The tag field of the TLV type.
;     (r8) string   - A pointer to the string to unpack the value into.
;
; Returns zero on success or a negative error code on failure.
;    -1 - Insufficient space in output buffer to decode.
;    -2 - Invalid output buffer supplied (NULL).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
unpack_str:
   mov    rcx, 1          ; Initialize the output length requirement.

   or      r8,  r8        ; Ensure the supplied output buffer is not NULL.
   jz     error.e_result  ;

   add     cx, word [r8]  ; Obtain the length of the output buffer and ensure
                          ; it is large enough to hold the string and a null
   cmp    rsi, rcx        ; terminator.
   js     error.e_length  ;

   add    rsi, rdi        ; Set the end of string marker.
   add     r8, 2          ; Advance pointer past length to output buffer.

   .loop:
   cmp    rdi, rsi        ; Determine if all bytes were copied.
   jz     exit            ;

   mov     al, [rdi]      ; Copy the byte.
   mov   [r8], al         ;

   inc    rdi             ; Advance to the next byte.
   inc     r8             ;
   jmp    .loop           ;

exit:
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
