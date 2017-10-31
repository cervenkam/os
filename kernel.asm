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
	;int 0x22
	mov ax,0x02
	mov bx,0x02
	;int 0x22
	mov ax,0x03
	mov bx,0x1234
	;int 0x22
	;mov ax,0x02
	;mov bx,0x02
	;int 0x22
	;mov ax,0x01
;menu_smycka:
;	cmp dx,8
;	je menu_smycka_konec
;	call pis16_registry
;	mov bx,dx
;	mov cx,[cs:tabulka_retezcu+bx]
;	mov bx,[cs:tabulka_pozic+bx]
;	int 0x22
;	add dx,2
;	jmp menu_smycka
;menu_smycka_konec:
	jmp segment_prohlizec:0x0000

tabulka_retezcu:
	dw retezec_prohlizec
	dw retezec_editor
	dw retezec_hra
	dw retezec_neco
tabulka_pozic:
	dw 0x1234
	dw 0x2345
	dw 0x3456
	dw 0x4567
retezec_prohlizec:
	db "1Prohlizec",0
retezec_editor:
	db "2Editor",0
retezec_hra:
	db "3Hra",0
retezec_neco:
	db "4Neco jineho",0
konec:
	jmp 0x1000:start

%include "splash.asm"             ; vlozeni nacitaci obrazovky
%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x1400-($-$$) db 0
