# aes128
## Sample implementations of AES-128 encryption

The POC (Proof-of-Concept) code is currently being used to make a simple file encryption program. Read through in order to see step-by-step on how AES-128 works. Run "compile.sh" file to create binary files.


## AES-CTR File Encryptor/Decryptor

In the AES-CTR folder, there are two implementations of CTR mode in two languages. One is written in C, and the other is written in x86 assembly.

**Note that they are both natively for Linux.**

Also note that x86 assembly implementation does not compile in an ARM environment. (One might need to port that somehow.)


### Compiling & Porting


- Run "./compile.sh" or "bash compile.sh" for either of the implementation to create a folder called "bin" and binaries inside.

- For the C implementation, you can somewhat easily port it to Windows version by changing the <sys/stat.h> with an Windows equivalent, or using a while loop to avoid using a separate header to determine the size of the input file altogether.
