bits 16
prepnuti_chraneny:
	cli                    ; zakaz preruseni
	lgdt [gdt_deskriptor]  ; nastaveni global descriptor table
	mov eax, cr0           ; nastaveni chraneneho rezimu nastavenim 1. bitu v registru cr0
	or eax, 1
	mov cr0, eax
	jmp gdt_kodovy_segment:inicializace_chraneny ; skok na inicializaci v chranenem rezimu
bits 32
inicializace_chraneny:
	mov ax, gdt_datovy_segment  ; nastaveni vsech registru segmentu na datovy segment
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ebp, 0x90000 ; nastaveni bazove adresy zasobniku
	mov esp, ebp     ; nastaveni aktualni adresy zasobniku (stack pointeru)
	call chraneny    ; volani funkce chraneny (musi se definovat v jinem modulu)
