bits 16
org 0
%define SIRKA_OKNA 320
%define VYSKA_OKNA 200
video_preruseni:
	cli                            ; obsluha preruseni 0x22 graficke knihovny, nejprve zakazeme preruseni
	push dx                        ; ulozime registr DX
	push bx                        ; a BX na zasobnik
	mov bx,ax                      ; prekopiruje AX do BX, aby bylo mozne s nim indexovat (v AX je cislo sluzby)
	shl bx,1                       ; vynasobime ho 2 (16ti bitova adresace)
	mov dx,[cs:tabulka_skoku+bx]   ; a najdeme adresu obsluhy dane sluzby dle vstupniho parametru AX
	pop bx                         ; obnovime BX pro obsluhu sluzby
	call dx                        ; a zavolame tuto obsluhu
	pop dx                         ; nakonec obnovime DX
	iret                           ; a ukoncime obsluhu preruseni
tabulka_skoku:
	dw text_nastavit_video_mod     ; obsluha sluzby 0x00 -> nastaveni video modu
	dw text_zobrazit               ; obsluha sluzby 0x01 -> vykresleni textu
	dw text_nastavit_font          ; obsluha sluzby 0x02 -> nastaveni fontu
	dw zobraz_hodiny               ; obsluha sluzby 0x03 -> zobrazeni hodin
	dw vypln_obdelnik              ; obsluha sluzby 0x04 -> vyplneni obdelniku
	dw vypln_obrazovku             ; obsluha sluzby 0x05 -> vyplneni cele obrazovky
vypln_obrazovku:
	pusha                          ; ulozeni vsech registru na zasobnik
	push es                        ; ulozeni extra segmentu na zasobnik, ten si pak nastavime na segment video pameti
	mov ax,0xa000                  ; nastaveni AX na segment video pameti
	mov es,ax                      ; presun segmentu video pameti do extra segmentu
	mov cx,SIRKA_OKNA*VYSKA_OKNA   ; nastaveni ridici promenne cyklu na pocet pixelu v okne
	vyplneni_smycka:
		mov bx,cx              ; zkopirovani ridici promenne do BX pro indexaci
		mov byte [es:bx],0     ; vynulovani aktualniho pixelu
		loop vyplneni_smycka   ; a opakovani smycky
	pop es                         ; obnova extra segmentu
	popa                           ; obnova vsech ostatnich registru
	ret                            ; a navrat z podprogramu
vypln_obdelnik:
	pusha                                       ; nejprve si ulozime stavy registru na zasobnik
	push es                                     ; a take extra segment
	mov ax,0xa000                               ; do AX vlozime segment video pameti
	mov es,ax                                   ; a ten prekopirujeme do extra segmentu
	mov cx,[ds:bx]                              ; co ridici promenne CX vlozime pocatecni Yovou souradnici kresleni
	vnejsi_smycka:
		cmp cx,[ds:bx+2]                    ; CX porovname s koncovou Yovou hranici
		je konec_vnejsi_smycky              ; a pokud jsme jiz mimo oblast, ukoncime smycku
		mov dx,[ds:bx+4]                    ; jinak do ridici promenne vnitrniho cyklu DX vlozime pocatecni Xovou hranici
		vnitrni_smycka:
			cmp dx,[ds:bx+6]            ; DX porovname s koncovou Xovou hranici vykreslovani
			je konec_vnitrni_smycky     ; a pokud jsme mimo, pujdeme kreslit dalsi radek
			mov ax,SIRKA_OKNA           ; do AX vlozime sirku okna
			push dx                     ; ulozime si DX, protoze nam ho nasledujici instrukce "mul" prepise
			mul cx                      ; a vynasobime CX sirkou okna -> ziskame vykreslovaci pozici pro dany radek v AX
			pop dx                      ; peekneme DX ...
			push dx                     ; ... ze zasobniku
			add ax,dx                   ; a do AX pridame BX (mame jiz kompletni vykreslovaci pozici)
			push bx                     ; ulozime BX, aby jsme s nim mohli indexovat
			mov dl,[ds:bx+8]            ; nejprve nacteme barvu, kterou budeme vyplnovat obdelnik
			mov bx,ax                   ; pote prekopirujeme AX do BX, aby jsme mohli indexovat
			mov [es:bx],dl              ; a na vykreslovaci pozici vlozime zvolenou barvu
			pop bx                      ; obnovime BX ...
			pop dx                      ; ... a DX ze zasobniku
			inc dx                      ; zvetsime ridici promennou DX vnitrniho cyklu
			jmp vnitrni_smycka          ; a vnitrni cyklus opakujeme
		konec_vnitrni_smycky:
		inc cx                              ; zvysime ridici promennou vnejsiho cyklu CX
		jmp vnejsi_smycka                   ; a vnejsi cyklus opakujeme
	konec_vnejsi_smycky:
	pop es                                      ; provedeme obnovu extra segmentu
	popa                                        ; spolu s ostatnimi registry
	ret                                         ; a ukoncime podprogram
