DEFAULT REL	          

; === I/O ===
; print(rsi=addr, rdx=len)
; println(rsi=addr, rdx=len)
; read_line(rsi=buf, rdx=max_len) -> rax=len
extern print, println, read_line

; === Conversions ===
; ascii_to_int(rsi=str, rdx=len) -> rax=value, CF=erreur
; int_to_ascii(edi=value, rsi=buf) -> rax=len
extern ascii_to_int, int_to_ascii

; === Validation ===
; is_numeric(rsi=str, rdx=len) -> rax=1/0
; is_in_range(edi=value, esi=min, edx=max) -> rax=1/0
extern is_numeric, is_in_range

; === Random ===
; get_random_uint32() -> eax=random
; random_range(edi=min, esi=max) -> eax=random
extern get_random_uint32, random_range

; === Exit ===
; exit(edi=code)
; exit_success()
; exit_error()
; exit_error_msg(rsi=msg, rdx=len)
extern exit, exit_success, exit_error, exit_error_msg

SECTION .rodata
    AskGuessANumber:        db "Devinez le nombre (1..100): "
    len_AskGuessANumber:    equ $ - AskGuessANumber
    InvalidNumber:          db "Entree invalide (1..100)"
    len_InvalidNumber:      equ $ - InvalidNumber
    More:                   db "Plus"
    len_More:               equ $ - More
    Less:                   db "Moins"
    len_Less:               equ $ - Less
    Win:                    db "Bravo!! Nombre d'essais: "
    len_Win:                equ $ - Win
    TooMuchTries:           db "Trop nul dsl"
    len_TooMuchTries:       equ $ - TooMuchTries

    max_tries               equ 100
    user_input_buf_size     equ 256
    uint32_size             equ 4
    nb_essais_size          equ 1

    MIN_VALUE equ 1
    MAX_VALUE equ 100

SECTION .bss    
    user_input:    resb user_input_buf_size
    ascii_buffer:  resb uint32_size
    nb_essais:     resb nb_essais_size

SECTION .text
    global _start
    
    _start:        
        ; On recupere un uint32 entre 1 et 100
        mov edi, MIN_VALUE    ; 1 
        mov esi, MAX_VALUE    ; 100
        call random_range
        mov r13d, eax   ; On le stock dans r13d
        
        game_loop:
            ; "Devinez le nombre (1..100): "
            lea rsi, [AskGuessANumber]
            mov rdx, len_AskGuessANumber
            call print

            ; Saisie user
            lea rsi, [user_input]
            mov rdx, user_input_buf_size
            call read_line

            ; Si la saisie est vide
            test rax, rax
            je game_loop

            mov r12, rax ; on stock len_user_input

            ; On verifie si tous les chars de l'input sont [0-9]
            lea rsi, [user_input]
            mov rdx, r12
            call is_numeric
            
            ; Si c'est pas le cas => invalide
            test rax, rax
            je .invalid_number

            ; On converti la saisie user en int pour la comparer
            lea rsi, [user_input]
            mov rdx, r12
            call ascii_to_int 
            mov r14d, eax

            ; Si c'est pas entre 1 et 100 => invalide
            mov edi, eax
            mov esi, MIN_VALUE
            mov edx, MAX_VALUE  
            call is_in_range

            test rax, rax
            je .invalid_number

            inc byte [nb_essais]
            cmp byte [nb_essais], max_tries  ; Max 100 essais !!
            jae .too_much_tries

            ; Sinon, on peut la comparer avec le secret
            cmp r13d, r14d
            ja .its_more
            jl .its_less
            je .its_win

            .its_less:
                ; "Moins"
                lea     rsi, [Less]
                mov     rdx, len_Less
                call println

                jmp game_loop

            .its_more:
                ; "Plus"
                lea     rsi, [More]
                mov     rdx, len_More
                call println

                jmp game_loop
            
            .its_win:        
                ; "Bravo!! Nombre d'essais: "   
                lea     rsi, [Win]
                mov     rdx, len_Win
                call print
                
                ; Nombre d'essais => ascii
                movzx edi, byte [nb_essais]
                lea rsi, [ascii_buffer]
                call int_to_ascii 

                ; Affichage nb_essais en ascii
                lea     rsi, [ascii_buffer]
                mov     rdx, rax
                call println

                xor edi, edi
                call exit

            .invalid_number:
                ; "Entree invalide (1..100)"
                lea rsi, [InvalidNumber]
                mov rdx, len_InvalidNumber
                call println
                
                jmp game_loop

            .too_much_tries:
                ; "Trop nul dsl"
                lea     rsi, [TooMuchTries]
                mov     rdx, len_TooMuchTries
                call println

                xor edi, edi
                call exit