.include "linux.s"
.include "std_fun.s"
.include "custom_fun.s"

.section .data
# Rijndael S-box Lookup
sbox:
    .byte 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76, 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0, 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15, 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75, 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84, 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf, 0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8, 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2, 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73, 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb, 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79, 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08, 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a, 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e, 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf, 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
# Multiplication Look-up Table for multiplying by 2 and 3 in Galois Field
table_2:
    .byte 0x00,0x02,0x04,0x06,0x08,0x0a,0x0c,0x0e,0x10,0x12,0x14,0x16,0x18,0x1a,0x1c,0x1e,0x20,0x22,0x24,0x26,0x28,0x2a,0x2c,0x2e,0x30,0x32,0x34,0x36,0x38,0x3a,0x3c,0x3e,0x40,0x42,0x44,0x46,0x48,0x4a,0x4c,0x4e,0x50,0x52,0x54,0x56,0x58,0x5a,0x5c,0x5e,0x60,0x62,0x64,0x66,0x68,0x6a,0x6c,0x6e,0x70,0x72,0x74,0x76,0x78,0x7a,0x7c,0x7e,0x80,0x82,0x84,0x86,0x88,0x8a,0x8c,0x8e,0x90,0x92,0x94,0x96,0x98,0x9a,0x9c,0x9e,0xa0,0xa2,0xa4,0xa6,0xa8,0xaa,0xac,0xae,0xb0,0xb2,0xb4,0xb6,0xb8,0xba,0xbc,0xbe,0xc0,0xc2,0xc4,0xc6,0xc8,0xca,0xcc,0xce,0xd0,0xd2,0xd4,0xd6,0xd8,0xda,0xdc,0xde,0xe0,0xe2,0xe4,0xe6,0xe8,0xea,0xec,0xee,0xf0,0xf2,0xf4,0xf6,0xf8,0xfa,0xfc,0xfe,0x1b,0x19,0x1f,0x1d,0x13,0x11,0x17,0x15,0x0b,0x09,0x0f,0x0d,0x03,0x01,0x07,0x05,0x3b,0x39,0x3f,0x3d,0x33,0x31,0x37,0x35,0x2b,0x29,0x2f,0x2d,0x23,0x21,0x27,0x25,0x5b,0x59,0x5f,0x5d,0x53,0x51,0x57,0x55,0x4b,0x49,0x4f,0x4d,0x43,0x41,0x47,0x45,0x7b,0x79,0x7f,0x7d,0x73,0x71,0x77,0x75,0x6b,0x69,0x6f,0x6d,0x63,0x61,0x67,0x65,0x9b,0x99,0x9f,0x9d,0x93,0x91,0x97,0x95,0x8b,0x89,0x8f,0x8d,0x83,0x81,0x87,0x85,0xbb,0xb9,0xbf,0xbd,0xb3,0xb1,0xb7,0xb5,0xab,0xa9,0xaf,0xad,0xa3,0xa1,0xa7,0xa5,0xdb,0xd9,0xdf,0xdd,0xd3,0xd1,0xd7,0xd5,0xcb,0xc9,0xcf,0xcd,0xc3,0xc1,0xc7,0xc5,0xfb,0xf9,0xff,0xfd,0xf3,0xf1,0xf7,0xf5,0xeb,0xe9,0xef,0xed,0xe3,0xe1,0xe7,0xe5
