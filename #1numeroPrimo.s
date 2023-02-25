stringa: db "PrimoNon primo"

start:
;inserimento di numero nello stack
    mov sp, 0x40    ;inizio lo stack da 0x40
    mov bx, 0   ;azzero bx
    mov bx, 19  ;inserisco il numero in bx
    push bx     ;inserisco il numero nello stack
    
    mov bx, 0   ;azzera
    pop bx      ;estrae il numero da analizzare
    mov cx, 2   ;inizializza il contatore a 2
    
    mov ax, bx  ;mettere il numero in ax
    div cl  ;divisione per 2
    mov dl, al  ;muovere il risultato in dl
    
verificaPrimo:
    cmp cl, dl  ;verifico se il contatore è inferiore al numero/2
    jbe verificaPrimo2  ;se diverso verifica primo
    jmp stampaPrimo     ;altrimenti stampa che è primo
    
verificaPrimo2:
    mov ax, bx      ;rimetto il numero originale in ax
    div cl      ;divido per il contatore
    add cl, 1   ;incremento il contatore
    
    cmp ah, 0   ;ritorna a verificare se il resto è diverso da 0
    jne verificaPrimo   ;se diverso da 0, torna a dividere
    jmp stampaNonprimo  ;altrimenti, stampa che non è primo
    

stampaNonprimo:
    mov ax, 0   ;azzera
    mov cx, 0   ;azzera
    mov dx, 0   ;azzera
    mov ah, 0x13    ;setto codice esad.
    mov cx, 9   ;setto lunghezzo stringa da stampare
    mov bx, 0   ;azzera
    mov es, bx;azzero es
    mov bx, 5   ;inserire punto della stringa da cui partire
    mov bp, bx  ;punto da cui parte la stampa
    mov dl, 0   ;colonna da stampare
    int 0x10    ;stampa
    jmp end     ;termina

stampaPrimo:
    mov ax, 0   ;azzera
    mov cx, 0   ;azzera
    mov dx, 0   ;azzera
    mov ah, 0x13    ;setto codice esad.
    mov cx, 5   ;setto lunghezzo stringa da stampare
    mov bx, 0   ;azzera
    mov es, bx  ;azzero es
    mov bx, 0   ;inserire punto della stringa da cui partire
    mov bp, bx  ;punto da cui parte la stampa
    mov dl, 0   ;colonna da stampare
    int 0x10    ;stampa
    jmp end     ;termina

end:    ;funzione per terminare senza passare per il resto