; nazvy - cheat kody z DOOM / DOOM2
; 1. soubor
db "iddqd   "      ; nazev souboru (max 8b)
db "txt"           ; pripona (3b)
db 0               ; atributy souboru (1b)
times 10 db 0      ; rezervovano (10b)
dw 0               ; cas vytvoreni, nebo posledniho updatu (2b)
dw 0               ; datum vytvoreni, nebo posledniho updatu (2b)
dw 2               ; cislo prvniho clusteru s obsahem souboru
dd 0               ; vleikost souboru

; 2. soubor
db "idkfa   "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 3
dd 0

; 3. soubor
db "idclip  "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 4
dd 0

; 4. soubor
db "idclev31"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 5
dd 0

; 5. soubor
db "iddt    "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 6
dd 0

; 6. soubor
db "idmypos "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 7
dd 0

; 7. soubor
db "idmus13 "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 8
dd 0

; 8. soubor
db "idchoprs"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 9
dd 0

; 9. soubor
db "idbholdr"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 10
dd 0

; 10. soubor
db "idbholdi"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 11
dd 0

; 11. soubor
db "idbholdv"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 12
dd 0

; 12. soubor
db "idbholda"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 13
dd 0

; 13. soubor
db "idbholdl"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 14
dd 0

; 14. soubor
db "idbholds"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 15
dd 0

; 15. soubor
db "idspsppd"
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 16
dd 0

; 16. soubor
db "idfa    "
db "txt"
db 0
times 10 db 0
dw 0
dw 0
dw 17
dd 0
