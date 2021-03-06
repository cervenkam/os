org 0
bits 16
%include "consts.asm"
start:
	mov ax, cs      ; zkopirovani code segmentu do AX
	mov ds, ax      ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax      ; a zkopirovani i do extra segmentu
	mov ss, ax      ; a i do stack segmentu
	mov bp, 0x9000  ; nastaveni bazove adresy zasobniku
	mov sp, bp      ; a ukazatele na aktualni prvek zasobniku (stack pointeru)
	
	mov ax,0x05     ; nastaveni sluzby 5 graficke knihovny - vyplneni pozadi
	mov bl,1
	int 0x22        ; provedeni vykresleni pozadi
	mov ax,0x02     ; nastaveni sluzby 2 graficke knihovny - nastaveni fontu
	xor bx,bx       ; vyber fontu - zakladni (maly, modry font)
	int 0x22        ; provedeni prepnuti fontu
	mov ax,0x01     ; nastaveni sluzby 1 graficke knihovny - vypis textu na obrazovku
	mov bx,0xed90   ; nastaveni pozice, kam se ma text vykresli - cca. levy spodni roh
	mov cx,verze    ; predani adresy vykreslovaneho retezce
	int 0x22        ; provedeni vykresleni retezce
	mov ax,0x02     ; nastaveni sluzby 2 graficke knihovny - nastaveni fontu
	mov bx,0x01     ; vyber fontu - doom font
	int 0x22        ; provedeni prepnuti fontu

	mov ax,0x01                     ; priprava na vypisovani menu - nastaveni sluzby na vykresleni retezce
	xor dx,dx                       ; vynulovani ridici promenne cyklu menu
menu_smycka:
	cmp dx,8                        ; porovnani, jestli jsme vypsali 4 polozky (pocitame po 2, takze 8)
	je menu_smycka_konec_prekresleni; ukonceni v pripade vykresleni celeho menu
	mov bx,dx                       ; prekopirovani ridici promenne do BX, aby bylo mozne dobre indexovat pamet
	mov cx,[cs:tabulka_retezcu+bx]  ; nacteni adresy retezce aktualni polozky menu do registru CX
	mov bx,[cs:tabulka_pozic+bx]    ; nacteni pozice vykreslovaneho retezce do registru BX
	int 0x22                        ; vykresleni retezce (cislo sluzby 1 je nastaveno pred cyklem)
	add dx,2                        ; pricteni 2 bajtu (cteme 16ti bitove adresy)
	jmp menu_smycka                 ; a vykresleni dalsi polozky
menu_smycka_konec_prekresleni:
	jmp prekresli
menu_smycka_konec:
	mov ax,0x03                     ; kod sluzby 3 graficke knihovny, zobrazeni hodin
	int 0x22                        ; a provedeni zobrazeni hodin
	xor ax,ax                       ; kod sluzby 0 - cekani na stisk klavesy
	int 0x16	                ; provedeni cekani na stisk klavesy
	mov dl,[cs:pozice]              ; nacteni aktualni pozice v menu do DL
	mov [cs:predchozi_pozice],dl    ; zaloha aktualni pozice do pameti
	cmp ah,0x48                     ; porovnani scankodu na 0x48 - sipka nahoru
	je sipka_nahoru                 ; skok na obsluhu sipky nahoru v pripade shody
	cmp ah,0x50                     ; porovnani scankodu na 0x50 - sipka dolu
	je sipka_dolu	                ; skok na obsluhu sipky dolu v pripade shody
	cmp ah,0x1C                     ; porovnani scankodu na 0x1C - enter
	je enter                        ; skok na obsluhu enteru v pripade shody
	jmp menu_smycka_konec           ; jinak ostatni klavesy ignorujeme a budeme cist stisk dalsi klavesy
sipka_nahoru:
	cmp byte [cs:pozice],0          ; porovnani pozice na 0 - v pripade sipky nahoru musime jit v menu na posledni pozici
	je rotuj_dolu                   ; pokud jsme na nule, musime rotovat dolu
	dec byte [cs:pozice]            ; jinak staci snizit hodnotu pozice
	jmp prekresli                   ; a jit znovu kreslit menu (pouze obe zucastnene polozky menu)
rotuj_dolu:
	mov bl,[cs:pocet_menu_1]        ; pokud jsme byli na pozici 0 a chceme jit nahoru, tak nova pozice bude posledni polozka v menu
	mov [cs:pozice],bl              ; kterou si tedy ulozime do pameti
	jmp prekresli                   ; a muzeme jit znovu kreslit menu (pouze predchozi a novou polozku menu)
