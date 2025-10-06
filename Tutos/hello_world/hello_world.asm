section        .text  
section        .data             
    msg        db "Hello world!", 0xa
    len        equ $ -msg

global         _start   

_start:
    mov edx, len 
    mov ecx, msg 
    mov ebx, 1
    mov eax, 4
    int 0x80
    mov eax, 1
    int 0x80


; nasm -f elf32 -o hello_world.o hello_world.asm 
; ld -m elf_i386 -o hello_world hello_world.o
; ./hello_world