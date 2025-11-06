clear
mkdir -p ./build/

nasm -f elf64 test_shellcode.asm -o ./build/test_shellcode.o
ld ./build/test_shellcode.o -o ./build/test_shellcode

./build/test_shellcode