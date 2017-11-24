org 0
bits 16
%include "consts.asm"

start:
	mov ax,cs                            ; zkopirovani kodoveho segmentu do AX
	mov ds,ax                            ; zkopirovani puvodne kodoveho segmentu do datoveho segmentu
	mov es,ax                            ; a i do extra segmentu

	mov ah,0x3f                          ; pozadani filesystemu o cteni souboru
	xor cx,cx                            ; pozadani o root directory
	mov bx,nacteny_buffer                ; ulozeni dat od "nacteneho_buffer"u
	int 0x21                             ; a nacteni dat z FS

	mov ax,5                             ; nastaveni sluzby 5 graficke knihovny - vyplnit pozadi obrazovky
	xor bl,bl                            ; nebudeme prekreslovat spodni listu
	int 0x22                             ; provest vyplneni pozadi obrazovky
	xor cx,cx                            ; vynulovani ridici promenne nasledujiciho cyklu
	mov bx,660+960+640                   ; nastaveni pocatecni adresy vykreslovani polozek prohlizece
	xor ax,ax                            ; vynulovani AX registru - adresa zaznamu souboru v root directory
	xor dx,dx                            ; vynulovani DX registru - identifikator smeru vykreslovani
	cyklus:
		cmp cx,16                    ; test na vykreslenych 16 souboru v prohlizeci
		jge konec_cyklu              ; pokud jich bylo jiz 16 vykresleno, ukoncime cyklus
		call kresli_jeden_soubor     ; zavolame kresleni jednoho souboru
		add ax,0x20                  ; posuneme se na dalsi soubor
		add bx,160                   ; pricteme 160 (polovinu sirky obrazovky) k pozici vykreslovani
		inc cx                       ; zvysime ridici promennou cyklu o 1
		call kresli_jeden_soubor     ; a nakreslime dalsi soubor
		add ax,0x20                  ; opet se presuneme na dalsi soubor
		add bx,8000-960              ; nyni pricteme mnohem vice k pozici vykreslovani (v dalsi iteraci kreslime na dalsi radku)
		inc cx                       ; pricteme 1 k ridici promenne
		xor dh,1                     ; prepneme smer vykreslovani v dalsi iteraci
		jmp cyklus                   ; a opakujeme cyklus
	konec_cyklu:
stisk_klavesy:
	xor ax,ax                            ; cislo sluzby 0 - cekani na stisk klavesy
	int 0x16	                     ; volani sluzby BIOSu
	cmp ah,0x48                          ; porovnani scankodu stisknute klavesy na hodnotu 0x48, ktery odpovida klavese sipky nahoru
	je sipka_nahoru                      ; provedeni presunu vzhuru v menu, pokud byla stisknuta klavesa sipka nahoru
	cmp ah,0x4B                          ; porovnani scankodu stisknute klavesy na hodnotu 0x4B, ktery odpovida klavese sipky vlevo
	je sipka_do_strany                   ; sipka vlevo i sipka vpravo dela stejnou operaci, meni sloupec, proto stejna obsluha
	cmp ah,0x4D                          ; porovnani scankodu stisknute klavesy na hodnotu 0x4D, ktery odpovida klavese sipky vpravo
	je sipka_do_strany                   ; sipka vlevo i sipka vpravo provadi stejnou operaci, proto stejna obsluha
	cmp ah,0x50                          ; porovnani scankodu stisknute klavesy na hodnotu 0x50, ktery odpovida klavese sipky dolu
	je sipka_dolu                        ; provedeni presunu dolu v menu prohlizece, pokud byla stisknuta klavesa "sipka dolu"
	cmp ah,0x1C                          ; porovnani scankodu stisknute klavesy na hodnotu 0x1C, ktery odpovida enteru
	je enter                             ; provedeni vyberu souboru, byl-li stiknut enter
	jmp stisk_klavesy                    ; jinak cteme jinou klavesu
sipka_do_strany:
	mov al,[cs:aktualni_soubor]          ; nacteme si ID aktualniho souboru
	mov [cs:predchozi_soubor],al         ; a toto ID ulozime do ID predchoziho souboru
	xor byte [cs:aktualni_soubor],1      ; pote vymenime sloupec (ID sloupce je 1. bit v cs:aktualni_soubor)
	jmp kresli_zmeny                     ; a vykreslime zmeny (dva soubory)
sipka_dolu:
	mov al,[cs:aktualni_soubor]          ; nacteme si ID aktualniho souboru
	mov [cs:predchozi_soubor],al         ; a toto ID ulozime do ID predchoziho souboru
	add byte [cs:aktualni_soubor],2      ; pricteme k aktualnimu ID 2ku, posun o radek dolu (preteceni nevadi, to resi nasledujici radek)
	and byte [cs:aktualni_soubor],15     ; a vymaskujeme cokoliv do 16. souboru (tim resime preteceni)
	xor byte [cs:aktualni_soubor],1      ; zmenime sloupec (sloupce nejsou "opravdove" sloupce)
	jmp kresli_zmeny                     ; nakonec prekreslime zmeny (dva soubory)
sipka_nahoru:
	mov al,[cs:aktualni_soubor]          ; nacteme si ID aktualniho souboru
	mov [cs:predchozi_soubor],al         ; a toto ID ulozime do ID predchoziho souboru
	sub byte [cs:aktualni_soubor],2      ; odecteme od aktualniho ID 2ku, posun o radek nahoru (podteceni nevadi, to resi nasledujici radek)
	and byte [cs:aktualni_soubor],15     ; vymaskujeme cokoliv do 16. souboru (tim resime podteceni)
	xor byte [cs:aktualni_soubor],1      ; zmenime sloupec (sloupce nejsou "opravdove" sloupce)
	jmp kresli_zmeny                     ; a nakonec prekreslime zmeny (predchozi a aktualni soubory)
enter:
	mov ax,segment_editor                ; do AX nastavime segment, do ktereho se chceme presunout (segment editoru)
	mov es,ax                            ; a tento segment presuneme do ES
	xor ax,ax                            ; v editoru pujdeme na adresu 0 (od zacatku programu)
	mov bl,[cs:aktualni_soubor]          ; do BL (index souboru pro editor) ulozime ID aktualniho vybraneho souboru)
	inc bl                               ; jenze indexace souboru je od 1 (0 je root directory), proto pricteme jedna
	int 0x23                             ; a prepneme se do editoru
kresli_zmeny:
	mov bl,[cs:aktualni_soubor]          ; ulozime si do BL ID aktualniho souboru
	call kresli_jednu_zmenu              ; a podle BL vykreslime dany soubor
	mov bl,[cs:predchozi_soubor]         ; pak do BL vlozime i ID predchoziho soubru
	call kresli_jednu_zmenu              ; a vykreslime i druhy zucastneny soubor
	jmp stisk_klavesy                    ; nakonec budeme cist dalsi klavesu

