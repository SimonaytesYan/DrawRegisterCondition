.model tiny
.code
org 100h

Start:
    mov ax, 100h
    __next: jmp __next
    end Start