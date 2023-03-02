.model tiny
.code
org 100h
locals __

Start:	jmp Main	

NewInt09	proc
	push es						;
	push bx						;
	push dx						;
	push ax						;
	push si						;
	push cx						;
	push bp						;
	push di						;save regs

	mov bx, 0b800h				;<----------------------|
	mov es, bx					;						|
	mov si, offset double_frame	;						|
	mov bp,	2*160d+134d			;offset in vmem			|
	mov dh, 15d					;height of the frame	|
	mov dl, 7d					;weight of the frame	|
	mov ah, 07eh				;color atr				|	DRAW FRAME
								;						|				
	call DrawFrame				;<----------------------|

	pop di						;
	pop bp						;
	pop cx						;
	pop si						;
	pop ax						;
	pop dx						;
	pop bx						;
	pop es						;recover value of registers
				
	db  0eah					;make jmp far
Old09Offset		dw 0			;jmp offset
Old90Segment 	dw 0			;jmp segment

endp NewInt09

include FRAME.ASM

EOP:

Main:	
	xor bx, bx								;
	mov es, bx								;es = 0
	mov bx, 4*9								;Set es:[bx] to int table ot 9-th interruption

	mov ax, word ptr es:[bx]				;
	mov word ptr [Old09Offset], ax			;
	mov ax, word ptr es:[bx+2]				;
	mov word ptr [Old90Segment], ax			;save address of old interruption handler

	cli
	mov es:[bx], offset NewInt09			;
	mov ax, cs								;
	mov es:[bx+2], ax						;Put in int table new 9th int
	sti

	mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4								;Convert to paragraphs
	inc dx									;Round up
	int 21h									;End program with saving code of new int in memory

end Start