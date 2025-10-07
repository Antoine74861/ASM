; Exemple d'assemblage "simple" x64:
;   nasm -f elf64 -o hello.o hello.asm
;   ld -o hello hello.o
;   ./hello

; utils:
;   objdump: objdump -d -M intel ./hello
;   gdb:     set disassembly-flavor intel

; syscalls x86-64
; https://syscalls.w3challs.com/?arch=x86_64

; registres:
;   rax : numéro du syscall (à l’entrée) et valeur de retour (à la sortie).
;   rdi, rsi, rdx, r10, r8, r9 : arguments 1 → 6.
;   rcx et r11 : écrasés par syscall (ne pas compter dessus après).
;   Retour : rax ≥ 0 = succès ; rax < 0 = -errno (ex. -22 pour EINVAL).