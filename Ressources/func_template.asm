print_string:
    ; === PROLOGUE ===
    push rbp           ; Sauvegarde rbp
    mov rbp, rsp       ; rbp = base de notre fonction
    
    ; === CORPS ===
    mov rax, 1
    mov rdi, 1
    ; rsi et rdx déjà passés en arguments
    syscall
    
    ; === ÉPILOGUE ===
    leave              ; Restaure rsp et rbp
    ret                ; Retourne à l'appelant