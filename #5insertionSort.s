valori:                             		;inserire i valori tramite comando DB
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

def scambia {                       		;procedura che scambia byte[bp] e byte[bp+1]
    mov ax, 0                       		;azzera
    mov al, byte[bp]                		;uso al come registro temporaneo
    inc bp                          		;incrementa bp per puntare al valore successivo
    mov ah, byte[bp]                		;uso ah come registro temporaneo
    mov byte[bp], al                		;muovo il valore del registro precedente
    dec bp                          		;riporta bp alla posizione originale
    mov byte[bp], ah                		;muovi il valore del secondo nel primo
}

def sort {                          		;procedura che applica l'insertion sort
    mov si, 1                       		;inizializza a 1 il puntatore
    mov bp, 0                       		;azzera
    
    condizFor:                      		;ciclo esterno dell'ordinamento
        cmp si, word[0x0ffe]        		;confronta il puntatore con il valore in posizione 0x0ffe, dove si trova la dimensione del vettore
        jb cicloFor
        jmp fuoriFor
        
        cicloFor:
            mov bh, byte[si]        		;copia il valore di confronto
            mov bp, si              		;muovi il primo contatore nel secondo
            dec bp                  		;decrementa il secondo contatore
        
            condiz1While:
                cmp bp, 0           		;confronto il contatore con 0
                jae condiz2While    		;se maggiore o uguale, verifica la seconda condizione
                jmp fuoriWhile      		;altrimenti torna al ciclo esterno
                
            condiz2While:
                cmp byte[bp], bh    		;confronta il valore con quello di confronto
                ja while            		;se maggiore, entra nel ciclo
                jmp fuoriWhile      		;altrimenti torna al ciclo esterno
                    
                    while:          		;ciclo interno
                        call scambia		;scambia i valori di bp e bp+1
                        dec bp      		;decrementa il secondo contatore
                        jmp condiz1While	;esci dal while
                        
        fuoriWhile:
            inc si                  		;incrementa il primo contatore
            jmp condizFor           		;torna a verificare la condizione del ciclo esterno
        
    fuoriFor:
    
}

start:
    mov byte[0x0ffe], offset ultimoVal  	;muovi in un punto remoto della memoria (vuoto) il valore della posizione dell'ultimo valore
    inc byte[0x0ffe]                    	;incrementa così da ottenere un valore corretto (dimensione effettiva)
    call sort                           	;ordina il vettore

end:                                    	;fine