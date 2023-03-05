.model tiny
.code
org 100h

Start:
    mov ax, 1111h
    mov bx, 2222h
    mov cx, 3333h
    mov dx, 4444h
    __next: 
        push ax
        in al, 60h  ;get scan-code
        cmp al, 1   ;if ecs pressed
        pop ax

        jne __next

    ret
    end Start