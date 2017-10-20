org 0
bits 16
jmp 0x07c0:start
;nasleduji definice segmentu a jejich velikosti (v sektorech po 512bajtech), lze menit jen velikosti
%define segment_jadra 0x1000
%define velikost_jadro 9
%define segment_filesystem 0x2000
%define velikost_filesystem 1
%define segment_editor 0x3000
%define velikost_editor 1
%define segment_prohlizec 0x4000
%define velikost_prohlizec 1
;nemenit nasledujici definice:
%define start_jadro 2
%define start_filesystem (start_jadro+velikost_jadro)
%define start_editor (start_filesystem+velikost_filesystem)
%define start_prohlizec (start_editor+velikost_editor)
%define jadro start_jadro*256+velikost_jadro
%define filesystem start_filesystem*256+velikost_filesystem
%define editor start_editor*256+velikost_editor
%define prohlizec start_prohlizec*256+velikost_prohlizec
start:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

	mov si, 0x03              ; tri pokusy pro nacteni sektoru
nacteni_sektoru:
	mov dx,0x0080             ; vyber pevneho disku (0x80), hlavy 0 (0x00)
	xor ax,ax                 ; zadost o restartovani disku (sluzba 0x00)
	int 0x13                  ; volani sluzeb BIOSu
	mov ah,0x02               ; vyber sluzby cteni z disku (0x02)
	mov ch,0x00               ; cylindr 0
	; cteni jednotlivych sektoru
	mov ax,jadro              ; informace o sektorech jadra
	mov bx,segment_jadra      ; informace o segmentu jadra
	call nacti_segmenty       ; nacteni sektoru do pameti
	mov ax,filesystem         ; informace o sektorech filesystemu
	mov bx,segment_filesystem ; informace o segmentu filesystemu
	call nacti_segmenty       ; nacteni sektoru do pameti
	mov ax,editor             ; informace o sektorech editoru
	mov bx,segment_editor     ; informace o segmentu editoru
	call nacti_segmenty       ; nacteni sektoru do pameti
	mov ax,prohlizec          ; informace o sektorech prohlizece
	mov bx,segment_prohlizec  ; informace o segmentu prohlizece
	call nacti_segmenty       ; nacteni sektoru do pameti
	; konec cteni sektoru
	jnc skok_jadro            ; skok do nacteneho jadra
	dec si                    ; snizeni poctu pokusu o 1
	cmp si, 0                 ; test na vycerpani pokusu
	jne nacteni_sektoru       ; opakovani nacitani pri dostatecnem poctu pokusu
restart:
	call pis16_registry
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

%include "print.asm"
zprava_boot:
	db "Nacteno!" ,0
zprava_restart:
	db "Restartovani...", 0
times 510-($-$$) db 0             ; doplneni pameti do 510ti bajtu
dw 0xaa55                         ; vlozeni bajtu 0xAA a 0x55 -> jedna se o bootovatelny sektor

