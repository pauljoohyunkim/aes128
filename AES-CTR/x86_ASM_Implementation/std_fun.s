.include "linux.s"

##### STRCMP #####
#ARGV 1: First string
#ARGV 2: Second string
#local var 1: length for first string
#local var 2: length for second string

# STACK
# Local Var 2   -8(%ebp)
# Local Var 1   -4(%ebp)
# Old %ebp      (%ebp)
# RET           4(%ebp)
# ARGV 1        8(%ebp)
# ARGV 2        12(%ebp)

#ADD 8 to esp after return
.type strcmp, @function
strcmp:
    pushl %ebp
    movl %esp, %ebp
    subl $8, %esp

    movl $0, %edi
    #Loading first string pointer
    movl 8(%ebp), %eax
    movb (%eax, %edi, 1), %cl

strcmp_loop_1:
    cmpb $0, %cl
    je strcmp_loop_1_exit
    incl %edi
    movb (%eax, %edi, 1), %cl
    jmp strcmp_loop_1

strcmp_loop_1_exit:
    movl %edi, -4(%ebp)

    movl $0, %edi
    #Loading second string pointer
    movl 12(%ebp), %eax
    movb (%eax, %edi, 1), %cl

strcmp_loop_2:
    cmpb $0, %cl
    je strcmp_loop_2_exit
    incl %edi
    movb (%eax, %edi, 1), %cl
    jmp strcmp_loop_2

strcmp_loop_2_exit:
    movl %edi, -8(%ebp)

    #Compare the length of the first and the second string
    #If the length is different, definitely different string
    movl -4(%ebp), %eax
    movl -8(%ebp), %ebx
    cmpl %eax, %ebx
    jne strcmp_different

strcmp_same_length:
    #movl %edi,%ecx
    movl $0, %edi
    movl 8(%ebp),%eax
    movl 12(%ebp),%ebx
    movb (%eax, %edi, 1), %cl
    movb (%ebx, %edi, 1), %dl
    
strcmp_same_length_loop:
    cmpl -4(%ebp), %edi
    je strcmp_same
    cmpb %cl, %dl
    jne strcmp_different
    incl %edi
    movb (%eax, %edi, 1), %cl
    movb (%ebx, %edi, 1), %dl
    jmp strcmp_same_length_loop


# Return 1
strcmp_different:
    movl $1, %eax
    movl %ebp, %esp
    popl %ebp
    ret
# Return 0
strcmp_same:
    movl $0, %eax
    movl %ebp, %esp
    popl %ebp
    ret



# https://stackoverflow.com/questions/1026327/what-common-algorithms-are-used-for-cs-rand
# Using linear congruential generator with a=1103515245, b=12345, and x0=time
#ARGV 1: Storage Location
#ARGV 2: Length
#ARGV 3: Divisor        (Will likely be 256)
#Local Var 1: X_n
##### RAND #####
# STACK
# Local Var 1   -4(%ebp)
# Old %ebp      (%ebp)
# RET           4(%ebp)
# ARGV 1        8(%ebp)
# ARGV 2        12(%ebp)
# ARGV 3        16(%ebp)

#ADD 12 to esp after return

.type rand, @function
rand:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp

    #Using time as seed     (Apparently ebx needs to be 0)
    movl $SYS_TIME, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL

    

    #Moving seed to X_n, and then saving remainder after dividing by ARGV 3
    #into the first entry of storage
    movl %eax, -4(%ebp)         #First local variable
    movl 16(%ebp),%ebx          #Divisor
    movl $0, %edx
    idivl %ebx

    movl $0, %edi
    movl 8(%ebp), %ecx
    movl %edx, (%ecx,%edi, 4)

    #Calculating the next X_{i}
    movl -4(%ebp), %eax         #Retrieving from first local variable
    imull $1103515245, %eax
    addl $12345, %eax


rand_loop:
    incl %edi
    cmpl 12(%ebp),%edi
    je end_rand_loop
    
    movl %eax, -4(%ebp)         #Saving X_n
    movl $0, %edx
    idivl %ebx
    movb %dl, (%ecx,%edi, 1)
    movl -4(%ebp), %eax         #Retrieving from first local variable
    imull $1103515245, %eax
    addl $12345, %eax
    jmp rand_loop

end_rand_loop:
    movl %ebp, %esp
    popl %ebp
    ret

