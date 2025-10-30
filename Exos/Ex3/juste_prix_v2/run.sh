clear
mkdir -p ./build/

nasm -f elf64 data.asm -o ./build/data.o
nasm -f elf64 funcs.asm -o ./build/funcs.o
nasm -f elf64 main.asm -o ./build/main.o

ld ./build/data.o ./build/funcs.o ./build/main.o -o ./build/juste_prix
./build/juste_prix