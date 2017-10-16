org 0x7c00
bits 16
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

	mov si, 0x03              ; tri pokusy pro nacteni sektoru
nacteni_sektoru:
	mov dx,0x0080             ; vyber pevneho disku (0x80), hlavy 0 (0x00)
	xor ax,ax                 ; zadost o restartovani disku (sluzba 0x00)
	int 0x13                  ; volani sluzeb BIOSu
	mov ax,0x0223             ; vyber sluzby cteni z disku (0x02), 35 (0x23) sektoru
	mov bx,dalsi_sektory      ; pokracovani na navesti "dalsi_sektory"
	mov cx,0x0002             ; cylindr 0, sektor 2
	int 0x13                  ; volani sluzeb BIOSu
	mov al, ah                ; predani chyboveho kodu do vypisu
	call pis16_registr        ; volani vypisu registru
	jnc dalsi_sektory         ; opakovani cteni pri neuspechu - TODO nekonecna smycka
	dec si                    ; snizeni poctu pokusu o 1
	cmp si, 0                 ; test na vycerpani pokusu
	jne nacteni_sektoru       ; opakovani nacitani pri dostatecnem poctu pokusu
restart:
	mov eax,zprava_restart    ; vyber zpravy pro vypis (zprava o restartu)
	call pis16                ; vypis zpravy
	xor ax,ax                 ; vyber sluzby BIOSu - cekani na stisk klavesy
	int 0x16                  ; zavolani sluzeb BIOSu
	db 0xea, 0, 0, 0xff, 0xff ; restart
zprava_restart:
	db "Pro restartovani stisknete klavesu...", 0

times 510-($-$$) db 0             ; doplneni pameti do 510ti bajtu
dw 0xaa55                         ; vlozeni bajtu 0xAA a 0x55 -> jedna se o bootovatelny sektor

test_zapis:
	mov ax,0x0313
	mov bx,test_zapis
	mov cx,0x0003
	mov dx,0x0081
	int 0x13
	call pis16_registr
	jmp $
dalsi_sektory:
	call obrazek_zobrazit     ; zobrazeni uvodniho obrazku
cyklus:
	xor ah,ah
	int 0x16
	mov ah,0xe
	call tabulka_znaku
	int 0x10                  ; volani video sluby BIOSu
	call pis16_registr
	jmp cyklus

%include "splash.asm"             ; vlozeni nacitaci obrazovky
%include "gdt.asm"                ; vlozeni definice global descriptor table
%include "print.asm"              ; vlozeni funkci pro vypis v realnem a chranenem modu
%include "characters.asm"

druha_radka:
	db "Dalsi radka!", 0
zprava_boot:
	db "Nacteno!", 0
fat_prostor:
	times 2000 db 0
editor_prostor:
	times 1000 db 0
prohlizec_prostor:
	times 1000 db 0
