org   0   ; program zacina v aktualnim segmentu od nuly
bits  16  ; 16ti bitovy realny rezim
%include "consts.asm"             ; ziskame spolecne konstanty
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu

	mov ax,0x5                ; kod pro smazani obrazovky
	int 0x22                  ; zavolani smazani obrazovky
	mov ax,0x2                ; kod pro nastaveni fontu
	mov bx,0x1                ; nastaveni fontu 1 (DOOM font)
	int 0x22                  ; volani nastaveni fontu
	call nacti_hru            ; nacteni hry
nakresli_vse:
	xor ah,ah                                     ; vynulovani ridici promene AH vnejsi smycky
	vnejsi_smycka:
		cmp ah,4                              ; test na 4 pruchody (4 radky)
		je konec_vnejsi_smycky                ; pokud jsou jiz 4 radky nakresleny, ukonceni kresleni
		xor al,al                             ; vynulovani ridici promenne AL vnitrni smycky
		vnitrni_smycka:
			cmp al,4                      ; test na 4 pruchody (4 sloupce)
			je konec_vnitrni_smycky       ; pokud jsou jiz 4 sloupce nakresleny, ukonecni vnitrni smycky a kresleni dalsiho radku
			call nakresli_jedno_pole      ; nakresleneni aktualniho pole
			inc al                        ; posun o jeden sloupec vpravo
			jmp vnitrni_smycka            ; opakovani vnitrni smycky
		konec_vnitrni_smycky:
		inc ah                                ; posun o jednu radku dolu
		jmp vnejsi_smycka                     ; opakovani vnejsi smycky
	konec_vnejsi_smycky:
stisk_klavesy:
	xor ax,ax            ; nastaveni parametru sluzby BIOSu na cteni stisknute klavesy
	int 0x16	     ; volani teto sluzby
	push ax              ; ulozeni stisknute klavesy
	mov ax,0x02          ; kod pro nastaveni fontu
	mov bx,0x1           ; nastaveni fontu 1 (DOOM font)
	int 0x22             ; volani nastaveni fontu
	pop ax               ; obnoveni stisknute klavesy
	call najdi_pozici    ; nalezeni prazdne pozice (ta se ulozi do BX)
	cmp ah,0x48          ; porovnani scankodu na sipku nahoru
	je sipka_nahoru      ; obsluha klavesy "sipka nahoru"
	cmp ah,0x4B          ; porovnani scankodu na sipku vlevo
	je sipka_vlevo       ; obsluha klavesy "sipka vlevo"
	cmp ah,0x4D          ; porovnani scankodu na sipku vpravo
	je sipka_vpravo      ; obsluha klavesy "sipka vpravo"
	cmp ah,0x50          ; porovnani scankodu na sipku dolu
	je sipka_dolu        ; obsluha klavesy "sipka dolu"
	cmp ah,0x01          ; dale testujeme escape na ukonceni hry
	je konec             ; a pripadne ukoncime hru
	jmp stisk_klavesy    ; pokud neni klavesa rozpoznana, bude se cist znova
sipka_nahoru:
	cmp bx,4             ; porovnani prazdne pozice se 4kou
	jl stisk_klavesy     ; pokud je pozice <4, pak jsme v prvni radce a nelze se tedy posunout vzhuru, tzn. cteme dalsi klavesu
	mov ax,bx            ; zahajeni hledani noveho pole, to bude stejne jako BX...
	sub ax,4             ; akorat o 4 mensi
	call prehod_pole     ; prehozeni poli ulozenych v AX a BX
	jmp stisk_klavesy    ; a cteni dalsiho znaku
sipka_dolu:
	cmp bx,12            ; porovnani prazdne pozice s 12kou
	jge stisk_klavesy    ; pokud je pozice >=12, pak jsme v posledni (4.) radce a nelze se posunout dolu, tzn. cteme dalsi klavesu
	mov ax,bx            ; zahajeni hledani noveho pole, to bude stejne jako predtim...
	add ax,4             ; jen o 4 vetsi
	call prehod_pole     ; prohozeni techto poli (AX a BX)
	cmp ax,0xf           ; pokud se posouvame dolu nebo vpravo, muze nastat konec hry, proto otestujeme, jestli nova pozice neni vpravo dole...
	je zkus_konec_hry    ; a pokud je, zjistime, jestli je konec hry, nebo zda-li se jedna jen o plany poplach
	jmp stisk_klavesy    ; a nakonec cteme dalsi znak
