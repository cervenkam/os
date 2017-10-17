%define HPC 16
%define SPT 63
%define HPC_SPT HPC*SPT
; Prevod linearni adresy (LBA) na adresu cylindr,hlava,sektor (CHS) dle vztahu
; C=LBA/(HPC*SPT)
; H=(LBA/SPT)%HPC
; S=(LBA%SPT)+1
; <= AX linearni adresa
; => CH cylindr
; => CL sektor
; => DH hlava
; => DL - vysledek LBA%(HPC*SPT) TODO nemel by se menit ;/
lba2chs_prevod:	
	push bx        ; ulozeni BX
	push ax        ; ulozeni linearni adresy na zasobnik
	mov bx,SPT     ; nastaveni delitele
	div bx         ; vydeleni AX/BX (provede se zaroven LBA/SPT -> AX a LBA%SPT -> DX)
	inc dx         ; zvyseni sektoru o jedna dle vzorce
	mov cl,dl      ; presun sektoru
	; sektor je v CL na spravnem miste
	mov bx,HPC     ; nastaveni delitele
	div bx         ; vydeleni -> vypocitani hlavy
	mov bl,dl      ; ulozeni hlavy do BL (zatim)
	pop ax         ; obnova linearni adresy ze zasobniku
	push ax        ; znovu ulozeni linearni adresy na zasobnik
	mov dx,HPC_SPT ; nastaveni delitele
	div dx         ; vydeleni -> vypocitani cylindru
	mov ch, al     ; ulozeni cylindru do spravneho registru CH
	mov dh,bl      ; vlozeni hlavy do spravneho registru
	pop ax         ; obnova linearni adresy ze zasobniku
	pop bx         ; obnova BX
	ret            ; navrat z podprogramu
