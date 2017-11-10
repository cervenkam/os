org 0
bits 16
%include "consts.asm"

start:
	mov ax,cs
	mov ds,ax

	mov ax,5
	int 0x22
	mov cx,8
	mov bx,660
	xor ax,ax
	xor dx,dx
	cyklus:
		test cx,cx
		jz konec_cyklu
		call kresli_jeden_soubor
		add ax,0x20
		add bx,160
		call kresli_jeden_soubor
		add ax,0x20
		add bx,8000
		dec cx
		xor dh,1
		jmp cyklus
	konec_cyklu:
	jmp $
konec:
	jmp segment_jadro:0x0000

; AX => pozice souboru
; BX => pozice, kam se ma kreslit
kresli_jeden_soubor:
	pusha
	push ax
	push dx
	;nastaveni pozadi
	mov ax,bx
	mov cx,320
	div cx
	mov [cs:pozice],ax
	mov [cs:pozice+4],dx
	add ax,17
	add dx,120
	mov [cs:pozice+2],ax
	mov [cs:pozice+6],dx
	;kresleni pozadi
	mov ax,0x4
	push bx
	mov bx,pozice
	int 0x22	
	pop bx
	pop ax
	push ax
	; kresleni obliceje	
	mov byte [cs:znak],2
	push bx
	mov bx,ax
	mov ax,[cs:nacteny_buffer+bx+0x1e]
	mov cx,102
	xor dx,dx
	div cx
	cmp al,5
	jle neopravuj_al
	mov al,5
neopravuj_al:
	add [cs:znak],al
	mov ax,0x2
	mov bx,0x3
	int 0x22
	pop bx
	pop dx
	push bx
	mov ax,0x1
	sub bx,320*6
	test dh,dh
	jz nepridavat
	add bx,96
nepridavat:
	mov cx,znak
	int 0x22
	; kresleni jmena
	mov ax,0x2
	mov bx,0x4
	int 0x22
	pop bx
	pop ax
	push ax
	push bx
	mov bx,ax
	add bx,nacteny_buffer
	mov dl,[cs:bx+8]
	mov byte [cs:bx+8],0
	mov cx,bx
	mov bx,ax
	pop bx
	push bx
	add bx,320*2+2
	test dh,dh
	jnz nepridavat_2
	add bx,60
nepridavat_2:
	mov ax,0x1
	int 0x22
	mov bx,cx
	mov [cs:bx+8],dl
	pop bx
	pop ax
	push ax
	push bx
	mov bx,ax
	add bx,nacteny_buffer
	add bx,8
	mov dl,[cs:bx+3]
	mov byte [cs:bx+3],0
	mov cx,bx
	mov bx,ax
	pop bx
	push bx
	add bx,320*9+2
	test dh,dh
	jnz nepridavat_3
	add bx,60
nepridavat_3:
	mov ax,0x1
	int 0x22
	mov bx,cx
	mov [cs:bx+3],dl
	pop bx
	pop ax
	popa
	ret	
pozice:
	dw 0
	dw 0
	dw 0
	dw 0
	db 4
znak:
	dw 0
nacteny_buffer:
	%include "filesystem/files.asm"
	;times 0x100 db 0xff,0x0

%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x600-($-$$) db 0
