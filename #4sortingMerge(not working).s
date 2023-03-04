valori:                             ;inserire i valori tramite comando DB
    db 5
    db 1
    ;db 3
    ;db 2
    ;db 1
ultimoVal: db 4

def stampaVett {
    mov cx, 0                       ;azzera
    mov ax, 0                       ;azzera
    mov al, offset ultimoVal        ;copia in AL il punto dove si trova memorizzata l'ultima cifra
    mov si, ax                      ;copia in SI il valore
    mov sp, 0x0FFF                  ;muovi lo stack pointer in un punto remoto dello stack (ipoteticamente vuoto)
    
    copiaOffsetASCII:               ;etichetta per copiare il valore per la stampa tutta su una riga
        mov bh, byte[si]            ;copia in bl il valore presente nella cella indicata da si
        add bh, 48                  ;incrementa con l'offset di 0 (ASCII)(scrivere nella parte H e' importante, infatti si ottiene sovrascrittura dei dati precendenti)
        push bx                     ;pusha nello stack (al contrario, le cifre devono essere stampate in ordine corretto)
        inc sp                      ;aggiungi 1 a SP, in quanto di muove di 2 alla volta
        dec si                      ;decrementa SI per passare alla cifra successiva
        inc cl                      ;incrementa CL (così da rientrare nel numero corretto di caratteri)
        cmp cl, al                  ;confronta se ci sono ancora caratteri da pushare
        jbe copiaOffsetASCII        ;se ce ne sono (minore uguale) torna a pushare
        
    stampaNumero:                   ;finiti i caratteri, prendere i caratteri per la stampa
        mov ax, 0                   ;azzera
        mov bx, 0                   ;azzera
        mov cx, offset ultimoVal    ;azzera
        inc cx                      ;aumenta di 1 (ottengo n. caratteri effettivo in quanto l'offset parte da 0 e non da 1)
        mov dx, 0                   ;azzera
        mov bp, sp                  ;copiare il valore di sp in bp (punto da cui iniziare la stampa)
        mov es, bx                  ;azzera es
        mov dl, 0                   ;punto da cui iniziare a stampare (la colonna di stampa, aka quanti caratteri "saltare" graficamente)
        mov ah, 0x13                ;indicatore per stampa
        int 0x10                    ;stampa la stringa
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

def merge {                         ;funzione che "fonde" i due pezzi di "vettore"
    pop ax                          ;estrae inizio e mezzo
    pop bx                          ;muove in mezzo il divisore
    mov byte[0x0c00], al            ;copia il mezzo in dimensione del vettore sinistro
    sub byte[0x0c00], ah            ;sottrae l'inizio
    inc byte[0x0c00]                ;calcola la dimensione sinistra definitiva
    mov byte[0x0d00], bh            ;muove la fine
    sub byte[0x0d00], al            ;sottrae il mezzo
    mov cx, 0                       ;azzera
    
    cicloSx:                        ;copia del vettore temporaneo
        mov si, 0x0400              ;muove i'indice per la copia
        mov bp, 0                   ;azzera
        mov byte[0x0E00], ch        ;copia temporaneamente
        mov byte[0x0E04], ah        ;muovi ah in un luogo leggermente diverso
        add si, word[0x0E00]        ;somma il valore del contatore a si
        add bp, word[0x0E00]        ;somma il contatore
        add bp, word[0x0E04]        ;somma l'inizio
        mov bl, 0                   ;si usa il registro bp come temporaneo, dato che non viene usato
        mov bl, byte[bp]            ;copiare il valore di memoria puntato da bp in bl
        mov byte[si], bl            ;copiare il conseguente valore nell'indirizzo indicato da si
        inc ch
        cmp ch, byte[0x0c00]        ;confronta contatore e limite
        jb cicloSx                  ;se minore, torna a spostare
    
    cicloDx:
        mov si, 0x0500              ;muove i'indice per la copia
        mov bp, 0                   ;azzera
        mov byte[0x0E00], cl        ;copia temporaneamente
        mov byte[0x0E04], al        ;muovi ah in un luogo leggermente diverso
        add si, word[0x0E00]        ;somma il valore del contatore a si
        add bp, word[0x0E00]        ;somma il contatore
        add bp, word[0x0E04]        ;somma l'inizio
        inc bp                      ;incrementa per ottenere la posizione corretta
        mov bl, 0                   ;si usa il registro bp come temporaneo, dato che non viene usato
        mov bl, byte[bp]            ;copiare il valore di memoria puntato da bp in bl
        mov byte[si], bl            ;copiare il conseguente valore nell'indirizzo indicato da si
        inc cl
        cmp cl, byte[0x0d00]        ;confronta contatore e limite
        jb cicloDx                  ;se minore, torna a spostare
        
    mov cx, 0                       ;azzera per i prossimi contatori
    mov bl, 0                       ;azzera
    mov dx, 0                       ;azzera per usare dh come temporaneo
    mov di, 0
    condiz1While1:
        cmp ch, byte[0x0c00]        ;confronta contatore e dimensioni
        jb condiz2While1           ;se minore, continua
        jmp fuoriWhile1             ;altrimenti esci
        
        condiz2While1:
            cmp cl, byte[0x0d00]    ;confronta contatore e dimensioni
            jb while1              ;se minore, entra nel ciclo
            jmp fuoriWhile1         ;altrimenti, esci
            
        while1:
            mov si, 0x0400          ;copio il valore del puntatore al primo vettore
            mov byte[0x0E00], ch    ;copia temporaneamente
            add si, word[0x0E00]    ;aggiungi il valore del contatore
            mov bp, 0x0500          ;copio il valore del puntatore al secondo vettore
            mov byte[0x0E04], cl    ;copia temporaneamente
            add bp, word[0x0E04]    ;aggiungi il valore del secondo contatore
            mov bl, 0               ;azzera
            mov bl, byte[bp]        ;muovi temporaneamente
            cmp byte[si], bl        ;confronta i valori dei vettori
            jbe if1
            jmp else1
            
            if1:
                mov byte[0x0E08], dh;dh è il valore dell'indice del vettore originale
                mov si, 0           ;azzera
                add si, word[0x0E08];copia l'indice
                mov bp, 0x0400      ;copia l'indirizzo di origine del primo vettore
                mov byte[0x0E04], ch;copia temporaneamente
                add bp, word[0x0E04];aggiungi il contatore definitivamente
                mov dl, 0           ;azzera
                mov dl, byte[bp]    ;copia temporaneamente
                mov byte[si], dl    ;copia definitivamente
                inc dh              ;aumenta indice vettore originale
                inc ch              ;aumenta indice del primo vettore
                jmp after1          ;esci dall'if
                
            else1:
                mov byte[0x0E08], dh;dh è il valore dell'indice del vettore originale
                mov si, 0           ;azzera
                add si, word[0x0E08];copia l'indice
                mov bp, 0x0500      ;copia l'indirizzo di origine del secondo vettore
                mov byte[0x0E04], cl;copia temporaneamente
                add bp, word[0x0E04];aggiungi il contatore definitivamente
                mov dl, 0           ;azzera
                mov dl, byte[bp]    ;copia temporaneamente
                mov byte[si], dl    ;copia definitivamente
                inc dh              ;aumenta indice vettore originale
                inc cl              ;aumenta indice del secondo vettore
                jmp after1          ;esci dall'else
                
            after1:                 ;etichetta per l'uscita dalla selezione
                jmp condiz1While1   ;torna nel ciclo a verificare
            
    fuoriWhile1:                    ;etichetta per l'uscita dal ciclo
    
    cmp ch, byte[0x0c00]
    jae condiz1While2
    jmp else2
    
    condiz1While2:
        cmp cl, byte[0x0d00]
        jb while2
        jmp fuoriWhile2
        
        while2:
            mov byte[0x0E08], dh;   dh è il valore dell'indice del vettore originale
            mov si, 0               ;azzera
            add si, word[0x0E08]    ;copia l'indice
            mov bp, 0x0500          ;copia l'offset del secondo vettore
            mov byte[0x0E04], cl    ;copia temporaneamente
            add bp, word[0x0E04]    ;aggiungi il contatore definitivamente
            mov dl, byte[bp]        ;copia temporaneamente
            mov byte[si], dl        ;copia definitivamente
            inc cl                  ;incremento il contatore del secondo vettore
            inc dh                  ;incremento il contatore del vettore originale
            jmp condiz1While2       ;torna
    
    else2:
        cmp cl, byte[0x0d00]        ;controlla se è stato l'altro vettore a terminare
        jae condiz1While3           ;se lo è stato, aggrega
        jmp fuoriWhile2             ;altrimenti esci
        
        condiz1While3:
            cmp ch, byte[0x0c00]
            jb while3
            jmp fuoriWhile2
            
            while3:
                mov byte[0x0E08], dh;dh è il valore dell'indice del vettore originale
                mov si, 0           ;azzera
                add si, word[0x0E08];copia l'indice
                mov bp, 0x0400      ;copia l'offset del primo vettore
                mov byte[0x0E04], ch;copia temporaneamente
                add bp, word[0x0E04];aggiungi il contatore definitivamente
                mov dl, byte[bp]    ;copia temporaneamente
                mov byte[si], dl    ;copia definitivamente
                inc ch              ;incremento il contatore del primo vettore
                inc dh              ;incremento il contatore del vettore originale
                jmp condiz1While2   ;torna
                
    fuoriWhile2:
}

def mergeSort {
    pop ax
    pop bx
    mov al, 0
    mov byte[0x0600], ah
    mov byte[0x0601], bh
    add al, byte[0x0600]
    add al, byte[0x0601]
    mov ah, 0
    mov byte[0x0602], 2
    div byte[0x0602]
    mov byte[0x0603], al
    mov ah, 0
    mov ah, byte[0x0600]
    mov bh, byte[0x0601]
    cmp ah, bh
    jb chiamate
    jmp dopoChiamate
    
    chiamate:
        mov ah, byte[0x0600]
        mov bh, byte[0x0603]
        mov al, 0
        mov bl, 0
        push bx
        push ax
        push bx
        push ax
        call mergeSort
        
        mov al, 0
        mov ah, byte[0x0603]
        inc ah
        mov bh, byte[0x601]
        mov bl, 0
        push bx
        push ax
        push bx
        push ax
        call mergeSort
        
        mov ah, byte[0x0600]
        mov al, byte[0x0603]
        mov bh, byte[0x0601]
        mov bl, 0
        push bx
        push ax
        push bx
        push ax
        call merge
    
    dopoChiamate:
}

start:
    mov ax, 0
    mov bx, 0
    mov bh, offset ultimoVal
    inc bh
    push bx
    push ax
    call mergeSort
    call stampaVett
    

end: