; pomocne funkce pro vypis textu na obrazovku
; dostupne funkce: pis32, pis16,

; funkce pis32, pise text v 32bitovem chranenem rezimu
; obrazovka ma 80 sloupcu a 25 radek, kazdy znak ma 2 bajty (1. bajt znak, 2. bajt vzhled (barvy...))
; text, ktery je zobrazen na obrazovce se mapuje do pameti (0xb8000 - 0xb8fa0)
; => EAX - adresa zpravy
; => EBX - pozice (napr 0)
; => ECX - barvy (napr 0x0f)
; <= EBX - pozice dalsi radky (tato funkce lze volat opakovane, pokud se nebude jinde upravovat EBX)
pis32:
	push edx  ; ulozeni registru EDX na zasobnik
	push ecx  ; ulozeni registru ECX na zasobnik
	push eax  ; ulozeni registru EAX na zasobnik
	push ebx  ; ulozeni registru EBX na zasobnik
pis32_smycka:
	mov cl, [eax]        ; nacteni ASCII znaku z retezce, na ktery ukazuje EAX
	cmp cl, 0            ; porovnani na konec retezce
	je pis32_konec       ; ukonceni, pokud je konec retezce
	cmp cl, 0xa          ; porovnani na odradkovani
	je pis32_rekurzivne  ; provede rekurzivni vypis dalsi radky
	cmp ebx, 0xfa0       ; zjisteni, zda-li se text jeste vejde na obrazovku (80 sloupcu*25 radek*2 bajty na znak=4000 bajtu=0xfa0 bajtu)
	jl pis32_pokracuj    ; pokud ano, napis radku
	call pis32_posun     ; jinak posun text o jeden radek vzhuru
pis32_pokracuj:
	mov [ebx+0xb8000], cx  ; vypsani znaku na obrazovku na aktualni pozici
	add ebx,2              ; posun na dalsi znak (2ka -> 2 bajty na znak)
	inc eax                ; zvyseni indexu znaku v retezci
	jmp pis32_smycka       ; psani dalsiho znaku
pis32_konec:
	pop ebx         ; obnova registru EBX ze zasobniku
	                ; v nasledujicich radkach probehne vypocet EBX, aby ukazoval na dalsi radek
	mov eax, ebx    ; kopirovani EAX do EBX (EAX je jako pomocny registr, bude nasledne obnoven)
	mov ecx, 0xa0   ; nastaveni 0xa0 (pamet potrebna pro jeden radek textu) do ECX (ECX bude obnoven)
	div ecx         ; vydeleni EAX/ECX
	sub ebx, edx    ; odecteni zbytku po deleni (EDX = EAX % ECX) od EBX -> posun na pevnou pozici dane radky
	add ebx, 0x120  ; pricteni konstanty 0x120, ktera posune na zacatek nasledujici radky
	                ; nyni je EBX nastaven na zacatek dalsi radky
	pop eax         ; obnova registru EAX ze zasobniku
	pop ecx         ; obnova registru ECX ze zasobniku
	pop edx         ; obnova registru EDX ze zasobniku
	ret             ; ukonceni podprogramu
pis32_rekurzivne:
	pop ebx         ; obnova pozice vypisovaneho textu (registru EBX) ze zasobniku
	push eax        ; ulozeni adresy retezce (registru EAX) na zasobnik
	                ; v nasledujicich radkach probehne vypocet EBX, aby ukazoval na dalsi radek (jiz okomentovano vyse o priblizne 14 radek)
	mov eax, ebx
	mov ecx, 0xa0
	div ecx
	sub ebx, edx
	add ebx, 0x120
	pop eax
	inc eax         ; zvyseni EAX o jedna (preskoceni znaku konce radky)
	pop ecx
	pop ecx
	pop edx
	call pis32      ; rekurzivni volani vypisu
	ret             ; ukonceni tohoto podprogramu
pis32_posun:
	pusha              ; ulozeni vsech registru na zasobnik
	mov eax, 0xb8000   ; nastaveni EAX na adresu pocatku "zobrazovane pameti"
pis32_posun_smycka:
	cmp eax, 0xb8f00               ; porovnani EAX na konec predposleni radky (na jakoukoliv pozici 0xb8000 - 0xb8f00 \
	                               ; se bude presouvat pamet o radku dale)
	jge pis32_posun_posledni_radek ; pokud jiz v teto oblasti nejsme (jsme na zacatku dalsi radky), probehne skok
	mov bx,[eax+0xa0]              ; ulozeni hodnoty o radku dale do registru BX
	mov [eax],bx                   ; vlozeni hodnoty z BX (o radku dale) na aktualni radku
	add eax,2                      ; prechod na dalsi 16bitovou hodnotu pameti
	jmp pis32_posun_smycka         ; opakovani
pis32_posun_posledni_radek:
	cmp eax, 0xb8fa0               ; porovnani EAX na konec posledni radky (konec zobrazovane pameti)
	jge pis32_posun_konec          ; pokud jiz v pameti nejsme, ukoncime posun
	mov word [eax],0               ; vynulovani bunky (posledni radka je vzdy prazdna, kdyz dochazi k posuvu)
	add eax,2                      ; prechod na dalsi 16bitovou hodnotu pameti
	jmp pis32_posun_posledni_radek ; opakovani
pis32_posun_konec:
	popa             ; obnova vsech registru ze zasobniku
	mov ebx, 0xf00   ; nastaveni pozice vypisu (EBX) na zacatek posledni radky
	ret              ; ukonceni podprogramu posuvu

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

