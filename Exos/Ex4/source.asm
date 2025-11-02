    ################### DEFINES #####################
    #  Register aliases - x64 syscall convention    #
    .set    r_syscall,      %rax
    .set    r_arg1,         %rdi
    .set    r_arg2,         %rsi
    .set    r_arg3,         %rdx
    .set    r_ret,          %rax            # unused
    .set    r_retb,         %al             # unused
     
    #       <unistd.h> syscall constants - x64      #
    .set    SYS_READ,       0
    .set    SYS_WRITE,      1
    .set    SYS_OPEN,       2               # unused
    .set    SYS_CLOSE,      3               # unused
    .set    SYS_EXIT,       60
     
    #               File descriptors                #
    .set    STDIN,          0
    .set    STDOUT,         1               # unused
    .set    STDERR,         2               # unused
     
    #       This challenge is themed with           #
    #       its creator's weird sense of humour     #
    .set    LANDSIZE,       80
    .set    BEEEH,          0xc3
    .set    MUTTONS,        7
    #################################################
     
     
    #################### MACROS #####################
    #       1: S-mov        (Small / Stack)         #
    .macro  smov    src,    dst
            push    \src
            pop     \dst
    .endm
    #################################################
     
     
    #################### MEMORY #####################
    .section .rodata
    greetings:
            .ascii  "===== Basic Shellcode Executor =====", "\n"
            .ascii  "Input shellcode: ", "\0"
    msglen = . - greetings
     
    fail:
            .ascii "\n"
            .ascii "\"BEEEH!\" - said the sheep as you stumbled upon it...\n"
            .ascii "\n"
            .ascii "Tip: Sometimes the best way to deal with a problem is to go around it! :P\n"
    faillen = . - fail
     
    .section .bss
            # This is where the shellcode will land #
            .lcomm  land,   LANDSIZE
    #################################################
     
     
    ##################### CODE ######################
    .text
    .globl _start
    _start:
            #             Hello world!              #
            smov    $SYS_WRITE,     r_syscall
            smov    $STDOUT,        r_arg1
            movq    $greetings,     r_arg2
            smov    $msglen,        r_arg3
            syscall
     
            #  Setting up the land (the shellcode)  #
            smov    $SYS_READ,      r_syscall
            smov    $STDIN,         r_arg1
            movq    $land,          r_arg2
            smov    $LANDSIZE,      r_arg3
            syscall
     
            #       Oh, wild sheeps appeared!       #
            movq    $land,          %rbx
            smov    $MUTTONS,       %rcx
            another_one:
            movb    $BEEEH,         0x1(%rbx, %rcx)
            loop    another_one
     
            #    Will you be able to handle them?   #
            call    land
     
            #               Nope :/                 #
            smov    $SYS_WRITE,     r_syscall
            smov    $STDOUT,        r_arg1
            movq    $fail,          r_arg2
            smov    $faillen,       r_arg3
            syscall
     
            smov    $SYS_EXIT,      r_syscall
            smov    $1,             r_arg1
            syscall
    #################################################
