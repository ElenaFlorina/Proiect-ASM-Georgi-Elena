# Proiect Limbaj de Asamblare

**Echipa:** Georgiana și Elena

Salut! Acesta este proiectul realizat de echipa noastră. Ne-am propus să creăm un program în limbaj de asamblare (x86) care prelucrează un șir de numere hexazecimale introduse de la tastatură. Aplicația trece datele printr-o serie de transformări matematice și logice.

### Ce face programul nostru

Pe scurt, aplicația urmează câțiva pași logici:

1. Mai întâi, îți cere să introduci un șir de numere (octeți) în format hexazecimal.
2. Verifică dacă ai introdus corect datele (trebuie să fie între 8 și 16 numere).
3. Calculează un "Cuvânt de Control" (o valoare specială obținută din sume și operații logice XOR/OR).
4. Sortează toate numerele introduse în ordine descrescătoare.
5. Analizează fiecare număr în parte și îți spune care dintre ele are cei mai mulți biți de 1.
6. La final, aplică o serie de rotiri pe biți asupra numerelor și afișează rezultatul final atât în format Hexazecimal, cât și în Binar.

### Cum se rulează

Pentru a testa programul, ai nevoie de un emulator precum DOSBox și de asamblorul TASM.

Compilează fișierul folosind comanda:

tasm main.asm

Leagă fișierul obiect creat:

tlink main.obj

Rulează executabilul:

main.exe

### Exemplu de utilizare

Când programul pornește, poți introduce un șir de genul:
01 02 03 04 05 06 0F 10

Apoi apasă **Enter** și vei vedea toate rezultatele afișate pe ecran.

Sperăm să vă placă!


