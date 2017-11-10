; 1. soubor = failos.txt
db "failos  "	; nazev souboru (max 8b)
db "txt"		; pripona (3b)
db 0			; atributy souboru (1b)
times 10 db 0xab	; rezervovano (10b)
dw 0			; cas vytvoreni, nebo posledniho updatu (2b)
dw 0			; datum vytvoreni, nebo posledniho updatu (2b)
dw 2			; cislo prvniho clusteru s obsahem souboru
db 0,0,0,0			; vleikost souboru

; 2. soubor = w10sucks.txt
db "w10sucks"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 3
db 0,0,0,0x80

; 3. soubor = linus.txt
db "linux   "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 4
db 0,0,0,0xc0

; 4. soubor = epicfile.txt
db "epicfile"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 5
db 0,0,1,0x40

; 5. soubor = doom.txt
db "doom    "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 6
db 0,0,1,0xa0

; 6. soubor = i386<3.txt
db "i386<3  "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 7
db 0,0,1,0xc0

; 7. soubor = asm4ever.txt
db "asm4ever"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 8
db 0,0,3,0

; 8. soubor = slack.txt
db "slack   "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 9
dd 0

; 9. soubor = minecraf.txt
db "minecraf"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 10
dd 0

; 10. soubor = h8google.txt
db "h8google"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 11
dd 0

; 11. soubor = random.txt
db "random  "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 12
dd 0

; 12. soubor = ascii.txt
db "ascii   "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 13
dd 0

; 13. soubor = asm4ever.txt
db "asm4ever"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 14
dd 0

; 14. soubor = makefile.txt
db "makefile"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 15
dd 0

; 15. soubor = devzero.txt
db "devzero "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 16
dd 0

; 16. soubor = pepe.txt
db "pepe    "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 17
db 0,0,0,0xff
