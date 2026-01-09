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
