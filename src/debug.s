%ifndef __DEBUG_S__
%define __DEBUG_S__

section .text
[BITS 16]                           ; Set to 16-bit mode.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a 16 bit register value using the BIOS.
;
; Parameters
;    [si] register - the register to print.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_r16:
  pusha                             ; Save register state.
  mov   bl, 0x0f                    ; Set the color to white on black.

  mov   dx, si                      ; Load the register value to print from si.
  mov   cx, 16                      ; Set the loop counter.
  mov   ah, 0x0e                    ; Set the bios print function.

.next:
  sub   cx, 4                       ; Determine if printing is complete.
  jb    .exit

  mov   si, dx                      ; Mask the next character in place.
  shr   si, cl                      ;
  and   si, 0x000f                  ;

  mov   al, byte [ascii_hex + si]   ; Lookup the hex ascii character.
  int   0x10                        ; Print the character to TTY.

  jmp   .next

.exit:
  mov   al, 0x0d                    ; Print a new line.
  int   0x10                        ;
  mov   al, 0x0a                    ;
  int   0x10                        ;

  popa                              ; Restore state.
  retn                              ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print a message to the screen in TTY mode.
;
; Parameters
;    [si] message - the address of the message to print.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_tty:
  pusha                             ; Save register state.
  mov   bl, 0x0f                    ; Set the color to white on black.
  mov   ah, 0x0e                    ; Set TTY write mode.

.next:
  lodsb                             ; Load next character.
  or    al, al                      ; Check for end of string (NULL).
  jz    .exit                       ;

  int   0x10                        ; Print the character and advance to the next one.
  jmp   .next                       ;

.exit:
  popa                              ; Restore state.
  retn                              ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hexidecimal ASCII lookup table.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ascii_hex:
  db "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"

%endif
