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
temp_byte  DB 0
word_C     DW 0
max_bits   DB 0
poz_max    DB 0
curr_bits  DB 0
rot_count  DB 0

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
    LEA SI, sir
    MOV AL, [SI]
    SHR AL, 4

    MOV BL, sir_len
    MOV BH, 0
    DEC BX
    MOV DL, sir[BX]
    AND DL, 0Fh

    XOR AL, DL
    MOV temp_byte, AL

    MOV CL, sir_len
    MOV CH, 0
    LEA SI, sir
    MOV BL, 0
loop_or:
    MOV AL, [SI]
    SHR AL, 2
    AND AL, 0Fh
    OR BL, AL
    INC SI
    LOOP loop_or

    SHL BL, 4
    OR temp_byte, BL

    MOV CL, sir_len
    MOV CH, 0
    LEA SI, sir
    MOV AX, 0
loop_sum:
    MOV BL, [SI]
    MOV BH, 0
    ADD AX, BX
    INC SI
    LOOP loop_sum

    MOV AH, AL
    MOV AL, temp_byte
    MOV word_C, AX

    MOV AH, 09h
    LEA DX, msg_c
    INT 21h

    MOV AL, BYTE PTR word_C + 1
    MOV BL, AL
    SHR AL, 4
    CMP AL, 9
    JBE c_h1
    ADD AL, 7
c_h1: ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    MOV AL, BL
    AND AL, 0Fh
    CMP AL, 9
    JBE c_h2
    ADD AL, 7
c_h2: ADD AL, 30h
    MOV DL, AL
    MOV AH, 02h
    INT 21h

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










