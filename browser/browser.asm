org 0
bits 16
%include "consts.asm"

start:
	mov bx,660
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
	mov [pozice],ax
	mov [pozice+2],dx
	add ax,20
	add dx,100
	mov [pozice+4],ax
	mov [pozice+6],dx
	;kresleni pozadi
	mov ax,0x4
	mov bx,pozice
	int 0x22	
	pop ax
	; kresleni face	
	mov byte [znak],1
	push bx
	mov bx,ax
	mov cx,[bx+0x1e]
	cmp cx,410
	jge procent100
	cmp cx,307
	jge procent80
	cmp cx,205
	jge procent60
	cmp cx,102
	jge procent40
	test cx,cx
	jnz procent20
	jmp procent0
procent100:
	inc byte [znak]
procent80:
	inc byte [znak]
procent60:
	inc byte [znak]
procent40:
	inc byte [znak]
procent20:
	inc byte [znak]
procent0:
	mov ax,0x2
	mov bx,0x3
	int 0x22
	pop bx
	push bx
	mov ax,0x1
	add bx,0x1000
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
	times 0x200 db 0

%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x400-($-$$) db 0
