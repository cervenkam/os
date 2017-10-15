bits 32
; GDT = Global Descriptor Table
; definice rozdeleni pameti na kodovy a datovy segment
; zdroj: https://en.wikipedia.org/wiki/Global_Descriptor_Table

gdt_zacatek:
	dd 0 ; 4 prazdne bajty
	dd 0 ; 4 prazdne bajty
gdt_kodovy_deskriptor:
	dw 0xffff ; limit segmentu 0 b - 15 b
	dw 0      ; bazova adresa  0 b - 15 b
	db 0      ; bazova adresa 16 b - 23 b
	db 0x9a   ; nastaveni pristupu
	db 0xcf   ; flags a limit segmentu 16 b - 20 b
	db 0      ; bazova adresa 24 b - 31 b
gdt_datovy_deskriptor:
	dw 0xffff ; limit segmentu 0 b - 15 b
	dw 0      ; bazova adresa  0 b - 15 b
	db 0      ; bazova adresa 16 b - 23 b
	db 0x92   ; nastaveni pristupu
	db 0xcf   ; flags a limit segmentu 16 b - 20 b
	db 0      ; bazova adresa 24 b - 31 b
gdt_konec:
gdt_deskriptor:
	dw gdt_konec-gdt_zacatek-1 ; velikost GDT
	dd gdt_zacatek             ; zacatek GDT
gdt_kodovy_segment equ gdt_kodovy_deskriptor-gdt_zacatek
gdt_datovy_segment equ gdt_datovy_deskriptor-gdt_zacatek
