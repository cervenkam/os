org 0x7c00
bits 16
	mov bp, 0x9000           ; nastaveni bazove adresy zasobniku
	mov sp, bp               ; a ukazatele na aktualni prvek zasobniku (stack pointeru)
	mov eax, zprava_boot     ; vyber zpravy k vypisu
	call pis16               ; vypis zpravy v realnem modu
	call obrazek_zobrazit    ; zobrazeni uvodniho obrazku
	jmp $
	call prepnuti_chraneny   ; prepnuti procesoru do chraneneho rezimu (dojde ke skoku na navesti "chraneny")
	jmp $                    ; nekonecna smycka (skok na sebe sama)

%include "splash.asm"            ; vlozeni nacitaci obrazovky
%include "gdt.asm"               ; vlozeni definice global descriptor table
%include "protected.asm"         ; vlozeni kodu pro prechod do chraneneho (protected) modu procesoru
%include "print.asm"             ; vlozeni funkci pro vypis v realnem a chranenem modu

bits 32                          ; zacatek kodu v chranenem 32bitovem rezimu
chraneny:
	mov eax, zprava_chraneny ; vyber zpravy k vypisu
	xor ebx, ebx             ; vynulovani EBX - zprava bude psana na zacatek obrazovky
	mov ch, 0x0f             ; vyber fontu
	call pis32               ; vypsani zpravy v chranenem modu
	jmp $                    ; nekonecna smycka (skok na sebe sama)
zprava_boot:
	db "Nacteno!", 0
zprava_chraneny:
	db "Prepnuto do chraneneho modu!", 0xa, "Vsechno OK", 0
druha_radka:
	db "Dalsi radka!", 0
times 510-($-$$) db 0           ; doplneni pameti do 510ti bajtu
dw 0xaa55                       ; vlozeni bajtu 0xAA a 0x55 -> jedna se o bootovatelny sektor
