%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60
%define SYS_GETRANDOM 318

; === I/O ===
; print(rsi=addr, rdx=len)
; println(rsi=addr, rdx=len)
; read_line(rdi=buf, rsi=max_len) -> rax=len

; === Conversions ===
; ascii_to_int(rsi=str, rdx=len) -> rax=value, CF=erreur
; int_to_ascii(edi=value, rsi=buf) -> rax=len

; === Validation ===
; is_numeric(rsi=str, rdx=len) -> rax=1/0
; is_in_range(edi=value, esi=min, edx=max) -> rax=1/0

; === Random ===
; get_random_uint32() -> eax=random
; random_range(edi=min, esi=max) -> eax=random

; === Exit ===
; exit(edi=code)
; exit_success()
; exit_error()
; exit_error_msg(rsi=msg, rdx=len)

section .text
    global print
    global println
    global read_line
    global ascii_to_int
    global int_to_ascii
    global is_numeric
    global is_in_range
    global get_random_uint32
    global random_range
    global exit
    global exit_success
    global exit_error
    global exit_error_msg

    ; print(rsi=addr, rdx=len)
    print:
        mov     rax, SYS_WRITE      
        mov     rdi, 1
        syscall

        ret

    ; println(rsi=addr, rdx=len)
    println:
        mov     rax, SYS_WRITE      
        mov     rdi, 1
        syscall

        mov     rax, SYS_WRITE
        mov     rdi, 1
        lea     rsi, [lf]
        mov     rdx, 1
        syscall

        ret

    ; read_line(rsi=buf, rdx=max_len) -> rax=len
    read_line:
        push rsi 

        mov     rax, SYS_READ 				   
        xor     rdi, rdi 
        syscall

        cmp rax, 0 
        jle end

        pop rsi
        cmp byte [rsi + rax - 1], 0x0A
        jnz  end
        dec rax
                
        end:
        ret 

    ; ascii_to_int(rsi=str, rdx=len) -> rax=value, CF=erreur
    ascii_to_int:

    ; int_to_ascii(edi=value, rsi=buf) -> rax=len
    int_to_ascii:

    ; is_numeric(rsi=str, rdx=len) -> rax=1/0
    is_numeric:
        xor rax, rax
        xor rcx, rcx 
        for_byte_in_str:            
            ; si char < '0' ou > '9' -> entrée invalide
            cmp byte [rsi + rcx], 0x30  
            jb end
            cmp byte [rsi + rcx], 0x39
            ja end
            inc rcx

        cmp rcx, rdx
        jne for_byte_in_str
        
        mov rax, 1

        end:
        ret

    ; is_in_range(edi=value, esi=min, edx=max) -> rax=1/0
    is_in_range:

    ; get_random_uint32() -> eax=random
    get_random_uint32:

    ; random_range(edi=min, esi=max) -> eax=random
    random_range:

    ; exit(edi=code)
    exit:

    ; exit_success()
    exit_success:

    ; exit_error()
    exit_error:

    ; exit_error_msg(rsi=msg, rdx=len)
    exit_error_msg: