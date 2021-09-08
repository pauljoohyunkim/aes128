# aes128
## Sample C implementation of AES-128 encryption

The POC (Proof-of-Concept) code is currently being used to make a simple file encryption program. Read through in order to see step-by-step on how AES-128 works. Simply compile each .c file by "gcc [file].c -o file"


# AES-CTR File Encryptor/Decryptor
In the AES-CTR folder, you can compile both aes128_enc.c and aes128_dec.c to use them as simple file encryptor/decryptor. Currently there is an issue where it won't process arbitrarily large files. Also, since single threaded, encryption process quite slow. These two issues will be fixed soon.
These both only work on Linux at the moment. To port to Windows, just note that I've used sys/stat.h header for the length of the file, which is a Linux exclusive, hence you may switch that out with a Windows equivalent.
