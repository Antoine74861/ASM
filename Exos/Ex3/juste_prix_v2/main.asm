DEFAULT REL	          

; === I/O ===
; print(rsi=addr, rdx=len)
; println(rsi=addr, rdx=len)
; read_line(rdi=buf, rsi=max_len) -> rax=len
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

    max_tries               equ 10
    user_input_buf_size     equ 256
    uint32_size             equ 4
    nb_essais_size          equ 1

SECTION .bss    
    user_input:    resb user_input_buf_size
    ascii_buffer:  resb uint32_size
    nb_essais:     resb nb_essais_size

SECTION .text
    global _start
    
    _start:
        ; On recupere un uint32 entre 1 et 100
        mov edi, 0x1    ; 1 
        mov esi, 0x64   ; 100
        call random_range
        mov r13d, eax   ; On le stock dans r13d
        
        game_loop:
            ; Devinez le nombre (1..100):
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
            
            ; Si c'est pas entre 1 et 100 => invalide
            cmp eax, 0x01  
            jb .invalid_number
            cmp eax, 0x64
            ja .invalid_number

            inc byte [nb_essais]
            cmp byte [nb_essais], max_tries  ; Max 100 essais !!
            je .too_much_tries


            ; Sinon, on peut la comparer avec le secret
            cmp r13d, eax
            ja .its_more
            jl .its_less
            je .its_win

            .its_less:
                lea     rsi, [Less]
                mov     rdx, len_Less
                call println

                jmp game_loop

            .its_more:
                lea     rsi, [More]
                mov     rdx, len_More
                call println

                jmp game_loop
            
            .its_win:           
                lea     rsi, [Win]
                mov     rdx, len_Win
                call print

                movzx edi, byte [nb_essais]
                lea rsi, [ascii_buffer]
                call int_to_ascii 

                lea     rsi, [ascii_buffer]
                mov     rdx, rax
                call println

                xor edi, edi
                call exit

            .invalid_number:
                lea rsi, [InvalidNumber]
                mov rdx, len_InvalidNumber
                call println
                
                jmp game_loop

            .too_much_tries:
                lea     rsi, [TooMuchTries]
                mov     rdx, len_TooMuchTries
                call println

                xor edi, edi
                call exit