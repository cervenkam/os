org 0
bits 16
jmp 0x07c0:start
interrupt:
	mov byte [es:bx],'X'	
	inc bx
	jmp [stare_int0x08]	
stare_int0x08:
	dd 0
start:
	mov ax,0xb800
	mov es,ax
	mov ax,0x0000
	mov ds,ax
	xor bx,bx
	mov ax,[ds:0x0020]
	mov [cs:stare_int0x08],ax
	mov ax,[ds:0x0022]
	mov [cs:stare_int0x08+2],ax
	mov word [ds:0x0020],interrupt
	mov word [ds:0x0022],cs
	jmp $
times 510-($-$$) db 0             ; doplneni pameti do 510ti bajtu
dw 0xaa55                         ; vlozeni bajtu 0xAA a 0x55 -> jedna se o bootovatelny sektor