text_nastavit_video_mod:
	push ax         ; ulozeni registru AX na zasobnik
	mov ax, 0x13    ; nastaveni typu video modu: 320x200, 256barev
	int 0x10        ; nastaveni video modu
	pop ax          ; obnoveni registru AX ze zasobniku
	ret             ; ukonceni podprogramu
text_nastavit_font:
	pusha                             ; ulozime se vsechny registry na zasobnik
	mov ax,10                         ; do AX vlozime 10 (velikost struktury pisma, viz dale...)
	mul bx                            ; prenasobnime BX (parametrem, ktere pismo volime)
	mov bx,ax                         ; vysledek nasobeni prekopirujeme do BX
	add bx,pisma                      ; a pricteme adresu pisem
	mov word [cs:aktivni_pismo],bx    ; tuto adresu vlozime do pameti jako aktivni pismo
	popa                              ; obnovime vsechny registry
	ret                               ; a ukoncime podprogram
aktivni_pismo:
	dw pismo_male             ; defaultne prvni pismo
pisma:
pismo_male:
	db 6                      ; vyska znaku
	db 5                      ; sirka obrazku
	db 0x34                   ; transparentni barva
	dw ascii_small            ; adresa obrazku
	dw ascii_small_pozice     ; pozice pismen v obrazku
	dw ascii_small_sirka      ; sirka pismen v obrazku
	db 0                      ; pridani konstantni barvy
pismo_doom:
	db 12                     ; vyska znaku
	db 16                     ; sirka obrazku
	db 0x34                   ; transparentni barva
	dw doom                   ; adresa obrazku
	dw doom_pozice            ; pozice pismen v obrazku
	dw doom_sirka             ; sirka pismen v obrazku
	db 0                      ; pridani konstantni barvy
pismo_doom_svetlejsi:
	db 12                     ; vyska znaku
	db 16                     ; sirka obrazku
	db 0x34                   ; transparentni barva
	dw doom                   ; adresa obrazku
	dw doom_pozice            ; pozice pismen v obrazku
	dw doom_sirka             ; sirka pismen v obrazku
	db 41                     ; pridani konstantni barvy
pismo_doomfaces:
	db 31                     ; vyska znaku
	db 24                     ; sirka obrazku
	db 11                     ; transparentni barva
	dw doomfaces_font         ; adresa obrazku
	dw doomfaces_pozice       ; pozice pismen v obrazku
	dw doomfaces_sirka        ; sirka pismen v obrazku
	db 0                      ; pridani konstantni barvy
pismo_male_pruhledne:
	db 6                      ; vyska znaku
	db 5                      ; sirka obrazku
	db 0                      ; transparentni barva
	dw ascii_small            ; adresa obrazku
	dw ascii_small_pozice     ; pozice pismen v obrazku
	dw ascii_small_sirka      ; sirka pismen v obrazku
	db 0                      ; pridani konstantni barvy
pismo_male_jina_barva:
	db 6                      ; vyska znaku
	db 5                      ; sirka obrazku
	db 0                      ; transparentni barva
	dw ascii_small            ; adresa obrazku
	dw ascii_small_pozice     ; pozice pismen v obrazku
	dw ascii_small_sirka      ; sirka pismen v obrazku
	db 3                      ; pridani konstantni barvy

