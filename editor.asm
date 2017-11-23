org 0
bits 16
%define ZNAKU_NA_RADEK 40
%define POCET_ODRADKOVANI 14
start:
	mov ax, cs                       ; zkopirovani code segmentu do AX
	mov ds, ax                       ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                       ; a zkopirovani i do extra segmentu
	mov word [cs:kurzor_pointer], 0  ; vynulovani kurzoru (presun na zacatek souboru)
	mov [cs:id_souboru],bl           ; ulozeni ID souboru do pameti (predano pres BL

default_editor:
	mov cl, [cs:id_souboru]          ; nacteni ID souboru z pameti do CL
	mov ah, 0x3f                     ; vyber sluzby filesystemu 0x3f - cteni souboru
	mov bx, buffer_editoru           ; predani adresy, kam se ma obsah zapsat - do buffer_editoru
	int 0x21                         ; a volani sluzeb filesystemu
	mov al,[cs:buffer_editoru]       ; ulozeni 1. znaku z bufferu
	mov [cs:zalozni_znak],al         ; a jeho zalohovani (bude tam kurzor)

cisteni:
	mov ax, 5   ; nastaveni sluzby cislo 5 graficke knihovny - vyplneni pozadi
	int 0x22    ; a volani graficke knihovny
nastaveni_fontu:
	mov ax, 2   ; nastaveni sluzby cislo 2 graficke knihovny - nastaveni fontu
	mov bx, 5   ; vyber fontu cislo 5 - zakladni font v oranzove barve
	int 0x22    ; a volani graficke knihovny

vykresleni:
	call zaloha_ukazatele      ; nejprve je potreba zalohovat kurzor
	call nastaveni_ukazatele   ; pak ho nastavit
	call nakresli              ; a nakonec vse nakreslit
klavesnice:
	xor ax, ax                 ; po te, co je vse vykresleno, budeme cekat na vstup z klavesnice
	int 0x16                   ; takze zavolame sluzbu BIOSu na cekani na vstup z klavesnice
	call obnova_ukazatele      ; obnovime si kurzor
	cmp ah,0x4B                ; a testujeme stisknutou klavesu na levou sipku
	je leva_sipka              ; a pokud se opravdu jednalo o levou sipku, provedeme jeji obsluhu
	cmp ah,0x48                ; dale testujeme na sipku nahoru
	je sipka_nahoru            ; a opet pokud se jednalo o sipku nahoru, obslouzime ji
	cmp ah,0x50                ; pote se pokusime otestovat shodu na sipku dolu
	je sipka_dolu              ; a pripadne ji obslouzit
	cmp ah,0x4D                ; dalsi moznosti je sipka vpravo
	je prava_sipka             ; jejiz obsluhu se taktez pokusime provest v pripade shody
	cmp ah,0x1C                ; dalsi funkci je enter, ktery uklada soubor
	je enter_ulozit            ; takze soubor ulozime, jestli byl enter stisknut
	cmp ah,0x0e                ; dale testujeme backspace na mazani znaku
	je backspace               ; a budeme mazat znaky, pokud byl stisknut backspace
	test al,0xa0               ; nakonec vyhodime vsechny znaky, jejichz ASCII hodnota je >= 0x80
	jz klavesnice              ; a misto nich radeji budeme cist jine znaky
	jmp jina_klavesa           ; vsechny ostatni klavesy se pokusime zapsat jako plaintext

jina_klavesa:
	mov bx,510                                    ; budeme vsechny znaky soupat dopredu, takze do BX dame konecnou hranici
	                                              ; kam az lze znaky soupat, cyklus se bude dekrementovat od teto hodnoty
	jina_klavesa_cyklus:
		cmp bx,[cs:kurzor_pointer]            ; zjistime jestli uz nejsme u kurzoru
		jl jina_klavesa_konec_cyklu           ; a pokud ano, ukoncime cyklus
		mov dh,[cs:buffer_editoru+bx]         ; jinak vezmeme znak na aktualni pozici
		mov [cs:buffer_editoru+bx+1],dh       ; a presuneme ho o jeden znak dopredu
		dec bx                                ; snizime ridici promennou cyklu
		jmp jina_klavesa_cyklus               ; a opakujeme cyklus
	jina_klavesa_konec_cyklu:	
	mov [cs:buffer_editoru+bx+1],al               ; na pozici kurzoru vlozime aktualni stisknuty znak
	inc word [cs:kurzor_pointer]                  ; posuneme kurzor o jedna dopredu
	cmp word [cs:kurzor_pointer],512              ; a otestujeme, pokud nam kurzor nevytekl
	jl jina_klavesa_neopravuj                     ; pokud ne, nebudeme delat zadne opravy
		mov word [cs:kurzor_pointer],511      ; jinak vratime kurzor na posledni moznou pozici (511)
		mov byte [cs:buffer_editoru+512],0    ; a ukoncime buffer znakem \0 (ten byl prepsan)
	jina_klavesa_neopravuj:
	jmp cisteni                                   ; nakonec nechame cely editor se prekreslit
	
backspace:
	mov bx,[cs:kurzor_pointer]                    ; nejprve si nacteme do BX pozici kurzoru
	test bx,bx                                    ; otestujeme, jestli nejsme na zacatku souboru
	jnz backspace_neopravuj                       ; pokud ne, lze normalne mazat
		mov word [cs:kurzor_pointer],1        ; jinak docasne posuneme kurzor o 1 dopredu, pak se vrati zpet na 0
	                                              ; a umozni to mazani znaku pod kurzorem
	backspace_neopravuj:
	dec word [cs:kurzor_pointer]                  ; snizime kurzor o 1 (situace, ze byl kurzor predtim 0 byla jiz osetrena)
	mov bx,[cs:kurzor_pointer]                    ; a znovu nacteme kurzor do BX (jako ridici promennou cyklu)
	backspace_cyklus:
		cmp bx,512                            ; zjistime, jestli jiz jsme presunuli vsechny znaky
		jge backspace_konec_cyklu             ; a pokud ano, ukoncime cyklus
		mov dh,[cs:buffer_editoru+bx+1]       ; jinak nacteme znak o jeden dopredu
		mov [cs:buffer_editoru+bx],dh         ; a vlozime ho na aktualni pozici
		test dh,dh                            ; pokud jsme presouvali \0
		jz backspace_konec_cyklu              ; tak take muzeme ukoncit cyklus, protoze zbytek neni treba presouvat
		inc bx                                ; jinak zvysime ridici promennou cyklu
		jmp backspace_cyklus                  ; a opakujeme cyklus
	backspace_konec_cyklu:	
	jmp cisteni                                   ; nakonec nechame cely editor se prekreslit
	
posun:
	add word [cs:kurzor_pointer], ax   ; posuneme kurzor o hodnotu ulozenou v AX
	js posun_nastav_0                  ; pokud jsme v zapornych cislech, tak predpokladame, ze jsme asi podtekli, takze
	                                   ; kurzor nastavime na nulu
	call strlen                        ; jinak si do AX ulozime delku retezce
	cmp word [cs:kurzor_pointer],ax    ; a s ni porovname kurzor
	jg posun_nastav_ax                 ; pokud jsme s kurzorem moc daleko, vratime ho na delku retezce (o jeden znak za
	                                   ; posledni nenulovy znak
	jmp cisteni                        ; a nechame cely editor se prekreslit
posun_nastav_0:
	mov word [cs:kurzor_pointer],0     ; nastavime kurzor na nulu
	jmp cisteni                        ; a prekreslime editor
posun_nastav_ax:
	mov word [cs:kurzor_pointer],ax    ; nastavime kurzor za poslendni nenulovy znak
	jmp cisteni                        ; a prekreslime editor

prava_sipka:
	mov ax,1                           ; inkrementujeme kurzor
	jmp posun                          ; a provedeme posun

leva_sipka:
	mov ax,0xffff                      ; dekrementujeme kurzor
	jmp posun                          ; a provedeme posun
sipka_dolu:
	mov ax,ZNAKU_NA_RADEK              ; ke kurzoru pridame pocet znaku na radek (pujdeme dolu o jeden radek)
	jmp posun                          ; a provedeme posun
sipka_nahoru:
	mov ax,0xffff-ZNAKU_NA_RADEK+1     ; od kurzoru odecteme pocet znaku na radce (pujdeme nahoru o jeden radek)
	jmp posun                          ; a provedeme posun

enter_ulozit:
	mov ah,0x40                        ; nastavime cislo sluzby na 0x40 - zapis souboru
	xor ch,ch                          ; vynulujeme CH, ID souboru nepresahne 255
	mov cl,[cs:id_souboru]             ; do CL vlozime ID tohoto souboru
	mov bx,buffer_editoru              ; a predame adresu ukladanych dat pres registr BX
	int 0x21                           ; zavolame sluzbu filesystemu
	jmp cisteni                        ; a prekreslime editor
konec:
	int 0x05                           ; prirozeny konec editoru - NEMEL BY NASTAT - vzdy cekame na stisk klavesy :/

zaloha_ukazatele:
	push ax                            ; ulozime si AX
	push bx                            ; a i BX na zasobnik
	mov bx, [cs:kurzor_pointer]        ; do BX si ulozime pozici kurzoru
	mov al, [cs:buffer_editoru+bx]     ; a z teto pozici v bufferu nacteme AL
	mov [cs:zalozni_znak],al           ; ktere zalohujeme do pameti s navestim "zalozni_znak"
	pop bx                             ; nakonec obnovime BX
	pop ax                             ; i AX
	ret                                ; a ukoncime podprogram

nastaveni_ukazatele:
	push ax                            ; ulozime si AX
	push bx                            ; a i BX na zasobnik
	mov bx, [cs:kurzor_pointer]        ; do BX si ulozime pozici kurzoru
	mov byte [cs:buffer_editoru+bx],1  ; a na tuto pozici vlozime ASCII 1 - to znaci kurzor
	pop bx                             ; obnovime BX
	pop ax                             ; spulu s AX ze zasobniku
	ret                                ; a ukoncime podprogram

obnova_ukazatele:
	push ax                            ; ulozime si AX
	push bx                            ; a i BX na zasobnik
	mov al, [cs:zalozni_znak]          ; nacteme si do AL zalohovany znak
	mov bx, [cs:kurzor_pointer]        ; do BX nacteme adresu, kam mame zalohovany znak vlozit
	mov [cs:buffer_editoru+bx],al      ; na tuto adresu zalohovany znak vlozime
	pop bx                             ; obnovime BX
	pop ax                             ; a zaroven i AX
	ret                                ; a nakonec ukoncime podprogram

strlen:
	push bx                            ; ulozime BX
	push cx                            ; spolu s CX na zasobnik
	mov bx, buffer_editoru             ; do BX si vlozime adresu retezce, jehoz chceme delku
do:
	mov cl, [cs:bx]                    ; do CL nacteme aktualni znak
	test cl, cl                        ; provedeme test na \0
	jz koneccc                         ; a pokud je znak nulovy, ukoncime cyklus
	inc bx                             ; jinak pokracujeme zvysenim ridici promenne cyklu
	jmp do                             ; a cyklus opakujeme
koneccc:
	mov ax, bx                         ; do AX (coz bude vysledek teto funkce) vlozime adresu, kde je nulovy znak
	sub ax, buffer_editoru             ; od ni odecteme adresu retezce - ziskame delku
	pop cx                             ; nakonec obnovime CX
	pop bx                             ; spolu z BX ze zasobniku
	ret                                ; a ukoncime vykonavani tohoto podprogramu

nakresli:
	pusha                                             ; ulozime vsechny registry na zasobnik
	mov bx,ZNAKU_NA_RADEK                             ; do BX vlozime pocet znaku na radek
	mov cx,321*10                                     ; do CX vlozime vykreslovaci pozici, odkud zahajime kresleni (x=10, y=10)
	mov ax,1                                          ; nastavime sluzbu graficke knihovny 1 - vykresleni textu
	nakresli_cyklus:
		cmp bx,POCET_ODRADKOVANI*ZNAKU_NA_RADEK   ; porovname BX, jestli jsme vypsali vsechny radky
		jge nakresli_konec_cyklu                  ; pokud ano, ukoncime cyklus
		mov dl,[cs:buffer_editoru+bx]             ; jinak zalohujeme prvni znak, ktery bude na dalsi radce
		mov byte [cs:buffer_editoru+bx],0         ; a nahradime ho znakem \0
		push bx                                   ; ulozime BX ...
		push cx                                   ; ... a CX na zasobnik
		xchg bx,cx                                ; prohodime registry BX a CX
		add cx,buffer_editoru                     ; k CX, coz je index znaku konce aktualniho radku, pricteme adresu retezce
		sub cx,ZNAKU_NA_RADEK                     ; a vratime se na zacatek teto radky
		int 0x22                                  ; nyni muzeme radek vykreslit
		pop cx                                    ; pak obnovime CX
		pop bx                                    ; a take BX ze zasobniku
		mov [cs:buffer_editoru+bx],dl             ; obnovime i znak, ktery byl nahrazen znakem \0
		add cx,320*8                              ; posuneme vykreslovani o 8 radek dolu
		add bx,ZNAKU_NA_RADEK                     ; posuneme se v retezci na dalsi radek
		jmp nakresli_cyklus                       ; a opakujeme kresleni
	nakresli_konec_cyklu:
	popa                                              ; obnovime vsechny registry
	ret                                               ; a ukoncime podprogram

kurzor_pointer:
	dw 0                                              ; hodnota, kam v souboru ukazuje kurzor

buffer_editoru:
	times 513 db 0                                    ; 513 protoze posledni bude vzdycky \0

zalozni_znak:
	db 0                                              ; znak, ktery byl nahrazen znakem kurzoru

id_souboru:
	db 1                                              ; ID akutalne otevreneho souboru

;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x800-($-$$) db 0
