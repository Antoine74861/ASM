; hello_name_v2 — version "finale"
;  
; build: 
;   nasm -f elf64 -o hello_name_v2.o hello_name_v2.asm
; link:  
;   ld -o hello_name_v2 hello_name_v2.o
; build+link+exec: 
;   clear && nasm -f elf64 -o hello_name_v2.o hello_name_v2.asm && ld -o hello_name_v2 hello_name_v2.o && ./hello_name_v2

DEFAULT REL			        ; use RIP-relative addressing modes by default, so [foo] = [rel foo]

SECTION .rodata
AskNameInput:               db "Entrez votre prénom: "
len_AskNameInput:           equ $ - AskNameInput

AnswerName:                 db "Bonjour "
len_AnswerName:             equ $ - AnswerName

AnswerExclamationMark:      db "!", 0x0A
len_AnswerExclamationMark:  equ $ - AnswerExclamationMark

LineFeed:                   db 0x0A
len_LineFeed:               equ $ - LineFeed

ReadIsEmpty:                db "Entrée vide", 0x0A
len_ReadIsEmpty:            equ $ - ReadIsEmpty

ReadError:                  db 0x0A, "Erreur de lecture", 0x0A
len_ReadError:              equ $ - ReadError

user_input_buf              equ 256

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
    cmp r12, 0                    ; r12 - 0
    jz .read_empty_add_linefeed   ; si flag ZF=1 (égal à zéro), alors jump
    js .read_error                ; si r12 < 0, erreur

    lea r13, [rel user_input]      ; lea = load effective adresse, ca permet de charger l'adresse d'user_input
    cmp byte [r13 + r12 - 1], 0x0A ; Si le -1 byte de r12 est un \n on le trim
    jz  .trim_lf 
    jmp .greetings 
    

.greetings:
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

    jmp .exit


.read_empty:
    ; write
    mov     rax, 1 				  ; ID du syscall
    mov     rdi, 1				  ; unsigned int fd
    mov     rsi, ReadIsEmpty	  ; const char *buf
    mov     rdx, len_ReadIsEmpty  ; size_t count
    syscall	

    jmp .exit

.read_error:
    ; write
    mov     rax, 1 				  ; ID du syscall
    mov     rdi, 1				  ; unsigned int fd
    mov     rsi, ReadError	      ; const char *buf
    mov     rdx, len_ReadError    ; size_t count
    syscall	

    mov     rax, 60
    mov     rdi, 1
    syscall

.trim_lf:
    dec r12                       ; enleve le dernier char pour trim le \n
    cmp r12, 0
    jz .read_empty                ; si r12 est egal a 0 apres le dec
    jmp .greetings 
    
.exit:
    ; exit(0)
    mov     rax, 60
    xor     rdi, rdi
    syscall

.read_empty_add_linefeed:
    mov     rax, 1 				            ; ID du syscall
    mov     rdi, 1				            ; unsigned int fd
    mov     rsi, LineFeed	                ; const char *buf
    mov     rdx, len_LineFeed               ; size_t count
    syscall	

    jmp .read_empty