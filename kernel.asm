org 0
bits 16
%include "consts.asm"
start:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)
	call obrazek_zobrazit     ; zobrazeni uvodniho obrazku
	jmp segment_prohlizec:start

%include "splash.asm"             ; vlozeni nacitaci obrazovky
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x1200-($-$$) db 0
