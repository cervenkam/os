bits 16
org 0
%define SIRKA_OKNA 320
; nastavi video mod, bez parametru
text_nastavit_video_mod:
	push ax
	mov ax, 0x13    ; nastaveni video modu 320x200, 256barev
	int 0x10        ; nastaveni video modu
	pop ax
	retf
times 0x40-($-$$) db 0
aktivni_pismo:
	dw pismo_male
pismo_male:
	db 6 ; vyska znaku
	db 5 ; sirka obrazku
	db 0x34 ; transparentni barva
	dw ascii_small ; adresa obrazku
	dw ascii_small_pozice ; pozice pismen v obrazku
	dw ascii_small_sirka ; sirka pismen v obrazku
	db 0 ; pridani konstantni barvy
pismo_doom:
	db 12 ; vyska znaku
	db 16 ; sirka obrazku
	db 0x34 ; transparentni barva
	dw doom ; adresa obrazku
	dw doom_pozice ; pozice pismen v obrazku
	dw doom_sirka ; sirka pismen v obrazku
	db 0 ; pridani konstantni barvy
pismo_doom_svetlejsi:
	db 12 ; vyska znaku
	db 16 ; sirka obrazku
	db 0x34 ; transparentni barva
	dw doom ; adresa obrazku
	dw doom_pozice ; pozice pismen v obrazku
	dw doom_sirka ; sirka pismen v obrazku
	db 4 ; pridani konstantni barvy

times 0x80-($-$$) db 0
; vykresli text na obrazovku ve video modu
; DS:AX => adresa retezce
; BX => pozice retezce
text_zobrazit:
	pusha
	push es
	mov di,bx       ; ulozeni pozice do DI
	mov cx, 0xa000  ; nastaveni video segmentu do CX
	mov es,cx       ; presun video segmentu do extra segmentu
	mov si,ax       ; nastaveni registru SI na hodnotu znaku ulozenou v AX
	xor ax,ax       ; vynulovani registru AX
	mov bx,[cs:aktivni_pismo]
	mov cx,[cs:bx+7]
	text_smycka:
		lodsb                 ; nacteni znaku z adresy DS:SI do registru AL
		cmp al, 0             ; porovnani na konec retezce
		je text_konec         ; ukonceni v pripade konce retezce
		xor bx,bx
		mov bl,al
		add bx,cx
		mov ah,[cs:bx] ; pridani pozice	
		call text_zobraz_znak ; volani zobrazeni znaku
		mov al,ah
		xor ah,ah
		add di,ax
		inc di                ; pridani mezery
		jmp text_smycka       ; opetovne volani, dokud neni konec retezce
	text_konec:
	pop es
	popa  ; obnova vsech registru
	retf

; vykresli znak na obrazovku ve video modu
; AL => ASCII znak
; AH => sirka znaku
; DI => pozice znaku ve video pameti
text_zobraz_znak:
	pusha
	mov bx,[cs:aktivni_pismo]
	push bx
	mov bx,[cs:bx+5]
	push ax
	xor ah,ah
	add bx,ax
	pop ax
	xor ch,ch
	mov cl,[cs:bx]
	pop bx
	push ax
	xor ah,ah
	mov al,[cs:bx]
	mul cl
	mov cl,[cs:bx+1]
	mul cl
	mov cx,ax
	pop ax
	mov si,cx
	add si,[cs:bx+3]
	xor cx,cx
	xor dh,dh
	text_vnejsi_cyklus:
		cmp cl,[cs:bx]
		je text_konec_vnejsi_cyklus
		xor ch,ch
		text_vnitrni_cyklus:
			cmp ch,ah
			je text_konec_vnitrni_cyklus
			push ax
			mov al,[cs:si]
			cmp al,[cs:bx+2] ; transparentni barva
			je text_pokracuj
				add al,[cs:bx+9] ; pridani konstantni barvy
				mov [es:di],al
			text_pokracuj:
			inc di
			inc si
			pop ax
			inc ch ; zvyseni cyklu
			jmp text_vnitrni_cyklus
		text_konec_vnitrni_cyklus:
		inc cl
		push ax
		mov al,ah
		xor ah,ah
		add di,SIRKA_OKNA ; posun ve video pameti 
		sub di,ax  ; na dalsi radek
		mov dl,[cs:bx+1]  ; posun o dany pocet pixelu
		add si,dx  ; v obrazku
		sub si,ax  ; na dalsi radek
		pop ax
		jmp text_vnejsi_cyklus
	text_konec_vnejsi_cyklus:
	popa
	ret
%include "images/ascii_small.asm"
%include "images/doom.asm"
	
doom_pozice:
ascii_small_pozice:
	times 48 db 0
	db 26,27,28,29,30,31,32,33,34,35 ; pozice cislic
	times 7 db 0
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; pozice znaku
	times 6 db 0
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; pozice znaku
	times 5 db 0
doom_sirka:
	times 48 db 0
	db 11,7,11,11,11,11,11,11,11,11                                                  ; sirka cislic
	times 7 db 0
	db 14,14,14,14,14,12,16,15,6,11,16,11,16,16,16,14,16,15,15,12,16,16,16,14,16,16  ; sirka znaku
	times 6 db 0
	db 14,14,14,14,14,12,16,15,6,11,16,11,16,16,16,14,16,15,15,12,16,16,16,14,16,16  ; sirka znaku
	times 5 db 0
ascii_small_sirka:
	times 48 db 0
	db 5,5,5,5,5,5,5,5,5,5                                 ; sirka cislic
	times 7 db 0
	db 5,5,5,5,5,5,5,5,1,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5 ; sirka cislic
	times 6 db 0
	db 5,5,5,5,5,5,5,5,1,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5 ; sirka cislic
	times 5 db 0
%include "print.asm"
times 0x2400-($-$$) db 0
