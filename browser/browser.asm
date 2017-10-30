org 0
bits 16
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu
	mov ss, ax                ; a i do stack segmentu
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

	mov ax, zprava
	call pis16	
	
	;stc
	;call pis16_registry
	;stc ;nastavi CF  	
	;call pis16_registry
	mov ax,0x9000
	mov gs,ax
	;call 0x9000:0x0000
	int 0x22
	mov ax,zprava
	mov bx,0x7108
	call 0x9000:0x0080
	mov bx,0x8129
	mov word [gs:0x0040],0x004C
	call 0x9000:0x0080
	mov bx,0x9129
	mov word [gs:0x0040],0x0056
	call 0x9000:0x0080
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
%include "print.asm"
%include "characters.asm"         ; vlozeni funkci pro praci se znaky
zprava:
	db "Spusteno",10,13,0
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x200-($-$$) db 0
