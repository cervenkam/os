%define POCET_BYTU_NA_BLOK 512
%define MAX_POCET_SOUBORU 16
%define KONEC_SOUBORU 0xFFFF
org 0
bits 16

interrupt_handler:
	pusha                        ; ulozim si registry na zasonik
	push es                      ; ulozim extrasegment
	push bx                      ; jeste jednou si ulozim bx

	mov dx, cs                   ; zkopirovani code segmentu do AX
	mov es, dx                   ; a zkopirovani i do extra segmentu

	sub ah,0x37                  ; odectu konstantu 0x37 abych jel od zacatku jump_table
	mov al,ah                    ; presunu cislo sluzby do al
	xor ah,ah                    ; vynuluji registr ah
	mov bx,ax                    ; presunu hodnotu z ax do bx
	shl bx,1                     ; hodnotu v registru bx vynasobim 2
	mov dx,[cs:tabulka_skoku+bx] ; spocitam adresu skoku do jump_table
	pop bx                       ; obnovim registr bx - muze obsahovat nejaky parametr
	call dx                      ; skocim do obsluzne procedury

	pop es                       ; obnovim extrasegment
	popa                         ; obnovim zbytek registru ze zasobniku
	iret                         ; vracim se zpet z preruseni

%include "disk.asm"
%include "print.asm"

formatuj_disk:                       ; naformatuje disk AH = 37h
	; zapise boot sektor na disk
	mov cl, 1                    ; nastaveni indexu sektoru v disku
	mov bx, boot_sektor          ; nastaveni adresy odkud se bude zapisovat na disk
	call zapis_sektoru_na_disk   ; zapsani boot sektoru do prvniho sektoru

	; zapise obsah FATky na disk
	mov cl, 2
	mov bx, fatka
	call zapis_sektoru_na_disk

	; zapise obsah root directory na disk
	mov cl, 3
	mov bx, definice_souboru
	call zapis_sektoru_na_disk


	call vymaz_textovy_buffer            ; pro jistotu vymazeme textovy buffer
	mov bx, textovy_buffer               ; nastaveni adresy na textovy_buffer, ktery budu zapisovat na disk
	.cyklus:
		inc cl                       ; inkrementuji cl
		cmp cl,16+3
	 	je .konec_cyklu              ; ukonci cyklus, pokud jsem pretekl
	 	call zapis_sektoru_na_disk
	 	jmp .cyklus

	.konec_cyklu:
	ret
precti_soubor:                              ; procedura pro precteni kusu souboru AH = 3Fh
	                                    ; cx = id souboru
	                                    ; ds:bx = buffer na obsah souboru
	add cl, 3                           ; cl registr (s id souboru) inkrementuji o 3, abych
	                                    ; se dostal do spravneho sektoru FATky
	push es                             ; ulozim si extrasegment
	mov ax, ds                          ; do registru ax vlozim pointer na buffer na obsah souboru
	mov es, ax                          ; do es vlozim obsah ax
	call cteni_sektoru_z_disku          ; nactu obsah souboru z disku
	pop es                              ; obnovim extra segment
	ret                                 ; vratim se z procedury
zapis_soubor:                               ; procedura pro zapsani kusu dat do souboru AH = 40h
	                                    ; cx = id souboru
	                                    ; ds:bx = buffer s obsahem souboru
	push cx                             ; ulozim si id souboru na zasobnik
	add cl, 3                           ; cl registr (s id souboru) inkrementuji o 3, abych
	                                    ; se dostal do spravneho sektoru FATky
	push es                             ; ulozim si extrasegment, protoze ho budu prepisovat
	mov ax, ds                          ; do ax ulozim pointer na buffer s obsahem souboru
	mov es, ax                          ; z ax vlotim tento pointer do es
	call zapis_sektoru_na_disk          ; zapisu obsah souboru na disk


	call strlen                         ; zjistim velikost souboru (vysledek do ax)
	pop es                              ; obnovim drive ulozeny extrasegment
	push ax                             ; ulozim si velikost souboru na zasobnik
	xor cl,cl                           ; vymazu obsah registru cl
	mov bx,textovy_buffer               ; do registru bx vlozim adresu s textovym bufferem
	mov ax,cs                           ; do registru ax vlozim cs
	push ds                             ; ulozim registr ds na zasobnik
	mov ds,ax                           ; do registru ds ulozim hodnotu registru ax
	call precti_soubor                  ; nactu root directory do textoveho bufferu
	pop ds                              ; obnovim registr ds
	pop ax                              ; obnovim registr ax
	pop cx                              ; obnovim registr cx (s id souboru)

	                                    ; ted spocitam index, na kterem se nachazi
	                                    ; informace o velikosti souboru v boot recordu
	mov bx, cx                          ; do bx ulozim id souboru
	dec bx                              ; odectu jednicku, protoze se indexuje od 0
	shl bx, 5                           ; vynasobim bx 2^5 = 32 = velikost jednoho
	                                    ; zaznamu o souboru v root directory
	add bx, 30                          ; prictu 30 = index, na kterem se nachazi velikost
	mov [cs:textovy_buffer+bx], ah      ; na vypoctenou adresu vlozim vypoctenou hodnotu
	mov [cs:textovy_buffer+bx+1], al    ; musim davat bacha na endianovost
	mov cl, 3                           ; vlozim do cl 3 = root directory
	mov bx, textovy_buffer              ; vlozim do bx pointer na textovy buffer
	mov ax,cs                           ; do ax si ulozim code segment
	push es                             ; ulozim si extrasegment do zasobniku
	mov es,ax                           ; do es vlozim ax
	call zapis_sektoru_na_disk          ; zapisu velikost souboru do root directory
	pop es                              ; obnovim es

	ret                                 ; vratim se z precedury



