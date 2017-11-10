org 0
bits 16
%include "consts.asm"

start:
	mov ax,cs
	mov ds,ax

	mov bx,660
	xor ax,ax
	call kresli_jeden_soubor
	jmp $
konec:
	jmp segment_jadro:0x0000

; AX => pozice souboru
; BX => pozice, kam se ma kreslit
kresli_jeden_soubor:
	pusha
	push ax
	;nastaveni pozadi
	mov ax,bx
	mov cx,320
	div cx
	mov [cs:pozice],ax
	mov [cs:pozice+4],dx
	add ax,40
	add dx,120
	mov [cs:pozice+2],ax
	mov [cs:pozice+6],dx
	;kresleni pozadi
	mov ax,0x4
	mov bx,pozice
	int 0x22	
	pop ax
	; kresleni face	
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
	push bx
	mov ax,0x1
	add bx,0x4a0
	mov cx,znak
	int 0x22
	pop bx
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
	times 0x100 db 0xff,0x0

%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x400-($-$$) db 0
