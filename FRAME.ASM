
;--------------------------------
;EXPECTS:   es->videomemory
;INPUTS:    bp - offset in vmem
;		    dh - height of frame
;		    dl - weight of frame
;		    ah - color atr
;           si - pointer to array with 9 symbols to draw frame in format:
;           0:[left  up   corner]
;           1:[up         border]
;           2:[right up   corner]
;           3:[left       border]
;           4:[symbol to fill frame]
;           5:[right      border]
;           6:[left  down corner]
;           7:[bottom     border]
;           8:[right down corner]
;
;OUTPUTS:   None
;DESTROYS:  bx, cx, di, bp, al, dx
;--------------------------------
DrawFrame   proc
    sub dl, 2           ;now we don`t consider the 1-st and the last symbol, because them we will put without loops
    sub dh, 2           ;the same reason

    mov di, bp
    mov al, cs:[si + 0]
    mov bl, cs:[si + 1]
    mov bh, cs:[si + 2]
    xor cx, cx          ;
    mov cl, dl          ;cx = dl
    call PutFrameLine   ;draw the first line

    add bp, 160d        ;go to the next line

    mov bl, cs:[si + 4]
    mov bh, cs:[si + 5]
    __next:
        mov di, bp
        mov al, cs:[si + 3]    ;rewrite in the loop because in PutFrameLine al destroys
        xor cx, cx          ;
        mov cl, dl          ;cx = dl
        call PutFrameLine   ;draw all middle lines
        add bp, 160d        ;go to the next line

        dec dh              ;dh--
        cmp dh, 0
        jne __next          ;while(dh!=0)

    mov di, bp
    mov al, cs:[si + 6]
    mov bl, cs:[si + 7]
    mov bh, cs:[si + 8]
    xor cx, cx          ;
    mov cl, dl          ;cx = dl
    call PutFrameLine   ;draw the first line

    ret
            endp

;--------------------------------
;PutFrameLine
;--------------------------------
;EXPECTS:   es -> videomemory segment
;           cld
;INPUTS:    di - offset in videomemory
;           ah - color atr of the symbols
;           al - ASCII code of the 1-st symbol
;           bl - ASCII code of cx middle symbols
;           bh - ASCII code of the last symbol
;           cx - numbers of middle symbols
;
;OUTPUTS:   None
;DESTROYS:  di, al, cx
;--------------------------------
PutFrameLine    proc
    cld         ;ToDo remove
    stosw       ;put the fisrt symbol

    mov al, bl  ;change putting simdol to middle symbol
    rep stosw   ;put all middle symbols

    mov al, bh  ;change putting simdol to the last symbol
    stosw

    ret
                endp
;--------------------------------

;--------------------------------
;EXPECTS:   es->videomemory
;
;INPUTS:    bx - offset in vmem
;		    ah - color atr for reg
;           dh - color atr for numbers
;
;DESTROYS:  bx, di, cx
;--------------------------------
DrawRegText proc
    xor di, di          ;di = 0
    lea di, cs:RegText
    mov cx, 11d         ;length of text
    
    __loop:
        mov al, cs:[di]
        mov es:[bx], ax
        inc di

        mov al, cs:[di]
        mov es:[bx+2], ax

        add bx, 160d
        inc di
        loop __loop
    ret

endp DrawRegText
;--------------------------------
RegText: db 'ax','bx','cx','dx','si','di','bp','sp','ds','es','ss'
;--------------------------------
;EXPECTS:   es->videomemory
;
;INPUTS:    bx - offset in vmem
;           dh - color atr for numbers
;          Stack:   ax      <--top
;                   bx
;                   cx
;                   dx
;                   si
;                   di
;                   bp
;                   sp
;                   ds
;                   es
;                   ss
;                   
;DESTROYS:  ax, di, bx, cx, si, bp
;--------------------------------
DrawRegNumber proc
    pop bp                  ;save return address
    mov di, 11d
    __next:
        pop ax
        call OutputNum16
        add bx, 8d          ;horisontal offset
        add bx, 160d        ;vertical   offset

        dec di
        cmp di, 0
        jne __next
    push bp                 ;recover return addres
    ret

endp DrawRegNumber
;--------------------------------


.data
;           0:[left  up   corner]
;           1:[up         border]
;           2:[right up   corner]
;           3:[left       border]
;           4:[symbol to fill frame]
;           5:[right      border]
;           6:[left  down corner]
;           7:[bottom     border]
;           8:[right down corner] 

single_frame db 0dah, 0c4h, 0bfh, '|',  ' ', '|',  0c0h, '-',  0d9h

double_frame db 0c9h, 0cdh, 0bbh, 0bah, ' ', 0bah, 0c8h, 0cdh, 0bch

empty_frame db 9 dup(' ')