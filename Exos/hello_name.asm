; Objectif:
;   Écrire un programme qui :
;   Affiche Entrez votre prénom: sur la sortie standard.
;   Lit une ligne au clavier (stdin) dans un buffer.
;   Retire le saut de ligne final (\n).
;   Affiche Bonjour, <prénom>!\n.
;   Se termine proprement.

;  build: nasm -f elf64 -o hello_name.o hello_name.asm
;  link:  ld -o hello_name hello_name.o
;  les deux: nasm -f elf64 -o hello_name.o hello_name.asm && ld -o hello_name hello_name.o && ./hello_name

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

	mov r12, rax                  ; on met rax (le retour de read) dans rcx
    dec r12                       ; enleve le dernier char (tres moche)
	
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

