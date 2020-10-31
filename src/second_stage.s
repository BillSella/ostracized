%ifndef __SECOND_STAGE_S__
%define __SECOND_STAGE_S__

%macro BREAK 0
	xchg bx, bx
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The second stage bootloader for ostracized.
;
; Author:  Bill Sella <bill.sella@gmail.com>
; License: GPL 2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[BITS 32]                ; Set to 32-bit mode.

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The protected mode jump destination.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
second_stage:
  ; Set all segment registers after the jump to protected mode.
  mov   ax, 0x0010
  mov   ds, ax
  mov   es, ax
  mov   ss, ax
  mov   sp, 0x0000

  mov  edi, test
  BREAK
  call  term_info
  BREAK
  call  term_warn
  BREAK
  call  term_dbug
  BREAK

  mov  esi, 0
  mov  edx, 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message to the terminal as either a debug message (blue), warning
; message (red), or informational message (white).
;
; Invalidates
;   eax, ecx
;
; Parameters
;   edi - The message to log to the screen (80 characters maximum).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
term_dbug:
  mov  ah, 0x10                        ; Set the text color to blue on black.
  jmp  term_text                       ;

term_warn:
  mov  ah, 0xc0                        ; Set the text color to red on black.
  jmp  term_text                       ;

term_info:
  mov  ah, 0x70                        ; Set the text color to grey on black.
  jmp  term_text                       ;

term_text:
  mov ecx, 0x000b8000                  ; Set the base video memory address.

.loop:
  cmp ecx, 0x000b8000 + (24 * 80 * 2)  ; Determine if the screen scrolling is
  jz  .line                            ; completed yet.

  mov   eax, dword [ecx + 160]         ; Move data from next line over current.
  mov [ecx], eax                       ;
  add  ecx , 4                         ;
  jmp .loop

.line:
  cmp ecx, 0x000b8000 + (25 * 80 * 2)  ; Determine if the line is off the
  jz  .exit                            ; screen.

  mov al, byte [edi]                   ; Determine if the end of string marker
  cmp al, 0x00                         ; was hit (NULL).
  jz  .zero                            ;
  inc edi                              ;

  mov [ecx], ax                        ; Write the character to the screen.
  add ecx, 2                           ;
  jmp .line                            ;

.zero:
  cmp ecx, 0x000b8000 + (25 * 80 * 2)  ; Determine if the line is off the
  jz  .exit                            ; screen.

  mov [ecx], ax                        ; Write the empty character.
  add ecx, 2                           ;
  jmp .zero                            ;

.exit
  ret                                  ; Logging completed.

test:
	db 'test message', 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The interrupt descriptor table.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
idt:
  times 2048 db 0       ; Zero the interrupt descriptor table.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zero pad the image to 16KB and sign.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times (512 * 32) - 4 - ($-$$) db 0
db 0xb5, 0x00, 0x1a, 0xe1

%endif
