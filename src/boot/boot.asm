; Declare constants used for creating a multiboot header.
ARCH        equ  0                      ; the architecture
MAGIC       equ  0xE85250D6             ; Multiboot spec magic

; Declare a header as in the Multiboot Standard. We put this into a special
; section so we can force the header to be in the start of the final program.
section .multiboot
align 4
header_start:
	dd MAGIC
	dd ARCH
  dd header_end - header_start
	dd 0x100000000-(MAGIC + ARCH + (header_end - header_start))  ; Checksum

  ; End tag
  dw 0
  dw 0
  dd 8
header_end:

; The linker script specifies _start as the entry point to the kernel and the
; bootloader will jump to this position once the kernel has been loaded. It
; doesn't make sense to return from this function as the bootloader is gone.
section .text
global _start
bits 32
_start:
	; Welcome to kernel mode! We now have sufficient code for the bootloader to
	; load and run our operating system.

	; In case the function returns, we'll want to put the computer into an
	; infinite loop. To do that, we use the clear interrupt ('cli') instruction
	; to disable interrupts, the halt instruction ('hlt') to stop the CPU until
	; the next interrupt arrives, and jumping to the halt instruction if it ever
	; continues execution, just to be safe.
  mov dword [0xb8000], 0x2f4b2f4f
	cli
  hlt
