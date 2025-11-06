section .text
    global _start
_start:
    sub     rsp, 1
    mov     byte [rsp], 0x41

    mov     eax, 1          ; sys_write
    mov     edi, 1          ; stdout
    mov     rsi, rsp        ; buf = &newline
    mov     edx, 1          ; count
    syscall

    add     rsp, 1

    mov     eax, 60         ; sys_exit
    xor     edi, edi
    syscall