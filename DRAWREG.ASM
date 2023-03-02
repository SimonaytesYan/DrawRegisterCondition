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

	in al, 60h					;get scan-code from 60-th pin
	cmp al, 43d					;\ or | buttons

	jne __end_draw_frame
		mov bx, 0b800h				;<----------------------|
		mov es, bx					;			 			|
		mov bp,	2*160d+134d			;offset in vmem			|
		mov dh, 15d					;height of the frame	| ARGUMENTS TO DRAW FRAME
		mov dl, 7d					;weight of the frame	|
		mov ah, 07eh				;color atr      <-------|
		
		xor bx, bx
		lea bx, cs:is_frame_visible							;put in bx offset of the labal is_frame_visible
		mov word ptr cx, cs:[bx]							;put in cx status is_frame_visible
		cmp cx, 1

		je __clear_frame
			mov si, cs:[offset double_frame]				;symbols to frame
			mov word ptr cs:[bx], 1d						;set new status
			call DrawFrame

			mov bx, 3*160d+136d
			call DrawReg 
		
			jmp __end_draw_frame
		__clear_frame:
			mov ah, 1d
			mov si, cs:[offset empty_frame]					;symbols to frame
			mov word ptr cs:[bx], 0d						;set new status
			call DrawFrame

__end_draw_frame:
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

is_frame_visible: dw 0

include FRAME.ASM
include SMALLIB.ASM

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