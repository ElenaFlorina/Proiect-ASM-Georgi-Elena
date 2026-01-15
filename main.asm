.MODEL SMALL
.STACK 100h
.DATA
    ;Mesaje de afisare
  msg_intro DB 13, 10, 'Introduceti intre 8 si 16 octeti HEX (ex: 1A 2B 3C). Apasati ENTER:', 13, 10, '$'
  msg_err_len DB 13, 10, 'EROARE: Numarul de octeti trebuie sa fie intre 8 si 16!$', 13, 10, '$'
  msg_c       DB 13, 10, 'Cuvantul C calculat: 0x$', 13, 10, '$'
  msg_sort    DB 13, 10, 'Sirul sortat descrescator: $', 13, 10, '$'
  msg_max     DB 13, 10, 'Pozitia octetului cu cei mai multi biti de 1: $', 13, 10, '$'
  msg_rot     DB 13, 10, 'Sirul dupa rotiri: $', 13, 10, '$'
  newline     DB 13, 10, '$'
  space       DB ' $'
  prefix_hex  DB '0x$'

     ;Variabile
  buffer      DB 60, ?, 60 DUP(?) 
  sir         DB 20 DUP(0)
  sir_len     DB 0 

    ;Variabile auxiliare pentru calcule
temp_byte  DB 0    ;variabila pentru calcule intermediare
word_C     DW 0    ;cuvantul de control C
max_bits   DB 0    ;numarul maxim de biti de 1 
poz_max    DB 0    ;pozitia numarului cu cei mai multi biti de 1
curr_bits  DB 0    ;contor curent de biti
rot_count  DB 0    ;de cate ori trebuie sa rotim un numar

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX

    ;Citirea datelor
MOV AH, 09h
LEA DX, msg_intro
INT 21h

MOV AH, 0Ah
LEA DX, buffer
INT 21h

LEA SI, buffer + 2
LEA DI, sir
MOV CL, buffer + 1
MOV CH, 0
MOV sir_len, 0

loop_parse:
CMP CX, 0
JE check_len

MOV AL, [SI]
CMP AL, 0Dh
JE check_len
CMP AL, ' '
JE skip_char

CMP AL, '9'
JBE digit_1
SUB AL, 7
digit_1:
SUB AL, 30h
SHL AL, 4
MOV BL, AL

INC SI
DEC CX

MOV AL, [SI]
CMP AL, '9'
JBE digit_2
SUB AL, 7
digit_2:
SUB AL, 30h
OR BL, AL

MOV [DI], BL
INC DI
INC sir_len

skip_char:
INC SI
DEC CX
JMP loop_parse

check_len:
CMP sir_len, 8
JB eroare
CMP sir_len, 16
JA eroare
JMP start_calcul

eroare:
MOV AH, 09h
LEA DX, msg_err_len
INT 21h
JMP final_program

    ;Calcul cuvant C
start_calcul:

    ;Pasul 1:xor intre primul octet si ultimul octet

    LEA SI, sir    ;luam adresa primului numar din sir
    MOV AL, [SI]   ;copiem primul numar din sir in registrul AL
    SHR AL, 4      ;izolam prima cifra hexa a numarului

    ;Gasim utimul numar
    MOV BL, sir_len
    MOV BH, 0
    DEC BX

    MOV DL, sir[BX]    ;luam ultimul octet
    AND DL, 0Fh        ;pastram doar bitii 3-0

    XOR AL, DL        
    MOV temp_byte, AL    ;salvam rezultatul partial

    ;Pasul 2:OR intre bitii din mijloc ai tuturor octetilor

    MOV CL, sir_len    
    MOV CH, 0

    LEA SI, sir    
    MOV BL, 0    ;aici vom acumula rezultatul OR

loop_or:
    MOV AL, [SI]

    SHR AL, 2    ;dorim bitii de la mijloc ca sa ii izolam ii mutam la dreapta cu 2 pozitii
    AND AL, 0Fh  ;izolam doar cei 4 biti doriti
    OR BL, AL    ;facem or cu ce am acumulat pana acum
    INC SI
    LOOP loop_or

    SHL BL, 4    ;mutam rezultatul pe pozitiile superioare 
    OR temp_byte, BL    ;combinam rezultatul xor cu rezultatul or

    ;Pasul 3:Suma tuturor octetilor modulo 256

    MOV CL, sir_len
    MOV CH, 0
    LEA SI, sir



    MOV AX, 0    ;in AX vom strange suma
loop_sum:
    MOV BL, [SI]    ;luam octetul
    MOV BH, 0

    ADD AX, BX    ;adunam la total

    INC SI
    LOOP loop_sum

    ;Compunere cuvant C

    MOV AH, AL    ;mutam suma in partea de sus
    MOV AL, temp_byte    ;mutam logica in partea de jos
    MOV word_C, AX    

    ;Afisam cuvantul C

    MOV AH, 09h
    LEA DX, msg_c
    INT 21h

    ;Convertim din hexazecimal in ascii

    ;Afisare primul octet

    MOV AL, BYTE PTR word_C + 1    ;luam octetul superior
    MOV BL, AL                     ;copie in BL pentru a nu pierde numarul original
    SHR AL, 4                      ;luam prima cifra hexa

    CMP AL, 9                      
    JBE c_h1
    ADD AL, 7    