table_3:
    .byte 0x00,0x03,0x06,0x05,0x0c,0x0f,0x0a,0x09,0x18,0x1b,0x1e,0x1d,0x14,0x17,0x12,0x11,0x30,0x33,0x36,0x35,0x3c,0x3f,0x3a,0x39,0x28,0x2b,0x2e,0x2d,0x24,0x27,0x22,0x21,0x60,0x63,0x66,0x65,0x6c,0x6f,0x6a,0x69,0x78,0x7b,0x7e,0x7d,0x74,0x77,0x72,0x71,0x50,0x53,0x56,0x55,0x5c,0x5f,0x5a,0x59,0x48,0x4b,0x4e,0x4d,0x44,0x47,0x42,0x41,0xc0,0xc3,0xc6,0xc5,0xcc,0xcf,0xca,0xc9,0xd8,0xdb,0xde,0xdd,0xd4,0xd7,0xd2,0xd1,0xf0,0xf3,0xf6,0xf5,0xfc,0xff,0xfa,0xf9,0xe8,0xeb,0xee,0xed,0xe4,0xe7,0xe2,0xe1,0xa0,0xa3,0xa6,0xa5,0xac,0xaf,0xaa,0xa9,0xb8,0xbb,0xbe,0xbd,0xb4,0xb7,0xb2,0xb1,0x90,0x93,0x96,0x95,0x9c,0x9f,0x9a,0x99,0x88,0x8b,0x8e,0x8d,0x84,0x87,0x82,0x81,0x9b,0x98,0x9d,0x9e,0x97,0x94,0x91,0x92,0x83,0x80,0x85,0x86,0x8f,0x8c,0x89,0x8a,0xab,0xa8,0xad,0xae,0xa7,0xa4,0xa1,0xa2,0xb3,0xb0,0xb5,0xb6,0xbf,0xbc,0xb9,0xba,0xfb,0xf8,0xfd,0xfe,0xf7,0xf4,0xf1,0xf2,0xe3,0xe0,0xe5,0xe6,0xef,0xec,0xe9,0xea,0xcb,0xc8,0xcd,0xce,0xc7,0xc4,0xc1,0xc2,0xd3,0xd0,0xd5,0xd6,0xdf,0xdc,0xd9,0xda,0x5b,0x58,0x5d,0x5e,0x57,0x54,0x51,0x52,0x43,0x40,0x45,0x46,0x4f,0x4c,0x49,0x4a,0x6b,0x68,0x6d,0x6e,0x67,0x64,0x61,0x62,0x73,0x70,0x75,0x76,0x7f,0x7c,0x79,0x7a,0x3b,0x38,0x3d,0x3e,0x37,0x34,0x31,0x32,0x23,0x20,0x25,0x26,0x2f,0x2c,0x29,0x2a,0x0b,0x08,0x0d,0x0e,0x07,0x04,0x01,0x02,0x13,0x10,0x15,0x16,0x1f,0x1c,0x19,0x1a
rci:
    .byte 0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x1b,0x36
wrong_argc:             #74 characters
    .ascii "Syntax: aes128_dec [input filename] [16-byte key file] [output filename]\n\0"
same_filenames:         #86 characters
    .ascii "Input file has the same name as the output file. This will cause a problem. Aborted.\n\0"
read_key_error:         #59 characters
    .ascii "Error while reading key. Make sure the key file is valid?\n\0"
read_input_file_error:  #37 characters
    .ascii "Error while reading the input file.\n\0"

.section .bss
    .lcomm BUFFER,16
    .lcomm KEY, 11*16
    .lcomm NONCE, 16
    .lcomm COUNTER, 16
    .lcomm NONCE_XOR_COUNTER, 16
    .lcomm RCON_TEMP_BUFFER, 4
    .lcomm TEMP, 16


.section .text

    .equ WRONG_ARGC_MESSAGE_LEN, 74
    .equ SAME_FILENAMES_MESSAGE_LEN, 86
    .equ READ_KEY_ERROR_MESSAGE_LEN, 59
    .equ READ_INPUT_FILE_ERROR_MESSAGE_LEN, 37

    .equ ST_SIZE_RESERVE, 12
    .equ ST_KEY_IN, -4
    .equ ST_FD_IN, -8
    .equ ST_FD_OUT, -12
    .equ ST_ARGC, 0
    .equ ST_ARGV_0, 4       #Name of Program
    .equ ST_ARGV_1, 8       #INPUT
    .equ ST_ARGV_2, 12      #KEY
    .equ ST_ARGV_3, 16      #OUTPUT

    .globl _start
