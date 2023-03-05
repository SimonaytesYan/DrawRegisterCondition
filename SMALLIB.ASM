.code
locals __

;-------------------------------------------
;Put number in dec form in videomem
;
;Expects:	es->Videomem
;
;Entry(Stack, reverse getting params):		
;			1st arg - offset in videomem
;			2nd arg - number for output
;			3rd arg - color atr for output
;
;Output:	None
;
;Destroys:	cx, ax, dx, bx, di, si
;
;-------------------------------------------
GigaOutputNum10	proc
	push bp			;save old bp
	mov bp, sp

	mov bx, [bp + 4];get memory offset
	mov ax, [bp + 6];get number to output
	mov cx, [bp + 8];get color atribute

	shl cx, 8		;put color atribute in ch
	call OutputNum10

	pop bp			;restore old bp value
	ret
				endp

;-------------------------------------------
;Get number from cmd
;-------------------------------------------
;Expects:	label named buffer
;
;Entry:		None
;
;Output:	ax - number
;
;Destroys:	cx, dx, di
;
;-------------------------------------------
GetNum	proc
	
	lea dx, buffer
	mov ah, 0ah
	int 21h			;get number from cml
	
	xor cx, cx
	mov cl, buffer[1]	;get length of number

	xor ax, ax
	mov di, 10d	
	mov si, 2h
	
	__Next:	
		mul di				;ax = ax*10
		mov dl, si + buffer	;put in dl next simbol
		sub dl, '0'			;convert simbol to number
		
		add ax, dx		;ax += dh
		
		inc si
		loop __Next
	ret
	endp

;-------------------------------------------

;-------------------------------------------
;Put number in dec form in videomem
;
;Expects:	es->Videomem
;
;Entry:		bx - offset in videomem
;			ax - number for output
;			ch - color atr for output
;
;Output:	None
;
;Destroys:	ax, dx, bx, di, si
;
;-------------------------------------------
OutputNum10	proc
	mov si, 5        		;max length of number
	mov di, 10d	

	__next:
		xor dx, dx			;dx = 0
		div di				;ax = dxax/10 
							;dx = ax%10
	
		add dl, '0'			;make symbol from num
		mov dh, ch			;set color
		
		mov word ptr es:[bx-2], dx	;put symbol in vmem
		sub bx, 2

		dec si 
		cmp si, 0			
		jne __next				;for(int si = 5; si != 0; si--)
	ret
	endp

;----------------------------------------------
;Put number in hex form in videomem
;
;Expects:	es->VideoMem
;
;Entry:		bx - offset in videomem
;			ax - number to output
;			dh - color atr to output
;
;Output:	None
;
;Destroys:	ax, dx, bx, cx, si
;
;----------------------------------------------
OutputNum16	proc
	mov cx, 4				;length of hex number
	__Next:					;do
		mov si, 000fh
		and si, ax			;get new number

		mov dl, cs:int_to_char_hex[si] ;make char from int

		mov word ptr es:[bx-2], dx	;put symb in vmem
		sub bx, 2					;bx -= 2

		ror ax, 4					;roll in the right to 4 bytes
		loop __Next
		
	ret
	endp

int_to_char_hex	db "0123456789ABCDEF"

.code
;----------------------------------------------

;----------------------------------------------
;Put number in binary form in videomem
;
;Expects:	es->VideoMem
;
;Entry:	bx - offset in videomem
;		ax - number to output
;		dh - color atr to output
;
;Output: 	None
;
;Destroys:	ax, bx,cx, dl
;----------------------------------------------
OutputNum2	proc
	
	mov cx, 10h		;set number of bits in number

	__Next:
		mov dl, 1
		and dl, al			;get last number
		add dl, '0'			;make char from number

		ror ax, 1
		mov word ptr es:[bx], dx	;print 1 or 0

		add bx, 2
		loop __Next
	
	ret	
	endp
;----------------------------------------------

buffer db 5, ?, 5 dup(' ')