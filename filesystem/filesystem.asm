%define POCET_BYTU_NA_BLOK 512
%define MAX_POCET_SOUBORU 16
%define KONEC_SOUBORU 0xFFFF
org 0
bits 16

interrupt_handler:
	pusha
	push es
	push bx

	mov dx, cs              ; zkopirovani code segmentu do AX
	mov es, dx              ; a zkopirovani i do extra segmentu

	sub ah,0x36				; odectu konstantu 0x36 abych jel od zacatku jump_table
	mov al,ah
	xor ah,ah
	mov bx,ax				; presunu hodnotu z ax do bx
	shl bx,1				; hodnotu v registru bx vynasobim 2
	mov dx,[cs:tabulka_skoku+bx] ; spocitam adresu skoku do jump_table
	pop bx
	call dx					; skocim do obsluzne procedury

	pop es
	popa
	iret

%include "disk.asm"
%include "print.asm"

velikost_disku:				; vypocet velikosti velikost_disku AH = 36h
	ret
formatuj_disk:				; naformatuje disk AH = 37h
	; zapise boot sektor na disk
	mov cl, 1				; nastaveni indexu sektoru v disku
	mov bx, boot_sektor		; nastaveni adresy odkud se bude zapisovat na disk
	call zapis_sektoru_na_disk ; zapsani boot sektoru do prvniho sektoru

	; zapise obsah FATky na disk
	mov cl, 2
	mov bx, fatka
	call zapis_sektoru_na_disk

	; zapise obsah root directory na disk
	mov cl, 3
	mov bx, definice_souboru
	call zapis_sektoru_na_disk


	; call vymaz_textovy_buffer  ; pro jistotu vymazeme textovy buffer
	; mov bx, textovy_buffer  ; nastaveni adresy na textovy_buffer, ktery budu zapisovat na disk
	; .cyklus:
	; 	inc cl				; inkrementuji cl
	; 	jo .konec_cyklu 	; ukonci cyklus, pokud jsem pretekl
	; 	call zapis_sektoru_na_disk
	; 	jmp .cyklus

	; .konec_cyklu:

	ret
nova_slozka:				; procedura pro vytvoreni nove slozky AH = 39h
	ret
smaz_slozku:				; procedura pro smazani slozky AH = 3Ah
	ret
nastav_slozku:				; procedura pro nastaveni aktualni slozky (cd) AH = 3Bh
	mov si, dx
	mov bx, 0
	.cyklus:
		lodsb
		test al, al
		jz .konec
		mov byte [textovy_buffer+bx],al
		inc bx

		jmp .cyklus

	.konec:

	ret
novy_soubor:				; procedura pro vytvoreni noveho prazdneho souboru AH = 3Ch
	ret
otevri_soubor:				; procedura pro otevreni souboru pro praci AH = 3Dh
	ret
zavri_soubor:				; procedura pro zavreni souboru AH = 3Eh
	ret
precti_soubor:				; procedura pro precteni kusu souboru AH = 3Fh, bx je id
	add cl, 3			; buffer bude v
	push es
	mov ax, ds
	mov es, ax
	call cteni_sektoru_z_disku
	pop es
	ret
zapis_soubor:				; procedura pro zapsani kusu dat do souboru AH = 40h
	push cx
	add cl, 3			; buffer bude v
	push es
	mov ax, ds
	mov es, ax
	call zapis_sektoru_na_disk


	call strlen
	pop es
	push ax
	xor cl,cl
	mov bx,textovy_buffer
	mov ax,cs
	push ds
	mov ds,ax
	call precti_soubor
	pop ds
	pop ax
	pop cx

	mov bx, cx
	dec bx
	shl bx, 5
	add bx, 30
	mov [cs:textovy_buffer+bx], ah
	mov [cs:textovy_buffer+bx+1], al
	mov cl, 3
	mov bx, textovy_buffer
	mov ax,cs
	push es
	mov es,ax
	call zapis_sektoru_na_disk
	pop es

	ret
smaz_soubor:				; procedura pro smazani souboru AH = 41h
	ret
nastav_pozici_v_souboru:	; procedura pro nastaveni pracovni pozice v souboru AH = 42h
	ret
ziskej_atributy_souboru:	; procedura pro ziskani atributu souboru AH = 43h
	ret
nastav_atributy_souboru:	; procedura pro nastaveni atributu souboru AH = 43h
	ret
ziskej_nazev_aktualniho_adresare:	; procedura pro ziskani nazvu aktualniho adresare AH = 47h
	ret
prejmenuj_soubor:			; procedura pro prejmenovani souboru AH = 56h
	ret
ziskej_casovy_udaj_o_souboru:		; procedura pro ziskani casoveho udaje o souboru AH = 57h
	ret