_start:
    #Check if there are 4 arguments.
    movl %esp, %ebp
    subl $ST_SIZE_RESERVE, %esp

    #If the number of arguments is not 4,
    #end program while showing syntax
    cmpl $4, ST_ARGC(%ebp)  
    jne argc_error_end_program

    pushl ST_ARGV_1(%ebp)
    pushl ST_ARGV_3(%ebp) 
    call strcmp
    addl $8, %esp
    #%eax = indicator(different)

    cmpl $0, %eax
    je same_filenames_end_program
main_open_key_file:
    #Open the key file
    movl $SYS_OPEN, %eax
    movl ST_ARGV_2(%ebp),%ebx
    movl $O_RDONLY, %ecx
    movl $0666, %edx
    int $LINUX_SYSCALL

    #Store the file descriptor
    movl %eax, ST_KEY_IN(%ebp)

    #Read the key file to KEY
    movl %eax, %ebx
    movl $SYS_READ, %eax
    movl $KEY, %ecx
    movl $16, %edx
    int $LINUX_SYSCALL

    #Check if key reading was successful.
    cmpl $0, %eax
    jle read_key_error_end_program

    #Close the key file
    movl $SYS_CLOSE, %eax
    movl ST_KEY_IN(%ebp),%ebx
    int $LINUX_SYSCALL

main_key_schedule:
    #Generating expanded key
    pushl $sbox
    pushl $RCON_TEMP_BUFFER
    pushl $rci
    pushl $KEY
    call key_schedule
    addl $12, %esp

main_open_file_in:
    #Open the input file
    movl $SYS_OPEN, %eax
    movl ST_ARGV_1(%ebp), %ebx
    movl $O_RDONLY, %ecx
    movl $0666,%edx
    int $LINUX_SYSCALL

    #If there is an error
    cmpl $0, %eax
    jl read_file_in_error_end_program

    #Store the file descriptor
    movl %eax, ST_FD_IN(%ebp)

main_open_file_out:
    #Open the output file
    movl $SYS_OPEN, %eax
    movl ST_ARGV_3(%ebp), %ebx
    movl $O_CREAT_WRONLY_TRUNC, %ecx        #Writing mode
    movl $0666, %edx
    int $LINUX_SYSCALL

    #Save file descriptor
    movl %eax, ST_FD_OUT(%ebp)

main_nonce_acquisition:
    #Read from in file
    movl $SYS_READ, %eax
    movl ST_FD_IN(%ebp), %ebx
    movl $NONCE, %ecx
    movl $16, %edx
    int $LINUX_SYSCALL

    #See if nonce acquisition was successful
    cmpl $16, %eax
    jl read_file_in_error_end_program

main_nonce_xor_key:
    # We eventually need to do nonce xor counter xor key
    # To avoid doing this at every loop, we xor the nonce with our key beforehand.
    # And write it onto our nonce.
    movl $NONCE, %esi                               #Address of NONCE in esi
    movl $KEY, %ecx                                 #Address of KEY in ecx

    
    movl (%esi), %eax                               #eax = 4 bytes of nonce
    movl (%ecx), %ebx                               #ebx = 4 bytes of key
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, (%esi)                               #Storing at NONCE

    movl 4(%esi), %eax                               #eax = 4 bytes of nonce
    movl 4(%ecx), %ebx                               #ebx = 4 bytes of key
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 4(%esi)                               #Storing at NONCE

    movl 8(%esi), %eax                               #eax = 4 bytes of nonce
    movl 8(%ecx), %ebx                               #ebx = 4 bytes of key
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 8(%esi)                               #Storing at NONCE

    movl 12(%esi), %eax                               #eax = 4 bytes of nonce
    movl 12(%ecx), %ebx                               #ebx = 4 bytes of key
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 12(%esi)                               #Storing at NONCE

##################FROM NOW ON, NONCE IS ACTUALLY NONCE + KEY##################

main_read_file_16:
    #Reading sixteen bytes
    movl $SYS_READ, %eax
    movl ST_FD_IN(%ebp), %ebx
    movl $BUFFER, %ecx
    movl $16, %edx
    int $LINUX_SYSCALL

    #Check if 16 bytes are read.
    cmpl $16, %eax
    #If less, jump to main_read_file_less_than_16
    jl main_read_file_less_than_16