sipka_vlevo:
	test bx,0x3          ; porovnani, jestli v poslednich 2 bitech BX neni nejaka 1ka
	jz stisk_klavesy     ; pokud tam neni, znamena to, ze jsme v prvnim sloupci (pozice 0,4,8 a 12), tzn. nelze jit vlevo a cteme dalsi klavesu
	mov ax,bx            ; zahajeni hledani nove pozice, ta bude jako predtim...
	dec ax               ; jen o jedna mensi
	call prehod_pole     ; prohozeni nove a predchozi pozice (v AX a BX)
	jmp stisk_klavesy    ; a znovu cteni dalsiho znaku
sipka_vpravo:
	inc bx               ; virtualne se posuneme o jeden sloupcec vpravo (i s pretecenim)
	test bx,0x3          ; pokud jsme (po posunu) v prvnim sloupci (tedy pred posunem ve tretim)...
	jz stisk_klavesy     ; nelze se posouvat vpravo, takze budeme misto toho cist dalsi znak
	dec bx               ; vratime virtualni posun do puvodniho stavu
	mov ax,bx            ; a hledame novou pozici prazdneho pole, ta bude jako ta puvodni
	inc ax               ; jenom o 1 vetsi
	call prehod_pole     ; a tak muzeme prohodit tato 2 pole (v AX a BX)
	cmp ax,0xf           ; nakonec je potreba zjistit, jestli nedoslo ke konci hry, nutnou podminkou je, aby pozice prazdneho pole byla 15...
	je zkus_konec_hry    ; pokud tomu tak je, pokusime se hru ukoncit (vyhrou)
	jmp stisk_klavesy    ; jinak jsme nuceni cist dalsi klavesu
zkus_konec_hry:
	pusha                                 ; ulozime si stav vsech registru
	xor bx,bx                             ; nastavime ridici promennou cyklu BX na nulu
	smycka_konec_hry:
		cmp bx,15                     ; a cyklime do 15ti (vsechna neprazdna pole, prazdne pole je jiz na pozici 15)
		je konec_konec_hry            ; pokud jsme na konci, dojde ke konci hry, protoze jsme splnili vsechny podminky pro vyhru
		mov al,[cs:aktualni_hra+bx]   ; jinak nacteme hodnotu na predchazejici pozici
		inc bx                        ; pricteme ridici promennou
		cmp al,[cs:aktualni_hra+bx]   ; a porovname predchazejici hodnotu s hodnotou aktualni
		jge neni_konec_hry            ; pokud je aktualni hodnota mensi nez aktualni, pole neni serazeno, tzn. nevyhrali jsme
		jmp smycka_konec_hry          ; pokud je tomu opacne a tyto dve hodnoty jsou ve spravnem poradi, projdeme zbytek hraciho pole
	konec_konec_hry:
	popa                                  ; vyhrali jsme ;), takze si obnovime registry
	jmp konec                             ; a ukoncime hru
neni_konec_hry:
	popa                                  ; nevyhrali jsme ;/, musime si obnovit registry
	jmp stisk_klavesy                     ; a budeme cist dalsi klavesu, snad se zadari jindy
konec:
	int 0x05  ; ukonceni hry (navraceni do hlavniho menu operacniho systemu)
prehod_pole:
	pusha                         ; nejprve si ulozime stav vsech registru
	mov cl,[cs:aktualni_hra+bx]   ; pak si ulozime hodnotu na predchazejicim poli (BX = predchazejici pole) do CL
	push bx                       ; ulozime BX, z toho si udelame pracovni registr
	mov bx,ax                     ; a do tohoto pracovniho registru si ulozime AX (BX je nyni aktualni pole)
	mov ch,[cs:aktualni_hra+bx]   ; ulozime si hodnotu na aktualnim poli do CH
	mov [cs:aktualni_hra+bx],cl   ; a tuto hodnotu nahradime CL (hodnotou z predchazejiciho pole)
	pop bx                        ; obnovime BX na index predchazejiciho pole
	mov [cs:aktualni_hra+bx],ch   ; a do predchazejiciho pole vlozime hodnotu CH (hodnotu noveho pole), cimz dokoncime vymenu hodnot
	mov ah,al                     ; nyni je treba preklesit zucastnena pole, zduplikujeme AL do AH (index aktualniho pole)
	shr ah,2	              ; jeden index vydelime ctyrma, cimz ziskame index radku
	and al,3                      ; druhou vymaskujeme s trojkou, cimz ziskame index sloupce
	call nakresli_jedno_pole      ; a muzeme toto pole (AH = radek, AL = sloupec) nakreslit
	mov ax,bx                     ; vyse uvedene 4 radky provedeme taktez s indexem predchoziho pole
	mov ah,al                     ; takze si znovu zduplikujeme AL do AX (ted uz index predchazejiciho pole)
	shr ah,2                      ; jeden index vydelime ctyrma, cimz ziskame index radku
	and al,3                      ; druhou vymaskujeme s trojkou, cimz ziskame index sloupce
	call nakresli_jedno_pole      ; a muzeme toto pole (AH = radek, AL = sloupec) nakreslit
	popa                          ; nezbyva nez obnovit stav registru
	ret                           ; a ukoncit podprogram