; vykresli text na obrazovku ve video modu
; DS:CX => adresa retezce
; BX => pozice retezce
text_zobrazit:
	pusha                           ; ulozeni stavu vsech registru
	push es                         ; ulozeni extra segmentu
	mov di,bx                       ; ulozeni pozice do DI
	mov ax, 0xa000                  ; nastaveni video segmentu do CX
	mov es,ax                       ; presun video segmentu do extra segmentu
	mov si,cx                       ; nastaveni registru SI na hodnotu znaku ulozenou v AX
	xor ax,ax                       ; vynulovani registru AX
	mov bx,[cs:aktivni_pismo]       ; nastaveni BX na strukturu aktivniho pisma
	mov cx,[cs:bx+7]                ; nastaveni CX na pole sirek znaku
	text_smycka:
		lodsb                   ; nacteni znaku z adresy DS:SI do registru AL
		cmp al, 0               ; porovnani na konec retezce
		je text_konec           ; ukonceni v pripade konce retezce
		xor bx,bx               ; vynulovani registru BX
		mov bl,al               ; do BL vlozime nacteny znak
		add bx,cx               ; ten posuneme v poli sirek na spravnou pozici
		mov ah,[cs:bx]          ; a do AH vlozime jeho sirku
		call text_zobraz_znak   ; volani zobrazeni znaku
		mov al,ah               ; pote presuneme AH do AL
		xor ah,ah               ; a AH vynulujeme, ziskame tim v AX sirku znaku
		add di,ax               ; tu pricteme k vykreslovaci pozici
		inc di                  ; a pridame 1px mezeru mezi znaky
		jmp text_smycka         ; opetovne volani, dokud neni konec retezce
	text_konec:
	pop es                          ; obnovime si stav extra segmentu
	popa                            ; a zaroven i vsech ostatnich registru
	ret                             ; a ukoncime podprogram

