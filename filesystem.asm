org 0
bits 16
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

	mov dword [0x0000:0x0021], dos_preruseni


dos_preruseni:
							; TODO implementovat jump table
	nop
	ret;

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

konec:
	jmp 0x1000:start

.section .rodata
	.align 4
.skoky:
	.long .nova_slozka
	.long .smaz_slozku
	.long .nastav_slozku
	.long .novy_soubor
	.long .otevri_soubor
	.long .zapis_soubor
	.long .precti_soubor
	.long .zapis_soubor
	.long .smaz_soubor
	.long .nastav_pozici_v_souboru
	.long .ziskej_atributy_souboru
	.long .nastav_atributy_souboru
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x200-($-$$) db 0
