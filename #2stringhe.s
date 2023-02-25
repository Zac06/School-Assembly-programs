db "abc)cd"                     ;inserire la stringa da analizzare prima del segno del dollaro

;DH CONTIENE IL NUMERO DI DOPPIE PRIMA DELLA STAMPA DI MESSAGGI

def contaDoppie {
    cmp bh, bl
    jne nullo
    inc dh
    nullo:
}

start:
    inserisciStringaErrore:     ;inserimento di un messaggio di errore in memoria
        mov sp, 0x46
        mov bx, 0
        mov bx, 0x6572
        push bx
        mov bx, 0x6f72
        push bx
        mov bx, 0x7265
        push bx
        mov bx, 0
    
    mov cx, 0                       ;azzera
    mov sp, 0                       ;azzera

    estrai:
        inc cx
        pop bx                      ;estrai la lettera dallo stack
        call contaDoppie
        dec sp                      ;decremento sp di 1 per scalare una lettera una a una anzichè due a due
        jmp confrontoZero           ;controlla se la lettera è nulla
        
    inserisciStackStampa:
        mov bx, 0                   ;azzera
        mov bx, 10                  ;inserisco la base con cui memorizzare le singole cifre del numero da stampare
        mov ah, 0                   ;azzero il resto
        div bl                      ;divido il quoziente per bl (la base)
        mov dx, 0                   ;azzera
        mov dl, ah                  ;muovo il resto in dl
        push dx                     ;inserisco il resto nello stack (conversione in base decimale con le singole cifre)
        cmp al, 0                   ;confronta il quoziente con 0
        jne inserisciStackStampa    ;se c'è ancora numero da inserire, continua a inserirlo
        pop dx                      ;estraggo la prima cifra
        jmp stampaNumero
        
    stampaNumero:
        add dx, 48                  ;aumento il numero per ottenere il corrispettivo ascii (0 è 48 in ascii)
        mov ah, 2                   ;istruzione per int 0x21
        int 0x21                    ;stampa il numero il dx
        mov dx, 0                   ;azzera
        pop dx                      ;estrai la msb del numero (cifra più significativa) dallo stack
        cmp dx,0                    ;controllo se la cifra seguente estratta è uguale a 0
        jne stampaNumero            ;se ci sono ancora cifre, torna a stampare
        jmp end
    
    confrontoZero:
        cmp bl, 0                   ;confronta se il carattere estratto è nullo
        jne confrontoSpazio
        mov sp, 0x80                ;setto sp alla fine della memoria per evitare sovrapposizioni con altri valori
        dec cx                      ;decrementa il contatore che ha un eccesso di 1
        mov ax, cx                  ;inserisco il numero in ax per la divisione
        jmp inserisciStackStampa    ;memorizza i numeri per la stampa
    
    confrontoSpazio:
        cmp bl, 32                  ;confronta se il carattere estratto è uno spazio
        jne confrontoMaiuscoleMinore    ;se non è uno spazio, controlla che non sia maiuscolo
        jmp estrai                  ;altrimenti è uno spazio (valido) e passa al prossimo carattere
    
    confrontoMaiuscoleMinore:
        cmp bl, 65                  ;confronta con A maiuscola
        jae confrontoMaiuscoleMaggiore  ;se è maggiore della A maiuscola, controlla che sia minore della Z maiuscola
        jmp stampaErrore1                     ;altrimenti termina
    
    confrontoMaiuscoleMaggiore:
        cmp bl, 90                  ;confronta con Z maiuscola
        jbe estrai                  ;se è minore di Z, passa al prossimo
        jmp confrontoMinuscoleMinore    ;altrimenti controlla che non sia minuscolo
    
    confrontoMinuscoleMinore:
        cmp bl, 97                  ;confronta con a minuscola
        jae confrontoMinuscoleMaggiore  ;se maggiore di a minuscola, controlla che sia minore di z minuscola
        jmp stampaErrore1                     ;altrimenti termina
    
    confrontoMinuscoleMaggiore:
        cmp bl, 122                 ;confronta con z minuscola
        jbe estrai                  ;se minore di z minuscola, passa al prossimo carattere
        jmp stampaErrore1                     ;altrimenti termina

    stampaErrore1:
        mov ax, 0x0
        mov cx, 0x0
        mov dx, 0x0
        mov ah, 0x13        ;setto codice esad.
        mov cx, 0x6         ;setto lunghezzo stringa da stampare
        mov bx, 0x0
        mov es, bx
        mov bx, 0x40         ;inserire punto della stringa da cui partire
        mov bp, bx          ;punto da cui parte la stampa
        mov dl, 0x0         ;colonna da stampare
        int 0x10            ;stampa
        jmp end
    
end: