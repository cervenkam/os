bits 16    ; jsme v 16ti bitovem realnem rezimu
org 0      ; a zaciname v aktualnim segmentu na adrese 0
%define OBRAZEK_SIRKA 64
%define OBRAZEK_VYSKA 64
obrazek_zobrazit:
	pusha                 ; ulozeni vsech registru na zasobnik
	push es               ; ulozeni extra segmentu na zasobnik
	mov ah, 0x0f          ; zjisteni video modu
	int 0x10              ; zavolani sluzby BIOSu
	xor ah, ah            ; smazani horniho bajtu AX
	push ax               ; ulozeni video modu na zasobnik
	mov ax, 0x13          ; nastaveni video modu 320x200, 256barev
	int 0x10              ; nastaveni video modu
	mov ax, 0xa558        ; nastaveni adresy, odkud se bude obrazek kreslit
	mov es, ax            ; nastaveni extra segmentu na tuto adresu
	mov bx, OBRAZEK_VYSKA ; ulozeni vysky do registru BX
	mov di, 0             ; ukladani do video pameti
	lea si, [obrazek]     ; ukladani dat z pameti zacinajici navestim "obrazek"
obrazek_smycka:
	cmp bx, 0                ; test na vycerpani poctu radku
	je obrazek_konec_smycky  ; ukonceni, pokud jsme prosli vsechny radky obrazku
	mov cx, OBRAZEK_SIRKA    ; nastaveni poctu opakovani na pocet sloupcu (sirka obrazku)
	rep movsb                ; opakovani presunu do video pameti CX krat (jedna radka)
	add di, 320              ; presun na dalsi radku ve video pameti
	sub di,OBRAZEK_SIRKA     ; ale odecteni sirky obrazku, aby se kreslily radky obrazku pod sebe
	dec bx                   ; snizeni poctu zbyvajicich radek
	jmp obrazek_smycka       ; opakovani vypisu radky
obrazek_konec_smycky:
	push cx         ; ulozeni registru CX na zasobnik
	mov cx,0x10     ; spat cca 1s (1048576us)
	mov ah,0x86     ; parametr pro spani
	int 0x15        ; volani sluzeb BIOSu
	pop cx          ; obnova registru CX ze zasobniku
	pop ax          ; obnova video modu ze zasobniku
	int 0x10        ; nastaveni tohoto modu
	pop es          ; nacteni extra segmentu ze zasobniku
	popa            ; nacteni vsech registru ze zasobniku
	ret             ; ukonceni tohoto podprogramu
%include "picture.asm"
	
