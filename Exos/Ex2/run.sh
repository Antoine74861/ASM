clear
nasm -f elf64 juste_prix.asm -o ./build/juste_prix.o
ld ./build/juste_prix.o -o ./build/juste_prix
./build/juste_prix