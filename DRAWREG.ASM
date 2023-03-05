.model tiny
.code
org 100h
locals __

SaveRegs MACRO 
	push ss es ds sp bp di si dx cx bx ax
ENDM

RecoverRegs MACRO
	pop ax bx cx dx si di bp sp ds es ss
ENDM

LeftUpCorner EQU 1*160d+134d;

FrameHeight EQU 13d;
FrameWeight EQU 9d;

HotKey EQU	43d		;\ or |

ClearFrame MACRO
	mov bx, 0b800h				;						|
	mov es, bx					;			 			|
	mov bp,	LeftUpCorner		;offset in vmem			|
	mov dh, FrameHeight			;height of the frame	| ARGUMENTS TO DRAW FRAME
	mov dl, FrameWeight			;weight of the frame 	|
	mov ah, 1d

	mov si, cs:[offset empty_frame]	;symbols to frame		
	call DrawFrame					;						| CLEAR FRAME
ENDM

Start:	jmp Main	

NewInt08 proc
	SaveRegs
	
	lea bx, cs:vis_status
	mov word ptr cx, cs:[bx]	;put in cx status vis_status
	cmp cx, 0

	je __end_draw_frame

		mov bx, 0b800h
		mov es, bx

		mov bp,	LeftUpCorner				;offset in vmem			|
		mov dh, FrameHeight					;height of the frame	|
		mov dl, FrameWeight					;weight of the frame	|ARGUMENTS TO DRAW FRAME
		mov ah, 07eh						;color atr				| 
		mov si, cs:[offset double_frame]	;symbols to frame		|
		call DrawFrame
		
		mov bx, LeftUpCorner + 160d + 2d		;go to new line + skip left frame border
		call DrawRegText

		mov bx, LeftUpCorner + 160d + (FrameWeight-1)*2	;go to new line + skip all frame withot right border
		mov dh, 71h										;color atr

		call DrawRegNumber

__end_draw_frame:

	;pop cx
	RecoverRegs
	db 0eah						;make jmp far	|
	Old08Offset		dw 0		;jmp offset		|jump to old int handler
	Old08Segment 	dw 0		;jmp segment	|
endp NewInt08

NewInt09	proc
	SaveRegs
	
	in al, 60h					;get scan-code from 60-th port

	cmp al, HotKey				;
	je __draw_frame				;if hot key pressed

	cmp al, HotKey or 80h		;if hot key released
	je __end_draw_frame
	
	RecoverRegs				
	db  0eah						;make jmp far	|
	Old09Offset		dw 0			;jmp offset		|jump to old int handler
	Old09Segment 	dw 0			;jmp segment	|

	__draw_frame:
		lea bx, cs:vis_status
		mov word ptr cx, cs:[bx]		;			put in cx status vis_status					
		cmp cx, 1							;													
											;															
		je __clear_frame					;													
			mov word ptr cs:[bx], 1d	;set new status										
			jmp __end_draw_frame			;													
		__clear_frame:						;													
			mov word ptr cs:[bx], 0d	;set new status										
			ClearFrame							
		
	__end_draw_frame:

		in al, 61h				;
		or al, 80h				;
		out 61h, al				;
		and al, not 80h			;
		out 61h, al				;Say OK to keyboard controler
		
		mov al, 20h				;
		out 20h, al				;Say OK to int controler

		RecoverRegs	
		iret
		

endp NewInt09

vis_status: dw 0

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
	mov ax, cs								;

	mov es:[bx], offset NewInt08			;Put in int table new 8th int handler
	mov es:[bx + 2], ax						;ax = cs

	mov es:[bx + 4], offset NewInt09		;Put in int table new 9th int handler
	mov es:[bx + 6], ax						;ax = cs
	sti

	int 9h									;
	int 8h									;

	mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4								;Convert to paragraphs
	inc dx									;Round up
	int 21h									;End program with saving code of new int in memory

end Start