%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60
%define SYS_GETRANDOM 318

DEFAULT REL	          

SECTION .rodata
AskGuessANumber:        db "Devinez le nombre (1..100): ", 0x0A
len_AskGuessANumber:    equ $ - AskGuessANumber

PrintError:             db "Catastrophe", 0x0A
len_PrintError:         equ $ - InvalidNumber

InvalidNumber:          db "Entree invalide (1..100), recommence.", 0x0A
len_InvalidNumber:      equ $ - InvalidNumber

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

    jmp loop_random_int_1_100       ; boucle de remplissage du buffer aléatoire

    loop_random_int_1_100:
        ; getrandom(&buffer[cumul], restant, flags=0)
        mov rax, SYS_GETRANDOM      ; RAX = n° syscall
        lea rdi, [r13 + r12]        ; RDI = pointeur de destination (base + cumul)
        mov rsi, r14                ; RSI = nombre d’octets à lire (restant)
        mov rdx, 0x0000             ; RDX = flags (0 = urandom-like, bloquant si entropie pas prête)
        syscall

        cmp rax, 0
        jle erreur_gravissime_tout_quitter

        add r12, rax                ; cumul += delta (octets effectivement reçus)
        sub r14, rax                ; restant -= delta
                                    ; invariant: random_int_size == r12 + r14

        cmp r12, random_int_size
        je loop_random_int_1_100_end
        jmp loop_random_int_1_100

    loop_random_int_1_100_end:
        ; write(1, random_4_bytes, r12)
        mov     rax, SYS_WRITE
        mov     rdi, 1
        lea     rsi, random_4_bytes
        mov     rdx, r12
        syscall

        ; write(1, AskGuessANumber, len)
        mov     rax, SYS_WRITE      
        mov     rdi, 1
        mov     rsi, AskGuessANumber
        mov     rdx, len_AskGuessANumber
        syscall

        ; suite du jeu

        jmp exit

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
