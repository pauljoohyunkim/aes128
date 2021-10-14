.include "linux.s"


##### BASE_ENC_256 #####
# For incrementing in 16 digit base 256 number.
# [0,0,0,...,0] -> [0,0,0,...,1]
# [0,0,0,...,0,255] -> [0,0,0,...,1,0]
# STACK
#
# Old %ebp                  (%ebp)
# RET                       4(%ebp)
# ARGV 1: Location of 16 byte 8(%ebp)

# Add 4 to %esp after usage.

.type base_enc_256, @function
base_enc_256:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %edx
    #Start from the right and go left.
    movl $15, %edi

    movb (%edx,%edi,1),%al         #Loading the digit to eax
    
    
    
base_enc_256_loop:
    addb $1, %al
    jc base_enc_256_set_zero       #If it is, deal with it.
    movb %al, (%edx, %edi, 1)      #If not, assign and return function.
    jmp base_enc_256_done   

base_enc_256_set_zero:
    movb %al, (%edx, %edi, 1)       #Put the digit
    cmpl $0, %edi                   #Check if it is the first digit.
    je base_enc_256_done            #If yes, return function.
    decl %edi                       #If not, decrease index
    movb (%edx,%edi,1),%al

    jmp base_enc_256_loop
    
base_enc_256_done:
    movl %ebp, %esp
    popl %ebp
    ret

##### SUBROTWORD #####
# Because AES128 has length of 4 words as its key, there is no
# need for separate definition for rotword and subword.
# https://en.wikipedia.org/wiki/AES_key_schedule

# STACK

# Local Var 1
# Old %ebp                  (%ebp)
# RET                       4(%ebp)
# ARGV 1: WORD_IN           8(%ebp)
# ARGV 2: WORD_OUT          12(%ebp)
# ARGV 3: SBOX
.type subrotword, @function
subrotword:
rotword_part:
    pushl %ebp
    movl %esp, %ebp


    movl 8(%ebp), %eax
    movl 12(%ebp), %esi
    movb (%eax), %dh        
    movb 1(%eax), %bl
    movb 2(%eax), %ch
    movb 3(%eax), %cl
    movb %bl, (%esi)
    movb %ch, 1(%esi)
    movb %cl, 2(%esi)
    movb %dh, 3(%esi)

subword_part:
    movl $0, %eax
    movl 16(%ebp), %edx         #SBOX

    movl $0, %edi
subword_part_loop:
    cmpl $4, %edi
    je subword_part_loop_done
    movb (%esi,%edi,1),%al      #Byte read from 4-byte word
    movb (%edx,%eax,1), %al     #Substitution
    movb %al, (%esi,%edi,1)
    incl %edi
    jmp subword_part_loop
subword_part_loop_done:
    movl %ebp, %esp
    popl %ebp
    ret

##### KEY_SCHEDULE #####

# STACK
# LOCAL VARIABLE 1: TEMP_BUFF for subrotword -4(%ebp)
# Old %ebp                          (%ebp)
# RET
# ARGV 1: KEY                       8(%ebp)
# ARGV 2: RCI for Key Schedule      12(%ebp)
# ARGV 3: RCON_TEMP_BUFFER          16(%ebp)
# ARGV 4: SBOX                      20(%ebp)

# 16 to esp after use
.type key_schedule, @function
key_schedule:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    
    movl 8(%ebp), %eax      #KEY
    addl $16, %eax          #eax will be acting as the index.
                            #Currently at 4th block

    movl 12(%ebp), %ebx     #RCI table
    movl 16(%ebp), %ecx     #RCON_TEMP_BUFFER

    movl $0, %edi           #Index

key_schedule_divisible_by_4:
    cmpl $10,%edi
    je key_schedule_end

    pushl %eax              #Protecting index (currently at 4th word)

    #XOR while protecting edi, ebx, ecx
    subl $4, %eax           #Currently at 3rd word
    movl %eax, %esi
    movl (%eax), %eax       #eax contains the actual contents of 3rd word
    movl %eax, -4(%ebp)     #Content in local variable

    subl $4, %ebp           #ebp now has the location of local variable

    #Saving all general purpose registers
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %esi
    pushl %edi


    pushl 24(%ebp)          #SBOX location is 24 away from local var
    pushl %ebp
    pushl %ebp
    addl $4, %ebp           #restore ebp to base of stack frame
    call subrotword
    addl $12, %esp

    popl %edi
    popl %esi
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax

    subl $12, %esi          #Currently at 0th word
    movl (%esi),%esi        #esi contains the actual contents of 0th word
    movl -4(%ebp),%eax
    

    xorl %eax, %esi         #xor-ed, and saved at esi

    popl %eax               #Back to 4th word
    movl %esi, (%eax)

key_schedule_rcon:
    #XOR with rcon
    pushl %eax
    movl (%eax), %esi
    movb (%ebx,%edi,1),%al
    movb %al, (%ecx)            #Loading RCON_TEMP_BUFFER
    movl (%ecx), %eax
    xorl %eax, %esi

    popl %eax
    movl %esi, (%eax)
    


key_schedule_other_block:
    addl $4, %eax               #5th block
    
    pushl %eax
    subl $4, %eax
    movl %eax, %esi
    subl $12, %esi
    movl (%eax), %eax
    movl (%esi), %esi
    xorl %eax, %esi

    popl %eax
    movl %esi, (%eax)

    addl $4, %eax               #6th block
    
    pushl %eax
    subl $4, %eax
    movl %eax, %esi
    subl $12, %esi
    movl (%eax), %eax
    movl (%esi), %esi
    xorl %eax, %esi

    popl %eax
    movl %esi, (%eax)

    addl $4, %eax               #7th block
    
    pushl %eax
    subl $4, %eax
    movl %eax, %esi
    subl $12, %esi
    movl (%eax), %eax
    movl (%esi), %esi
    xorl %eax, %esi

    popl %eax
    movl %esi, (%eax)

    incl %edi
    addl $4, %eax
    jmp key_schedule_divisible_by_4


key_schedule_end:
    movl %ebp, %esp
    popl %ebp
    ret


# STACK
# 
# Old %ebp                      (%ebp)
# RET                           4(%ebp)
# ARGV 1: 16-Byte Storage       8(%ebp)
# ARGV 2: SBOX                  12(%ebp)

# Add 8 to esp after usage.

.type sbox16, @function
sbox16:
    pushl %ebp
    movl %esp, %ebp
    
    movl 8(%ebp), %ecx              #Storage Location
    movl 12(%ebp), %edx             #SBOX

    movl $0, %edi                   #Index
    movl $0, %eax                   #Zeroing out eax

sbox16_loop:
    cmpl $16, %edi
    je sbox16_done
    movb (%ecx, %edi, 1), %al       #Higher part is zeroed. Only using al.
    movb (%edx, %eax, 1), %bl       #SBOXing
    movb %bl, (%ecx, %edi, 1)
    
    incl %edi
    jmp sbox16_loop

sbox16_done:
    movl %ebp, %esp
    popl %ebp
    ret




