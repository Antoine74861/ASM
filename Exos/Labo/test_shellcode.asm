section .text
    global _start
_start:
    sub     rsp, 8
    mov     rax, 0x68732f6e69622f
    mov     [rsp], rax

    mov     rax, 0x3b         
    mov     rdi, rsp         
    xor     rsi, rsi       
    xor     rdx, rdx        
    syscall

    add     rsp, 8

    mov     eax, 60       
    xor     edi, edi
    syscall