%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60
%define SYS_GETRANDOM 318

; === I/O ===
; print(rsi=addr, rdx=len)
; println(rsi=addr, rdx=len)
; read_line(rdi=buf, rsi=max_len) -> rax=len

; === Conversions ===
; ascii_to_int(rsi=str, rdx=len) -> rax=value, CF=erreur
; int_to_ascii(edi=value, rsi=buf) -> rax=len

; === Validation ===
; is_numeric(rsi=str, rdx=len) -> rax=1/0
; is_in_range(edi=value, esi=min, edx=max) -> rax=1/0

; === Random ===
; get_random_uint32() -> eax=random
; random_range(edi=min, esi=max) -> eax=random

; === Exit ===
; exit(edi=code)
; exit_success()
; exit_error()
; exit_error_msg(rsi=msg, rdx=len)