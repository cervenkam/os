org 0
bits 16
jmp 0x07c0:start
%include "consts.asm"
start:
	mov ax, cs
	mov ds, ax
	mov es, ax
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
	; naveseni interruptu
	push es
	xor ax, ax
	mov es, ax 		  ; segmentovy registr = 0
	cli 			  ; vycistit interrupty
	;0x22 video sluzby, adresa obsluhy je potom 0x9000:0x0000 (zacatek segmentu)
	mov word [es:0x0088],0x0000
	mov word [es:0x008a],segment_obrazky
	;0x21 sluzby souboroveho systemu
	mov word [es:0x0084],0x0000
	mov word [es:0x0086],segment_filesystem
	;0x08 test casovace
	mov word [es:0x0030],0x0000
	mov word [es:0x0032],segment_prohlizec	
	sti ;nastavit interrupty
	pop es
	; konec naveseni interruptu
	; cteni jednotlivych sektoru
	mov ax,jadro              ; informace o sektorech jadra
	mov bx,segment_jadra      ; informace o segmentu jadra
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart
	mov ax,filesystem         ; informace o sektorech filesystemu
	mov bx,segment_filesystem ; informace o segmentu filesystemu
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart
	mov ax,editor             ; informace o sektorech editoru
	mov bx,segment_editor     ; informace o segmentu editoru
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart
	mov ax,prohlizec          ; informace o sektorech prohlizece
	mov bx,segment_prohlizec  ; informace o segmentu prohlizece
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart
	mov ax,obrazky            ; informace o sektorech obrazky
	mov bx,segment_obrazky    ; informace o segmentu obrazku
	call nacti_segmenty       ; nacteni sektoru do pameti
	jc restart
	; konec cteni sektoru
	jmp skok_jadro            ; skok do nacteneho jadra
restart:
	mov ax,zprava_restart
	call pis16
	xor ax,ax                 ; vyber sluzby BIOSu - cekani na stisk klavesy
	int 0x16                  ; zavolani sluzeb BIOSu
	db 0xea, 0, 0, 0xff, 0xff ; restart

skok_jadro:
	jmp segment_jadra:0x0000

nacti_segmenty:
	mov cl,ah
	mov ah,0x02
	mov es,bx
	xor bx,bx
	int 0x13
	ret

; funkce pis16, pise zpravu v realnem 16bitovem rezimu
; => DS:AX - adresa zpravy
pis16:
	pusha         ; ulozeni vsech registru do zasobniku
	push ds
	mov si, ax    ; nastaveni registru SI na hodnotu znaku ulozenou v AX
	mov ah, 0x0e  ; nastaveni AH na sluzbu BIOSu cislo 14 (pri int 0x10 je 0x0e psani znaku v TTY rezimu)
pis16_smycka:
	lodsb             ; nacteni znaku z adresy DS:SI do registru AL
	cmp al, 0         ; porovnani na konec retezce
	je pis16_konec    ; ukonceni v pripade konce retezce
	int 0x10          ; volani video sluby BIOSu
	jmp pis16_smycka  ; opetovne volani, dokud neni konec retezce
pis16_konec:
	pop ds
	popa  ; obnova vsech registru
	ret   ; ukonceni podprogramu vypisu v 16tibitovem rezimu

zprava_boot:
	db "Nacteno!" ,0
zprava_restart:
	db "Restartovani...", 0
times 510-($-$$) db 0             ; doplneni pameti do 510ti bajtu
dw 0xaa55                         ; vlozeni bajtu 0xAA a 0x55 -> jedna se o bootovatelny sektor

