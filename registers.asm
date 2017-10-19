%define reg_num 8

print_registers:
	pusha ;ax, cx, dx, bx, sp, bp, si, di <- vrchol zasobniku 
	mov bx, reg_num

	mov ax, reg_text
	call pis16
loop:
	;xor ax, ax ;nefunguje
	;mov ax, reg_si
	;add ax, cx
	;add cx, 7
	;call pis16

	pop ax;
	ror ax,8
	call pis16_registr
	rol ax,8
	call pis16_registr	
	dec bl	
	jne loop
	ret


reg_text db "Vypis registru:", 10, 13, 0 ; pokud tento string zustane na teto radce tak ok
reg_si db "si:", 10, 13, 0
reg_bp db "bp:", 10, 13, 0
; pokud se presune sem tak se nevypise cely :( jakoby narazil na nulovy znak drive