; vykresli znak na obrazovku ve video modu
; AL => ASCII znak
; AH => sirka znaku
; DI => pozice znaku ve video pameti
text_zobraz_znak:
	pusha                                        ; ulozime si stav vsech registru
	mov bx,[cs:aktivni_pismo]                    ; do BX ulozime pozici aktivniho pisma
	push bx                                      ; BX ulozime na zasobnik (zacatek struktury aktivniho pisma)
	mov bx,[cs:bx+5]                             ; a do BX vlozime adresu pozic znaku v obrazku
	push ax                                      ; ulozime si AX na zasobnik (sirka znaku a ASCII hodnota)
	xor ah,ah                                    ; vynulujeme jeho horni cast (sirku znaku) -> v AX je ASCII hodnota
	add bx,ax                                    ; pricteme ASCII hodnotu k adrese pozic znaku
	pop ax                                       ; obnovime AX ze zasobniku (sirku znaku a ASCII hodnotu)
	xor ch,ch                                    ; vynulujeme CH
	mov cl,[cs:bx]                               ; a do CL vlozime pozici znaku (CH=0, tzn. v CX je pozice znaku)
	pop bx                                       ; obnovime BX ze zasobniku (zacatek struktury aktivniho pisma)
	push ax                                      ; opet ulozime AX na zasobnik (sirku znaku a ASCII hodnotu)
	xor ah,ah                                    ; vynulujeme AH -> v AX zbyde ASCII hodnota
	mov al,[cs:bx]                               ; jenze tu prepiseme vyskou znaku
	mul cx                                       ; tuto vysku prenasobime CX (pozici znaku)
	mov cl,[cs:bx+1]                             ; do CL vlozime sirku obrazku
	mul cx                                       ; a prenasobnime s ni AX (v AX bude (ASCII hodnota)*(pozice znaku)*(sirka obrazku)
	                                             ; tzn. zacatek znaku v obrazku)
	mov si,ax                                    ; do SI vlozime zacatek znaku v obrazku
	pop ax                                       ; a AX obnovime na sirku znaku a ASCII hodnotu
	add si,[cs:bx+3]                             ; a do SI pridame adresu obrazku (v SI mame kompletni adresu v pameti)
	xor cx,cx                                    ; vynulujeme ridici promenne CL a CH obou zanorenych cyklu
	xor dh,dh                                    ; vynulujeme DH
	text_vnejsi_cyklus:
		cmp cl,[cs:bx]                       ; porovname CL na vysku znaku
		je text_konec_vnejsi_cyklus          ; a pokud jsme jiz na vysce znaku, znak byl nakreslen cely a muzeme ukoncit smycku
		xor ch,ch                            ; jinak vynulujeme ridici promennou CH vnitrniho cyklu
		text_vnitrni_cyklus:
			cmp ch,ah                    ; porovname CH s AH (sirkou znaku)
			je text_konec_vnitrni_cyklus ; a pokud jsme jiz na sirce znaku, budeme kreslit dalsi radku
			push ax                      ; ulozime si AX na zasobnik (sirku znaku a ASCII hodnotu)
			mov al,[cs:si]               ; do AL precteme aktualni pixel fontu
			cmp al,[cs:bx+2]             ; a tento pixel porovname s transparentni barvou
			je text_pokracuj             ; a pokud jsou stejne, nebudeme pixel kopirovat
				add al,[cs:bx+9]     ; jinak k AL pridani konstantni barvu (lze s ni menit barvu fontu)
				mov [es:di],al       ; a do video pameti vlozime dany pixel
			text_pokracuj:
			inc di                       ; zvysime pozici, kam vykreslujeme
			inc si                       ; zvysime pozici, odkud vykreslujeme
			pop ax                       ; obnovime AX ze zasobniku (na sirku znaku a ASCII hodnotu)
			inc ch                       ; zvyseni ridici promenne vnitrniho cyklu
			jmp text_vnitrni_cyklus      ; a vnitrni cyklus opakujeme
		text_konec_vnitrni_cyklus:
		inc cl                               ; zvysime ridici promennou vnejsiho cyklu
		push ax                              ; ulozime AX (sirku znaku a ASCII hodnotu) na zasobnik
		mov al,ah                            ; presuneme AH (sirku znaku) do AL
		xor ah,ah                            ; a vynulujeme AH -> v AX je sirka znaku
		add di,SIRKA_OKNA                    ; posuneme se ve video pameti na dalsi radek
		sub di,ax                            ; ale musime odecist sirku obrazku
		mov dl,[cs:bx+1]                     ; do DL vlozime sirku obrazku (DH je vynulovano pred zacatkem cyklu)
		add si,dx                            ; v obrazku se posuneme o sirku obrazku
		sub si,ax                            ; ale vratime o sirku znaku (protoze znak muze byt mensi nez sirka obrazku)
		pop ax                               ; obnovime AX (sirku znaku a ASCII hodnotu) ze zasobniku
		jmp text_vnejsi_cyklus               ; a opakujeme dalsi radku
	text_konec_vnejsi_cyklus:
	popa                                         ; obnovime stav vsech registru
	ret                                          ; a provedeme navrat z podprogramu
%include "images/doomfaces_font.asm"
%include "images/ascii_small.asm"
%include "images/doom.asm"
	
doom_pozice:
	times 48 db 0                                                          ; na prvnich 48 ASCII pozicich neni zadny znak
	db 26,27,28,29,30,31,32,33,34,35                                       ; pozice cislic v obrazku "0-9"
	times 7 db 0                                                           ; na techto pozicich neni zadny znak
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; pozice znaku "A-Z"
	times 6 db 0                                                           ; na techto pozicich neni zadny znak
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; pozice znaku "a-z"
	times 5 db 0                                                           ; na techto pozicich neni zadny znak
ascii_small_pozice:
	db 0                                                                   ; zde neni zadny znak
	db 39                                                                  ; pozice plneho znaku (kurzoru pro editor) "#"
	times 30 db 0                                                          ; na techto pozicich neni zadny znak
	db 37                                                                  ; ASCII znak mezery " "
	times 13 db 0                                                          ; na techto pozicich neni zadny znak
	db 38                                                                  ; ASCII znak tecky "."
	db 0                                                                   ; zde neni zadny znak
	db 26,27,28,29,30,31,32,33,34,35                                       ; pozice cislic "0-9"
	db 36                                                                  ; pozice dvojtecky ":"
	times 6 db 0                                                           ; na techto pozicich neni zadny znak
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; pozice znaku "A-Z"
	times 6 db 0                                                           ; na techto pozicich neni zadny znak
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; pozice znaku "a-z"
	times 5 db 0
