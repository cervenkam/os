org 0
bits 16
start:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)
	call pis16_registry
	call obrazek_zobrazit     ; zobrazeni uvodniho obrazku
cyklus:
	xor ah,ah
	int 0x16
	mov ah,0xe
	call tabulka_znaku
	int 0x10                  ; volani video sluby BIOSu
	;call pis16_registr
	jmp cyklus

%include "characters.asm"         ; vlozeni funkci pro praci se znaky
%include "splash.asm"             ; vlozeni nacitaci obrazovky
%include "print.asm"              ; vlozeni funkci pro vypis v realnem a chranenem modu
%include "disk.asm"               ; vlozeni funkci pro praci s diskem
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x1200-($-$$) db 0
