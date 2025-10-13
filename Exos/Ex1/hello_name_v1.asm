; hello_name_v1 — version d’apprentissage (conservée pour l’historique)
; Affiche le prompt, lit une ligne, trim naïf (-1) avec «dec», affiche « Bonjour, <nom> !».
; Améliorations à faire : trim conditionnel du LF (\n) et validation basique de l’entrée.
; 
; build: 
;   nasm -f elf64 -o hello_name_v1.o hello_name_v1.asm
; link:  
;   ld -o hello_name_v1 hello_name_v1.o
; build+link+exec: 
;   nasm -f elf64 -o hello_name_v1.o hello_name_v1.asm && ld -o hello_name_v1 hello_name_v1.o && ./hello_name_v1

SECTION .rodata
AskNameInput:        db "Entrez votre prénom: "
len_AskNameInput:    equ $ - AskNameInput
AnswerName:        db "Bonjour "
len_AnswerName:    equ $ - AnswerName
AnswerExclamationMark:        db "!", 10
len_AnswerExclamationMark:    equ $ - AnswerExclamationMark
user_input_buf       equ 256

SECTION .bss
user_input: resb 256

SECTION .text
global _start
_start:
    ; write
    mov     rax, 1 				  ; ID du syscall
    mov     rdi, 1				  ; unsigned int fd
    mov     rsi, AskNameInput	  ; const char *buf
    mov     rdx, len_AskNameInput ; size_t count
    syscall	

	; read
    mov     rax, 0 				  ; ID du syscall
    mov     rdi, 0				  ; unsigned int fd
    mov     rsi, user_input		  ; char *buf
    mov     rdx, user_input_buf   ; size_t count
    syscall

	mov r12, rax                  ; on met rax (le retour de read) dans r12
    test r12, r12                 ; test si r12 est a 0
    



    dec r12                       ; enleve le dernier char pour trim le \n (tres moche)
	
    ; write
    mov     rax, 1 				  ; ID du syscall
    mov     rdi, 1				  ; unsigned int fd
    mov     rsi, AnswerName  	  ; const char *buf
    mov     rdx, len_AnswerName   ; size_t count
    syscall	

	; write
    mov     rax, 1 				  ; ID du syscall
    mov     rdi, 1				  ; unsigned int fd
    mov     rsi, user_input	  	  ; const char *buf
    mov     rdx, r12              ; size_t count
    syscall	

    ; write
    mov     rax, 1 				            ; ID du syscall
    mov     rdi, 1				            ; unsigned int fd
    mov     rsi, AnswerExclamationMark	    ; const char *buf
    mov     rdx, len_AnswerExclamationMark  ; size_t count
    syscall	

    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

