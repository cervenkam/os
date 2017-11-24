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

	; naveseni interruptu
	cli 			                  ; zakazani preruseni
	push es                                   ; zaloha extra segmentu
	xor ax, ax                                ; vynulovani AX - nula bude vlozena do ES
	mov es, ax 		                  ; nastaveni extra segmentu na 0 - zde lezi od adresy 0 tabulka vektoru preruseni
	;0x23 spusteni programu
	mov word [es:0x008c],spustit_program      ; nastaveni offsetu obsluhy SW preruseni 0x23 (prepnuti programu
	mov word [es:0x008e],segment_jadro        ; nastaveni segmentu obsluhy SW preruseni 0x23 (prepnuti programu)
	;0x22 video sluzby, adresa obsluhy je potom 0x9000:0x0000 (zacatek segmentu)
	mov word [es:0x0088],0x0000               ; nastaveni offsetu obsluhy SW preruseni 0x22 (graficke funkce)
	mov word [es:0x008a],segment_obrazky      ; nastaveni segmentu obsluhy SW preruseni 0x22 (graficke funkce)
	;0x21 sluzby souboroveho systemu
	mov word [es:0x0084],0x0000               ; nastaveni offsetu obsluhy SW preruseni 0x21 (filesystem FailFAT)
	mov word [es:0x0086],segment_filesystem   ; nastaveni segmentu obsluhy SW preruseni 0x21 (filesystem FailFAT)
	;Ox05 PrtSc
	mov word [es:0x0014],break                ; nastaveni offsetu obsluhy HW preruseni 0x05 (stisk klavesy PrtSc - ukonceni programu)
	mov word [es:0x0016],segment_jadro        ; nastaveni segmentu obsluhy HW preruseni 0x05 (stisk klavesy PrtSc - ukonceni programu)
	;0x08 PIT - programmable interrupt timer
	mov word [es:0x0020],interrupt            ; nastaveni offsetu obsluhy HW preruseni 0x08 (system timer - casovac)
	mov word [es:0x0022],cs                   ; nastaveni segmentu obsluhy HW preruseni 0x08 (system timer - casovac)
	pop es                                    ; obnova extra segmentu
	sti                                       ; povoleni preruseni
	xor ax,ax       ; nastaveni sluzby 0 graficke knihovny - nastaveni video modu
	int 0x22        ; provedeni prepnuti do video modu
konec:
	jmp segment_menu:0x0000
interrupt:
	cli                          ; zacatek obsluhy preruseni casovace - zakazani preruseni
	pusha                        ; ulozeni stavovych registru na zasobnik
	pushf                        ; ulozeni FLAGU pro nasledujici call (ten vola iret, takze obnovuje tyto flagy)
	call 0xf000:0xfea5           ; volani puvodni obsluhy BIOSu - adresa je pevne dana - proto neni potreba ji cist
	cmp byte [cs:pocitadlo],0    ; porovnani pocitadla na nulu
	jne pokracuj_interrupt       ; pokud neni nula, pouze zvysime pocitadlo a nic se nestane
	push ax                      ; jinak budeme prekreslovat hodiny, nejprve si ulozime AX
	mov ax,0x03                  ; nastavime sluzbu graficke knihovny 3 - vykresleni hodin
	int 0x22                     ; a provedeme vykresleni
	pop ax                       ; pak obnovime registr AX
	mov byte [cs:pocitadlo],17   ; a restartujeme pocitadlo
pokracuj_interrupt:
	dec byte [cs:pocitadlo]      ; snizime pocitadlo o 1
	popa                         ; obnovime vsechny stavove registry
	iret                         ; a ukoncime obsluhu preruseni
pocitadlo:
	db 17                        ; pocitadlo - kdyz dojede na 0, prekresli se hodiny a restartuje se na 17

break:
	cli                           ; zacatek obsluhy preruseni stisku klavesy PrtSc - ukonceni programu, nejprve zakazeme preruseni
	mov bp,sp                     ; nastavime base pointer na stack pointer
	mov word [ss:bp],konec        ; nastavime navratovy offset na navesti "po_logu"
	mov word [ss:bp+2],cs         ; nastavime navratovy segment na kodovy segment
	mov al,0x20                   ; do AL vlozime 20
	out 0x20,al                   ; a oznamime PIC, ze jsme s obsluhou hotovi
        iret                          ; a ukonceni obsluhy preruseni

spustit_program:
	cli                           ; zacatek obsluhy preruseni - prepnuti programu na ES:AX
	mov bp,sp                     ; nastavime base pointer na stack pointer
	mov word [ss:bp],ax           ; nastavime navratovy offset na navesti "po_logu"
	mov word [ss:bp+2],es         ; nastavime navratovy segment na kodovy segment
        iret                          ; a ukoncime obsluhu preruseni

%include "splash.asm"             ; vlozeni nacitaci obrazovky
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x1400-($-$$) db 0
