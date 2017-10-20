org 0
bits 16
jmp 0x07c0:start
%define segment_jadra 0x1000
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
	mov cx,0x0002             ; cylindr 0, sektor 2
	mov ax,0x0209             ; vyber sluzby cteni z disku (0x02), 35 (0x23) sektoru
	mov bx,segment_jadra      ; pokracovani do jadra
	mov es,bx
	xor bx,bx
	int 0x13                  ; volani sluzeb BIOSu
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

%include "print.asm"
zprava_boot:
	db "Nacteno!" ,0
zprava_restart:
	db "Restartovani...", 0
times 510-($-$$) db 0             ; doplneni pameti do 510ti bajtu
dw 0xaa55                         ; vlozeni bajtu 0xAA a 0x55 -> jedna se o bootovatelny sektor