kresli_jednu_zmenu:
	xor cl,cl                                   ; vynulujeme ridici promennou cyklu
	mov bx,660+960+640                          ; nastavime pocatecni pozici kresleni
	xor ax,ax                                   ; nastavime pozici zaznamu o souboru v root directory na nulu
	xor dx,dx                                   ; a vynulujeme smer vykreslovani
	cyklus_jedna:
		cmp cl,16                           ; porovname, jestli jsme jiz projeli pres vsechny soubory
		jge konec_cyklu_jedna               ; pokud ano, ukoncime vykonavani
		cmp cl,[cs:aktualni_soubor]         ; porovname CL na ID aktualniho souboru
		je muzes_kreslit_1                  ; pokud jsou stejne, budeme kreslit
		cmp cl,[cs:predchozi_soubor]        ; porovname CL i na ID predchoziho souboru
		je muzes_kreslit_1                  ; a pokud jsou stejne, opet budeme kreslit tento soubor
		jmp konec_kresleni_1                ; jinak nebudeme tento soubor kreslit
		muzes_kreslit_1:
			call kresli_jeden_soubor    ; nakreslime tento soubor
		konec_kresleni_1:
		add ax,0x20                         ; posuneme se v root directory na dalsi zaznam o souboru
		add bx,160                          ; posuneme se ve vykreslovani o pul obrazovky dale
		inc cl                              ; pricteme ridici promennou cyklu
		cmp cl,[cs:aktualni_soubor]         ; provedeme podobne porovnani jako v prvni casti cyklu, nejprve ID porovname s aktualnim souborem
		je muzes_kreslit_2                  ; a pokud jsou stejne, muzeme tento soubor nakreslit
		cmp cl,[cs:predchozi_soubor]        ; a stejne porovnani provedeme i s ID predchoziho souboru
		je muzes_kreslit_2                  ; opet muzeme kreslit, pokud s ID shoduje s promennou cyklu
		jmp konec_kresleni_2                ; jinak se nebudeme obtezovat s kreslenim
		muzes_kreslit_2:
			call kresli_jeden_soubor    ; jedna se o aktualni nebo predchozi soubor, proto ho nakreslime
		konec_kresleni_2:
		add ax,0x20                         ; posuneme se v root directory na dalsi zaznam o souboru
		add bx,8000-960                     ; posuneme se ve vykreslovani na dalsi radek
		inc cl                              ; pricteme ridici promennou cyklu
		xor dh,1                            ; vymenime sloupec
		jmp cyklus_jedna                    ; a opakujeme vykreslovaci smycku
	konec_cyklu_jedna:
	ret                                         ; nakonec se vratime z podprogramu
	
konec:
	int 0x05    ; ukonceni programu, skok do menu - NEMELO BY NIKDY NASTAT, vzdy se ceka na klavesu ;/

; AX => pozice souboru
; BX => pozice, kam se ma kreslit
; CL => ID vykreslovaneho souboru
; DH => 1/0 smer kresleni
kresli_jeden_soubor:
	pusha                         ; nejprve si ulozime stav vsech registru
	push ax                       ; ulozime si i AX - pozice souboru
	push dx                       ; ulozime si i DX - smer kresleni
	push cx                       ; a i CX - ID vykreslovaneho souboru
	;nastaveni pozadi
	mov ax,bx                     ; nejprve nastavime obdelnik pozadi, presuneme si vykreslovaci pozici do AX (citatel)
	mov cx,320                    ; nastavime CX na 320 (jmenovatel)
	div cx                        ; vydelime vykrelovaci pozici 320 - v AX ziskame index radku, v DX index sloupce
	mov [cs:pozice],ax            ; a tak si index radku ulozime do struktury pozic
	mov [cs:pozice+4],dx          ; stejne tak jako index sloupce
	add ax,17                     ; pricteme k indexu radku 17 - coz bude vyska pozadi
	add dx,120                    ; pricteme k indexu sloupce 120 - coz bude sirka pozadi
	mov [cs:pozice+2],ax          ; a opet zapiseme index radku ...
	mov [cs:pozice+6],dx          ; a sloupce do struktury pozic
	mov byte [cs:pozice+8],4      ; nakonec vybereme barvu pozadi, bude to 4. barva ve VGA palete
	pop cx                        ; obnovime CX - ID vykreslovaneho souboru
	cmp cl,[cs:aktualni_soubor]   ; a porovname ho s aktualnim souborem
	jne nemenit_pozadi            ; pokud jsou stejne, zmenime pozadi, aby bylo videt, ktery soubor je vybran
	mov byte [cs:pozice+8],5      ; zmena pozadi na 5. barvu ve VGA palete
