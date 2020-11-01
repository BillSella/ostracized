%ifndef __BOOT_S__
%define __BOOT_S__

%include "macro.s"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A simple first stage bootloader which loads the second stage bootloader and
; jumps to protected mode.
;
; Author:  Bill Sella <bill.sella@gmail.com>
; License: GPL 2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[ORG  0x7c00]           ; Start output of bits at offset 0x7c00.
[BITS 16]               ; Set to 16-bit mode.

section .text

global  ostracized      ; The bootloader execution start point.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bootloader entry point.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ostracized:
  xor  eax, eax         ; Set data segment to start of binary.
  mov   ds, ax          ;
  mov   ax, 0x0bdd      ; Set the stack segment past the bootloader.
  mov   ss, ax          ;
  mov   sp, 0x0000      ;

  call load_bootloader  ; Load the full bootloader image from disk.

  call check_cpuid      ; Validate the CPUID instruction is available.
  call check_flags      ; Validate this is a 64 bit capable processor.

  call protected_mode   ; Switch to protected mode.

shutdown:
  PRINT_TTY(halt)       ; Print the halt message to the screen.

  cli                   ; Disable interrupts.
  hlt                   ; Halt the machine.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load all second stage sectors to pull the entire 16KB boot loader into RAM.
;
; Parameters
;   [dl] device - The device number to read second stage from.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_bootloader:
  mov  bx, 0x7e00       ; Set the read destination address.

  mov  ch, 0x00         ; Set the cylinder number.
  mov  cl, 0x02         ; Set the start sector for the read.
  mov  dh, 0x00         ; Set the head to 0.

.retry:
  mov  ah, 0x02         ; BIOS disk read sectors function.
  mov  al, 0x1f         ; Number of sectors to read.

  int  0x13             ; Read from the disk.

  cmp  ax, 0x001f       ; Retry the read if failure, else return.
  jnz  .retry           ;

  retn                  ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine if the CPU supports the CPUID instruction. This can be detected by
; attempting to flip the the id bit in the flags register.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_cpuid:
  pushfd                ; Copy the flags into eax and ecx.
  pop   eax             ;
  mov   ecx, eax        ;

  xor   eax, 1 << 21    ; Toggle the id bit.

  push  eax             ; Push eax back on the stack.
  popfd

  pushfd                ; Copy flags back into eax (with flipped bit).
  pop   eax             ;

  push  ecx             ; Restore flags from original version.
  popfd

  cmp   eax, ecx        ; Determine if the bit was flipped (CPUID available).
  je    .not_available  ; If registers match, the instruction is not available.

  retn                  ;

.not_available:
  TERMINATE(fail_cpuid) ; Halt the machine.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine if the CPU supports all required CPU features.
; - 64 Bit Long Mode
; - VMX Instruction Set
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_flags:
  mov   eax, 0x80000000 ; Call the CPUID instruction.
  cpuid                 ;

  cmp   eax, 0x80000001 ; Check CPU identifier to determine if it supports the
  jb    .fail_64bit     ; extended information query.

  mov   eax, 0x80000001 ; Call the CPUID instruction for extended information.
  cpuid                 ;

  test  edx, 1 << 29    ; Check the long mode flag.
  jz    .fail_64bit     ;

  retn                  ;

.fail_64bit:
  TERMINATE(fail_64bit) ; Halt the machine.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enter protected mode on the processor and jump to the second stage boot
; loader.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
protected_mode:
  cli                   ; Disable interrupts.
  lgdt [gdt_handle]     ; Load the global descriptor table.

  mov   bx, 0x00        ; Select descriptor 1.
  mov   ds, bx          ;

  mov  eax, cr0         ; Set the protection bit in control register 0.
  or    al, 1           ;
  mov  cr0, eax         ;

  jmp  08h:0x7e00       ; Perform a far jump to the second stage bootloader.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Message table for boot display.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
halt:
  db "System Halted", 0x0d, 0x0a
  db 0

fail_cpuid:
  db "CPU Not Supported", 0x0d, 0x0a
  db 0

fail_64bit:
  db "CPU Not 64 Bit Long Mode Capable", 0x0d, 0x0a
  db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The global descriptor table.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gdt:
  dq 0x0000000000000000 ; The null segment.

.code:
  dw 0xffff             ; The table entry limit 0:15.
  dw 0x0000             ; The table entry base 0:15.
  db 0x00               ; The table entry base 16:23.
  db 0x9a               ; The table entry access byte: 1 00 1 1 0 1 0.
                        ;   Present:          1 (Set)
                        ;   Privelege Level: 00 (Ring 0)
                        ;   Segment Type:     1 (Code)
                        ;   Executable:       1 (True)
                        ;   Direction:        0 (Only Callable from Ring 0)
                        ;   Readable:         1 (Allowed / Read-Only)
                        ;   Acessed Bit:      0 (Default)
  db 0xcf               ; The table entry limit 16:19.
                        ; The table entry flags: 1 1 1 0
                        ;   Granularity:      0 (Byte Granularity)
                        ;   Size:             1 (Protected Mode)
                        ;   Long Mode:        0 (Disabled)
                        ;   Rserved:          0 (Zero)
  db 0x00               ; The Table entry base 24:31.

.data:
  dw 0xffff             ; The table entry limit 0:15.
  dw 0x0000             ; The table entry base 0:15.
  db 0x00               ; The table entry base 16:23.
  db 0x92               ; The table entry access byte: 1 00 0 0 0 1 0.
                        ;   Present:          1 (Set)
                        ;   Privelege Level: 00 (Ring 0)
                        ;   Segment Type:     0 (Data)
                        ;   Executable:       0 (False)
                        ;   Direction:        0 (Only Accessable from Ring 0)
                        ;   Writable:         1 (Allowed)
                        ;   Acessed Bit:      0 (Default)
  db 0xcf               ; The table entry limit 16:19.
                        ; The table entry flags: 1 1 1 0
                        ;   Granularity:      0 (Byte Granularity)
                        ;   Size:             1 (Protected Mode)
                        ;   Long Mode:        0 (Disabled)
                        ;   Rserved:          0 (Zero)
  db 0x00               ; The Table entry base 24:31.

.task:

gdt_handle:
  dw gdt_handle - gdt   ; The table length.
  dd gdt                ; The table location.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Include debug functons.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include "debug.s"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zero pad the boot sector and set the bootloader signature.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 510 - ($-$$) db 0 ; Zero pad the binary to 512 bytes and add bootsector
dw    0xaa55            ; marker to end of file.

%include "second_stage.s"
%endif
