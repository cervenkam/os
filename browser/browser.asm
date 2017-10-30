org 0
bits 16
interrupt_handler: ;nefunguje :'(
	push ax
	xor ax, ax
	mov ax, [odpocet_jak_krava]
	cmp ax, 0
	je cas_vyprsel
	dec ax
	mov [odpocet_jak_krava], al ;slo by asi dec byte [odpocet_jako_krava]
	pop ax
	iret
cas_vyprsel:
	pop ax
	call pis16_registry
	mov byte [odpocet_jak_krava], 18
	iret

start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu
	mov ss, ax                ; a i do stack segmentu
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)
	jmp $

odpocet_jak_krava db 18

%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x200-($-$$) db 0