nacti_hru:
	pusha                                    ; ulozime si stav registru
	xor bx,bx                                ; vynulujeme ridici promennou cyklu
	mov cx,[cs:cislo_hry]                    ; nacteme index hry do CX
	shl cx,4                                 ; tento index vynasobime 16 (*2^4), aby jsme se mohli posouvat v 16bajtovych hrach
	add cx,hry                               ; a pricteme adresu pole her
	smycka_najdi:
		cmp bx,16                        ; porovnani, jesli uz jsme nenacetli celou hru
		je konec_smycka_najdi            ; pokud je jiz cela hra nactena, ukoncime smycku
		add bx,cx                        ; jinak si pricteme do BX (indexu pole ve hre) adresu hry (CX)
		mov al,[cs:bx]                   ; nacteme hodnotu z tabulky her
		sub bx,cx                        ; obnovime ridici promennou cyklu
		mov [cs:aktualni_hra+bx],al      ; a prekopirujeme hodnotu z tabulky her do aktualni hry
		inc bx                           ; zvysime ridici promennou cyklu
		jmp smycka_najdi                 ; a budeme kopirovat dalsi pole
	konec_smycka_najdi:
	popa                                     ; nakonec obnovime stav registru
	ret                                      ; a ukoncime podprogram
najdi_pozici:
	xor bx,bx                                  ; vynulujeme ridici promennou cyklu (BX)
	smycka_pozice:
		cmp bx,16                          ; cyklus provedeme 16x
		je konec_smycka_pozice             ; pokud jsme u 16. iterace, ukoncime vykonavani
		cmp byte [cs:aktualni_hra+bx],15   ; porovname aktualni hodnotu na hodnotu prazdneho pole (ta je 15)
		je konec_smycka_pozice             ; pokud jsme nalezli prazdne pole, ukoncime smycku
		inc bx                             ; jinak si zvysime ridici promennou
		jmp smycka_pozice                  ; a pokracujeme v hledani 15ky
	konec_smycka_pozice:
	ret                                        ; nakonec ukoncime vykonavani podprogramu
nakresli_jedno_pole:
	pusha                          ; nejprve si ulozime stav vsech registru
	call nastav_pozice             ; pak nastavime pozice obdelniku/ctverce pod polem
	push ax                        ; ulozime si AX (AL = index sloupce, AH = index radku), ktere pouzijeme jako pracovni registr
	mov bx,ax                      ; do BX si ulozime hodnotu AX
	shr bx,6                       ; vydelime BX 2^6 (takze 64) - to je proto, aby jsme meli v BL index radky posunute o 2 bity vlevo (8-6)
	or al,bl		       ; logicky pricteme tyto 2 bity indexu radky k indexu sloupce (zde je logicke i klasicke scitani shodne)
	xor ah,ah                      ; a vynulujeme AH, tim ziskame v AX index bunky od 0 do 15
	mov bx,ax                      ; nakopirujeme si tuto novou hodnotu do BX
	mov al,[cs:aktualni_hra+bx]    ; a precteme si hodnotu znaku na teto pozici
	cmp al,15                      ; provedeme porovnani aktualniho pole s prazdnym polem
	jne nemenit_barvu              ; pokud aktualni pole neni prazdne pole, pak nebudeme menit barvu pozadi
	mov byte [cs:pozice+8],6       ; jinak prazdne pole bude mit jinou barvu pozadi
