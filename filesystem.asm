org 0
bits 16
interrupt_handler:          ;
	sub ax,0x36				; odectu konstantu 0x36 abych jel od zacatku jump_table

	push bx
	push dx
	mov bx,ax
	shl bx,1
	mov dx,[cs:tabulka_skoku+bx]
	call dx
	pop dx
	pop bx

	iret


start:
	mov ax, cs              ; zkopirovani code segmentu do AX
	mov ds, ax              ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax              ; a zkopirovani i do extra segmentu
	mov bp, 0x9000          ; nastaveni bazove adresy zasobniku
	mov sp, bp              ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

velikost_disku:				; vypocet velikosti velikost_disku AH = 36h
	ret
nova_slozka:				; procedura pro vytvoreni nove slozky AH = 39h
	ret
smaz_slozku:				; procedura pro smazani slozky AH = 3Ah
	ret
nastav_slozku:				; procedura pro nastaveni aktualni slozky (cd) AH = 3Bh
	ret
novy_soubor:				; procedura pro vytvoreni noveho prazdneho souboru AH = 3Ch
	ret
otevri_soubor:				; procedura pro otevreni souboru pro praci AH = 3Dh
	ret
zavri_soubor:				; procedura pro zavreni souboru AH = 3Eh
	ret
precti_soubor:				; procedura pro precteni kusu souboru AH = 3Fh
	ret
zapis_soubor:				; procedura pro zapsani kusu dat do souboru AH = 40h
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
	ret
pomocna_casovy_udaj_o_souboru:		; pomocna procedura pro obsluhu prace s casovym udajem o souboru
	ret
konec:
	jmp 0x1000:start

tabulka_skoku:
	dw velikost_disku					; 36h
	dw 0								; 37h
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




;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x200-($-$$) db 0
