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

    ; ascii_to_int(rsi=str, rdx=len) -> rax=value
    ascii_to_int:
        mov r8, rdx    ; len dans r8
        xor rcx, rcx
        xor edx, edx
        for_byte_in_str:    
            cmp rcx, r8
            je end

            movzx r9d, byte [rsi + rcx]
            sub r9d, 0x30

            mov eax, edx    ; val
            mov edx, 10     ; 10
            mul edx         ; mul = val * 10

            add eax, r9d   ; (mul + digit)
            mov rdx, eax    ; val = val + (mul + digit)

            inc rcx

        jmp for_byte_in_str
        end:

        mov rax, rdx
        ret


    ; int_to_ascii(edi=value, rsi=buf) -> rax=len
    int_to_ascii:
        loop_int_to_ascii:
            cmp edi, 0
            je end

            mov edx, 0
            mov eax, edi
            mov ecx, 10
            div ecx

            mov edi, eax   ; quotient
            mov r12b, dl   ; reste

            add r12b, 0x30
            lea r15, [rsi + r14] 
            mov [r15], r12b

            dec r14
            inc r13

        jmp loop_int_to_ascii
        end:
        ret 


    ; is_numeric(rsi=str, rdx=len) -> rax=1/0
    is_numeric:
        xor rax, rax
        xor rcx, rcx 
        for_byte_in_str:  
            cmp rcx, rdx
            je if_all_numeric

            ; si char < '0' ou > '9' -> entrée invalide
            cmp byte [rsi + rcx], 0x30  
            jb end
            cmp byte [rsi + rcx], 0x39
            ja end
            inc rcx

            jmp for_byte_in_str
        if_all_numeric:
            mov rax, 1
        end:
        ret

    ; is_in_range(edi=value, esi=min, edx=max) -> rax=1/0
    is_in_range:
        xor rax, rax

        cmp edi, esi  
        jb not_in_range
        cmp edi, edx
        ja not_in_range

        mov rax, 1 ; si (esi <= edi => edx)
        
        not_in_range:
        ret
        
    ; get_random_uint32() -> eax=random
    get_random_uint32:
        sub rsp, 8

        mov rax, SYS_GETRANDOM      
        lea rdi, [rsp]
        mov rsi, 4
        xor rdx, rdx    
        syscall

        mov eax, [rsp]
        add rsp, 8
        
        ret

    ; random_range(edi=min, esi=max) -> eax=random
    random_range:
        push r11        ; sauvegarde de r11 (convention)
        push r12        ; sauvegarde de r12 (convention)
        push r13        ; sauvegarde de r13 (convention)

        sub esi, edi    ; max = max - min
        mov r12d, esi   ; max        
        mov r13d, edi   ; min

        ; ======  T = (2^32 / max) * max ======
        ; eax = (2^32 / max)
        mov rdx, 0x1  ; 
        xor rax, rax  ; 2^32
        mov rcx, esi
        div rcx

        ; eax = rdx * max
        mov rdx, rax
        mov rax, esi
        mul rdx
        ; =====================================
        
        mov r11d, edx   ; T
        while_not_in_range:
            call get_random_uint32 ; -> eax

        cmp eax, r11d
        ja while_not_in_range

        mov edx, 0
        mov ecx, r12d
        div ecx

        mov eax, edx 
        add eax, r13d  ; ajoute min

        pop r13
        pop r12
        pop r11
        ret
        

    ; exit(edi=code)
    exit:
        mov al, SYS_EXIT
        syscall

    ; exit_error_msg(rsi=msg, rdx=len)
    exit_error_msg:
        call println 
        mov al, SYS_EXIT
        mov edi, 1
        syscall