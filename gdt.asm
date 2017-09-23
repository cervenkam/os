gdt_zacatek:
	dd 0
	dd 0
gdt_kodovy_deskriptor:
	dw 0xFFFF
	dw 0
	db 0
	db 0x9a
	db 0xcf
	db 0
gdt_datovy_deskriptor:
	dw 0xFFFF
	dw 0
	db 0
	db 0x92
	db 0xcf
	db 0
gdt_konec:
gdt_deskriptor:
	dw gdt_konec-gdt_zacatek-1 ; velikost GDT
	dd gdt_zacatek             ; zacatek GDT
gdt_kodovy_segment equ gdt_kodovy_deskriptor-gdt_zacatek
gdt_datovy_segment equ gdt_datovy_deskriptor-gdt_zacatek
