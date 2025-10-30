DEFAULT REL	          
global _start

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


SECTION .text
    _start:
        mov rsi, [buff]
        mov rdx, len
        call print