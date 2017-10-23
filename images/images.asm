bits 16
org 0
%define VYSKA_ZNAKU 6
%define SIRKA_OBRAZKU 5
%define SIRKA_OKNA 320
%define TRANSPARENTNI 0x34
; nastavi video mod, bez parametru
text_nastavit_video_mod:
	push ax
	mov ax, 0x13    ; nastaveni video modu 320x200, 256barev
	int 0x10        ; nastaveni video modu
	pop ax
	ret
times 0x40-($-$$) db 0
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
	xor bx,bx       ; vynulovani registru BX
	text_smycka:
		lodsb                 ; nacteni znaku z adresy DS:SI do registru AL
		test al,al
		jz text_konec         ; ukonceni v pripade konce retezce
		mov bl,al
		mov ah,[cs:znaky_sirka+bx] ; pridani pozice TODO
		call text_zobraz_znak ; volani zobrazeni znaku
		mov al,ah
		xor ah,ah
		add di,ax
		inc di                ; pridani mezery
		jmp text_smycka       ; opetovne volani, dokud neni konec retezce
	text_konec:
	pop es
	popa  ; obnova vsech registru
	ret

; vykresli znak na obrazovku ve video modu
; AL => ASCII znak
; AH => sirka znaku
; DI => pozice znaku ve video pameti
text_zobraz_znak:
	pusha
	push ds
	push ax
	mov ax,cs
	mov ds,ax
	xor bh,bh
	mov bl,al
	mov bl,[ds:znaky_pozice+bx]
	mov ax,VYSKA_ZNAKU
	mul bx
	mov bx,SIRKA_OBRAZKU
	mul bx
	mov bx,ax
	pop ax
	mov si,bx
	add si,small
	xor cx,cx
	text_vnejsi_cyklus:
		cmp cl,VYSKA_ZNAKU
		je text_konec_vnejsi_cyklus
		xor ch,ch
		text_vnitrni_cyklus:
			cmp ch,ah
			je text_konec_vnitrni_cyklus
			push ax
			lodsb
			cmp al,TRANSPARENTNI ; transparentni barva
			je text_pokracuj
				mov byte [es:di],al
				call pis16_registr
				mov al, byte [es:di]
				call pis16_registr
				inc di
			text_pokracuj:
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
		add si,SIRKA_OBRAZKU  ; posun v obrazku 
		sub si,ax  ; na dalsi radek
		pop ax
		jmp text_vnejsi_cyklus
	text_konec_vnejsi_cyklus:
	pop ds
	popa
	ret
%include "images/small.asm"
%include "print.asm"
	
znaky_pozice:
	times 48 db 0
	db 26,27,28,29,30,31,32,33,34,35 ; pozice cislic
	times 7 db 0
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; pozice znaku
	times 6 db 0
	db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 ; pozice znaku
	times 5 db 0
;znaky_sirka:
;	times 48 db 0
;	db 11,7,11,11,11,11,11,11,11,11                                                  ; sirka cislic
;	times 7 db 0
;	db 14,14,14,14,14,12,16,15,6,11,16,11,16,16,16,14,16,15,15,12,16,16,16,14,16,16  ; sirka znaku
;	times 6 db 0
;	db 14,14,14,14,14,12,16,15,6,11,16,11,16,16,16,14,16,15,15,12,16,16,16,14,16,16  ; sirka znaku
;	times 5 db 0
znaky_sirka:
	times 48 db 0
	db 5,5,5,5,5,5,5,5,5,5                                 ; sirka cislic
	times 7 db 0
	db 5,5,5,5,5,5,5,5,1,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5 ; sirka cislic
	times 6 db 0
	db 5,5,5,5,5,5,5,5,1,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5 ; sirka cislic
	times 5 db 0
times 0x1e00-($-$$) db 0
