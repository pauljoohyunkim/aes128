# aes128
## Sample C implementation of AES-128 encryption

The POC (Proof-of-Concept) code is currently being used to make a simple file encryption program. Read through in order to see step-by-step on how AES-128 works. Simply compile each .c file by "gcc [file].c -o file"

In the AES-CTR folder, you can compile both aes128_enc.c and aes128_dec.c to use them as simple file encryptor/decryptor. Currently there is an issue where it won't process large files (from about 3~4 gigabyte file). Also, since single threaded, encryption process quite slow. These two issues will be fixed soon.
