%ifndef __PCI_S__
%define __PCI_S__

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A collection of PCI related functions.
;
; Author:  Bill Sella <bill.sella@gmail.com>
; License: GPL 2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[BITS 32]                ; Set to 64-bit mode.

section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Scan the PCI bus and initialize all devices.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pci_init:
  push edx                ; Save register state on the stack.
  push ecx                ;
  push ebx                ;
  push eax                ;

  xor  edx, edx           ;
  mov  ecx, 0x80000000    ; Start at device (0, 0).
  xor  ebx, ebx           ;
  xor  eax, eax           ;

  BOLD "scanning pci bus for devices"

.loop:
  mov  eax, ecx           ; Set the address of the next port to probe, then
  add  ecx,  256          ; advanced the counter to the next port.

  cmp  eax, 0x81000000    ; Determine if all ports have been probed.
  jns  .exit              ;

  mov   dx, 0x0cf8        ; Execute the port probe to read the configuration
  out   dx, eax           ; register.

  mov   dx, 0x0cfc        ; Extract the result from the port and check for a
  in   eax, dx            ; valid vendor (0xffff is invalid).
  cmp   ax, 0xffff        ;
  jz  .loop               ;

  mov  eax, ecx           ; Read the device class from the port.
  sub  eax, 248           ;
  mov   dx, 0x0cf8        ;
  out   dx, eax           ;

  mov   dx, 0x0cfc        ; Check the device class.
  in   eax, dx            ;
  INFO "- found"
  BREAK

  jmp .loop               ;

.exit:
  BOLD "- done"           ;
  pop  eax                ; Restore register state and return.
  pop  ebx                ;
  pop  ecx                ;
  pop  edx                ;
  retn                    ;

pci_class:
  db 'Unclassified'
  db 'Mass Storage Controller           ', 0, 0
  db 'Network Controller                ', 0, 0
  db 'Display Controller                ', 0, 0

  db 'Multimedia Controller             ', 0, 0
  db 'Memory Controller                 ', 0, 0
  db 'Bridge Device                     ', 0, 0
  db 'Simple Communication Controller   ', 0, 0

  db 'Base System Peripheral            ', 0, 0
  db 'Input Device Controller           ', 0, 0
  db 'Docking Station                   ', 0, 0
  db 'Processor                         ', 0, 0

  db 'Serial Bus Controller             ', 0, 0
  db 'Wireless Controller               ', 0, 0
  db 'Intelligent Controller            ', 0, 0
  db 'Satellite Communication Controller', 0, 0

  db 'Encryption Controller             ', 0, 0
  db 'Signal Processing Controller      ', 0, 0
  db 'Processing Accellerator           ', 0, 0
  db 'Non-Essential Instrumentation     ', 0, 0

%endif
