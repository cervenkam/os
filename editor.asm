org 0
bits 16
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu

default_editor:
	;mov cl, 1
	;mov ah, 0x3f
	;mov bx, buffer_editoru ; nactaceni dat (zatim staticky definovane)
	;int 0x21

cisteni:
	mov ax, 5	
	int 0x22
nastaveni_fontu:
	mov ax, 2
	mov bx, 5
	int 0x22

vykresleni:
	call strlen
	call zaloha_ukazatele
	
	
	mov ax, 1
	xor bx, bx
	mov cx, buffer_editoru
	int 0x22

	;call strlen
	;jmp $

klavesnice:
	xor ax, ax
	int 0x16
	cmp ah,0x4B
	je leva_sipka
	cmp ah,0x4D
	je prava_sipka
	cmp ah,0x1C ;enter
	je enter_ulozit
	jmp cisteni
	
prava_sipka: ;inkrementuje pointer
	add word [cs:kurzor_pointer], 1
	push ax
	mov word ax, [cs:pocet_znaku]
	inc ax
	cmp word ax, [cs:kurzor_pointer] ;pokud je moc za textem
	jne cisteni	
	mov word [cs:kurzor_pointer], 0 ;kurzor zpatky na zacatek
	pop ax
	jmp cisteni

leva_sipka: ;dekrementuje pointer
	sub word [cs:kurzor_pointer], 1
	jnc cisteni ;skoc pokud neni -1 carry
	push ax
	mov word ax, [cs:pocet_znaku]
	mov word [cs:kurzor_pointer], ax ;konec edit textu
	pop ax
	jmp cisteni

enter_ulozit:
	
konec:
	int 0x05

zaloha_ukazatele:
	push bx
	push ax
	xor bx, bx
	mov bx, buffer_editoru
	add word bx, [cs:kurzor_pointer]
	xor ax, ax
	mov byte al, [cs:bx]
	mov byte [cs:zalozni_znak], al
	mov byte [cs:bx], 1 ;dvojtecka jako znak	
	pop ax
	pop bx
	ret

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
	mov [cs:pocet_znaku], ax
	pop cx
	pop bx
ret

vypis:
	mov ax,0x05
	int 0x22
	mov ax, [cs:kurzor_pointer]
	call pis16_registry
	jmp $


pocet_znaku:
	dw 0

kurzor_pointer:
	dw 0

buffer_editoru:
	db "text12345"
	times 504 db 0 ;513 protoze posledni bude vzdycky \0

zalozni_znak
	db 0

%include "print.asm"

;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x800-($-$$) db 0
