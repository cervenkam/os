org 0
bits 16
%define ZNAKU_NA_RADEK 40
%define POCET_ODRADKOVANI 14
start:
	mov ax, cs                ; zkopirovani code segmentu do AX
	mov ds, ax                ; zkopirovani tohoto code segmentu do data segmentu (jsou stejne)
	mov es, ax                ; a zkopirovani i do extra segmentu

default_editor:
	mov cl, [cs:id_souboru]
	mov ah, 0x3f
	mov bx, buffer_editoru ; nactaceni dat (zatim staticky definovane)
	int 0x21
	mov al,[cs:buffer_editoru]
	mov [cs:zalozni_znak],al

cisteni:
	mov ax, 5	
	int 0x22
nastaveni_fontu:
	mov ax, 2
	mov bx, 5
	int 0x22

vykresleni:
	call strlen
	call zaloha_ukazatele
	call nastaveni_ukazatele
	call nakresli
klavesnice:
	xor ax, ax
	int 0x16
	call obnova_ukazatele
	cmp ah,0x4B
	je leva_sipka
	cmp ah,0x48
	je sipka_nahoru
	cmp ah,0x50
	je sipka_dolu
	cmp ah,0x4D
	je prava_sipka
	cmp ah,0x1C ;enter
	je enter_ulozit
	cmp ah,0x0e
	je backspace
	jmp jina_klavesa

jina_klavesa:
	mov bx,510
	jina_klavesa_cyklus:
		cmp bx,[cs:kurzor_pointer]
		jl jina_klavesa_konec_cyklu
		mov dh,[cs:buffer_editoru+bx]
		mov [cs:buffer_editoru+bx+1],dh
		dec bx
		jmp jina_klavesa_cyklus
	jina_klavesa_konec_cyklu:	
	mov [cs:buffer_editoru+bx+1],al
	inc word [cs:kurzor_pointer]
	cmp word [cs:kurzor_pointer],512
	jl jina_klavesa_neopravuj
		mov word [cs:kurzor_pointer],511
		mov byte [cs:buffer_editoru+512],0
	jina_klavesa_neopravuj:
	jmp cisteni
	
backspace:
	mov bx,[cs:kurzor_pointer]
	test bx,bx
	jnz backspace_neopravuj
		mov word [cs:kurzor_pointer],1
	backspace_neopravuj:
	dec word [cs:kurzor_pointer]
	mov bx,[cs:kurzor_pointer]
	backspace_cyklus:
		cmp bx,512
		jge backspace_konec_cyklu
		mov dh,[cs:buffer_editoru+bx+1]
		mov [cs:buffer_editoru+bx],dh
		inc bx
		jmp backspace_cyklus
	backspace_konec_cyklu:	
	jmp cisteni
	
posun:
	add word [cs:kurzor_pointer], ax
	js posun_nastav_0
	call strlen
	cmp word [cs:kurzor_pointer],ax
	jge posun_nastav_ax
	jmp cisteni
posun_nastav_0:
	mov word [cs:kurzor_pointer],0
	jmp cisteni
posun_nastav_ax:
	mov word [cs:kurzor_pointer],ax
	jmp cisteni

prava_sipka: ;inkrementuje pointer
	mov ax,1
	jmp posun

leva_sipka: ;dekrementuje pointer
	mov ax,0xffff
	jmp posun
sipka_dolu:
	mov ax,ZNAKU_NA_RADEK
	jmp posun
sipka_nahoru:
	mov ax,0xffff-ZNAKU_NA_RADEK+1
	jmp posun

enter_ulozit:
	mov ah,0x40
	xor ch,ch
	mov cl,[cs:id_souboru]
	mov bx,buffer_editoru
	int 0x21
	jmp cisteni
konec:
	int 0x05

zaloha_ukazatele:
	push ax
	push bx
	mov bx, [cs:kurzor_pointer]
	mov al, [cs:buffer_editoru+bx]
	mov [cs:zalozni_znak],al
	pop bx
	pop ax
	ret

nastaveni_ukazatele:
	push ax
	push bx
	mov bx, [cs:kurzor_pointer]
	mov byte [cs:buffer_editoru+bx], 1 ;dvojtecka jako znak	
	pop bx
	pop ax
	ret

obnova_ukazatele:
	push ax
	push bx
	mov al, [cs:zalozni_znak]
	mov bx, [cs:kurzor_pointer]
	mov [cs:buffer_editoru+bx],al
	pop bx
	pop ax
	ret

strlen:
	push bx
	push cx
	mov bx, buffer_editoru
do:
	xor cx, cx
	mov cl, [cs:bx]
	test cl, cl
	jz koneccc 
	inc bx
	jmp do
koneccc:
	mov ax, bx 
	sub ax, buffer_editoru 
	mov [cs:pocet_znaku], ax
	pop cx
	pop bx
	ret

nakresli:
	pusha
	mov bx,ZNAKU_NA_RADEK
	mov cx,321*10
	mov ax,1
	nakresli_cyklus:
		cmp bx,POCET_ODRADKOVANI*ZNAKU_NA_RADEK
		jge nakresli_konec_cyklu
		mov dl,[cs:buffer_editoru+bx]
		mov byte [cs:buffer_editoru+bx],0
		push bx
		push cx
		xchg bx,cx
		add cx,buffer_editoru
		sub cx,ZNAKU_NA_RADEK
		int 0x22
		pop cx
		pop bx
		mov [cs:buffer_editoru+bx],dl
		add cx,320*8
		add bx,ZNAKU_NA_RADEK
		jmp nakresli_cyklus
	nakresli_konec_cyklu:
	popa
	ret


pocet_znaku:
	dw 0

kurzor_pointer:
	dw 0

buffer_editoru:
	db "text12345sadfnaugaeraiogaerhomairehnaregnaruhgaerovmaiorhayorjvojiareijriaohejaiorgioraiegjaeio4624taioergjiq54ty5iy8hahg885858qh8ar"
	times 450 db 0 ;513 protoze posledni bude vzdycky \0

zalozni_znak:
	db 0
id_souboru:
	db 1

%include "print.asm"

;zacne hazet chybu pri rostoucim kodu, proto pak zvysit ale
;NEZAPOMENOUT upravit velikost tohoto segmentu i v makru loaderu !!!!
times 0x800-($-$$) db 0
