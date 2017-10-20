org 0
bits 16
start:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)
	call pis16_registry
	call obrazek_zobrazit     ; zobrazeni uvodniho obrazku
test_zapis:
	;mov dx,0x0081 ;id disku
	;mov ax,0x1300 
	;int 0x13
	;jc cyklus

	;call pis16_registr

	mov di, 0x1234
	mov ax, 0x1122
	mov bx, 0x5678
	mov cx, 0x9ABC
	mov dx, 0xEF01

	call pis16_registry
	;jmp $

cyklus:
	xor ah,ah
	int 0x16
	mov ah,0xe
	call tabulka_znaku
	int 0x10                  ; volani video sluby BIOSu
	call pis16_registr
	jmp cyklus

%include "characters.asm"         ; vlozeni funkci pro praci se znaky
%include "lba2chs.asm"            ; vlozeni funkce pro prevod linearni adresu na adresu cylindr,hlava,sektor
%include "splash.asm"             ; vlozeni nacitaci obrazovky
%include "print.asm"              ; vlozeni funkci pro vypis v realnem a chranenem modu
