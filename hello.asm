org 0x7c00
bits 16
start:
	cli            ;zakaz preruseni
	mov si, ahoj   ;adresa tisknuteho retezce
	mov ah, 0x0e   ;cislo sluzby tisknuti znaku
.loop:
	lodsb
	or al, al      ;jedna se o znak \0?
	jz halt
	int 0x10       ;volani sluzby BIOSu
	jmp .loop
halt:
	hlt
ahoj:
	db "Ahoj, Svete!", 0
times 510-($-$$) db 0  ;zapis nul do 510. bajtu
dw 0xaa55              ;511. a 512. bajt je 0xaa55
