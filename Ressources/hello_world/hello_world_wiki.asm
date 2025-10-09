;  build: nasm -f elf64 -F dwarf hello.asm
;  link:  ld -o hello hello.o

DEFAULT REL			    ; use RIP-relative addressing modes by default, so [foo] = [rel foo]

SECTION .rodata			; read-only data should go in the .rodata section on GNU/Linux, like .rdata on Windows
Hello:		db "Hello world!", 10   ; Ending with a byte 10 = newline (ASCII LF)
len_Hello:	equ $-Hello             ; Get NASM to calculate the length as an assembly-time constant
                                    ; the ‘$’ symbol means ‘here’. write() takes a length so that
                                    ; a zero-terminated C-style string isn't needed.
                                    ; It would be for C puts()

SECTION .text

global _start
_start:
	mov eax, 1				; __NR_write syscall number from Linux asm/unistd_64.h (x86_64)
	mov edi, 1				; int fd = STDOUT_FILENO
	lea rsi, [rel Hello]			; x86-64 uses RIP-relative LEA to put static addresses into regs
	mov rdx, len_Hello		; size_t count = len_Hello
	syscall					; write(1, Hello, len_Hello);  call into the kernel to actually do the system call
     ;; return value in RAX.  RCX and R11 are also overwritten by syscall

	mov eax, 60				; __NR_exit call number (x86_64) is stored in register eax.
	xor edi, edi		    ; This zeros edi and also rdi.
                            ; This xor-self trick is the preferred common idiom for zeroing
                            ; a register, and is always by far the fastest method.
                            ; When a 32-bit value is stored into eg edx, the high bits 63:32 are
                            ; automatically zeroed too in every case. This saves you having to set
                            ; the bits with an extra instruction, as this is a case very commonly
                            ; needed, for an entire 64-bit register to be filled with a 32-bit value.
                            ; This sets our routine’s exit status = 0 (exit normally)
	syscall					; _exit(0)