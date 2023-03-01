valori:
    db 0x12
    db 0x34
    db 0x10
    db 0x13
    db 0x9b
    db 0x65
    db 0xc5
    db 0x73
    db 0x82
    db 0x11
    db 0x84
    db 0x36
ultimo: db 0x69     ;ultimo valore del array di numeri

start:
    mov cx, 0               ;azzera il contatore
    mov si, 0               ;azzera il puntatore
    mov dh, offset ultimo   ;muovi la posizione (numero di elementi) dell'ultimo elemento in dh
    dec dh                  ;decrementa dh (ciclo esterno exchange sort)
    mov dl, offset ultimo   ;muovi la posizione (numero di elementi) dell'ultimo elemento in dh
    cicloEst:
        mov cl, ch          ;muovi in cl il contatore del ciclo esterno
        inc cl
    ciclo:
        mov bx, 0           ;azzera i valori
        mov ax, 0
        mov al, ch
        mov si, ax          ;muovi nel puntatore 
        mov bh, byte [si]   ;estrai il valore puntato dal ciclo esterno
        mov ax, 0
        mov al, cl
        mov si, ax          ;muovi nel puntatore
        mov bl, byte [si]   ;estrai il valore puntato dal ciclo interno
        cmp bh, bl
        ja scambia
        jmp continua
        scambia:
            mov ax, 0
            mov al, bh
            mov bh, bl
            mov bl, al
            mov ax, 0
            mov al, ch
            mov si, ax
            mov byte [si], bh
            mov ax, 0
            mov al, cl
            mov si, ax
            mov byte [si], bl
        continua:
            inc cl          ;incrementa cl (i+1)
            cmp cl, dl
            jbe ciclo
            inc ch
            cmp ch, dh
            jbe cicloEst
            jmp end
end:
