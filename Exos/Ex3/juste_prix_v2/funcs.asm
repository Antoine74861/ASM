%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60
%define SYS_GETRANDOM 318

section .text
    global print, println, read_line
    global ascii_to_int, int_to_ascii, is_numeric, is_in_range
    global get_random_uint32, random_range

    ; --- Gestion de la sortie du programme ---
    global exit, exit_success, exit_error, exit_error_msg

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
        
        sub rsp, 1
        mov byte [rsp], 0x0A
        
        mov rax, 1
        mov rdi, 1
        mov rsi, rsp
        mov rdx, 1
        syscall

        add rsp, 1

        ret

    ; read_line(rsi=buf, rdx=max_len) -> rax=len
    read_line:
        push rsi 

        mov     rax, SYS_READ 				   
        xor     rdi, rdi 
        syscall

        cmp rax, 0 
        jle .end

        pop rsi
        cmp byte [rsi + rax - 1], 0x0A
        jnz  .end
        dec rax
                
        .end:
            
        ret 

    ; ascii_to_int(rsi=str, rdx=len) -> rax=value
    ascii_to_int:
        mov r8, rdx    ; len dans r8
        xor rcx, rcx
        xor edx, edx
        .for_byte_in_str:    
            cmp rcx, r8
            je .end

            movzx r9d, byte [rsi + rcx]
            sub r9d, 0x30

            mov eax, edx    ; val
            mov edx, 10     ; 10
            mul edx         ; mul = val * 10

            add eax, r9d   ; (mul + digit)
            mov edx, eax   ; val = val + (mul + digit)

            inc rcx

            jmp .for_byte_in_str
        .end:

        mov rax, rdx
        ret


    ; int_to_ascii(edi=value, rsi=&buf) -> rax=len
    int_to_ascii:
        xor r9, r9
        loop_int_to_ascii:
            cmp edi, 0
            je .end

            mov edx, 0
            mov eax, edi
            mov ecx, 10
            div ecx

            mov edi, eax   ; quotient
            mov r8b, dl    ; reste
            add r8b, 0x30

            mov byte [rsi + r9], r8b

            inc r9
            jmp loop_int_to_ascii
        .end:
        mov rax, r9
        ret 


    ; is_numeric(rsi=str, rdx=len) -> rax=1/0
    is_numeric:
        xor rax, rax
        xor rcx, rcx 
        .for_byte_in_str:  
            cmp rcx, rdx
            je .if_all_numeric

            ; si char < '0' ou > '9' -> entrée invalide
            cmp byte [rsi + rcx], 0x30  
            jb .end
            cmp byte [rsi + rcx], 0x39
            ja .end
            inc rcx

            jmp .for_byte_in_str
        .if_all_numeric:
            mov rax, 1
        .end:
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
    ; range: [min, max]
    random_range:
        push r11        ; sauvegarde de r11 (convention)
        push r12        ; sauvegarde de r12 (convention)
        push r13        ; sauvegarde de r13 (convention)

        sub esi, edi    ; max = max - min
        inc esi         ; max = max + 1 
        mov r12d, esi   ; max        
        mov r13d, edi   ; min

        ; ======  T = (2^32 / max) * max ======
        ; eax = (2^32 / max)
        mov edx, 0x1  ; 
        xor rax, rax  ; 2^32
        mov ecx, esi
        div ecx

        ; eax = rdx * max
        mov rdx, rax
        mov eax, esi
        mul rdx
        ; =====================================
        
        mov r11d, eax   ; T
        while_not_in_range:
            call get_random_uint32 ; -> eax

        cmp r11d, eax
        jae while_not_in_range

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