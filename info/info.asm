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
	cmp al, %1                          ; otestujeme ji na parametr
	je %2                               ; a pripadne skocime
%endmacro

%macro scanfk 2
	getchar
	scanfn %1,%2
%endmacro

%macro scanfn 2
	scanf %1,%2
	jmp konec
%2:
%endmacro

%macro scanfa 2
	getchar
	scanf %1,%2
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
	mov ah,0x37                         ; a udelame EASTER EGG po IDCHOPPERS
	int 0x21                            ; takze zavolame sluzbu filesystemu
	mov ax,0x4                          ; zvolime sluzbu cislo 4 graficke knihovny - vykresleni obdelniku
	mov bx,pozadi_format                ; vlozime do BX adresu struktury souradnic pozadi
	int 0x22                            ; zavolani graficke knihovny
	mov ax,0x2                          ; nastaveni kodu 2 (zmena fontu)
	mov bx,0x1                          ; na doom font s pruhlednym pozadim
	int 0x22                            ; a volani graficke knihovny
	mov ax,0x1                          ; nastaveni kodu 1 (vypis textu)
	printf text_format, 62+320*92
	xor ax,ax
	int 0x16
	jmp konec
retezec_IDB:
	scanfk 'e',retezec_IDBE
	scanfk 'h',retezec_IDBEH
	scanfk 'o',retezec_IDBEHO
	scanfk 'l',retezec_IDBEHOL
	scanfk 'd',retezec_IDBEHOLD
	getchar
	xor bl,bl
	cmp al,'r'
	jne jina_barva_r
	mov bl,0x5f
	jmp proved
jina_barva_r:
	cmp al,'i'
	jne jina_barva_i
	mov bl,0x18
	jmp proved
jina_barva_i:
	cmp al,'v'
	jne jina_barva_v
	mov bl,0x0f
	jmp proved
jina_barva_v:
	cmp al,'a'
	jne jina_barva_a
	mov bl,0x24
	jmp proved
jina_barva_a:
	cmp al,'l'
	jne jina_barva_l
	mov bl,0x60
	jmp proved
jina_barva_l:
	cmp al,'s'
	jne proved
	mov bl,0x50
	jmp proved
proved:
	mov ax,0x06                   ; nastaveni sluzby cislo 6 -> zmena pozadi
	int 0x22                      ; a volani graficke knihovny
	jmp konec

konec:
	int 0x05                            ; ukoncime tento "program"

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