c_h1: ADD AL, 30h        ;facem caracter ASCII
    MOV DL, AL           ;mutam caracterul calculat in DL

    MOV AH, 02h    ;functia dos pt afisare caractere
    INT 21h

    ;Extragem cea de-a doua cifra

    MOV AL, BL            ;aducem valoarea originala din copia salvata
    AND AL, 0Fh           ;luam a doua cifra hexa

    CMP AL, 9
    JBE c_h2
    ADD AL, 7

c_h2: ADD AL, 30h    ;Facem caracter ascii

    MOV DL, AL       ;mutam caracterul calculat in DL
    MOV AH, 02h
    INT 21h

    ;Afisare al doilea octet

    MOV AL, BYTE PTR word_C
    MOV BL, AL
    SHR AL, 4
    CMP AL, 9
    JBE c_l1
    ADD AL, 7
c_l1: ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV AL, BL
    AND AL, 0Fh
    CMP AL, 9
    JBE c_l2
    ADD AL, 7
c_l2: ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h

        ;Sortare descrescatoare
    MOV CL, sir_len
    DEC CL
outer_sort:
    MOV CH, CL
    LEA SI, sir
inner_sort:
    MOV AL, [SI]
    MOV BL, [SI+1]
    CMP AL, BL
    JAE no_swap

    MOV [SI], BL
    MOV [SI+1], AL
no_swap:
    INC SI
    DEC CH
    JNZ inner_sort

    DEC CL
    JNZ outer_sort

    MOV AH, 09h
    LEA DX, msg_sort
    INT 21h
    MOV AH, 09h
    LEA DX, newline
    INT 21h

    MOV CL, sir_len
    MOV CH, 0
    LEA SI, sir
print_loop_1:
    MOV AL, [SI]

    MOV BL, AL
    SHR AL, 4
    CMP AL, 9
    JBE p1_1
    ADD AL, 7
p1_1: ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV AL, BL
    AND AL, 0Fh
    CMP AL, 9
    JBE p1_2
    ADD AL, 7
p1_2: ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV DL, ' '
    INT 21h
    INC SI
    LOOP print_loop_1

    ;Rotiri pe biti si determinare maxim

    ;Determinare octet cu cei mai multi biti de 1

    MOV max_bits, 0
    MOV poz_max, 0

    MOV CL, sir_len    ;folosim registrul CX ca si contor pentru bucla mare
    MOV CH, 0

    LEA SI, sir

    MOV DI, 0    ;DI va tine indexul curent

loop_find_max:
    MOV AL, [SI]    ;Luam numarul
    MOV BL, 0       ;BL va fi contorul de biti de 1 pentru acest numar
    MOV DL, 8       ;avem 8 biti de verificat

count_loop:
    SHR AL, 1       ;shiftam dreapta, bitul 0 intra in carry flag
    JNC not_one     ;daca bitul a fost 0 sarim
    INC BL          ;daca bitul a fost 1, incrementam contorul

not_one:
    DEC DL        ;scadem contorul
    JNZ count_loop    ;repetam pentru toti cei 8 biti

    ;Verificam daca am gasit un nou record

    CMP BL, max_bits
    JBE next_byte
    MOV max_bits, BL

    MOV AX, DI    ;mutam indexul curent(DI) in AX 
    MOV poz_max, AL    ;Salvam indexul unde l-am gasit

next_byte:
    INC SI
    INC DI
    LOOP loop_find_max

    ;Afisam pozitia maxima

    MOV AH, 09h
    LEA DX, msg_max
    INT 21h

    MOV AL, poz_max
    INC AL
    ADD AL, 30h

    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ;Rotiri pe biti

    MOV AH, 09h
    LEA DX, msg_rot
    INT 21h

    MOV AH, 09h
    LEA DX, newline
    INT 21h

    MOV CL, sir_len
    MOV CH, 0    ;Resetam contorul si pointerul pentru a parcurge din nou sirul
    LEA SI, sir

loop_rotiri:
    MOV AL, [SI]

    ;Calculam N = bit0 + bit1

    MOV BL, AL    ;Copiem numarul in BL si mascam totul in afara de ultimul bit.
    AND BL, 1     ;BL devine bitul 0

    MOV DL, AL    ;Copiem numarul in DL, mutam dreapta si mascam.DL devine bitul 1
    SHR DL, 1
    AND DL, 1

    ADD BL, DL

    MOV rot_count, BL        ;Salvam numarul de rotiri in variabila contor

    CMP rot_count, 0    ;Daca e 0 nu intram in bucla de rotire
    JE skip_rotate
do_rot:
    ROL AL, 1        
    DEC rot_count
    JNZ do_rot    ;repetam pana rot_count ajunge la 0
skip_rotate:

    MOV [SI], AL    ;salvam numarul rotit inapoi in memorie

    MOV BL, AL
    SHR AL, 4
    CMP AL, 9
    JBE r1
    ADD AL, 7
r1: ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV AL, BL
    AND AL, 0Fh
    CMP AL, 9
    JBE r2
    ADD AL, 7
r2: ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    PUSH CX
    MOV DL, '('
    MOV AH, 02h
    INT 21h

    MOV BL, [SI]
    MOV CX, 8
print_bin:
    SHL BL, 1
    MOV DL, '0'
    ADC DL, 0
    MOV AH, 02h
    INT 21h
    LOOP print_bin

    MOV DL, ')'
    MOV AH, 02h
    INT 21h
    POP CX

    MOV DL, ' '
    INT 21h

    MOV CH, 0
    INC SI
    LOOP loop_rotiri

final_program:
    MOV AH, 4Ch
    INT 21h

END START
    








