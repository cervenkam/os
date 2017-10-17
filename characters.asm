tabulka_znaku:
	cmp al,0x0D
	je enter
tabulka_znaku_konec:
	ret
enter:
	push ax
	mov ax,0x0E0A
	int 0x10
	pop ax
	jmp tabulka_znaku_konec
