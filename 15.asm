org   0
bits  16
%include "consts.asm"
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu
	mov ss, ax                ; a i do stack segmentu
	mov bp, 0x9000            ; nastaveni bazove adresy zasobniku
	mov sp, bp                ; a ukazatele na aktualni prvek zasobniku (stack pointeru)

	mov ax,0x5
	int 0x22
	mov ax,0x2	
	xor bx,bx
	int 0x22
	mov ax,0x02
	mov bx,0x1
	int 0x22
	call nacti_hru
nakresli_vse:
	mov ah,0
	vnejsi_smycka:
		cmp ah,4
		je konec_vnejsi_smycky
		mov al,0
		vnitrni_smycka:
			cmp al,4
			je konec_vnitrni_smycky
			call nakresli_jedno_pole
			inc al
			jmp vnitrni_smycka
		konec_vnitrni_smycky:
		inc ah
		jmp vnejsi_smycka
	konec_vnejsi_smycky:
stisk_klavesy:
	xor ax,ax
	int 0x16	
	push ax
	mov ax,0x02
	mov bx,0x1
	int 0x22
	pop ax
	call najdi_pozici
	cmp ah,0x48
	je sipka_nahoru
	cmp ah,0x4B
	je sipka_vlevo
	cmp ah,0x4D
	je sipka_vpravo
	cmp ah,0x50
	je sipka_dolu
	jmp stisk_klavesy
sipka_nahoru:
	cmp bx,4
	jl stisk_klavesy
	mov ax,bx
	sub ax,4
	call prehod_pole
	jmp stisk_klavesy
sipka_dolu:
	cmp bx,12
	jge stisk_klavesy
	mov ax,bx
	add ax,4
	call prehod_pole
	jmp stisk_klavesy
sipka_vlevo:
	test bx,0x3
	jz stisk_klavesy
	mov ax,bx
	dec ax
	call prehod_pole
	jmp stisk_klavesy
sipka_vpravo:
	inc bx
	test bx,0x3
	jz stisk_klavesy
	dec bx
	mov ax,bx
	inc ax
	call prehod_pole
	jmp stisk_klavesy
konec:
	jmp segment_jadro:0x0000
prehod_pole:
	pusha
	mov cl,[cs:aktualni_hra+bx]
	push bx
	mov bx,ax
	mov ch,[cs:aktualni_hra+bx]
	mov [cs:aktualni_hra+bx],cl
	pop bx
	mov [cs:aktualni_hra+bx],ch
	mov ah,al
	shr ah,2	
	and al,3
	call nakresli_jedno_pole
	mov ax,bx
	mov ah,al
	shr ah,2	
	and al,3
	call nakresli_jedno_pole
	popa
	ret
nacti_hru:
	pusha
	xor bx,bx
	mov cx,[cs:cislo_hry]
	shr cx,4
	add cx,hry
	smycka_najdi:
		cmp bx,16
		je konec_smycka_najdi
		add bx,cx
		mov al,[cs:bx]
		sub bx,cx
		mov [cs:aktualni_hra+bx],al
		inc bx
		jmp smycka_najdi
	konec_smycka_najdi:
	popa
	ret
najdi_pozici:
	xor bx,bx
	smycka_pozice:
		cmp bx,16
		je konec_smycka_pozice
		cmp byte [cs:aktualni_hra+bx],0
		je konec_smycka_pozice
		inc bx
		jmp smycka_pozice
	konec_smycka_pozice:
	ret
nakresli_jedno_pole:
	pusha
	call nastav_pozice
	push ax
	mov bx,ax
	shr bx,6
	or al,bl		
	xor ah,ah
	mov bx,ax
	mov al,[cs:aktualni_hra+bx]
	cmp al,0
	jne nemenit_barvu
	mov byte [cs:pozice+8],6
nemenit_barvu:
	push ax
	mov ax,0x4
	mov bx,pozice
	int 0x22
	pop ax
	add al,0x40	
	mov [cs:znak], al
	pop ax
	mov bx,0x11d2
	mov cl,0x30
	push ax
	mul cl
	xor ah,ah
	add bx,ax
	pop ax
	mov al,ah
	xor ah,ah
	mov cx,320*32
	mul cx
	add bx,ax
	mov ax,0x1
	mov cx,znak
	int 0x22
	popa
	ret
nastav_pozice:
	pusha
	mov cx,ax
	xor ch,ch
	mov bx,ax
	mov bl,bh
	xor bh,bh
	mov ax,0x30
	mul cl
	mov cx,ax
	shl bx,5
	add bx,8
	add cx,76
	mov [cs:pozice],bx
	mov [cs:pozice+4],cx
	add bx,26
	add cx,26
	mov [cs:pozice+2],bx
	mov [cs:pozice+6],cx
	mov byte [cs:pozice+8],3
	popa
	ret
pozice:
	dw 0
	dw 30
	dw 0
	dw 30
	db 3
znak:
	db 'X',0
cislo_hry:
	dw 0
hry:
	db 1,2,3,4
	db 5,6,7,8
	db 9,10,11,12
	db 13,14,0,15	
aktualni_hra:
	times 16 db 0
%include "print.asm"
times 0x400-($-$$) db 0
