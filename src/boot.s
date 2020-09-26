;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author:  Bill Sella <bill.sella@gmail.com>
; Updated: 2020-09-12
; License: GPL 2.0
;
; Define global exports for public function calls in this module.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
global  ostracized      ; The bootloader execution start point.

[ORG  0x7c00]            ; Start output of bits at offset 0x7c00.
[BITS 16]                ; Set to 16-bit mode.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Boots the operating system.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init:
  xor  eax, eax         ;
  mov   dx, ax          ; Set data segment to start of binary.
  mov   ss, ax          ; Set stack segment to start of binary.
  mov   sp, 0x8000      ; Set stack pointer past code.

ostracized:
  mov  si, boot_message ; Load the boot message and print to screen.
  call print_tty        ;

  call check_cpuid      ; Validate the CPUID instruction is available.
  call check_flags      ; Validate this is a 64 bit capable processor.

  call protected_mode   ; Switch to protected mode.

shutdown:
  mov  si, halt_message ; Load the halt message and print to screen.
  call print_tty        ;

  cli                   ; Disable interrupts.
  hlt                   ; Halt the machine.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enter protected mode on the processor and jump to the second stage boot
; loader.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
protected_mode:
  mov   si, mode_switch ; Print the protected mode message.
  call print_tty        ;

  cli                   ; Disable interrupts.
  lgdt [gdt_handle]     ; Load the global descriptor table.

  mov  eax, cr0         ; Set the protection bit in control register 0.
  or    al, 1           ;
  mov  cr0, eax         ;

  mov   bx, 0x00        ; Select descriptor 1.
  mov   ds, bx          ;

  jmp  08h:second_stage ; Perform a far jump to seletor 08h.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print a message to the screen in TTY mode.
;
; Parameters
;    [si] message - the address of the message to print.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_tty:
  mov   ah, 0x0e        ; Set TTY write mode.

.next:
  lodsb                 ;

  or    al, al          ; Check for end of string (NULL).
  jz    .exit           ;

  int   0x10            ; Print the character and advance to the next one.
  jmp   .next           ;

.exit:
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
  mov  si, fail_cpuid   ; Print the CPUID instruction check fail.
  call print_tty        ;

  jmp  shutdown         ; Halt the machine.

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

  mov   eax, 0x00000001 ; Call the CPUID instruction for feature information.
  cpuid                 ;

  test  ecx, 1 << 5     ; Check the VMX flag.
; jz    .fail_vmx       ;

  retn                  ;

.fail_64bit:
  mov  si, fail_64bit   ; Print the 64 bit check fail.
  call print_tty        ;

  jmp  shutdown         ; Halt the machine.

.fail_vmx:
  mov  si, fail_vmx     ; Print the VMX check fail.
  call print_tty        ;

  jmp  shutdown         ; Halt the machine.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Message table for boot display.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
boot_message:
  db "|", 0x0d, 0x0a
  db "| Ostracized, 1.0 - 64 Bit, Multi-Core", 0x0d, 0x0a
  db "| Copyright 2020, Bill Sella. All Rights Reserved.", 0x0d, 0x0a
  db 0

mode_switch:
  db "|", 0x0d, 0x0a
  db "| Entering Protected Mode", 0x0d, 0x0a
  db 0

halt_message:
  db "|", 0x0d, 0x0a
  db "| System Halted", 0x0d, 0x0a
  db 0

fail_cpuid:
  db "|", 0x0d, 0x0a
  db "| CPU Not Supported", 0x0d, 0x0a
  db 0

fail_64bit:
  db "|", 0x0d, 0x0a
  db "| CPU Not 64 Bit Long Mode Capable", 0x0d, 0x0a
  db 0

fail_vmx:
  db "|", 0x0d, 0x0a
  db "| VMX Instructions Not Supported", 0x0d, 0x0a
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
  db 0xf4               ; The table entry limit 16:19.
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
  db 0x80               ; The table entry access byte: 1 00 0 0 0 0 0.
                        ;   Present:          1 (Set)
                        ;   Privelege Level: 00 (Ring 0)
                        ;   Segment Type:     0 (Data)
                        ;   Executable:       0 (False)
                        ;   Direction:        0 (Only Accessable from Ring 0)
                        ;   Writable:         0 (Read-Only)
                        ;   Acessed Bit:      0 (Default)
  db 0xf4               ; The table entry limit 16:19.
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
; Protected Mode Section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[BITS 32]
second_stage:
  cli
  hlt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zero pad the image and set the bootloader signature.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times 510 - ($-$$) db 0 ; Zero pad the binary.
dw    0xaa55            ; Mark the binary as a bootloader sector.