doom_sirka:
	times 48 db 0                                                                    ; na prvnich 48 ASCII pozicich neni zadny znak
	db 11,7,11,11,11,11,11,11,11,11                                                  ; sirka cislic v obrazku "0-9"
	times 7 db 0                                                                     ; na techto pozicich neni zadny znak
	db 14,14,14,14,14,12,16,15,6,11,16,11,16,16,16,14,16,15,15,12,16,16,16,14,16,16  ; sirky znaku "A-Z"
	times 6 db 0                                                                     ; na techto pozicich neni zadny znak
	db 14,14,14,14,14,12,16,15,6,11,16,11,16,16,16,14,16,15,15,12,16,16,16,14,16,16  ; sirka znaku "a-z"
	times 5 db 0                                                                     ; na techto pozicich neni zadny znak
ascii_small_sirka:
	db 0                                                   ; na teto pozici neni zadny znak
	db 5                                                   ; sirka plneho znaku (kurzoru pro editor) "#"
	times 30 db 0                                          ; na techto pozicich neni zadny znak
	db 5                                                   ; sirka mezery " "
	times 13 db 0                                          ; na techto pozicich neni zadny znak
	db 1                                                   ; sirka tecky "."
	db 0                                                   ; zde neni zadny znak
	db 5,5,5,5,5,5,5,5,5,5                                 ; sirka cislic "0-9"
	db 1                                                   ; sirka dvojtecky ":"
	times 6 db 0                                           ; zde nejsou zadne znaky
	db 5,5,5,5,5,5,5,5,1,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5 ; sirka znaku "A-Z"
	times 6 db 0                                           ; na techto pozicich nejsou zadne znaky
	db 5,5,5,5,5,5,5,5,1,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5 ; sirka znaku "a-z"
	times 5 db 0                                           ; na techto pozicich nejsou zadne znaky
doomfaces_sirka:
	dw 0             ; na prvnich dvou pozicich nejsou zadne znaky
	times 6 db 24    ; dalsich 6 znaku ma sirku 24 (6 obliceju)
	times 250 db 0   ; ostatni znaky nemaji sirku
doomfaces_pozice:
	dw 0             ; na prvnich dvou pozicich nejsou zadne znaky
	db 0,1,2,3,4,5   ; dalsich 6 znaku jsou obliceje od 0 do 5ti vcetne
	times 250 db 0   ; ostatni znaky neexistuji

; ziska cas z BIOSu
; zadne parametry
; CH - hodiny
; CL - minuty
; DH - sekundy
ziskej_hodiny:
	push ax
	push bx
	push dx
	push es
	mov ax,0x0040
	mov es,ax
	xor ax,ax
	mov dx,[es:0x006c]
	mov cx,[es:0x006e]
	pop es
	; az sem je to OK
	mov bx,dx
	mov ax,cx
	push bx
	mov bx,540
	mul bx
	pop bx
	mov cx,ax
	mov ax,bx
	push bx
	mov bx,540
	mul bx
	pop bx
	add cx,dx
	mov dx,cx
	push bx
	mov bx,19663
	div bx
	xor dx,dx
	pop bx
	mov bx,ax
	mov cx,30
	div cx
	shl dx,1
	;mov cx,[es:0x006c]
	;and cx,1
	;add dx,cx
	mov cx,60
	push dx
	xor dx,dx
	div cx
	push dx
	mov ch,al
	pop ax
	mov cl,al
	pop ax
	pop dx
	mov dh,al
	pop bx
	pop ax
	ret
zobraz_hodiny:
	pusha
	push ds
	mov ax, cs
	mov ds, ax
	call ziskej_hodiny
	mov bx,8
	xor ah,ah
	mov al,ch
	call zobraz_registr
	mov al,cl
	call zobraz_registr
	mov al,dh
	call zobraz_registr
	mov cx,hodiny
	mov bx,0xee6e
	mov word [aktivni_pismo],pismo_male
	call text_zobrazit
	pop ds
	popa
	ret		

zobraz_registr:
	push ax
	push cx
	push dx
	mov cx,10
	div cl
	add ax,0x3030
	mov [hodiny+bx],al
	inc bx
	mov [hodiny+bx],ah
	add bx,2
	pop dx
	pop cx
	pop ax
	ret
hodiny:
	db "Hodiny: 00:00:00", 0
times 0x3a00-($-$$) db 0
