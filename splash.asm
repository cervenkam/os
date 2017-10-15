bits 16
%define OBRAZEK_SIRKA 52
%define OBRAZEK_VYSKA 67
obrazek_zobrazit:
	pusha
	mov ah, 0x0f    ; zjisteni video modu
	int 0x10        ; zavolani sluzby BIOSu
	xor ah, ah      ; smazani horniho bajtu AX
	push ax         ; ulozeni video modu na zasobnik
	mov ax, 0x13    ; nastaveni video modu 320x200, 256barev
	int 0x10        ; nastaveni video modu
	mov ax, 0xa000
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
	pop ax          ; obnova video modu ze zasobniku
	;int 0x10        ; nastaveni tohoto modu (TODO smaze se obrazek)
	popa
	ret
%include "picture.asm"
	
