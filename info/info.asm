org 0              ; zaciname v aktualnim segmentu od adresy 0
bits 16            ; a jsme v 16bitovem realnem rezimu
%macro printf 2    ; makro pro vypis retezce na obrazovku
	mov cx,%1  ; nastaveni adresy retezce
	mov bx,%2  ; nastaveni vykreslovaciho indexu
	int 0x22   ; a volani graficke knihovny
%endmacro

%macro getchar 0
	xor ax,ax                           ; kodem 0
	int 0x16                            ; budeme cekat na stisknutou klavesu
%endmacro

%macro scanf 2
	cmp al, %1                          ; otestujeme registr AL na parametr
	je %2                               ; a pripadne skocime na zvolene navesti
%endmacro

%macro scanfk 2
	getchar                             ; precteme stisk jedne klavesy
	scanfn %1,%2                        ; a porovname, pripadne ukoncime program
%endmacro

%macro scanfn 2
	scanf %1,%2                         ; porovname stisk klaves
	jmp konec                           ; a pripadne ukoncime program
%2:                                         ; jinak skocime na toto navesti
%endmacro

%macro scanfa 2
	getchar                             ; precteme znak
	scanf %1,%2                         ; a otestujeme ho, nebudeme ale ukoncovat program
%endmacro

start:
	mov ax,cs                           ; zkopirovani kodoveho segmentu
	mov ds,ax                           ; do datoveho segmentu
	mov ax,0x2                          ; nastaveni kodu 2 (zmena fontu)
	mov bx,0x5                          ; na maly modry font s pruhlednym pozadim
	int 0x22                            ; a volani graficke knihovny
	mov ax,0x5                          ; nastaveni kodu 5 (vycisteni obrazovky)
	int 0x22                            ; a opet volani graficke knihovny
	mov ax,0x1                          ; nastaveni kodu 1 (vypis textu)
	printf retezec_popis,  100+320*30   ; vypis popisu ("Semestralni prace") na prvni radku
	printf retezec_predmet,100+320*38   ; vypis predmetu ("KIV/OS 2017/2018") na druhou radku
	printf retezec_jmeno_1,100+320*48   ; vypis jmen ("Martin Cervenka") na treti
	printf retezec_jmeno_2,100+320*55   ; ("Petr Stechmuller") na ctvrtou
	printf retezec_jmeno_3,100+320*62   ; a ("Antonin Vrba") na patou radku
	; ZDE ZACINAJI EASTEREGGY ... ;)
	scanfk 'i',retezec_I                ; otestujeme klavesu na I
	scanfk 'd',retezec_ID               ; otestujeme klavesu na D
	scanfa 'b',retezec_IDB              ; otestujeme klavesu na B
	scanfn 'c',retezec_IDC              ; otestujeme klavesu na C
	scanfk 'h',retezec_IDCH             ; otestujeme klavesu na H
	scanfk 'o',retezec_IDCHO            ; otestujeme klavesu na O
	scanfk 'p',retezec_IDCHOP           ; otestujeme klavesu na P
	scanfk 'p',retezec_IDCHOPP          ; otestujeme klavesu na P
	scanfk 'e',retezec_IDCHOPPE         ; otestujeme klavesu na E
	scanfk 'r',retezec_IDCHOPPER        ; otestujeme klavesu na R
	scanfk 's',retezec_IDCHOPPERS       ; otestujeme klavesu na S
	mov ah,0x37                         ; a udelame EASTER EGG po IDCHOPPERS - zformatujeme si disk :P
	int 0x21                            ; takze zavolame sluzbu filesystemu
	mov ax,0x4                          ; zvolime sluzbu cislo 4 graficke knihovny - vykresleni obdelniku
	mov bx,pozadi_format                ; vlozime do BX adresu struktury souradnic pozadi
	int 0x22                            ; zavolani graficke knihovny
	mov ax,0x2                          ; nastaveni kodu 2 (zmena fontu)
	mov bx,0x1                          ; na doom font s pruhlednym pozadim
	int 0x22                            ; a volani graficke knihovny
	mov ax,0x1                          ; nastaveni kodu 1 (vypis textu)
	printf text_format, 62+320*92       ; vypiseme text o uspesnem zformatovani disku
	getchar                             ; pockame na stisk klavesy
	jmp konec                           ; a ukoncime program
