# http://faculty.nps.edu/cseagle/assembly/sys_call.html
# 32 bit
    .equ SYS_OPEN, 5
    .equ SYS_WRITE, 4
    .equ SYS_READ, 3
    .equ SYS_CLOSE, 6
    .equ SYS_EXIT, 1
    .equ SYS_TIME, 13

    .equ O_RDONLY, 0
    .equ O_CREAT_WRONLY_TRUNC, 03101

    .equ STDIN, 0
    .equ STDOUT, 1
    .equ STDERR, 2
    .equ LINUX_SYSCALL ,0x80
    .equ END_OF_FILE, 0

    