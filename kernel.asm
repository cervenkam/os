org 0
bits 16
%include "consts.asm"
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu
	mov ss, ax                ; a i do stack segmentu
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

	call obrazek_zobrazit     ; zobrazeni uvodniho obrazku
	
	xor dx,dx
	; naveseni interruptu
	cli 			  ; vycistit interrupty
	push es
	xor ax, ax
	mov es, ax 		  ; segmentovy registr = 0
	;0x22 video sluzby, adresa obsluhy je potom 0x9000:0x0000 (zacatek segmentu)
	mov word [es:0x0088],0x0000
	mov word [es:0x008a],segment_obrazky
	;0x21 sluzby souboroveho systemu
	mov word [es:0x0084],0x0000
	mov word [es:0x0086],segment_filesystem
	pop es
	sti ;nastavit interrupty

	xor ax,ax
	int 0x22
	mov ax,0x03
	int 0x22
	mov ax,0x02
	mov bx,0x01
	int 0x22
	mov ax,0x01

menu_smycka:
	cmp dx,8
	je menu_smycka_konec
	mov bx,dx
	mov cx,[cs:tabulka_retezcu+bx]
	mov bx,[cs:tabulka_pozic+bx]
	int 0x22
	add dx,2
	jmp menu_smycka
menu_smycka_konec:

	cli 			  ; vycistit interrupty
	push es
	xor ax, ax
	mov es, ax 		  ; segmentovy registr = 0
	;0x08 test casovace
	mov ax,[es:0x0070]
	call pis16_registry
	mov [cs:stare_int0x08],ax
	call pis16_registry
	mov ax,[es:0x0072]
	mov [cs:stare_int0x08+2],ax
	;mov word [es:0x0070],interrupt
	;mov word [es:0x0072],cs
	pop es
	sti ;nastavit interrupty

	xor ax,ax
	int 0x16	
	mov dl,[pozice]
	mov [predchozi_pozice],dl
	cmp ah,0x48 ;sipka nahoru
	je sipka_nahoru
	cmp ah,0x50 ;sipka dolu
	je sipka_dolu	
	cmp ah,0x1C ;enter
	je enter
	jmp menu_smycka_konec
sipka_nahoru:
	cmp byte [pozice],0
	je rotuj_dolu
	dec byte [pozice]
	jmp prekresli
rotuj_dolu:
	mov bl,[pocet_menu_1]
	mov [pozice],bl
	jmp prekresli
sipka_dolu:
	mov bl,[pozice]
	cmp bl,[pocet_menu_1]
	je rotuj_nahoru
	inc byte [pozice]
	jmp prekresli
rotuj_nahoru:
	mov byte [pozice],0
	jmp prekresli
prekresli:
	mov ax,0x02
	mov bx,0x01
	int 0x22
	mov ax,0x01
	mov bl,[predchozi_pozice]
	shl bx,1
	mov cx,[cs:tabulka_retezcu+bx]
	mov bx,[cs:tabulka_pozic+bx]
	int 0x22
	mov ax,0x02
	mov bx,0x02
	int 0x22
	mov ax,0x01
	mov bl,[pozice]
	shl bx,1
	mov cx,[cs:tabulka_retezcu+bx]
	mov bx,[cs:tabulka_pozic+bx]
	int 0x22
	jmp menu_smycka_konec
enter:
	mov bl,[pozice]
	xor bh,bh
	shl bx,1
	mov ax,[tabulka_segmentu+bx]
	push ax
	xor bx,bx
	push bx
	retf
	
pocet_menu_1:
	db 3
pozice:
	db 3
predchozi_pozice:
	db 0
tabulka_retezcu:
	dw retezec_prohlizec
	dw retezec_editor
	dw retezec_hra
	dw retezec_neco
tabulka_pozic:
	dw 0x11e0
	dw 0x3000
	dw 0x47d0
	dw 0x6940
tabulka_segmentu:
	dw segment_prohlizec
	dw segment_editor
	dw segment_hra ;TODO
	dw segment_editor ;TODO
retezec_prohlizec:
	db "Prohlizec",0
retezec_editor:
	db "Editor",0
retezec_hra:
	db "Hra",0
retezec_neco:
	db "Neco jineho",0
konec:
	jmp 0x1000:start
interrupt:
	call pis16_registry
	;cmp byte [pocitadlo],0
	;jne pokracuj_interrupt
	;push ax
	;mov ax,0x03
	;int 0x22
	;pop ax
	;mov byte [pocitadlo],17
;pokracuj_interrupt:
	;dec byte [pocitadlo]
	;pop es
	;push ax
	;mov al,0x20
	;out 0x20,al
	;pop ax
	jmp [cs:stare_int0x08]
stare_int0x08:
	dw 0
	dw 0
pocitadlo:
	db 17

%include "splash.asm"             ; vlozeni nacitaci obrazovky
%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x1400-($-$$) db 0
