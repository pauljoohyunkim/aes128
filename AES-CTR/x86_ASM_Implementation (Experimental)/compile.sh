#!/bin/bash

mkdir bin

as aes128_enc.s -o aes128_enc.o --32
as linux.s -o linux.o --32
as std_fun.s -o std_fun.o --32
as custom_fun.s -o custom_fun.o --32
as aes128_dec.s -o aes128_dec.o --32

ld aes128_enc.o linux.o std_fun.o custom_fun.o -o bin/aes128_enc -m elf_i386
ld aes128_dec.o linux.o std_fun.o custom_fun.o -o bin/aes128_dec -m elf_i386

rm *.o
