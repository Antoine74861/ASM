clear
mkdir -p ./build/

nasm -f elf64 funcs.asm -o ./build/funcs.o
nasm -f elf64 main.asm -o ./build/main.o

ld ./build/funcs.o ./build/main.o -o ./build/juste_prix
./build/juste_prix