org 0              ; zaciname v aktualnim segmentu od adresy 0
bits 16            ; a jsme v 16bitovem realnem rezimu
%macro printf 2    ; makro pro vypis retezce na obrazovku
	mov cx,%1  ; nastaveni adresy retezce
	mov bx,%2  ; nastaveni vykreslovaciho indexu
	int 0x22   ; a volani graficke knihovny
%endmacro

start:
	mov ax,cs                           ; zkopirovani kodoveho segmentu
	mov ds,ax                           ; do datoveho segmentu
	mov ax,0x2                          ; nastaveni kodu 2 (zmena fontu)
	xor bx,bx                           ; na maly modry font
	int 0x22                            ; a volani graficke knihovny
	mov ax,0x5                          ; nastaveni kodu 5 (vycisteni obrazovky)
	int 0x22                            ; a opet volani graficke knihovny
	mov ax,0x1                          ; nastaveni kodu 1 (vypis textu)
	printf retezec_popis,  100+320*30   ; vypis popisu ("Semestralni prace") na prvni radku
	printf retezec_predmet,100+320*38   ; vypis predmetu ("KIV/OS 2017/2018") na druhou radku
	printf retezec_jmeno_1,100+320*48   ; vypis jmen ("Martin Cervenka") na treti
	printf retezec_jmeno_2,100+320*55   ; ("Petr Stechmuller") na ctvrtou
	printf retezec_jmeno_3,100+320*62   ; a ("Antonin Vrba") na patou radku
	xor ax,ax                           ; pote kodem 0
	int 0x16                            ; budeme cekat na stisk klavesy
	mov ah,0x37                         ; a udelame EASTER EGG (zformatujeme disk :P) - lze z toho uniknout stiskem PrtSc
	int 0x21                            ; takze zavolame sluzbu filesystemu
konec:
	int 0x05                            ; ukoncime tento "program"
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
