bits 16
prepnuti_chraneny:
	cli
	lgdt [gdt_deskriptor]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp gdt_kodovy_segment:inicializace_chraneny
bits 32
inicializace_chraneny:
	mov ax, gdt_datovy_segment
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ebp, 0x90000
	mov esp, ebp
	call chraneny
