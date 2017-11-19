org 0
bits 16
%include "consts.asm"

start:
	mov ax,cs
	mov ds,ax
	mov es,ax

	xor cx,cx
	mov bx,nacteny_buffer
	mov ah,0x3f
	int 0x21
	;mov ax, 0x37 ; nastaveni procedury formatovat disk
	;int 0x21	 ; preruseni pro vykonani formatovani disku

	mov ax,5
	int 0x22
	xor cx,cx
	mov bx,660+960+640
	xor ax,ax
	xor dx,dx
	cyklus:
		cmp cx,16
		jge konec_cyklu
		call kresli_jeden_soubor
		add ax,0x20
		add bx,160
		inc cx
		call kresli_jeden_soubor
		add ax,0x20
		add bx,8000-960
		inc cx
		xor dh,1
		jmp cyklus
	konec_cyklu:
stisk_klavesy:
	xor ax,ax
	int 0x16	
	cmp ah,0x48
	je sipka_nahoru
	cmp ah,0x4B
	je sipka_do_strany
	cmp ah,0x4D
	je sipka_do_strany
	cmp ah,0x50
	je sipka_dolu
	cmp ah,0x1C ;enter
	je enter
	jmp stisk_klavesy
sipka_do_strany:
	mov al,[cs:aktualni_soubor]
	mov [cs:predchozi_soubor],al
	xor byte [cs:aktualni_soubor],1
	jmp kresli_zmeny
sipka_dolu:
	mov al,[cs:aktualni_soubor]
	mov [cs:predchozi_soubor],al
	add byte [cs:aktualni_soubor],2
	xor byte [cs:aktualni_soubor],1
	and byte [cs:aktualni_soubor],15
	jmp kresli_zmeny
sipka_nahoru:
	mov al,[cs:aktualni_soubor]
	mov [cs:predchozi_soubor],al
	sub byte [cs:aktualni_soubor],2
	xor byte [cs:aktualni_soubor],1
	and byte [cs:aktualni_soubor],15
	jmp kresli_zmeny
enter:
	mov ax,segment_editor
	mov es,ax
	xor ax,ax
	mov bl,[cs:aktualni_soubor]
	inc bl
	int 0x23
kresli_zmeny:
	mov bl,[cs:aktualni_soubor]
	call kresli_jednu_zmenu
	mov bl,[cs:predchozi_soubor]
	call kresli_jednu_zmenu
	jmp stisk_klavesy

kresli_jednu_zmenu:
	xor cl,cl
	mov bx,660+960+640
	xor ax,ax
	xor dx,dx
	cyklus_jedna:
		cmp cl,16
		jge konec_cyklu_jedna
		cmp cl,[cs:aktualni_soubor]
		je muzes_kreslit_1
		cmp cl,[cs:predchozi_soubor]
		je muzes_kreslit_1
		jmp konec_kresleni_1
		muzes_kreslit_1:
			call kresli_jeden_soubor
		konec_kresleni_1:
		add ax,0x20
		add bx,160
		inc cl
		cmp cl,[cs:aktualni_soubor]
		je muzes_kreslit_2
		cmp cl,[cs:predchozi_soubor]
		je muzes_kreslit_2
		jmp konec_kresleni_2
		muzes_kreslit_2:
			call kresli_jeden_soubor
		konec_kresleni_2:
		add ax,0x20
		add bx,8000-960
		inc cl
		xor dh,1
		jmp cyklus_jedna
	konec_cyklu_jedna:
	ret
	
konec:
	int 0x05

; AX => pozice souboru
; BX => pozice, kam se ma kreslit
; DH => 1/0 smer kresleni
kresli_jeden_soubor:
	pusha
	push ax
	push dx
	push cx
	;nastaveni pozadi
	mov ax,bx
	mov cx,320
	div cx
	mov [cs:pozice],ax
	mov [cs:pozice+4],dx
	add ax,17
	add dx,120
	mov [cs:pozice+2],ax
	mov [cs:pozice+6],dx
	mov byte [cs:pozice+8],4
	pop cx
	cmp cl,[cs:aktualni_soubor]
	jne nemenit_pozadi
	mov byte [cs:pozice+8],5
nemenit_pozadi:
	;kresleni pozadi
	mov ax,0x4
	push bx
	mov bx,pozice
	int 0x22	
	pop bx
	pop dx
	pop ax
	push ax
	push dx
	; kresleni obliceje	
	mov byte [cs:znak],2
	push bx
	mov bx,ax
	mov ah,[cs:nacteny_buffer+bx+0x1e]
	mov al,[cs:nacteny_buffer+bx+0x1f]
	mov cx,102
	xor dx,dx
	div cx
	cmp al,5
	jle neopravuj_al
	mov al,5
neopravuj_al:
	add [cs:znak],al
	mov ax,0x2
	mov bx,0x3
	int 0x22
	pop bx
	pop dx
	push bx
	mov ax,0x1
	sub bx,320*6
	test dh,dh
	jz nepridavat
	add bx,96
nepridavat:
	mov cx,znak
	int 0x22
	; kresleni jmena
	mov ax,0x2
	mov bx,0x4
	int 0x22
	pop bx
	pop ax
	push ax
	push bx
	mov bx,ax
	add bx,nacteny_buffer
	mov dl,[cs:bx+8]
	mov byte [cs:bx+8],0
	mov cx,bx
	mov bx,ax
	pop bx
	push bx
	add bx,320*2+2
	test dh,dh
	jnz nepridavat_2
	add bx,60
nepridavat_2:
	mov ax,0x1
	int 0x22
	mov bx,cx
	mov [cs:bx+8],dl
	pop bx
	pop ax
	push ax
	push bx
	mov bx,ax
	add bx,nacteny_buffer
	add bx,8
	mov dl,[cs:bx+3]
	mov byte [cs:bx+3],0
	mov cx,bx
	mov bx,ax
	pop bx
	push bx
	add bx,320*9+2
	test dh,dh
	jnz nepridavat_3
	add bx,60
nepridavat_3:
	mov ax,0x1
	int 0x22
	mov bx,cx
	mov [cs:bx+3],dl
	pop bx
	pop ax
	popa
	ret	
pozice:
	dw 0
	dw 0
	dw 0
	dw 0
	db 4
znak:
	dw 0
aktualni_soubor:
	db 0
predchozi_soubor:
	db 0
nacteny_buffer:
	times 0x201 db 0

%include "print.asm"
;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x600-($-$$) db 0