; pomocna procedura pro vycisteni bufferu
vymaz_textovy_buffer:
	pusha                                        ; ulozim si registry na zasobnik 

	mov cx, 512                                  ; vlozim do cx velikost bufferu = 512
	xor ax, ax                                   ; vymazu ax registr
	.vymazani:
		mov bx,cx                            ; presunu hodnotu z cx do bx
		mov byte [cs:textovy_buffer+bx-1],0  ; na vypoctenou adresu zapisu 0
		loop .vymazani                       ; skacu na .loop, dokud v cx neni 0

	popa                                         ; obnovim vsechny registry
	ret                                          ; vracim se z procedury

strlen:
	push bx                        ; ulozim bx
	push cx                        ; spolu s cx
	push dx                        ; a dx na zasobnik
	mov dx,bx                      ; presunu obsah registru bx do dx
	xor cx, cx                     ; vynuluji registr cx
	.do:
		mov cl, [es:bx]        ; do cl vlozim obsah na vypoctene adrese
		cmp cl,0               ; pokud je v cl 0 = konec retezce
		je .koneccc            ; pokud jsem na konci, skocim na koneccc
		inc bx                 ; jinak inkrementuji bx
		jmp .do                ; a skacu zpet na .do
	.koneccc:
		mov ax, bx             ; ulozim velikost retezce do ax
		sub ax, dx             ; odectu adresu, kde byl retezec
		                       ; abych ziskal spravnou velikost
		pop dx                 ; obnovim registr dx
		pop cx                 ; obnovim registr cx
		pop bx                 ; obnovim registr bx
		ret                    ; vracim se z procedury 

; datova cast
;=================================================

tabulka_skoku:
	dw formatuj_disk   ; 37h
	times 7 dw 0
 	dw precti_soubor   ; 3Fh
 	dw zapis_soubor    ; 40h

boot_sektor:                ; bootovaci sektor fatky zarovnany na 512 bytu
	times 3 db 0        ; program
	db "FailOSas"       ; nazev spolecnosti
	dw 512              ; pocet bytu na blok
	db 16               ; pocet bloku na alokacni jednotku
	dw 1                ; pocet rezervovanych bloku
	db 1                ; pocet fat tabulek
	dw 1                ; pocet korenovych slozek
	dw 0xFFFF           ; celkovy pocet bloku (nepocitam s tim)
	db 0xF0             ; typ media (neznamy parametr)
	dw 32               ; pocet bloku na fat tabulku
	dw 0xFFFF           ; pocet bloku na stopu (neznamy parametr)
	dw 0xFFFF           ; pocet ploch disku (neznamy parametr)
	dd 0                ; pocet skrytych bloku
	dd 0xFFFFFFFF       ; celkovy pocet bloku
	dw 0                ; cislo fyzicke jednotky
	db 0                ; EBRS (neznamy parametr)
	dd 0xFACEB00C       ; seriove cislo jednotky
	db "FailOS fs  "    ; popisek jednotky
	db "FAT16   "       ; identifikator souboroveho systemu
	times 499 db 0      ; doplneni na nuly

textovy_buffer:             ; univerzalni buffer pro odkladani dat
	times 512 db 0

fatka:
	db 0xF0             ; prvni dva bajty jsou magicke konstanty
	db 0xFF
	times MAX_POCET_SOUBORU dw KONEC_SOUBORU
	times 478 db 0

definice_souboru:
	%include "filesystem/files.asm"

;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0xC00-($-$$) db 0
