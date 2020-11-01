%ifndef __MACRO_S__
%define __MACRO_S__

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log an informational message to the terminal.
;
; Parameters
;   1 - The message to log (80 characters maximum).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro INFO 1
  push edi
  jmp  %%code

  %%data:
    db %1, 0
  %%code:

  mov  edi, %%data
  call term_info
  pop  edi
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log an informational message to the terminal.
;
; Parameters
;   1 - The message to log (80 characters maximum).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro WARN 1
  push edi
  jmp  %%code

  %%data:
    db %1, 0
  %%code:

  mov  edi, %%data
  call term_warn
  pop  edi
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Log an informational message to the terminal.
;
; Parameters
;   1 - The message to log (80 characters maximum).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro DBUG 1
  push edi
  jmp  %%code

  %%data:
    db %1, 0
  %%code:

  mov  edi, %%data
  call term_dbug
  pop  edi
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cause a breakpoint to trigger within bochs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro BREAK 0
	xchg bx, bx
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a TTY message using the BIOS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro PRINT_TTY 1
	mov  si, %1          ; Load the message to display.
   call print_tty       ; Call the function.
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a register to TTY using the BIOS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro PRINT_R16 1
  mov   si, %1          ; Load the register to display.
  call  print_r16       ; Call the function.
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a TTY message using the BIOS and halt the machine.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%macro TERMINATE 1
   PRINT_TTY(%1)        ; Print the error message.
   jmp  shutdown        ; Halt the machine.
%endmacro

%endif