sipka_dolu:
	mov bl,[cs:pozice]              ; nacteni hodnoty aktualni pozice do BL
	cmp bl,[cs:pocet_menu_1]        ; porovnani, jestli nejsme na posleni polozce v menu
	je rotuj_nahoru                 ; pokud ano, musime nastavit aktualni polozku na prvni polozku menu
	inc byte [cs:pozice]            ; jinak lze pouze zvysit aktualni pozici
	jmp prekresli                   ; a nakonec musime prekreslit menu (pouze dve zucastnene polozky)
rotuj_nahoru:
	mov byte [cs:pozice],0          ; pokud jsme na posledni polozce a stiskneme sipku dolu, vratime se na pozici 0
	jmp prekresli                   ; a muzeme prekreslit menu (pouze dve zucastnene polozky)
prekresli:
	mov ax,0x02                       ; nastaveni sluzby 2 graficke knihovny - zmena fontu
	mov bx,0x01                       ; nastaveni fontu 1 - doom font (nyni prekreslujeme predchozi polozku menu)
	int 0x22                          ; provedeni zmeny fontu
	mov ax,0x01                       ; nastaveni sluzby 1 graficke knihovny - vykresleni retezce
	mov bl,[cs:predchozi_pozice]      ; ulozeni indexu predchozi pozice do BL
	shl bx,1                          ; vynasobeni BX 2ma - kvuli 16ti bitove adresaci
	mov cx,[cs:tabulka_retezcu+bx]    ; nacteni adresy retezce do CX
	mov bx,[cs:tabulka_pozic+bx]      ; nacteni pozice retezce do BX
	int 0x22                          ; a provedeni vykresleni textu
	mov ax,0x02                       ; nastaveni sluzby 2 graficke knihovny - zmena fontu
	mov bx,0x02                       ; nastaveni fontu 2 - doom font ve svetle barve (nyni prekreslujeme aktivni polozku menu)
	int 0x22                          ; provedeni zmeny fontu
	mov ax,0x01                       ; nastaveni sluzby 1 graficke knihovny - vykresleni retezce
	mov bl,[cs:pozice]                ; nacteni indexu aktualni pozice z pameti do BL
	shl bx,1                          ; vynasobeni indexu 2ma - 16ti bitova adresace
	mov cx,[cs:tabulka_retezcu+bx]    ; nacteni adresy retezce do CX
	mov bx,[cs:tabulka_pozic+bx]      ; nacteni pozice retezce do BX
	int 0x22                          ; provedeni vykresleni textu
	jmp menu_smycka_konec             ; a lze cist dalsi klavesu
enter:
	mov bl,[cs:pozice]                ; nacteni aktualni pozice do BL
	xor bh,bh                         ; vynulovani BH
	shl bx,1                          ; vynasobeni BX 2ma - 16ti bitova adresace
	mov ax,[cs:tabulka_segmentu+bx]   ; nacteni segmentu, do ktereho se ma skocit, dle indexu aktualni pozice
	push ax                           ; ulozeni tohoto segmentu na zasobnik (pro retf)
	xor bx,bx                         ; vynulovani BX - budeme zacinat na offsetu 0
	push bx                           ; ulozeni offsetu na zasobnik (pro retf)
	mov bl,1                          ; nastaveni defaultniho parametr pro editor - soubor 1
	retf                              ; skok na uvedeny segment:offset
	
pocet_menu_1:
	db 3                     ; pocet polozek v menu
pozice:
	db 0                     ; aktualni pozice v menu
predchozi_pozice:
	db 1                     ; predchozi pozice v menu (musi se prekreslovat)
tabulka_retezcu:
	dw retezec_prohlizec     ; adresa retezce prohlizece
	dw retezec_editor        ; adresa retezce editoru
	dw retezec_hra           ; adresa retezce hry
	dw retezec_info          ; adresa retezce info
tabulka_pozic:
	dw 12*320+160-55-8       ; pozice, kam se vykresli retezec prohlizece
	dw 12*3*320+160-35-8     ; pozice, kam se vykresli retezec editoru
	dw 12*5*320+160-20-8     ; pozice, kam se vykresli retezec hry
	dw 12*7*320+160-20-8     ; pozice, kam se vykresli retezec infa
tabulka_segmentu:
	dw segment_prohlizec     ; segment, kde zacina program prohlizece
	dw segment_editor        ; segment, kde zacina program editoru
	dw segment_hra           ; segment, kde zacina program hry
	dw segment_info          ; segment, kde zacina program infa
retezec_prohlizec:
	db "Prohlizec",0         ; retezec prohlizece
retezec_editor:
	db "Editor",0            ; retezec editoru
retezec_hra:
	db "15ka",0              ; retezec hry
retezec_info:
	db "Info",0              ; retezec infa
verze:
	db "Verze OS: 1.0.4", 0  ; retezec verze OS
konec:
	int 0x05                 ; konec tohoto programu - NEMEL BY NIKDY NASTAT ;/
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x200-($-$$) db 0
