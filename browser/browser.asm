org 0
bits 16
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

	mov ax, zprava
	call pis16	
	
	;stc
	;call pis16_registry
	;stc ;nastavi CF  	
	;call pis16_registry
	call text_nastavit_video_mod
	mov ax,zprava
	mov bx,0x70e0
	call text_zobrazit
	jmp $
;cyklus:
	;xor ah,ah
	;int 0x16
	;mov ah,0xe
	;call tabulka_znaku
	;int 0x10                  ; volani video sluby BIOSu
	;call pis16_registr
	;jmp cyklus
konec:
	jmp 0x1000:start
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
%include "print.asm"
%include "characters.asm"         ; vlozeni funkci pro praci se znaky
%include "browser/text.asm"
zprava:
	db "Spusteno",10,13,0
times 0x1e00-($-$$) db 0
