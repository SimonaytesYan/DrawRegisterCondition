.model tiny
.code
org 100h
locals __

Start:	jmp Main


NewInt09	proc
	push es						;
	push bx						;
	push ax						;save regs
	
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d*5+80d
	
	mov ah, 07eh
	in al, 60h					;get scan-code
	mov word ptr es:[bx], ax	;put in videomem
	
	pop ax						;
	pop bx						;
	pop es						;recover value of registers

	pushf
	db  09ah					;make jmp far
Old09Offset		dw 0			;jmp offset
Old90Segment 	dw 0			;jmp segment
	iret

endp NewInt09

Main:	
	xor bx, bx								;
	mov es, bx								;es = 0
	mov bx, 4*9								;Set es:[bx] to int table ot 9-th interruption

	mov ax, word ptr es:[bx]				;
	mov word ptr [Old09Offset], ax			;
	mov ax, word ptr es:[bx+2]				;
	mov word ptr [Old90Segment], ax			;save address of old interruption handler

	cli
	mov es:[bx], offset NewInt09	;
	mov ax, cs						;
	mov es:[bx+2], ax				;Put in int table new 9th int
	sti
	
	mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4					;Convert to paragraphs
	inc dx						;Round up
	int 21h						;End program with saving code of new int in memory

EOP:
end Start