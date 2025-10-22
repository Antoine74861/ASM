%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60
%define SYS_GETRANDOM 318

DEFAULT REL	          

SECTION .rodata
AskGuessANumber:        db "Devinez le nombre (1..100): "
len_AskGuessANumber:    equ $ - AskGuessANumber
PrintError:             db "Catastrophe", 0x0A
len_PrintError:         equ $ - PrintError
InvalidNumber:          db "Entree invalide (1..100)", 0x0A
len_InvalidNumber:      equ $ - InvalidNumber
More:                   db "Plus", 0x0A
len_More:               equ $ - More
Less:                   db "Moins", 0x0A
len_Less:               equ $ - Less
Win:                    db "Bravo!! Nombre d'essais: "
len_Win:                equ $ - Win
TooMuchTries:           db "Trop nul dsl", 0x0A
len_TooMuchTries:       equ $ - TooMuchTries                
lf:                     db 10

max_tries               equ 100
user_input_buf_size     equ 256
uint32_size             equ 4
nb_essais_size          equ 1

SECTION .bss
user_input:    resb user_input_buf_size
random_uint32: resb uint32_size
ascii_buffer:  resb uint32_size
nb_essais:     resb nb_essais_size

SECTION .text
global _start
_start:
    xor r12, r12                    ; r12 = cumul d’octets reçus (0 au départ)
    lea r13, [random_uint32]        ; r13 = base (adresse) du buffer aléatoire
    mov r14, uint32_size            ; r14 = restant à lire (initialement 4 bytes)
    
    ; Boucle de remplissage du buffer aléatoire
    ; En soit elle sert a rien:
    ;   >If the urandom source has been initialized, 
    ;   reads of up to 256 bytes will always return as many bytes as requested 
    ;   and will not be interrupted by signals.
    ; Mais je l'ai fait quand même.
    loop_get_random_uint32:
        ; getrandom(&buffer[cumul], restant, flags=0)
        mov rax, SYS_GETRANDOM      ; RAX = n° syscall
        lea rdi, [r13 + r12]        ; RDI = pointeur de destination (base + cumul)
        mov rsi, r14                ; RSI = nombre d’octets à lire (restant)
        mov rdx, 0x0000             ; RDX = flags
        syscall

        cmp rax, 0
        jle erreur_gravissime_tout_quitter

        add r12, rax                ; cumul += delta (octets effectivement reçus)
        sub r14, rax                ; restant -= delta
                                    ; invariant: uint32_size == r12 + r14
    cmp r12, uint32_size
    jne loop_get_random_uint32     ; tant que r12 n'est pas == uint32_size, on boucle

    cmp dword [random_uint32], 0xFFFFFFA0   ; T = plus grand multiple de 100 ≤ 2^32 (4294967200)
    jb skip_retry_random
    xor r12, r12  
    lea r13, [random_uint32] 
    mov r14, uint32_size
    jmp  loop_get_random_uint32 ; rejeter si x ≥ T (évite le biais du %100)
    skip_retry_random:

    mov edx, 0
    mov eax, [random_uint32]
    mov ecx, 0x64
    div ecx
    
    inc edx
    mov dword [random_uint32], edx  

    lea r13, [user_input]
    game_loop:
        ; write(1, AskGuessANumber, len)
        mov     rax, SYS_WRITE      
        mov     rdi, 1
        lea     rsi, [AskGuessANumber]
        mov     rdx, len_AskGuessANumber
        syscall

        ; read
        mov     rax, SYS_READ 				   
        mov     rdi, 0	 
        mov     rsi, r13
        mov     rdx, user_input_buf_size
        syscall

        ; VALIDATION DE L'INPUT
        mov r12, rax
        cmp r12, 0 
        jle erreur_gravissime_tout_quitter ; jle, je peaufinerais a la fin
    
        ; trim du LF si y en a un
        cmp byte [r13 + r12 - 1], 0x0A
        jnz  skip_trim ; si y en a pas on skip
        dec r12
        cmp r12, 0
        je invalid_number ; si len(input) == 0 apres trim du lf -> entrée invalide

        skip_trim:
        xor r14, r14 ; index de la loop
        for_byte_in_user_input:            
            lea r15, [r13 + r14] ; pointeur du char
            ; si char < '0' ou > '9' -> entrée invalide
            cmp byte [r15], 0x30  
            jb invalid_number
            cmp byte [r15], 0x39
            ja invalid_number
            inc r14
            
        ;si index != r12 on loop
        cmp r14, r12
        jne for_byte_in_user_input

        ; CONVERSION ASCII => ENTIER
        ; Pour chaque caractère :
        ;   digit = byte - '0'      ; ex : '1' (0x31) → 1 (0x01)
        ;   val   = val*10 + digit  ; accumulation en base 10
        xor r14, r14 ; index de la loop
        xor r11d, r11d ; resultat total
        ascii_to_int:  ; on converti l'ASCII user_input en int           
            lea rax, [r13 + r14] ; pointeur du char
            mov al, [rax]  
            sub al, 0x30    ; al = digit
            movzx r15d, al  ; on le stocke AVANT mul sinon ca l'écrase et on passe 1h à debugguer!!!!!!

            mov edx, r11d   ; val
            mov eax, 10     ; 10
            mul edx         ; mul = val * 10

            add eax, r15d     ; (mul + digit)
            mov r11d, eax     ; val = val + (mul + digit)

            inc r14
        
        ;si index != r12 on loop
        cmp r14, r12
        jne ascii_to_int
        
        ; validation int entre 1 et 100
        cmp r11d, 0x01  
        jb invalid_number
        cmp r11d, 0x64
        ja invalid_number

        inc byte [nb_essais]
        cmp byte [nb_essais], max_tries  ; Max 100 essais !!
        je too_much_tries

        ; Plus ou moins
        cmp dword [random_uint32], r11d
        ja plus
        jl moins
        je win
        plus:
            ; write(1, More, len)
            mov     rax, SYS_WRITE
            mov     rdi, 1
            lea     rsi, [More]
            mov     rdx, len_More
            syscall
            
            jmp game_loop

        moins:
            ; write(1, Less, len)
            mov     rax, SYS_WRITE
            mov     rdi, 1
            lea     rsi, [Less]
            mov     rdx, len_Less
            syscall

            jmp game_loop

        win:
        ; CONVERSION ENTIER => ASCII
        ; On divise par 10 jusqua val = 0.
        ;   ex: 132 / 10 => q=13, r=2 => buffer '2'
        ;       13 / 10  => q=1,  r=3 => buffer '3'
        ;       1 / 10   => q=0,  r=1 => buffer '1'
        ; Je pars du principe que le int a convertir est dans r11d (donc 32bits)
        ; Résultat dans ascii_buffer.
        movzx r11d, byte [nb_essais]  
        mov r14, uint32_size ; index du buffer
        dec r14
        xor r13, r13
        int_to_ascii:
            mov edx, 0
            mov eax, r11d
            mov ecx, 10
            div ecx

            mov r11d, eax  ; quotient
            mov r12b, dl   ; reste

            add r12b, 0x30
            lea r15, [ascii_buffer + r14] 
            mov [r15], r12b

            dec r14
            inc r13
        
        ;Tant que r11d > 0 on loop
        cmp r11d, 0
        ja int_to_ascii
        
        ; write(1, Win, len)
        mov     rax, SYS_WRITE
        mov     rdi, 1
        lea     rsi, [Win]
        mov     rdx, len_Win
        syscall

        ; write(1, Win, len)
        mov     rax, SYS_WRITE
        mov     rdi, 1
        lea     rsi, [ascii_buffer + uint32_size]  ; vu que je rempli mon ascii_buffer a l'envers, je dois ignorer les bits "morts" du debut
        sub     rsi, r13
        mov     rdx, r13
        syscall

        ; write(1, lf, len)
        mov     rax, SYS_WRITE
        mov     rdi, 1
        lea     rsi, [lf]
        mov     rdx, 1
        syscall

        ; exit(0)
        mov rax, SYS_EXIT
        xor rdi, rdi
        syscall

    invalid_number:
    ; write(1, InvalidNumber, len)
    mov     rax, SYS_WRITE
    mov     rdi, 1
    lea     rsi, [InvalidNumber]
    mov     rdx, len_InvalidNumber
    syscall

    jmp game_loop

    too_much_tries:
    ; write(1, lf, len)
    mov     rax, SYS_WRITE
    mov     rdi, 1
    lea     rsi, [TooMuchTries]
    mov     rdx, len_TooMuchTries
    syscall

    ; exit(0)
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

    erreur_gravissime_tout_quitter:
    ; write(1, PrintError, len)
    mov     rax, SYS_WRITE
    mov     rdi, 1
    lea     rsi, [PrintError]
    mov     rdx, len_PrintError
    syscall

    ; exit(1)
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall