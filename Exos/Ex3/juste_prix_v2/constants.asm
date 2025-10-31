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

    max_tries               equ 100
    user_input_buf_size     equ 256
    uint32_size             equ 4
    nb_essais_size          equ 1

    MIN_VALUE equ 1
    MAX_VALUE equ 100