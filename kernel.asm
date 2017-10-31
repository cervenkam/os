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
	xor ax,ax
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
	xor ax,ax
	int 0x16	
	mov al,ah
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
	mov bl,[pozice]
	mov [predchozi_pozice],bl
	dec byte [pozice]
	jmp prekresli
rotuj_dolu:
	mov bl,[pocet_menu_1]
	mov [pozice],bl
	mov byte [predchozi_pozice],0
	jmp prekresli
sipka_dolu:
	mov bl,[pocet_menu_1]
	cmp bl,[pozice]
	je rotuj_nahoru
	mov [predchozi_pozice],bl
	inc byte [pozice]
	jmp prekresli
rotuj_nahoru:
	mov [predchozi_pozice],bl
	mov byte [pozice],0
	jmp prekresli
prekresli:
	xor bh,bh
	mov ax,0x02
	mov bx,0x01
	int 0x22
	mov ax,0x01
	mov bl,[predchozi_pozice]
	mov cx,[cs:tabulka_retezcu+bx]
	mov bx,[cs:tabulka_pozic+bx]
	int 0x22
	mov ax,0x02
	mov bx,0x02
	int 0x22
	mov ax,0x01
	mov bl,[pozice]
	mov cx,[cs:tabulka_retezcu+bx]
	mov bx,[cs:tabulka_pozic+bx]
	int 0x22
	jmp menu_smycka_konec
enter:
	mov bl,[pozice]
	xor bh,bh
	shl bx,1
	mov ax,[tabulka_segmentu+bx]
	mov [cilova_adresa],ax
	jmp [cilova_adresa]
	
cilova_adresa:
	dw 0x1000
	dw 0x0000
pocet_menu_1:
	db 4
pozice:
	db 0
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
	dw segment_editor ;TODO
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

%include "splash.asm"             ; vlozeni nacitaci obrazovky
%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x1400-($-$$) db 0
