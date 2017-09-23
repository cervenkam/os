;EAX - adresa zpravy
;EBX - pozice (napr 0)
;ECX - barvy (napr 0x0f)
pis32:
	push edx
	push ecx
	push eax
	push ebx
pis32_smycka:
	mov cl, [eax]
	cmp cl, 0
	je pis32_konec
	cmp cl, 0xa
	je pis32_rekurzivne
	;je pis32_konec
	cmp ebx, 0xfa0
	jl pis32_pokracuj
	call pis32_posun
pis32_pokracuj:
	mov [ebx+0xb8000], cx
	add ebx,2
	inc eax
	jmp pis32_smycka
pis32_konec:
	pop ebx
	mov eax, ebx
	mov ecx, 0xa0
	div ecx
	sub ebx, edx
	add ebx, 0x120
	pop eax
	pop ecx
	pop edx
	ret
pis32_rekurzivne:
	pop ebx
	push eax
	mov eax, ebx
	mov ecx, 0xa0
	div ecx
	sub ebx, edx
	add ebx, 0x120
	pop eax
	inc eax
	pop ecx
	pop ecx
	pop edx
	call pis32
	ret
pis32_posun:
	pusha
	mov eax, 0xb8000
pis32_posun_smycka:
	cmp eax, 0xb8f00
	jge pis32_posun_posledni_radek
	mov bx,[eax+0xa0]
	mov [eax],bx
	add eax,2
	jmp pis32_posun_smycka
pis32_posun_posledni_radek:
	cmp eax, 0xb8fa0
	jge pis32_posun_konec
	mov word [eax],0
	add eax,2
	jmp pis32_posun_posledni_radek
pis32_posun_konec:
	popa
	mov ebx, 0xf00
	ret
;AL - adresa zpravy
pis16:
	pusha
	mov si, ax
	mov ah, 0x0e
pis16_smycka:
	lodsb
	cmp al, 0
	je pis16_konec
	int 0x10
	jmp pis16_smycka
pis16_konec:
	popa
	ret