#This is the process assuming 16 bytes read.
main_aes_ctr_process:

main_aes_ctr_process_nonce_xor_counter:
    #XORing modified nonce and counter, and writing to nonce_xor_counter
    movl $NONCE, %esi                               #Address of NONCE in esi
    movl $COUNTER, %ecx                             #Address of COUNTER in edi
    movl $NONCE_XOR_COUNTER, %edx                   #Address of NONCE_XOR_COUNTER in ecx
    
    movl (%esi), %eax                               #eax = 4 bytes of modified_nonce
    movl (%ecx), %ebx                               #ebx = 4 bytes of counter
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, (%edx)                               #Storing at NONCE_XOR_COUNTER

    movl 4(%esi), %eax                               #eax = 4 bytes of modified_nonce
    movl 4(%ecx), %ebx                               #ebx = 4 bytes of counter
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 4(%edx)                               #Storing at NONCE_XOR_COUNTER

    movl 8(%esi), %eax                               #eax = 4 bytes of modified_nonce
    movl 8(%ecx), %ebx                               #ebx = 4 bytes of counter
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 8(%edx)                               #Storing at NONCE_XOR_COUNTER

    movl 12(%esi), %eax                               #eax = 4 bytes of modified_nonce
    movl 12(%ecx), %ebx                               #ebx = 4 bytes of counter
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 12(%edx)                               #Storing at NONCE_XOR_COUNTER

main_aes_ctr_process_increment_counter:
    #Incrementing counter
    pushl $COUNTER
    call base_enc_256
    addl $4, %esp
    