nemenit_barvu:
	push ax                        ; znovu si ulozime AX (nyni index 0-15)
	mov ax,0x4                     ; nastavime si sluzbu cislo 4 (vyplnit obdelnik)
	mov bx,pozice                  ; na pozici stanovenou strukturou "pozice"
	int 0x22                       ; a zavolame grafickou "knihovnu"
	pop ax                         ; nyni si muzeme opet obnovit AX (na index 0-15 aktualniho pole)
	cmp al,15                      ; provedeme porovnani na prazdne pole
	je preskocit                   ; a pokud se jedna o prazdne pole, nebudeme vubec kreslit text
	add al,0x41	               ; jinak si pricteme k hodnote bunky 0x41 (ASCII 'A') - nase Lloydova 15ka bude z pismen, nikoliv z cisel
	mov [cs:znak], al              ; presuneme znak do vyrovnavaci pameti pro vypis znaku
	pop ax                         ; a obnovime AX (zpet na AL = index sloupce, AH = index radku)
	mov bx,0x11d2                  ; do BX si ulozime odkud zacneme kreslit (index leveho horniho rohu prvni bunky)
	mov cl,0x30                    ; do CL vlozime hodnotu 0x30 (vzdalenost mezi sloupci)
	push ax                        ; ulozime AX, protoze nam ho nasledujici MUL prepise
	mul cl                         ; vynasobime index sloupce (AL) triceti, cimz ziskame index prave hrany aktualni bunky
	xor ah,ah                      ; vycisitme AH
	add bx,ax                      ; a pridame index prave hrany do celkoveho indexu vykreslovani
	pop ax                         ; AX jako vykreslovaci index neni treba, proto si ho obnovime na AL = index sloupce a AH = index radku
	mov al,ah                      ; presuneme si index radku do AL
	xor ah,ah                      ; a AH vycistime, tzn. v AX je index radku
	mov cx,320*32                  ; index radku budeme prenasobovat 32 radkami
	mul cx                         ; takze ho prenasobime
	add bx,ax                      ; a tento vysledek (index horni hrany aktualni bunky) pricteme do celkoveho indexu vykreslovani, ktery je v BX
	mov ax,0x1                     ; do AX nastavime cislo sluzby 1 (vykresleni textu)
	mov cx,znak                    ; nastavime adresu textu (ulozeny znak)
	int 0x22                       ; a provedeme volani graficke knihovny
	popa                           ; pak nezbyva nez obnovit stav registru
	ret                            ; a ukoncit volani podprogramu
preskocit:
	pop ax                         ; nebylo treba kreslit text, takze vybereme hodnotu ze zasobniku (nezalezi co je v ni, jen obnovujeme stav zasobniku)
	popa                           ; obnovime stav vsech stavovych registru
	ret                            ; a ukoncime podprogram
nastav_pozice:
	pusha                       ; nejprve si ulozime stav registru
	mov cx,ax                   ; ulozime si indexy bunky do registru CX
	xor ch,ch                   ; a vynulujeme CH, tim ziskame v CX pouze index sloupce
	mov bx,ax                   ; zde si ulozime indexy bunky i do registru BX
	mov bl,bh                   ; ale zde budeme ukladat index radky, takze si ho prekopirujeme do BL
	xor bh,bh                   ; a BH vynulujeme, aby v BX byl pouze index radky
	mov ax,0x30                 ; ulozime si do AX hodnotu 0x30
	mul cl                      ; a prenasobime s ni CL (vysledek v AL)
	mov cx,ax                   ; presuneme vyledek do CX (zacatek vypoctu sloupcoveho vykreslovaciho indexu)
	shl bx,5                    ; vynasobime BX 2^5 (takze 32) - vypocet radkoveho vykreslovaciho indexu
	add bx,8                    ; nyni posuneme radkovy index o 8 (zarovnani, aby text nelezel mimo pozadi)
	add cx,76                   ; a posuneme i sloupcovy index o 76 (opet zarovnani)
	mov [cs:pozice],bx          ; ulozime si souradnici Y1
	mov [cs:pozice+4],cx        ; a take souradnici X1
	add bx,26                   ; pricteme k souradnici radku 26 (sirka pozadi bude tedy 26)
	add cx,26                   ; a tu samou hodnotu pricteme i k souradnici sloupce (ziskame ctverec)
	mov [cs:pozice+2],bx        ; ulozime si takto vypocitanou souradnici Y2
	mov [cs:pozice+6],cx        ; a i X2
	mov byte [cs:pozice+8],3    ; nakonec nastavime barvu pozadi
	popa                        ; obnovime stav registru
	ret                         ; a ukoncime podprogram
pozice:
	dw 0   ; souradnice Y1 pozadi pod bunkou
	dw 30  ; souradnice Y2 pozadi pod bunkou
	dw 0   ; souradnice X1 pozadi pod bunkou
	dw 30  ; souradnice X2 pozadi pod bunkou
	db 3   ; barva pozadi pod bunkou
znak:
	db 'X',0  ; vykreslovany znak
cislo_hry:
	dw 0 ; index aktualni hry
hry:
	db 0,1,2,3      ; prvni radka prvni hry (read-only hodnoty)
	db 4,5,6,7      ; druha radka prvni hry (read-only hodnoty)
	db 8,9,10,11    ; treti radka prvni hry (read-only hodnoty)
	db 12,13,15,14	; ctvrta radka prvni hry (read-only hodnoty)
aktualni_hra:
	times 16 db 0   ; pole aktualni hry, kde se meni hodnoty behem hry
times 0x400-($-$$) db 0 ; zarovnani na 2 bloky
