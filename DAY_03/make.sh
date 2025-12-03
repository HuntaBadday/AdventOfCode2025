#!/bin/bash
nasm -f elf64 -o main.o main.asm
gcc -static -lc -o main main.o