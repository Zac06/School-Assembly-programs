valori:                             ;inserire i valori tramite comando DB
    db 8
    db 7
    db 4
    db 2
    db 6
    db 5
    db 1
    db 9
    db 3
    db 8
    db 0
ultimoVal: db 2

messaggio:  db "Vettore originale:Vettore ordinato:"


def stampaMess1 {
        mov ax, 0                   ;azzera
        mov bx, 0                   ;azzera
        mov cx, 18                  ;inserisci a dimensione del messaggio
        mov dx, 0                   ;azzera
        mov bp, offset messaggio    ;copiare il valore del messaggio in bp (punto da cui iniziare la stampa)
        mov es, bx                  ;azzera es
        mov dl, 0                   ;punto da cui iniziare a stampare (la colonna di stampa, aka quanti caratteri "saltare" graficamente)
        mov ah, 0x13                ;indicatore per stampa
        int 0x10                    ;stampa la stringa
}

def stampaMess2 {
        mov ax, 0                   ;azzera
        mov bx, 0                   ;azzera
        mov cx, 17                  ;inserisci a dimensione del messaggio
        mov dx, 0                   ;azzera
        mov bp, offset messaggio    ;copiare il valore del messaggio in bp (punto da cui iniziare la stampa)
        add bp, 18                  ;aggiungere la dimensione del primo per ottenere il secondo
        mov es, bx                  ;azzera es
        mov dl, 0                   ;punto da cui iniziare a stampare (la colonna di stampa, aka quanti caratteri "saltare" graficamente)
        mov ah, 0x13                ;indicatore per stampa
        int 0x10                    ;stampa la stringa
}

def stampaVett {
    mov cx, 0                       ;azzera
    mov ax, 0                       ;azzera
    mov al, offset ultimoVal        ;copia in AL il punto dove si trova memorizzata l'ultima cifra
    mov si, ax                      ;copia in SI il valore
    mov sp, 0xEFFF                  ;muovi lo stack pointer in un punto remoto dello stack (ipoteticamente vuoto)
    
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
        mov cx, offset ultimoVal    ;inserisci l'offset dell'ultimo numero
        inc cx                      ;aumenta di 1 (ottengo n. caratteri effettivo in quanto l'offset parte da 0 e non da 1)
        mov dx, 0                   ;azzera
        mov bp, sp                  ;copiare il valore di sp in bp (punto da cui iniziare la stampa)
        mov es, bx                  ;azzera es
        mov dl, 4                   ;punto da cui iniziare a stampare (la colonna di stampa, aka quanti caratteri "saltare" graficamente)
        mov ah, 0x13                ;indicatore per stampa
        int 0x10                    ;stampa la stringa
}

def scambia {                       ;procedura che scambia byte[bp] e byte[bp+1]
    mov ax, 0                       ;azzera
    mov al, byte[bp]                ;uso al come registro temporaneo
    inc bp                          ;incrementa bp per puntare al valore successivo
    mov ah, byte[bp]                ;uso ah come registro temporaneo
    mov byte[bp], al                ;muovo il valore del registro precedente
    dec bp                          ;riporta bp alla posizione originale
    mov byte[bp], ah                ;muovi il valore del secondo nel primo
}

def sort {                          ;procedura che applica l'insertion sort
    mov si, 1                       ;inizializza a 1 il puntatore
    mov bp, 0                       ;azzera
    
    condizFor:                      ;ciclo esterno dell'ordinamento
        cmp si, word[0x0ffe]        ;confronta il puntatore con il valore in posizione 0x0ffe, dove si trova la dimensione del vettore
        jb cicloFor
        jmp fuoriFor
        
        cicloFor:
            mov bh, byte[si]        ;copia il valore di confronto
            mov bp, si              ;muovi il primo contatore nel secondo
            dec bp                  ;decrementa il secondo contatore
        
            condiz1While:
                cmp bp, 0           ;confronto il contatore con 0
                jae condiz2While    ;se maggiore o uguale, verifica la seconda condizione
                jmp fuoriWhile      ;altrimenti torna al ciclo esterno
                
            condiz2While:
                cmp byte[bp], bh    ;confronta il valore con quello di confronto
                ja while            ;se maggiore, entra nel ciclo
                jmp fuoriWhile      ;altrimenti torna al ciclo esterno
                    
                    while:          ;ciclo interno
                        call scambia;scambia i valori di bp e bp+1
                        dec bp      ;decrementa il secondo contatore
                        jmp condiz1While;esci dal while
                        
        fuoriWhile:
            inc si                  ;incrementa il primo contatore
            jmp condizFor           ;torna a verificare la condizione del ciclo esterno
        
    fuoriFor:
    
}

start:
    mov byte[0x0ffe], offset ultimoVal  ;muovi in un punto remoto della memoria (vuoto) il valore della posizione dell'ultimo valore
    inc byte[0x0ffe]                    ;incrementa così da ottenere un valore corretto (dimensione effettiva)
    call stampaMess1                    ;stampa "vettore originale:"
    call stampaVett                     ;stampa il vettore originale
    call sort                           ;ordina il vettore
    call stampaMess2
    call stampaVett                     ;stampa il vettore ordinato

end:                                    ;fine