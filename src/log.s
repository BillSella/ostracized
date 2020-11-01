%ifndef __LOG_S__
%define __LOG_S__

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A collection of logging functions.
;
; Author:  Bill Sella <bill.sella@gmail.com>
; License: GPL 2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[BITS 32]                ; Set to 32-bit mode.

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log a message to the terminal as either a debug message (yellow), warning
; message (red), or informational message (white). Before writing the message to
; the bottom of the screen, first scroll the page up one line.
;
; Parameters
;   edi - The message to log to the screen (80 characters maximum).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
term_dbug:
  push edx                             ; Store the color as yellow on black and
  mov  dx, 0x0e00                      ; then jump to the main function block.
  jmp  term_text                       ;

term_warn:
  push edx                             ; Store the color as red on black and
  mov  dx, 0x0c00                      ; then jump to the main function block.
  jmp  term_text                       ;

term_info:
  push edx                             ; Store the color as grey on black and
  mov  dx, 0x0700                      ; then jump to the main function block.
  jmp  term_text                       ;

term_bold:
  push edx                             ; Store the color as green on black and
  mov  dx, 0x0200                      ; then jump to the main function block.
  jmp  term_text                       ;

term_text:
  push ecx                             ; Store register state.
  push eax                             ;

  mov ecx, 0x000b8000                  ; Set the base video memory address.

.loop:
  cmp ecx, 0x000b8000 + (24 * 80 * 2)  ; Determine if the screen scrolling is
  jz  .line                            ; completed yet.

  mov   eax, dword [ecx + 160]         ; Move data from next line over current.
  mov [ecx], eax                       ;
  add  ecx , 4                         ;
  jmp .loop

.line:
  mov eax, edx                         ; Set the line color.

  cmp ecx, 0x000b8000 + (25 * 80 * 2)  ; Determine if the line is off the
  jz  .exit                            ; screen.

  mov al, byte [edi]                   ; Determine if the end of string marker
  cmp al, 0x00                         ; was hit (NULL).
  jz  .char                            ;

  inc edi                              ; Increment to next character.

.char:
  mov [ecx], ax                        ; Write the character to the screen.
  add ecx, 2                           ;
  jmp .line                            ;

.exit:
  pop  eax                             ; Restore registers and return from
  pop  ecx                             ; function call.
  pop  edx                             ;
  ret                                  ; 

%endif
