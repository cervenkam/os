org 0
bits 16
jmp 0x07c0:start
%include "consts.asm"
start:
	mov ax, cs                ; zkopirovani kodoveho segmentu ...
	mov ds, ax                ; do datoveho segmentu ...
	mov es, ax                ; a i do extra segmentu
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

	mov si, 0x03              ; tri pokusy pro nacteni sektoru
nacteni_sektoru:
	cmp si, 0                 ; test na vycerpani pokusu
	je restart                ; opakovani nacitani pri dostatecnem poctu pokusu
	dec si                    ; snizeni poctu pokusu o 1
	mov dx,0x0080             ; vyber pevneho disku (0x80), hlavy 0 (0x00)
	xor ax,ax                 ; zadost o restartovani disku (sluzba 0x00)
	int 0x13                  ; volani sluzeb BIOSu
	mov ah,0x02               ; vyber sluzby cteni z disku (0x02)
	mov ch,0x00               ; cylindr 0
	; cteni jednotlivych sektoru
	mov ax,jadro              ; informace o sektorech jadra
	mov bx,segment_jadro      ; informace o segmentu jadra
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart                ; a pokud se to nezdari, restartuj system
	; cteni jednotlivych sektoru
	mov ax,info               ; informace o sektorech informacni obrazovky
	mov bx,segment_info       ; informace o segmentu informacni obrazovky
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart                ; a pokud se to nezdari, restartuj system
	mov ax,filesystem         ; informace o sektorech filesystemu
	mov bx,segment_filesystem ; informace o segmentu filesystemu
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart                ; a pokud se to nezdari, restartuj system
	mov ax,editor             ; informace o sektorech editoru
	mov bx,segment_editor     ; informace o segmentu editoru
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart                ; a pokud se to nezdari, restartuj system
	mov ax,prohlizec          ; informace o sektorech prohlizece
	mov bx,segment_prohlizec  ; informace o segmentu prohlizece
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart                ; a pokud se to nezdari, restartuj system
	mov ax,hra                ; informace o sektorech hry
	mov bx,segment_hra        ; informace o segmentu hry
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart                ; a pokud se to nezdari, restartuj system
	mov ax,obrazky            ; informace o sektorech obrazky
	mov bx,segment_obrazky    ; informace o segmentu obrazku
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart                ; a pokud se to nezdari, restartuj menu
	mov ax,menu               ; informace o sektorech menu
	mov bx,segment_menu       ; informace o segmentu menu
	call nacti_segmenty       ; nacteni sektoru do pameti
	mov ax,zprava_restart     ; nastaveni vypisovaneho retezce na zpravu o restartu
	call pis16                ; zavolani vypisu retezce restartu
	jc restart                ; a pokud se to nezdari, restartuj system
	; konec cteni sektoru
	jmp skok_jadro            ; skok do nacteneho jadra
restart:
	mov ax,zprava_restart     ; nastaveni vypisovaneho retezce na zpravu o restartu
	call pis16                ; zavolani vypisu retezce restartu
	xor ax,ax                 ; vyber sluzby BIOSu - cekani na stisk klavesy
	int 0x16                  ; zavolani sluzeb BIOSu
	db 0xea, 0, 0, 0xff, 0xff ; restart

skok_jadro:
	jmp segment_jadro:0x0000  ; skok do jadra (pevna adresa, jadro teprve nastavi interrupt na skoky mezi programy)

nacti_segmenty:
	mov cl,ah    ; presun cisla segmentu do CL
	mov ah,0x02  ; nastaveni AH na kod 2 (cteni z disku)
	mov es,bx    ; nastaveni segmentu, kam se bude zapisovat, na BX
	xor bx,bx    ; a offset bude nula
	int 0x13     ; provede se cteni z disku
	ret          ; a ukonci se podprogram

; funkce pis16, pise zpravu v realnem 16bitovem rezimu
; => DS:AX - adresa zpravy
pis16:
	pusha             ; ulozeni vsech registru do zasobniku
	push ds           ; ulozeni i data segmenut do zasobniku
	mov si, ax        ; nastaveni registru SI na hodnotu znaku ulozenou v AX
	mov ah, 0x0e      ; nastaveni AH na sluzbu BIOSu cislo 14 (pri int 0x10 je 0x0e psani znaku v TTY rezimu)
pis16_smycka:
	lodsb             ; nacteni znaku z adresy DS:SI do registru AL
	cmp al, 0         ; porovnani na konec retezce
	je pis16_konec    ; ukonceni v pripade konce retezce
	int 0x10          ; volani video sluby BIOSu
	jmp pis16_smycka  ; opetovne volani, dokud neni konec retezce
pis16_konec:
	pop ds            ; obnova data segmentu ze zasobniku
	popa              ; obnova vsech registru
	ret               ; ukonceni podprogramu vypisu v 16tibitovem rezimu

zprava_boot:
	db "Nacteno!" ,0
zprava_restart:
	db "Restartovani...", 0
times 510-($-$$) db 0             ; doplneni pameti do 510ti bajtu
dw 0xaa55                         ; vlozeni bajtu 0xAA a 0x55 -> jedna se o bootovatelny sektor