nemenit_pozadi:
	mov ax,0x4                           ; nyni vykreslime obdelnik pozadi, nastavime ID sluzby 4 graficke knihovny - vykresleni obdelniku
	push bx                              ; ulozime BX - pozice vykresleni
	mov bx,pozice                        ; a misto nej do nej vlozime adresu struktury pozic
	int 0x22	                     ; nakonec zavolame grafickou knihovnu, ktera vykresli obdelnik
	pop bx                               ; obnovime BX - pozice vykresleni
	pop dx                               ; obnovime DX - smer kresleni
	pop ax                               ; obnovime AX - pozice souboru
	push ax                              ; ale opet ho zase ulozime, to znamena, ze jsme provedli peek na zasobniku do AX
	push dx                              ; a ulozime i DX - smer kresleni (opet peek do DX)
	mov byte [cs:znak],2                 ; v teto casti budeme kreslit oblicej dle "zaplnenosti" souboru, nastavime vykreslovany znak na ASCII
	                                     ; 2ku (obrazek mrtveho doomguye/marine), obliceje se budou kreslit jako text (jsou nastaveny jako font)
	push bx                              ; ulozime BX - pozici vykreslovani
	mov bx,ax                            ; ulozme AX do BX - pozice v souboru
	mov ah,[cs:nacteny_buffer+bx+0x1e]   ; precteme horni bajt velikosti vykreslovaneho souboru
	mov al,[cs:nacteny_buffer+bx+0x1f]   ; precteme dolni bajt velikosti vykreslovaneho souboru - velikost je nyni v AX
	xor dx,dx                            ; vycistime DX
	mov cx,102                           ; do CX vlozime 102 (mame 512 bajtu max. velikost souboru a 5 obliceju (6ty je zvlast) => 512/5 ~= 102)
	div cx                               ; a vydelime AX/CX, ziskame index obliceje v AX
	cmp al,5                             ; porovname AL na 5 (vice nez 6 obliceju neni, ochrana proti preteceni)
	jle neopravuj_al                     ; pokud jsme <=5, je to dobre, nemusime index opravovat
	mov al,5                             ; jinak ho opravime na 5 (oblicej "smrti" - plny soubor), provedli jsme vlastne "index = min(index,5)"
neopravuj_al:
	add [cs:znak],al                     ; pricteme vypocitany index obliceje k znaku
	mov ax,0x2                           ; nastavime sluzbu graficke knihovny na 2 - nastaveni fontu
	mov bx,0x3                           ; vybereme font 3 - obliceje doomguye
	int 0x22                             ; a zavolame grafickou knihovnu
	pop bx                               ; obnovime BX - pozici vykreslovani
	pop dx                               ; obnovime DX - smer kresleni
	push bx                              ; a znovu ulozime BX - pozici vykreslovani
	mov ax,0x1                           ; vybereme sluzbu graficke knihovny 1 - kresleni retezce
	sub bx,320*6                         ; od vykreslovaci pozice odecteme 6 radek - oblicej se posune o 6 px vzhuru
	test dh,dh                           ; otestujeme, na kterou stranu mame oblicej kreslit
	jz nepridavat                        ; pokud je DH rovno nule, muzeme kreslit rovnou, jinak se posuneme na druhou stranu obdelnika
	add bx,96                            ; posun na druhou stranu obdelnika (sirka obdelnika - sirka obliceje)
nepridavat:
	mov cx,znak                          ; do CX ulozime adresu "retezce" - jeden znak nasledovany \0
	int 0x22                             ; a vykreslime oblicej (pres font)
	mov ax,0x2                           ; nyni zacneme vykreslovat nazev souboru (priponu zatim ne), nastavime sluzbu graficke knihovny
	                                     ; na 2ku - nastaveni fontu
	mov bx,0x4                           ; vybereme font 4 (zakladni font s pruhlednosti)
	int 0x22                             ; a zavolame grafickou knihovnu
	pop bx                               ; peeknem BX - vykreslovaci pozici
	pop ax                               ; a peeknem AX ...
	push ax                              ; ... coz je pozice souboru
	push bx                              ; dokoncime peek BX
	mov bx,ax                            ; presuneme pozici souboru do BX
	add bx,nacteny_buffer                ; pricteme k ni nacteny buffer
	mov dl,[cs:bx+8]                     ; a zalohujeme znak na 8. pozici do DL
	mov byte [cs:bx+8],0                 ; ktery nahradime znakem \0 (umele ukoncime retezec, aby bylo mozne ho vypsat)
	mov cx,bx                            ; presuneme adresu do CX
	pop bx                               ; opet peekneme registr BX ...
	push bx                              ; ... coz je vykreslovaci pozice
	add bx,320*2+2                       ; k ni pricteme 2 radky a 2 sloupce (padding)
	test dh,dh                           ; otestujeme, jestli nemame kreslit na druhou stranu
	jnz nepridavat_2                     ; a pokud ne, preskakujeme opravu
	add bx,60                            ; jinak opravime vykreslovaci pozici (pricteme k ni 60)
