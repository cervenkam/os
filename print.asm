bits 16
; funkce pis16, pise zpravu v realnem 16bitovem rezimu
; => AL - adresa zpravy
pis16:
	pusha         ; ulozeni vsech registru do zasobniku
	mov si, ax    ; nastaveni registru SI na hodnotu znaku ulozenou v AX
	mov ah, 0x0e  ; nastaveni AH na sluzbu BIOSu cislo 14 (pri int 0x10 je 0x0e psani znaku v TTY rezimu)
pis16_smycka:
	lodsb             ; nacteni znaku z adresy DS:SI do registru AL
	cmp al, 0         ; porovnani na konec retezce
	je pis16_konec    ; ukonceni v pripade konce retezce
	int 0x10          ; volani video sluby BIOSu
	jmp pis16_smycka  ; opetovne volani, dokud neni konec retezce
pis16_konec:
	popa  ; obnova vsech registru
	ret   ; ukonceni podprogramu vypisu v 16tibitovem rezimu

; funkce pis16_registr - vypisuje obsah registru
; => AL - obsah registru
pis16_registr:
	pusha                                 ; ulozeni vsech registru do zasobniku
	mov si, ax                            ; nastaveni registru SI na hodnotu znaku ulozenou v AX
	mov ah, 0x0e                          ; nastaveni AH na sluzbu BIOSu cislo 14 (pri int 0x10 je 0x0e psani znaku v TTY rezimu)
	mov bl, al                            ; zaloha registru AL do BL
	shr al, 4                             ; deleni 16ti
	call pis16_registr_preved_znak        ; volani vypisu jednoho znaku
	int 0x10                              ; volani video sluby BIOSu
	mov al, bl                            ; obnova registru AL z BL
	and al,0xf
	call pis16_registr_preved_znak        ; volani vypisu jednoho znaku
	int 0x10                              ; volani video sluby BIOSu
pis16_registr_konec:
	popa                                  ; obnova vsech registru
	ret                                   ; ukonceni podprogramu vypisu v 16tibitovem rezimu
pis16_registr_preved_znak:
	add al,0x30                           ; posun do oblasi ASCII cislic
	cmp al,0x3A                           ; pokud znak je cislice
	jl pis16_registr_preved_znak_konec   ; neni treba provadet upravy
	add al,7                              ; posun do oblasti ASCII znaku
pis16_registr_preved_znak_konec:
	ret

%define pocet_registru 8
; funkce pis16_registry - vypis obsahu vsech registru
; zadne parametry ani vystupy
pis16_registry:
	pusha ; pro zachovani stavu registru
	pusha ;ax, cx, dx, bx, sp, bp, si, di <- vrchol zasobniku (pro postupny vypis)
	jc nastav_carry ; zaznamenani CF, predchozi instrukce pusha jej nezměni
	xor dx, dx 
pokracuj: 	
	mov bx, pocet_registru
	mov ax, pis16_registry_zprava
	call pis16
	mov ax, pis16_carry_flag
	call pis16
        mov ax, dx
	call pis16_registr 
	mov cx, pis16_registry_texty
pis16_registry_smycka:
	mov ax,cx
	call pis16
	add cx,7 ;zvyseni adresy na dalsi polozku
	pop ax;
	ror ax,8
	call pis16_registr
	rol ax,8
	call pis16_registr	
	dec bl	
	jne pis16_registry_smycka
	mov ax, pis16_registry_odradkovani
	call pis16
	popa
	ret
nastav_carry:
	xor dx, dx
	or dl, 0x01
	jmp pokracuj

pis16_registry_texty: db 10,13,"di: ",0,10,13,"si: ",0,10,13,"bp: ",0,10,13,"sp: ",0,10,13,"bx: ",0,10,13,"dx: ",0,10,13,"cx: ",0,10,13,"ax: " ,0
pis16_registry_zprava:
	db "Vypis registru:", 0
pis16_carry_flag
	db 10, 13, "Carry Flag:", 0
pis16_registry_odradkovani:
	db 10, 13, 0

