pis_konec:
	popa
	ret

;EAX - adresa zpravy
;EBX - pozice (napr 0)
;ECX - barvy (napr 0x0f)
pis32:
	pusha
pis32_smycka:
	mov cl, [eax]
	cmp cl, 0
	je pis_konec
	mov [ebx+0xb8000], cx
	add ebx,2
	add eax,1
	jmp pis32_smycka

;AL - adresa zpravy
pis16:
	pusha
	mov si, ax
	mov ah, 0x0e
pis16_smycka:
	lodsb
	cmp al, 0
	je pis_konec
	int 0x10
	jmp pis16_smycka

