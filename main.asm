org 0x7c00
	mov bp, 0x9000
	mov sp, bp
	mov eax, zprava_boot
	call pis16
	call prepnuti_chraneny
	jmp $

%include "gdt.asm"
%include "protected.asm"
%include "print.asm"

bits 32
chraneny:
	mov eax, zprava_chraneny
	xor ebx, ebx
	mov ch, 0x0f
	call pis32
	jmp $
zprava_boot:
	db "Nacteno!", 0
zprava_chraneny:
	db "Prepnuto do chraneneho modu!", 0
times 510-($-$$) db 0
dw 0xaa55