retezec_IDB:
	scanfk 'e',retezec_IDBE             ; dalsi vetev, testujeme cheat "IDBEHOLDx", nyni testujeme znak 'E'
	scanfk 'h',retezec_IDBEH            ; otestujeme znak 'H'
	scanfk 'o',retezec_IDBEHO           ; otestujeme znak 'O'
	scanfk 'l',retezec_IDBEHOL          ; otestujeme znak 'L'
	scanfk 'd',retezec_IDBEHOLD         ; otestujeme znak 'D'
	getchar                             ; a precteme nasledujici znak
	xor bl,bl                           ; defaultni barva pozadi bude cerna

	cmp al,'r'                          ; porovname na znak 'R' - oblek proti radiaci
	jne jina_barva_r                    ; pokud se neshoduje, nevybereme toto pozadi
	mov bl,0x5f                         ; jinak vybereme pozadi s barvou 0x5f - svetle zelena barva
	jmp proved                          ; a provedeme zmenu pozadi
jina_barva_r:
	cmp al,'i'                          ; porovname na znak 'I' - castecna neviditelnost
	jne jina_barva_i                    ; pokud se znak neshoduje, budeme testovat jiny
	mov bl,0x18                         ; jinak nastavime barvu pozadi 0x18 - seda barva
	jmp proved                          ; a provedeme zmenu pozadi
jina_barva_i:
	cmp al,'v'                          ; porovname na znak 'V' - docasna nesmrtelnost
	jne jina_barva_v                    ; pokud se znak neshoduje, budeme testovat jiny
	mov bl,0x2c                         ; jinak nastavime barvu pozadi 0x2c - zluta barva
	jmp proved                          ; a provedeme zmenu pozadi
jina_barva_v:
	cmp al,'a'                          ; porovname na znak 'A' - ziskani mapy
	jne jina_barva_a                    ; pokud se znak neshoduje, budeme testovat jiny
	mov bl,0x24                         ; jinak nastavime barvu pozadi na 0x24 - ruzova (protoze ruzova je hezka :D)
	jmp proved                          ; a provedeme zmenu pozadi
jina_barva_a:
	cmp al,'l'                          ; porovname na znak 'L' - nocni videni
	jne jina_barva_l                    ; pokud se znak neshoduje, budeme testovat jiny
	mov bl,0x0f                         ; jinak nastavime barvu pozadi na 0x0f - bila barva
	jmp proved                          ; a provedem zmenu pozadi
jina_barva_l:
	cmp al,'s'                          ; porovname na znak 'S' - berserk
	jne proved                          ; pokud se znak neshoduje, budeme testovat jiny
	mov bl,0x70                         ; jinak nastavime barvu pozadi na 0x70 - tmave cervena barva
	jmp proved                          ; a provedeme zmenu pozadi
proved:
	mov ax,0x06                   ; nastaveni sluzby cislo 6 -> zmena pozadi
	int 0x22                      ; a provedem volani graficke knihovny
	jmp konec                     ; nakonec ukoncime program

konec:
	int 0x05                      ; ukoncime tento "program"

pozadi_format:
	dw 80   ; souradnice Y1 vykreslovaneho dialogu
	dw 120  ; souradnice Y2 vykreslovaneho dialogu
	dw 50   ; souradnice X1 vykreslovaneho dialogu
	dw 270  ; souradnice X2 vykreslovaneho dialogu
	db 2    ; barva dialogu

text_format:
	db "Zformatovano",0  ; text dialogu
retezec_jmeno_1:
	db "Martin Cervenka",0              ; jmeno prvniho autora
retezec_jmeno_2:
	db "Petr Stechmuller",0             ; jmeno druheho autora
retezec_jmeno_3:
	db "Antonin Vrba",0                 ; jmeno tretiho autora
retezec_popis:
	db "Semestralni prace",0            ; ucel prace
retezec_predmet:
	db "KIV/OS 2017/2018",0             ; predmet a rok vypracovani
times 0x200-($-$$) db 0                     ; zarovnani na jeden blok
