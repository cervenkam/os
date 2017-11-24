; Zapise jeden sektor (512 bajtu) na disk
; => CX Index sektoru na disku
; => ES:BX Adresa, odkud se bude zapisovat na disk
zapis_sektoru_na_disk:
	pusha             ; ulozeni vsech registru na zasobnik
	mov ax, 0x0301    ; sluzba zapisu na disk (0x03), zapis jednoho sektoru (0x01)
	xor ch, ch        ; cylindr = 0
	mov dx, 0x0081    ; prvni hlava (0x00) z druheho disku (0x81)
	int 0x13          ; volani sluzeb BIOSu
	popa              ; obnova registru ze zasobniku
	ret               ; navrat z podprogramu
; Precte jeden sektor (512 bajtu) z disku
; => CX Index sektoru na disku
; => ES:BX Adresa, kam se bude zapisovat z disku
cteni_sektoru_z_disku:
	pusha             ; ulozeni vsech registru na zasobnik
	mov ax, 0x0201    ; sluzba cteni z disku (0x03), cteni jednoho sektoru (0x01)
	xor ch, ch        ; cylindr = 0
	mov dx, 0x0081    ; prvni hlava (0x00) z druheho disku (0x81)
	int 0x13          ; volani sluzeb BIOSu
	popa              ; obnova registru ze zasobniku
	ret               ; navrat z podprogramu
