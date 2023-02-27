.model tiny
.186
.code
org 100h
locals __

Start:	jmp Main

Int09	proc
	push es
	push bx
	push ax
	
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d*5+80d
	
	mov ah, 07eh
	in al, 60h					;get scan-code
	mov word ptr es:[bx], ax
	
	in al, 61h				;
	or al, 80h				;
	out 61h, al				;
	and al, not 80h			;
	out 61h, al				;Say to keyboard controler OK
	
	mov al, 20h				;
	out 20h, al				;Say to int controler OK

	pop ax
	pop bx
	pop es
	iret
	endp
EOP:

Main:	
	mov bx, 0h					;
	mov es, bx					;
	mov bx, 4*9					;
	mov es:[bx], offset Int09	;
	mov ax, cs					;
	mov es:[bx+2], ax			;Put in int table new 9th int
	
	mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4			;Convert to paragraphs
	inc dx				;Round up
	int 21h				;End program with saving code of new int in memory

end Start