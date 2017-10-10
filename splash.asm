%define OBRAZEK_SIRKA 8
%define OBRAZEK_VYSKA 8
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
obrazek:
	db  8,10,10, 8,10, 8,10,10 ; TODO creeper face
	db 10, 3,10,10,10,10, 8,10
	db 10, 0, 0,10, 2, 0, 0,10
	db 10, 0, 0,10,10, 0, 0, 2
	db  2,10,10, 0, 0,10,10,10
	db 10,10, 0, 0, 0, 0,3,10
	db  8,10, 0, 0, 0, 0,10,10
	db 10,10, 0,10,10, 0,10,10
	