main_aes_ctr_process_add_key:

    movl $KEY, %eax                         #Location of KEY
    movl $NONCE_XOR_COUNTER, %ebx           #Location of NONCE_XOR_COUNTER

    movl (%eax), %ecx                       #4 bytes of KEY
    movl (%ebx), %edx
    xorl %ecx, %edx
    movl %edx, (%ebx)

    movl 4(%eax), %ecx
    movl 4(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 4(%ebx)

    movl 8(%eax), %ecx
    movl 8(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 8(%ebx)

    movl 12(%eax), %ecx
    movl 12(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 12(%ebx)

    #For looping rounds, and also navigating expanded key
    movl $16, %edi
main_aes_round_sbox:
    
    pushl %edi
    #SBOXing NONCE_XOR_COUNTER
    pushl $sbox
    pushl $NONCE_XOR_COUNTER
    call sbox16
    addl $8, %esp
    popl %edi

main_aes_round_perm:
    movl $NONCE_XOR_COUNTER, %esi           #esi contains the address of NONCE_XOR_COUNTER

    #Second row
    movb 1(%esi), %ah
    movb 5(%esi), %al
    movb 9(%esi), %bh
    movb 13(%esi), %bl
    movb %al, 1(%esi)
    movb %bh, 5(%esi)
    movb %bl, 9(%esi)
    movb %ah, 13(%esi)

    #Third row
    movb 2(%esi), %ah
    movb 6(%esi), %al
    movb 10(%esi), %bh
    movb 14(%esi), %bl
    movb %al, 14(%esi)
    movb %bh, 2(%esi)
    movb %bl, 6(%esi)
    movb %ah, 10(%esi)

    #Fourth row
    movb 3(%esi), %ah
    movb 7(%esi), %al
    movb 11(%esi), %bh
    movb 15(%esi), %bl
    movb %al, 11(%esi)
    movb %bh, 15(%esi)
    movb %bl, 3(%esi)
    movb %ah, 7(%esi)

main_aes_round_mult:
    #Check if last round, don't multiply
    cmpl $160, %edi
    je main_aes_round_add_subkey
    #Multiplication by matrix in Galois Field
    pushl $TEMP
    pushl $NONCE_XOR_COUNTER
    call mult
    addl $8, %esp

main_aes_round_add_subkey:
    #edi holds offset from beginning of key
    movl $NONCE_XOR_COUNTER, %eax               #Address of eax
    movl (%eax), %ebx                           #4-bytes of NONCE_XOR_COUNTER
    movl KEY(%edi), %ecx
    xorl %ebx, %ecx
    movl %ecx, (%eax)

    addl $4, %edi
    movl 4(%eax), %ebx
    movl KEY(%edi), %ecx
    xorl %ebx, %ecx
    movl %ecx, 4(%eax)

    addl $4, %edi
    movl 8(%eax), %ebx
    movl KEY(%edi), %ecx
    xorl %ebx, %ecx
    movl %ecx, 8(%eax)

    addl $4, %edi
    movl 12(%eax), %ebx
    movl KEY(%edi), %ecx
    xorl %ebx, %ecx
    movl %ecx, 12(%eax)

    addl $4, %edi

    cmpl $176, %edi                 #Check if done.
    je main_aes_round_done
    jmp main_aes_round_sbox

main_aes_round_done:
    #XORing with BUFFER
    movl $BUFFER, %eax
    movl $NONCE_XOR_COUNTER, %ebx
    
    #Loading 4 bytes
    movl (%eax), %ecx
    movl (%ebx), %edx
    xorl %ecx, %edx
    movl %edx, (%eax)               #Writing to BUFFER

    movl 4(%eax), %ecx
    movl 4(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 4(%eax) 

    movl 8(%eax), %ecx
    movl 8(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 8(%eax)

    movl 12(%eax), %ecx
    movl 12(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 12(%eax)

main_write_block_16:
    movl $SYS_WRITE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    movl $BUFFER, %ecx
    movl $16, %edx
    int $LINUX_SYSCALL

    jmp main_read_file_16


# In the case that the block read was less than 16, it means it is the last block of the file.
main_read_file_less_than_16:
    pushl %eax                                      #Number of bytes to write
main_aes_ctr_process_nonce_xor_counter_lt16:
    #XORing modified nonce and counter, and writing to nonce_xor_counter
    movl $NONCE, %esi                               #Address of NONCE in esi
    movl $COUNTER, %ecx                             #Address of COUNTER in edi
    movl $NONCE_XOR_COUNTER, %edx                   #Address of NONCE_XOR_COUNTER in ecx
    
    movl (%esi), %eax                               #eax = 4 bytes of modified_nonce
    movl (%ecx), %ebx                               #ebx = 4 bytes of counter
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, (%edx)                               #Storing at NONCE_XOR_COUNTER

    movl 4(%esi), %eax                               #eax = 4 bytes of modified_nonce
    movl 4(%ecx), %ebx                               #ebx = 4 bytes of counter
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 4(%edx)                               #Storing at NONCE_XOR_COUNTER

    movl 8(%esi), %eax                               #eax = 4 bytes of modified_nonce
    movl 8(%ecx), %ebx                               #ebx = 4 bytes of counter
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 8(%edx)                               #Storing at NONCE_XOR_COUNTER

    movl 12(%esi), %eax                               #eax = 4 bytes of modified_nonce
    movl 12(%ecx), %ebx                               #ebx = 4 bytes of counter
    xorl %ebx, %eax                                 #XORing nonce and counter
    movl %eax, 12(%edx)                               #Storing at NONCE_XOR_COUNTER

main_aes_ctr_process_increment_counter_lt16:
    #Incrementing counter
    pushl $COUNTER
    call base_enc_256
    addl $4, %esp
    
main_aes_ctr_process_add_key_lt16:

    movl $KEY, %eax                         #Location of KEY
    movl $NONCE_XOR_COUNTER, %ebx           #Location of NONCE_XOR_COUNTER

    movl (%eax), %ecx                       #4 bytes of KEY
    movl (%ebx), %edx
    xorl %ecx, %edx
    movl %edx, (%ebx)

    movl 4(%eax), %ecx
    movl 4(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 4(%ebx)

    movl 8(%eax), %ecx
    movl 8(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 8(%ebx)

    movl 12(%eax), %ecx
    movl 12(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 12(%ebx)

    #For looping rounds, and also navigating expanded key
    movl $16, %edi
main_aes_round_sbox_lt16:
    
    pushl %edi
    #SBOXing NONCE_XOR_COUNTER
    pushl $sbox
    pushl $NONCE_XOR_COUNTER
    call sbox16
    addl $8, %esp
    popl %edi

main_aes_round_perm_lt16:
    movl $NONCE_XOR_COUNTER, %esi           #esi contains the address of NONCE_XOR_COUNTER

    #Second row
    movb 1(%esi), %ah
    movb 5(%esi), %al
    movb 9(%esi), %bh
    movb 13(%esi), %bl
    movb %al, 1(%esi)
    movb %bh, 5(%esi)
    movb %bl, 9(%esi)
    movb %ah, 13(%esi)

    #Third row
    movb 2(%esi), %ah
    movb 6(%esi), %al
    movb 10(%esi), %bh
    movb 14(%esi), %bl
    movb %al, 14(%esi)
    movb %bh, 2(%esi)
    movb %bl, 6(%esi)
    movb %ah, 10(%esi)

    #Fourth row
    movb 3(%esi), %ah
    movb 7(%esi), %al
    movb 11(%esi), %bh
    movb 15(%esi), %bl
    movb %al, 11(%esi)
    movb %bh, 15(%esi)
    movb %bl, 3(%esi)
    movb %ah, 7(%esi)

main_aes_round_mult_lt16:
    #Check if last round, don't multiply
    cmpl $160, %edi
    je main_aes_round_add_subkey_lt16
    #Multiplication by matrix in Galois Field
    pushl $TEMP
    pushl $NONCE_XOR_COUNTER
    call mult
    addl $8, %esp

main_aes_round_add_subkey_lt16:
    #edi holds offset from beginning of key
    movl $NONCE_XOR_COUNTER, %eax               #Address of eax
    movl (%eax), %ebx                           #4-bytes of NONCE_XOR_COUNTER
    movl KEY(%edi), %ecx
    xorl %ebx, %ecx
    movl %ecx, (%eax)

    addl $4, %edi
    movl 4(%eax), %ebx
    movl KEY(%edi), %ecx
    xorl %ebx, %ecx
    movl %ecx, 4(%eax)

    addl $4, %edi
    movl 8(%eax), %ebx
    movl KEY(%edi), %ecx
    xorl %ebx, %ecx
    movl %ecx, 8(%eax)

    addl $4, %edi
    movl 12(%eax), %ebx
    movl KEY(%edi), %ecx
    xorl %ebx, %ecx
    movl %ecx, 12(%eax)

    addl $4, %edi

    cmpl $176, %edi                 #Check if done.
    je main_aes_round_done_lt16
    jmp main_aes_round_sbox_lt16

main_aes_round_done_lt16:
    #XORing with BUFFER
    movl $BUFFER, %eax
    movl $NONCE_XOR_COUNTER, %ebx
    
    #Loading 4 bytes
    movl (%eax), %ecx
    movl (%ebx), %edx
    xorl %ecx, %edx
    movl %edx, (%eax)               #Writing to BUFFER

    movl 4(%eax), %ecx
    movl 4(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 4(%eax) 

    movl 8(%eax), %ecx
    movl 8(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 8(%eax)

    movl 12(%eax), %ecx
    movl 12(%ebx), %edx
    xorl %ecx, %edx
    movl %edx, 12(%eax)

main_write_block_lt16:
    popl %edx
    movl $SYS_WRITE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    movl $BUFFER, %ecx
    int $LINUX_SYSCALL

    jmp end_program
    

##### ERRORS #####

argc_error_end_program:
    #Write syntax message
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx
    movl $wrong_argc, %ecx
    movl $WRONG_ARGC_MESSAGE_LEN, %edx
    int $LINUX_SYSCALL

    jmp end_program_error

same_filenames_end_program:
    #Error message
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx
    movl $same_filenames, %ecx
    movl $SAME_FILENAMES_MESSAGE_LEN, %edx
    int $LINUX_SYSCALL

    jmp end_program_error

read_key_error_end_program:
    #Close the key file
    movl $SYS_CLOSE, %eax
    movl ST_KEY_IN(%ebp),%ebx
    int $LINUX_SYSCALL

    #Error Message
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx
    movl $read_key_error, %ecx
    movl $READ_KEY_ERROR_MESSAGE_LEN, %edx
    int $LINUX_SYSCALL

    jmp end_program_error

read_file_in_error_end_program:
    #Close the input file
    movl $SYS_CLOSE, %eax
    movl ST_FD_IN(%ebp), %ebx
    int $LINUX_SYSCALL

    #Error Message
    movl $SYS_WRITE, %eax
    movl $STDOUT, %ebx
    movl $read_input_file_error, %ecx
    movl $READ_INPUT_FILE_ERROR_MESSAGE_LEN, %edx
    int $LINUX_SYSCALL

    jmp end_program_error



#When exiting due to error
end_program_error:
    #End Program
    movl $SYS_EXIT, %eax
    movl $1, %ebx       #Exit code: 1
    int $LINUX_SYSCALL

end_program:

    #Close the input file
    movl $SYS_CLOSE, %eax
    movl ST_FD_IN(%ebp), %ebx
    int $LINUX_SYSCALL

    #Close the output file
    movl $SYS_CLOSE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    int $LINUX_SYSCALL

    #Exit call
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
















# STACK

# Old %ebp                              (%ebp)
# RET                                   4(%ebp)
# ARGV 1: NONCE_XOR_COUNTER             8(%ebp)
# ARGV 2: TEMP                          12(%ebp)


#Multiplying by the following matrix:
    #2,3,1,1
    #1,2,3,1
    #1,1,2,3
    #3,1,1,2
    #in Galois Field

#Add 16 to esp after usage
.type mult, @function
mult:
    
    pushl %ebp
    movl %esp, %ebp

    movl $0, %eax
    movl $0, %ebx
    movl 8(%ebp), %ecx
    movl 12(%ebp), %edx
pos_0:
    movb (%ecx), %al
    movb table_2(,%eax,1), %al
    movb 1(%ecx), %bl
    movb table_3(,%ebx,1), %bl
    xorb %bl, %al
    movb 2(%ecx), %bl
    xorb %bl, %al
    movb 3(%ecx), %bl
    xorb %bl, %al
    movb %al, (%edx)
pos_1:
    movb (%ecx), %al
    movb 1(%ecx), %bl
    movb table_2(,%ebx,1), %bl
    xorb %bl, %al
    movb 2(%ecx), %bl
    movb table_3(,%ebx,1), %bl
    xorb %bl, %al
    movb 3(%ecx), %bl
    xorb %bl, %al
    movb %al, 1(%edx)
pos_2:
    movb (%ecx), %al
    movb 1(%ecx), %bl
    xorb %bl, %al
    movb 2(%ecx), %bl
    movb table_2(,%ebx,1),%bl
    xorb %bl, %al
    movb 3(%ecx), %bl
    movb table_3(,%ebx,1),%bl
    xorb %bl, %al
    movb %al, 2(%edx)
pos_3:
    movb (%ecx), %al
    movb table_3(,%eax,1),%al
    movb 1(%ecx), %bl
    xorb %bl, %al
    movb 2(%ecx), %bl
    xorb %bl, %al
    movb 3(%ecx), %bl
    movb table_2(,%ebx,1), %bl
    xorb %bl, %al
    movb %al, 3(%edx)

pos_4:
    movb 4(%ecx), %al
    movb table_2(,%eax,1), %al
    movb 5(%ecx), %bl
    movb table_3(,%ebx,1), %bl
    xorb %bl, %al
    movb 6(%ecx), %bl
    xorb %bl, %al
    movb 7(%ecx), %bl
    xorb %bl, %al
    movb %al, 4(%edx)

pos_5:
    movb 4(%ecx), %al
    movb 5(%ecx), %bl
    movb table_2(,%ebx,1), %bl
    xorb %bl, %al
    movb 6(%ecx), %bl
    movb table_3(,%ebx,1), %bl
    xorb %bl, %al
    movb 7(%ecx), %bl
    xorb %bl, %al
    movb %al, 5(%edx)

pos_6:
    movb 4(%ecx), %al
    movb 5(%ecx), %bl
    xorb %bl, %al
    movb 6(%ecx), %bl
    movb table_2(,%ebx,1),%bl
    xorb %bl, %al
    movb 7(%ecx), %bl
    movb table_3(,%ebx,1),%bl
    xorb %bl, %al
    movb %al, 6(%edx)
    
pos_7:
    movb 4(%ecx), %al
    movb table_3(,%eax,1),%al
    movb 5(%ecx), %bl
    xorb %bl, %al
    movb 6(%ecx), %bl
    xorb %bl, %al
    movb 7(%ecx), %bl
    movb table_2(,%ebx,1), %bl
    xorb %bl, %al
    movb %al, 7(%edx)
pos_8:
    movb 8(%ecx), %al
    movb table_2(,%eax,1), %al
    movb 9(%ecx), %bl
    movb table_3(,%ebx,1), %bl
    xorb %bl, %al
    movb 10(%ecx), %bl
    xorb %bl, %al
    movb 11(%ecx), %bl
    xorb %bl, %al
    movb %al, 8(%edx)
pos_9:
    movb 8(%ecx), %al
    movb 9(%ecx), %bl
    movb table_2(,%ebx,1), %bl
    xorb %bl, %al
    movb 10(%ecx), %bl
    movb table_3(,%ebx,1), %bl
    xorb %bl, %al
    movb 11(%ecx), %bl
    xorb %bl, %al
    movb %al, 9(%edx)

pos_10:
    movb 8(%ecx), %al
    movb 9(%ecx), %bl
    xorb %bl, %al
    movb 10(%ecx), %bl
    movb table_2(,%ebx,1),%bl
    xorb %bl, %al
    movb 11(%ecx), %bl
    movb table_3(,%ebx,1),%bl
    xorb %bl, %al
    movb %al, 10(%edx)

pos_11:
    movb 8(%ecx), %al
    movb table_3(,%eax,1),%al
    movb 9(%ecx), %bl
    xorb %bl, %al
    movb 10(%ecx), %bl
    xorb %bl, %al
    movb 11(%ecx), %bl
    movb table_2(,%ebx,1), %bl
    xorb %bl, %al
    movb %al, 11(%edx)
pos_12:
    movb 12(%ecx), %al
    movb table_2(,%eax,1), %al
    movb 13(%ecx), %bl
    movb table_3(,%ebx,1), %bl
    xorb %bl, %al
    movb 14(%ecx), %bl
    xorb %bl, %al
    movb 15(%ecx), %bl
    xorb %bl, %al
    movb %al, 12(%edx)
pos_13:
    movb 12(%ecx), %al
    movb 13(%ecx), %bl
    movb table_2(,%ebx,1), %bl
    xorb %bl, %al
    movb 14(%ecx), %bl
    movb table_3(,%ebx,1), %bl
    xorb %bl, %al
    movb 15(%ecx), %bl
    xorb %bl, %al
    movb %al, 13(%edx)

pos_14:
    movb 12(%ecx), %al
    movb 13(%ecx), %bl
    xorb %bl, %al
    movb 14(%ecx), %bl
    movb table_2(,%ebx,1),%bl
    xorb %bl, %al
    movb 15(%ecx), %bl
    movb table_3(,%ebx,1),%bl
    xorb %bl, %al
    movb %al, 14(%edx)

pos_15:
    movb 12(%ecx), %al
    movb table_3(,%eax,1),%al
    movb 13(%ecx), %bl
    xorb %bl, %al
    movb 14(%ecx), %bl
    xorb %bl, %al
    movb 15(%ecx), %bl
    movb table_2(,%ebx,1), %bl
    xorb %bl, %al
    movb %al, 15(%edx)
mult_copy:
    #Copying contents from TEMP to NONCE_XOR_COUNTER
    movl (%edx), %eax
    movl %eax, (%ecx)
    movl 4(%edx), %eax
    movl %eax, 4(%ecx)
    movl 8(%edx), %eax
    movl %eax, 8(%ecx)
    movl 12(%edx), %eax
    movl %eax, 12(%ecx)

mult_done:
    movl %ebp, %esp
    popl %ebp
    ret

