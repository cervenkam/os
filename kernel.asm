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
	
	xor ax,ax
	int 0x22
	mov ax,0x02
	mov bx,0x02
	int 0x22
	mov ax,0x01
	mov bx,0x7108
	mov cx,retezec_prohlizec
	int 0x22
	mov bx,0x8129
	int 0x22
	mov bx,0x9129
	int 0x22
	jmp segment_prohlizec:0x0000
tabulka_retezcu:
	dw retezec_prohlizec
	dw retezec_editor
	dw retezec_hra
	dw retezec_neco
tabulka_pozic:
	dw 0x3000
	dw 0x4000
	dw 0x5000
	dw 0x6000
retezec_prohlizec:
	dw "tuvwxyz",0
retezec_editor:
	dw "Editor",0
retezec_hra:
	dw "Hra",0
retezec_neco:
	dw "Neco jineho",0
konec:
	jmp 0x1000:start

%include "splash.asm"             ; vlozeni nacitaci obrazovky
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x1200-($-$$) db 0