nastav_casovy_udaj_o_souboru:		; procedura pro nastaveni casoveho udaje o souboru AH = 57h
	ret
pomocna_atributy_souboru:			; pomocna procedura pro obsluhuprace s atributem souboru
	cmp al, 0
	je pokracuj_dal
	call nastav_atributy_souboru
	jmp konec_1
	pokracuj_dal:
		call ziskej_atributy_souboru
	konec_1:
		ret
pomocna_casovy_udaj_o_souboru:		; pomocna procedura pro obsluhu prace s casovym udajem o souboru
	ret
konec:
	jmp 0x1000:0x0000

; pomocna procedura pro vycisteni bufferu
vymaz_textovy_buffer:
	pusha

	mov cx, 512
	xor ax, ax
	.vymazani:
		mov bx,cx
		mov byte [cs:textovy_buffer+bx],0
		loop .vymazani

	popa

; DS:SI prvni porovnavany retezec
; ES:DI druhy porovnavany retezec
; vysledek se ulozi do al registru
porovnej_retezce:
	push si
	push di

	.cyklus:
		lodsb 		; nacte ASCII hodnotu z DS:SI do al a inkrementuje SI
		mov ah, [es:di] ; nacte ASCII hodnotu z ES:DI do ah
		inc di		; inkrementuje di

		xor al, ah
		jnz .nejsou_stejny	; pokud al neni nulovy, tak nejsou testovane znaky stejny

		test ah, ah ; otestuje registr al (neco jako al AND al)
		jz .jsou_stejny

		jmp .cyklus
	.nejsou_stejny:
		mov al, 1	; nastavime vysledek na 0 - nejsou stejny
		jmp .konec
	.jsou_stejny:
		mov al, 0	; nastavime vysledek na 1 - jsou stejny
	.konec:
		pop di
		pop si
		ret

strlen:
	push bx
	push cx
	push dx
	mov dx,bx
	xor cx, cx
	.do:
		mov cl, [es:bx]
		cmp cl,0
		je .koneccc
		inc bx
		jmp .do
	.koneccc:
		mov ax, bx
		sub ax, dx
		pop dx
		pop cx
		pop bx
		ret

; datova cast
;=================================================

tabulka_skoku:
	dw velikost_disku					; 36h
	dw formatuj_disk					; 37h
	dw 0								; 38h
	dw nova_slozka						; 39h
 	dw smaz_slozku						; 3Ah
 	dw nastav_slozku					; 3Bh
 	dw novy_soubor						; 3Ch
 	dw otevri_soubor					; 3Dh
 	dw zapis_soubor						; 3Eh
 	dw precti_soubor					; 3Fh
 	dw zapis_soubor						; 40h
 	dw smaz_soubor						; 41h
 	dw nastav_pozici_v_souboru			; 42h
 	dw pomocna_atributy_souboru   		; 43h
 	dw 0								; 44h
 	dw 0								; 45h
 	dw 0								; 46h
 	dw ziskej_nazev_aktualniho_adresare ; 47h
 	times 13 dw 0						; 48h - 55h
 	dw prejmenuj_soubor					; 56h
 	dw pomocna_casovy_udaj_o_souboru	; 57h

boot_sektor:							; bootovaci sektor fatky zarovnany na 512 bytu
	times 3 db 0						; program
	db "FailOSas"						; nazev spolecnosti
	dw 512								; pocet bytu na blok
	db 16								; pocet bloku na alokacni jednotku
	dw 1								; pocet rezervovanych bloku
	db 1								; pocet fat tabulek
	dw 1								; pocet korenovych slozek
	dw 0xFFFF							; celkovy pocet bloku (nepocitam s tim)
	db 0xF0								; typ media (neznamy parametr)
	dw 32								; pocet bloku na fat tabulku
	dw 0xFFFF							; pocet bloku na stopu (neznamy parametr)
	dw 0xFFFF							; pocet ploch disku (neznamy parametr)
	dd 0								; pocet skrytych bloku
	dd 0xFFFFFFFF						; celkovy pocet bloku
	dw 0								; cislo fyzicke jednotky
	db 0								; EBRS (neznamy parametr)
	dd 0xFACEB00C						; seriove cislo jednotky
	db "FailOS fs  "					; popisek jednotky
	db "FAT16   "						; identifikator souboroveho systemu
	times 499 db 0						; doplneni na nuly

textovy_buffer: ; univerzalni buffer pro odkladani dat
	times 512 db 0

fatka:
	db 0xF0	; prvni dva bajty jsou magicke konstanty
	db 0xFF
	times MAX_POCET_SOUBORU dw KONEC_SOUBORU
	times 478 db 0

definice_souboru:
	%include "filesystem/files.asm"

;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0xC00-($-$$) db 0
