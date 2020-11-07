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
; Scroll the terminal screen by one line leaving an empty line on the bottom.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
term_next:
  push ecx                             ; Store register state.
  push eax                             ;
  mov  ecx, 0x000b8000                 ; Set the base video memory address.

.loop:
  cmp  ecx, 0x000b8000 + (24 * 80 * 2) ; Determine if the screen scrolling is
  jz   .wipe                           ; completed yet.

  mov  eax, dword [ecx + 160]          ; Move data from next line over current.
  mov  [ecx], eax                      ;
  add  ecx, 4                          ;
  jmp  .loop                           ;

.wipe:
  cmp  ecx, 0x000b8000 + (25 * 80 * 2) ; Determine if the line is blank yet.
  jz   .exit                           ;

  mov  [ecx], dword 0x00000000         ;
  add  ecx, 4                          ;
  jmp  .wipe

.exit:
  pop  eax                             ; Restore register state and return.
  pop  ecx                             ;
  retn                                 ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print a line to the terminal screen after scrolling.
;
; Parameters
;   edi - A pointer to the text line to print (null terminated up to 80
;         characters maximum).
;   esi - The color of the text to print.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
term_line:
  push ecx                             ; Push register state on the stack.
  push eax                             ;

  call term_next                       ; Scroll to the next line.
  mov  ecx, 0x000b8f00                 ; Set the output line pointer.
  shl  esi, 8                          ; Shift the color into the high bits.

.line:
  mov eax, esi                         ; Set the line color.

  cmp ecx, 0x000b8fa0                  ; Determine if the line is off the
  jz  .exit                            ; screen.

  mov al, byte [edi]                   ; Determine if the end of string marker
  cmp al, 0x00                         ; was hit (NULL).
  jz  .exit                            ;

  inc edi                              ; Increment to next character.

.char:
  mov [ecx], ax                        ; Write the character to the screen.
  add ecx, 2                           ;
  jmp .line                            ;

.exit:
  pop  eax                             ; Restore registers and return from
  pop  ecx                             ; function call.
  ret                                  ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print a single register to the terminal screen in hex (32-bit).
;
; Parameters
;   edi - The name of the register to print (2 characters with color code).
;   esi - The register value to print.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
term_r32s:
  push  ecx                            ; Save register state.

.name:
  call  term_next                      ; Scroll the buffer to the next line.

  mov     ecx, 0x000b8f00              ; Print the register name.
  mov   [ecx], edi                     ;
  add     ecx, 4                       ;
  mov      di, 0x0e3a                  ;
  mov   [ecx], di                      ;
  add     ecx, 18                      ;

.loop:
  cmp     ecx, 0x000b8f06              ; Check the loop counter for exit.
  jz     .exit                         ;

  mov      di,  si                     ; Move the next nibble into the buffer.
  and      di, 0x000f                  ; Determine if this character is a hex
  cmp      di, 0x000a                  ; alpha or number.
  js     .mask                         ;

  add      di, 0x0027                  ; Add ('a' - '9') to the ascii code.

.mask:
  add      di, 0x0730                  ; Set color mask and add '0' to ascii.

  mov   [ecx], di                      ; Write the bytes to the screen and move
  sub     ecx, 2                       ; to the next output offset.

  shr     esi, 4                       ; Shift to next character and advance.
  jmp   .loop                          ;

.exit:
   pop  ecx                            ; Restore register state and return.
   retn                                ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print all registers to the terminal in hex (32-bit).
;
; ax: 00 00 00 00
; bx: 00 00 00 00
; cx: 00 00 00 00
; dx: 00 00 00 00
; si: 00 00 00 00
; bp: 00 00 00 00
; di: 00 00 00 00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
term_r32a:
  push  edi                            ; Save register state.
  push  esi                            ;

  push  edi                            ; Push register values for printing.
  push  ebp                            ;
  push  esi                            ;
  push  edx                            ;
  push  ecx                            ;
  push  ebx                            ;
  push  eax                            ;

  mov  edi, 0x0e780e61                 ; Print the ax register.
  pop  esi                             ;
  call term_r32s                       ;

  mov  edi, 0x0e780e62                 ; Print the bx register.
  pop  esi                             ;
  call term_r32s                       ;

  mov  edi, 0x0e780e63                 ; Print the cx register.
  pop  esi                             ;
  call term_r32s                       ;

  mov  edi, 0x0e780e64                 ; Print the dx register.
  pop  esi                             ;
  call term_r32s                       ;

  mov  edi, 0x0e690e73                 ; Print the si register.
  pop  esi                             ;
  call term_r32s                       ;

  mov  edi, 0x0e700e62                 ; Print the bp register.
  pop  esi                             ;
  call term_r32s                       ;

  mov  edi, 0x0e690e64                 ; Print the di register.
  pop  esi                             ;
  call term_r32s                       ;

.exit:
  pop  esi                             ; Restore register state and return.
  pop  edi                             ;
  retn                                 ;

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
