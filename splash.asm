bits 16
org 0
%define OBRAZEK_SIRKA 64
%define OBRAZEK_VYSKA 64
obrazek_zobrazit:
	pusha
	push es
	mov ah, 0x0f    ; zjisteni video modu
	int 0x10        ; zavolani sluzby BIOSu
	xor ah, ah      ; smazani horniho bajtu AX
	push ax         ; ulozeni video modu na zasobnik
	mov ax, 0x13    ; nastaveni video modu 320x200, 256barev
	int 0x10        ; nastaveni video modu
	mov ax, 0xa558
	mov es, ax
	mov bx, OBRAZEK_VYSKA
	mov di, 0         ; ukladani do video pameti
	lea si, [obrazek] ; ukladani dat z pameti zacinajici navestim "obrazek"
obrazek_smycka:
	cmp bx, 0
	je obrazek_konec_smycky
	mov cx, OBRAZEK_SIRKA ; ulozeni sirky obrazku
	rep movsb
	add di, 320
	sub di,OBRAZEK_SIRKA
	dec bx                 ; snizeni poctu zbyvajicich radek
	jmp obrazek_smycka     ; opakovani vypisu radky
obrazek_konec_smycky:
	push cx         ; ulozeni registru CX na zasobnik
	mov cx,0x10     ; spat cca 1s (1048576us)
	mov ah,0x86     ; parametr pro spani
	int 0x15        ; volani sluzeb BIOSu
	pop cx          ; obnova registru CX ze zasobniku
	pop ax          ; obnova video modu ze zasobniku
	int 0x10        ; nastaveni tohoto modu (TODO smaze se obrazek)
	pop es
	popa
	ret
%include "picture.asm"
	
