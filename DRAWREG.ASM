.model tiny
.code
org 100h
locals __

Start:	jmp Main	

NewInt08 proc
	
	push ss						;
	push es						;
	push ds						;
	push sp						;
	push bp						;
	push di						;
	push si						;
	push dx						;
	push cx						;
	push bx						;
	push ax						;save regs
	
	lea bx, cs:is_frame_visible							;put in bx offset of the label is_frame_visible
	mov word ptr cx, cs:[bx]							;put in cx status is_frame_visible
	cmp cx, 0

	je __end_draw_frame
		mov bx, 0b800h
		mov es, bx

		mov bp,	2*160d+134d					;offset in vmem			|
		mov dh, 13d							;height of the frame	|
		mov dl, 9d							;weight of the frame	| ARGUMENTS TO DRAW FRAME
		mov ah, 07eh						;color atr				|
		mov si, cs:[offset double_frame]	;symbols to frame		|
		call DrawFrame
			
		mov bx, 3*160d+136d
		call DrawRegText

		mov bx, 3*160d+150d
		mov dh, 71h
		call DrawRegNumber

__end_draw_frame:
	pop ax						;
	pop bx						;
	pop cx						;
	pop dx						;
	pop si						;
	pop di						;
	pop bp						;
	pop sp						;
	pop ds						;
	pop es						;
	pop ss						;recover value of registers


	db  0eah					;make jmp far
	Old08Offset		dw 0			;jmp offset
	Old08Segment 	dw 0			;jmp segment
endp NewInt08

NewInt09	proc
	push ss						;
	push es						;
	push ds						;
	push sp						;
	push bp						;
	push di						;
	push si						;
	push dx						;
	push cx						;
	push bx						;
	push ax						;save regs
	
	in al, 60h					;get scan-code from 60-th pin
	cmp al, 43d					;\ or | buttons
	
	jne __end_draw_frame
		xor bx, bx
		lea bx, cs:is_frame_visible					;put in bx offset of the label is_frame_visible
		mov word ptr cx, cs:[bx]					;put in cx status is_frame_visible
		cmp cx, 1

		je __clear_frame			
			mov word ptr cs:[bx], 1d				;set new status
			jmp __end_draw_frame
		__clear_frame:			
			mov word ptr cs:[bx], 0d						;set new status

			mov bx, 0b800h				;						|
			mov es, bx					;			 			|
			mov bp,	2*160d+134d			;offset in vmem			|
			mov dh, 13d					;height of the frame	| ARGUMENTS TO DRAW FRAME
			mov dl, 9d					;weight of the frame 	|
			mov ah, 1d

			mov si, cs:[offset empty_frame]					;symbols to frame
			call DrawFrame

__end_draw_frame:
	pop ax						;
	pop bx						;
	pop cx						;
	pop dx						;
	pop si						;
	pop di						;
	pop bp						;
	pop sp						;
	pop ds						;
	pop es						;
	pop ss						;recover value of registers
				
	db  0eah					;make jmp far
Old09Offset		dw 0			;jmp offset
Old09Segment 	dw 0			;jmp segment

endp NewInt09

is_frame_visible: dw 0

include FRAME.ASM
include SMALLIB.ASM

EOP:

Main:
	xor bx, bx								;
	mov es, bx								;es = 0
	mov bx, 4*8								;Set es:[bx] to int table ot 9-th interruption
	
	mov ax, word ptr es:[bx]				;
	mov word ptr [Old08Offset], ax			;
	mov ax, word ptr es:[bx + 2]			;
	mov word ptr [Old08Segment], ax			;save address of old 08 interruption handler

	mov ax, word ptr es:[bx + 4]			;
	mov word ptr [Old09Offset], ax			;
	mov ax, word ptr es:[bx + 6]			;
	mov word ptr [Old09Segment], ax			;save address of old 09 interruption handler

	cli
	mov es:[bx], offset NewInt08			;
	mov ax, cs								;
	mov es:[bx + 2], ax						;Put in int table new 8th int handler

	mov es:[bx + 4], offset NewInt09		;
	mov ax, cs								;
	mov es:[bx + 6], ax						;Put in int table new 9th int handler
	sti

	mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4								;Convert to paragraphs
	inc dx									;Round up
	int 21h									;End program with saving code of new int in memory

end Start