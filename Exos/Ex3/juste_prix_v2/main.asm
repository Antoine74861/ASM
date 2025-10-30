DEFAULT REL	          
global _start

extern AskGuessANumber, len_AskGuessANumber
extern PrintError, len_PrintError
extern InvalidNumber, len_InvalidNumber
extern More, len_More
extern Less, len_Less
extern Win, len_Win
extern TooMuchTries, len_TooMuchTries
extern lf

extern user_input, random_uint32, ascii_buffer, nb_essais

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
        call get_random_uint32

        mov edi, eax
        mov rsi, ascii_buffer
        call int_to_ascii
        
        lea rsi, [rel ascii_buffer]
        mov rdx, 4
        call println

        mov edi, 0x1
        mov esi, 0x64
        call random_range

        mov edi, eax
        mov rsi, ascii_buffer
        call int_to_ascii
        
        lea rsi, [rel ascii_buffer]
        mov rdx, rax
        call println
        
        lea rsi, [rel AskGuessANumber]
        mov rdx, len_AskGuessANumber
        call println


        call exit