nepridavat_2:
	mov ax,0x1                           ; nastavime sluzbu graficke knihovny na 1 - vykresleni textu
	int 0x22                             ; a provedeme samotne vykresleni textu
	mov bx,cx                            ; presuneme do BX adresu zaznamu o souboru v root directory
	mov [cs:bx+8],dl                     ; a tam opravime znak na 8. pozici (z \0 na puvodni znak)
	pop bx                               ; peeknem BX - vykreslovaci pozici
	pop ax                               ; a peeknem AX ...
	push ax                              ; ... coz je pozice souboru
	push bx                              ; dokoncime peek BX
	mov bx,ax                            ; nyni zacneme vykreslovat priponu (obdobnym zpusobem jako nazev souboru), presuneme si pozici
	                                     ; souboru do BX
	add bx,nacteny_buffer                ; pricteme adresu bufferu
	add bx,8                             ; ale oproti nazvu souboru pripona lezi az za nazvem souboru, ktery ma delku 8, proto pricteme 8
	mov dl,[cs:bx+3]                     ; od teto pozice si zalohujeme znak 3 znaky dale (max. delka pripony) - bajt za priponou
	mov byte [cs:bx+3],0                 ; a misto nej tam vlozime ukoncovaci znak retece \0
	mov cx,bx                            ; presuneme adresu vykreslovaneho textu do CX
	pop bx                               ; opet peekneme registr BX ...
	push bx                              ; ... coz je vykreslovaci pozice
	add bx,320*9+2                       ; k vykreslovaci pozici pricteme 9 radek a 2 sloupce (kreslime pod nazev souboru s
	                                     ; respekovanim paddingu)
	test dh,dh                           ; otestujeme, jestli nemame kreslit obracene
	jnz nepridavat_3                     ; pokud ne, nemusime nic pridavat k vykreslovaci pozici
	add bx,60                            ; jinak pricteme 60, tim budeme kreslit na druhou stranu
nepridavat_3:
	mov ax,0x1                           ; nastavime sluzbu graficke knihovny na 1 - vykresleni retezce
	int 0x22                             ; a retezec vykreslime
	mov bx,cx                            ; nacteme si adresu pripony z CX do BX
	mov [cs:bx+3],dl                     ; a obnovime bajt za priponou z \0 na puvodni bajt
	pop bx                               ; obnovime BX ze zasobniku
	pop ax                               ; obnovime AX ze zasobniku
	popa                                 ; a nakonec i vsechny registry
	ret	                             ; nakonec ukoncime podprogram
pozice:
	dw 0  ; Y1 pozice vykreslovaneho obdelniku
	dw 0  ; Y2 pozice vykreslovaneho obdelniku
	dw 0  ; X1 pozice vykreslovaneho obdelniku
	dw 0  ; X2 pozice vykreslovaneho obdelniku
	db 4  ; barva pozadi obdelniku
znak:
	dw 0  ; ASCII hodnota vykreslovaneho obliceje, nasledovana bajtem \0
aktualni_soubor:
	db 0  ; ID aktualne vybraneho souboru
predchozi_soubor:
	db 0  ; ID vybraneho souboru v predchozim kroku
nacteny_buffer:
	times 0x201 db 0 ; buffer, kam se nacte root directory (je o 1 vetsi, aby bylo mozne pohodlne vypisovat, kdyby bylo treba a
	                 ; vzdy bude buffer zakoncen \0)
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x600-($-$$) db 0
