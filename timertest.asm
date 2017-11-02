org 0
bits 16
jmp 0x07c0:start
interrupt:
	cli
	pushf
	call 0xf000:0xfea5
	mov byte [es:bx],'X'	
	inc bl
	iret
start:
	mov ax,0xb800
	mov es,ax
	mov ax,0x0000
	mov ds,ax
	xor bx,bx
	cli
	mov word [ds:0x0020],interrupt
	mov word [ds:0x0022],cs
	sti
	jmp $
times 510-($-$$) db 0             ; doplneni pameti do 510ti bajtu
dw 0xaa55                         ; vlozeni bajtu 0xAA a 0x55 -> jedna se o bootovatelny sektor
