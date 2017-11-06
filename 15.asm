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

	mov ax,0x2	
	xor bx,bx
	int 0x22
	mov ax,0x02
	mov bx,0x1
	int 0x22
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
	xor ax,ax
	int 0x16	
	cmp ah,0x48
	je sipka_nahoru
	cmp ah,0x50
	je sipka_dolu
	cmp ah,0x4B
	je sipka_vlevo
	cmp ah,0x4D
	je sipka_vpravo
sipka_nahoru:
sipka_dolu:
sipka_vlevo:
sipka_vpravo:
konec:
	jmp segment_jadro:0x0000
nakresli_jedno_pole:
	pusha
	push ax
	call nastav_pozice
	mov ax,0x4
	mov bx,pozice
	int 0x22
	pop ax
	push ax
	mov bx,ax
	shr bx,6
	or al,bl		
	mov bx,[cislo_hry]
	shr bx,4
	add bx,hry
	xor ah,ah
	add bx,ax
	mov al,[bx]
	cmp al,0
	je konec_jedno_pole
	add al,0x40	
	mov [znak], al
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
konec_jedno_pole:
	pop ax
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
	mov [pozice],bx
	mov [pozice+4],cx
	add bx,26
	add cx,26
	mov [pozice+2],bx
	mov [pozice+6],cx
	popa
	ret
pozice:
	dw 0
	dw 30
	dw 0
	dw 30
	db 2
znak:
	db 'X',0
cislo_hry:
	dw 0
hry:
	db 1,2,3,4
	db 5,6,7,8
	db 9,10,11,12
	db 13,14,0,15	
%include "print.asm"
times 0x400-($-$$) db 0
