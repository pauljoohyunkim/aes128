# aes128
## Sample implementations of AES-128 encryption

The POC (Proof-of-Concept) code is currently being used to make a simple file encryption program. Read through in order to see step-by-step on how AES-128 works. Run "compile.sh" file to create binary files.


# AES-CTR File Encryptor/Decryptor
In the AES-CTR folder, you can compile both aes128_enc.c and aes128_dec.c to use them as simple file encryptor/decryptor. Also, since single threaded, encryption process could be quite slow. These two issues will be fixed soon.

These both only work on Linux at the moment. To port the C implementation to Windows, just note that I've used sys/stat.h header for the length of the file, which is a Linux exclusive, hence you may switch that out with a Windows equivalent.
