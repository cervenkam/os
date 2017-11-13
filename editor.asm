org 0
bits 16
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu

default_editor:
	mov cl, 1
	mov ah, 0x3f
	mov bx, buffer_editoru
	int 0x21

cisteni:
	mov ax, 5	
	int 0x22
nastaveni_fontu:
	mov ax, 2
	mov bx, 5
	int 0x22

vykresleni:
	mov ax, 1
	xor bx, bx
	mov cx, buffer_editoru
	int 0x22

	call strlen
	
	jmp $
		
konec:
	int 0x05


strlen:
	push bx
	push cx
	mov bx, buffer_editoru
do:
	xor cx, cx
	mov cl, [cs:bx]
	test cl, cl
	jz koneccc 
	inc bx
	jmp do
koneccc:
	mov ax, bx 
	sub ax, buffer_editoru 
	pop cx
	pop bx
ret

buffer_editoru:
	times 513 db 0

%include "print.asm"

;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x400-($-$$) db 0
