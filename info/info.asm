org 0
bits 16
%macro printf 2
	mov cx,%1
	mov bx,%2
	int 0x22
%endmacro
start:
	mov ax,cs
	mov ds,ax 
	mov ax,0x2
	xor bx,bx
	int 0x22
	mov ax,0x5
	int 0x22
	mov ax,0x1
	printf retezec_popis,  100+320*30
	printf retezec_predmet,100+320*38
	printf retezec_jmeno_1,100+320*48
	printf retezec_jmeno_2,100+320*55
	printf retezec_jmeno_3,100+320*62
	xor ax,ax
	int 0x16
	mov ah,0x37
	int 0x21
konec:
	int 0x05
retezec_jmeno_1:
	db "Martin Cervenka",0
retezec_jmeno_2:
	db "Petr Stechmuller",0
retezec_jmeno_3:
	db "Antonin Vrba",0
retezec_popis:
	db "Semestralni prace",0
retezec_predmet:
	db "KIV/OS",0
times 0x200-($-$$) db 0
