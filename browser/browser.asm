org 0
bits 16
interrupt_handler: ;nefunguje :'(
	cli
	push ax
	mov al, [odpocet_jak_krava]
	cmp al, 0
	jne cas_nevyprsel
	call pis16_registry
	mov byte [odpocet_jak_krava], 31
cas_nevyprsel:
	dec byte [odpocet_jak_krava]
	pop ax
	sti
	iret

start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu
	mov ss, ax                ; a i do stack segmentu
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)
	jmp $

odpocet_jak_krava:
	db 30

%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x200-($-$$) db 0
