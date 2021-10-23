#!/bin/bash

mkdir bin
gcc aes128_dec.c -o bin/aes128_dec -O3
gcc aes128_enc.c -o bin/aes128_enc -O3
