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

InvalidNumber:          db "Entree invalide (1..100), recommence: "
len_InvalidNumber:      equ $ - InvalidNumber

Debug:                  db "DEBUG", 0x0A
len_Debug:              equ $ - Debug

itsMore:                db "Plus", 0x0A
len_itsMore:            equ $ - itsMore

itsLess:                db "Moins", 0x0A
len_itsLess:            equ $ - itsLess

YouWon:                 db "Bravo!", 0x0A
len_YouWon:             equ $ - YouWon

user_input_buf_size     equ 256
random_int_size         equ 4

SECTION .bss
user_input:      resb user_input_buf_size
random_4_bytes:  resb random_int_size

SECTION .text
global _start
_start:
    xor r12, r12                    ; r12 = cumul d’octets reçus (0 au départ)
    lea r13, [random_4_bytes]       ; r13 = base (adresse) du buffer aléatoire
    mov r14, random_int_size        ; r14 = restant à lire (initialement 4)

    ; Boucle de remplissage du buffer aléatoire
    ; En soit elle sert a rien:
    ;   >If the urandom source has been initialized, 
    ;   reads of up to 256 bytes will always return as many bytes as requested 
    ;   and will not be interrupted by signals.
    ; Mais je l'ai fait quand même.
    loop_get_random_4_bytes:
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
                                    ; invariant: random_int_size == r12 + r14
    cmp r12, random_int_size
    jne loop_get_random_4_bytes     ; tant que r12 n'est pas == random_int_size, on boucle
    
    ; write(1, AskGuessANumber, len)
    mov     rax, SYS_WRITE      
    mov     rdi, 1
    mov     rsi, AskGuessANumber
    mov     rdx, len_AskGuessANumber
    syscall

    game_loop:
        lea r13, [rel user_input]

        ; read
        mov     rax, 0 				   
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
    xor r15d, r15d ; stock 32 bit pour le calculs 
    xor r11, r11 ; resultat total
    ascii_to_int:  ; on converti l'ASCII user_input en int           
        lea rax, [r13 + r14] ; pointeur du char
        movzx r15d, byte [rax - 0x30] ; digit 

        xor edx,edx     ; 
        mov edx, 2     ; 
        mov eax, 5      ; 
        mul edx,       ;

        add r11, r15d
        inc r14
    
    ;si index != r12 on loop
    cmp r14, r12
    jne ascii_to_int
    
    ; write(1, Debug, len)
    mov     rax, SYS_WRITE      
    mov     rdi, 1
    mov     rsi, Debug
    mov     rdx, len_Debug
    syscall

    jmp exit

    invalid_number:
    ; write(1, InvalidNumber, len)
    mov     rax, SYS_WRITE
    mov     rdi, 1
    mov     rsi, InvalidNumber
    mov     rdx, len_InvalidNumber
    syscall

    jmp game_loop

    erreur_gravissime_tout_quitter:
    ; write(1, PrintError, len)
    mov     rax, SYS_WRITE
    mov     rdi, 1
    mov     rsi, PrintError
    mov     rdx, len_PrintError
    syscall

    ; exit(1)
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

    exit:
    ; exit(0)
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall