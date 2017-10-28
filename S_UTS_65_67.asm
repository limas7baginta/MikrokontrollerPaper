;AUTHOR
;Kelompok 65
;Akhmad Muntako 1306368646
;Muhammad Zaini 1306368652
;Kelompok 67
;Limas Baginta 1306368690
;Fransiska Dyah 1306383691
                               
;PERATURAN
;   1. Pemain hanya bisa memasukkan angka maksimal 3 digit angka
;   2. Pemain hanya bisa memasukkan angka,bukan huruf atau karakter lainnya                               

;SKENARIO
;   -Pemain 1 memasukkan input maksimal 3 digit angka 
;   -Pemain 2 menebak angka yang dimasukkan Pemain 1 dengan memasukkan angka maksimal 3 digit
;   -Setelah tebakan Pemain 2 benar, bila ingin mengulangi permainan, tekan tombol 'y' atau 'Y'
;   -Setelah tebakan Pemain 2 benar, bila ingin keluar dari game, tekan tombol 'n' atau 'N' 

; This program is free software: youcan redistribute it and/or modify
; It under the terms og the GNU General Public Licence as published by
; the Free Software Foundation, either version 3 of the licence, or (at your opinion) any later version
; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE see the
; GNU General Public Licence for more details.
; You should have received a copy of the GNU General Public Licence along with program.
; If not, see <http://www.gnu.org/licences/>


.model small
.stack 100h
.data
 
    
 
    ;Deklarasi digunakan untuk menambah LineBreak menuju string
    CR          equ 13d
    LF          equ 10d
 
    ;Pesan string digunakan dalam Aplikasi 
    judul       db  CR,LF,'GAME TEBAK ANGKA$'
    angkarahasia db CR,LF,'Masukkan maksimal 3 digit angka rahasia(0-255): $'
    tampilanLayar      db  CR, LF,'Temukan aku, Masukkan maksimal 3 digit angka(0-255) : $'
    kurang     db  CR, LF,'Aku berada dibawah angka masukanmu ','$'
    lebih      db  CR, LF,'Aku berada diatas angka masukanmu ', '$'
    sama       db  CR, LF,'Ahhh, kau menemukanku!', '$'
    salahMasukan db  CR, LF,'Salah memasukan input, cobalagi!', '$'
    retry       db  CR, LF,'Ulangi [y/n] ? ' ,'$'
                                                              
    angka       db  0d      ;variabel 'angka' menyimpan niai random
    inputUser   db  0d      ;variabel user untuk menyimpan masukan user
    cekError    db  0d      ;variabel user untuk mengecek jika nilai masukan dalam range
 
    parameter       label Byte
 
.code  


MACRO tampil a 
    
    MOV ah, 9h              ; melakukan Write string menuju STDOUT (untuk DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt) 
    endm  

proc input  
jumlahinput: 
 
    CMP     cl, 3d          ; melakukan Compare CL dengan 3d (3 adalah maksimum angka dari digit yang diperbolehkan)
    JG      selesaiinput    ; melakukan IF CL > 5 lalu JUMP menuju label 'selesaiinput'
 
    MOV     ah, 7h          ; membaca karakter dari STDIN menuju AL (untuk DOS interrupt)namun tidak ditapilkan di layar
    INT     21h             ; DOS INT 21h (DOS interrupt)
 
    CMP     al, 0Dh         ; melakukan Compare untuk read value dengan 0Dh yang merupakan ASCII code untuk key ENTER
    JE      selesaiinput        ; melakukan IF AL = 0Dh, key Enter ditekan, lulu JUMP menuju 'selesaiinput'
    ;melihat apakah input yang dimasukkan merupakan angka
    cmp     al, 39h
    JG      start
    cmp     al, 30h
    JL      start
    SUB     al, 30h         ; melakukan Substract 30h dari masukan nila ASCII untuk mendapat angka yang aktual. (Karena ASCII 30h = angka '0')
    MOV     dl, al          ; melakukan Move terhadap nilai masukan menuju DL
    PUSH    dx              ; melakukan Push DL menuju stack, untuk dapat dibaca masukan berikutnya
    INC     cl              ; melakukan Increment CL (Counter)
 
    JMP jumlahinput         ; melakukan JUMP kembali menuju label 'jumlahinput' jika telah sampai
 
selesaiinput:
; END reading user input
 
    DEC cl                  ; melakukan decrement CL dengan 1(satu) untuk mengurangi increment yang dibuat dalam akhir iterasi
 
    CMP cl, 02h             ; melakukan compare CL dengan 02, karena hanya 3 angka yang dapat diterima IN RANGE
    JG  over                ; melakukan IF CL (angka dari masukan karakter) jika lebih daripada 3 maka JUMP menuju label 'overflow'
 
    MOV BX, OFFSET cekError ; mendapat alamat dari variabel 'cekError' dalam BX.
    MOV BYTE PTR [BX], cl   ; melakukan set 'cekError' untuk nilai dari CL
 
    MOV cl, 0h              ; melakukan set CL ke 0, karena counter digunakan dalam sesi berikutnya
 
; MULAI memproses masukan user   
; Membuat NUMERIC yang aktual untuk representasi dari angka yang dibaca dari user sebagai 3 karakter
wile2: 
    CMP cl,cekError
    JG endwile2
 
    POP dx                  ; melaukan POP DX nilai yang dilakukan store dalam stack, (dari least-significant-digit menuju most-significant-digit)
 
    MOV ch, 0h              ; melakukan clear CH yang digunakan dalam inner loop sebagai counter
    MOV al, 1d              ; melakukan inisialisasi  set AL ke 1   (desimal)
    MOV dh, 10d             ; melakukan set DH ke 10  (desimal)
 
 ; MULAI loop untuk membuat perkalian 10 untuk membuat posisi relasi dari digit
 ;  IF CL adalah 2
 ; loop pertama akan menghasilkan 10^0
 ; loop kedua akan menghasilkan  10^1
 ; loop ketiga akan menghasilkan  10^2
 wile3:
 
    CMP ch, cl              ; melakukan compare CH dengan CL
    JGE endwile3           ; melakukan IF CH >= CL, lalu JUMP menuju 'endtiga
 
    MUL dh                  ; melakukan AX = AL * DH yang mana sama dengan AL dikali dengan 10 (AL * 10)
 
    INC ch                  ; melakukan increment CH
    JMP wile3
 
 endwile3:
 ; END loop perkalian untuk menentukan posisi digit
 
    ; sekarang AL memiliki 10^0, 10^1 atau 10^2 bergantung pada nilai dari CL
 
    MUL dl                  ; AL = AL * DL, yang mana posisi aktual nilai dari angka 
 
    JO  over            ; Jika terdapat kesalahan masukan atau overflow maka dilakukan JUMP menuju label 'over' (untuk nilai diatas 300)
 
    MOV dl, al              ; melakaukan move restlt untuk perkalian menuju DL
    ADD dl, angka           ; melakukan add result (posisi actual nilai dari angka) menuju nilai dalam variable 'angka'
    mov angka,dl
    
    JC  over                ; Jika terdapat overflow aka JUMP menuju label 'over' (untuk nilai diatas 255 sampai 300)
 
    MOV BX, OFFSET angka    ; mendapat alamat dari variabel 'angka' dalam BX.
    MOV BYTE PTR [BX], dl   ; melakuka set 'cekError' menuju nilai dalam DL
 
    INC cl                  ; melakukan increment CL counter
 
    JMP wile2              ; melakukan JUMP kembali menuju label 'total' 
        
endwile2:
; END proses masukan dari user
 
    MOV ax, @data           ; mendapat alamat dari data menuju AX
    MOV ds, ax              ; melakukan set 'data segment' menuju nilai dari AX yang mana adalah 'alamat dari data (@data)'

    JMP game
    over:
 
    MOV dx, offset salahMasukan ; melakukan load alamat dari 'salahMasukan' menuju DX
    tampil dx
    JMP start        ; melakukan JUMP menuju input angka rahasia 

input endp 
    

proc tebak
    ; MULAI membaca masukan dari user
while:
 
    CMP     cl, 5d          ; melakukan Compare CL dengan 10d (5 adalah maksimum angka dari digit yang diperbolehkan)
    JG      endwhile        ; melakukan IF CL > 5 lalu JUMP menuju label 'endwhile'
 
    MOV     ah, 1h          ; membaca karakter dari STDIN menuju AL (untuk DOS interrupt)
    INT     21h             ; DOS INT 21h (DOS interrupt) 

    CMP     al, 0Dh         ; melakukan Compare untuk read value dengan 0Dh yang merupakan ASCII code untuk key ENTER
    JE      endwhile        ; melakukan IF AL = 0Dh, key Enter ditekan, lulu JUMP menuju 'endwhile'
    ;melihat apakah input yang dimasukkan merupakan angka
    cmp     al, 39h
    JG      start
    cmp     al, 30h
    JL      start
    SUB     al, 30h         ; melakukan Substract 30h dari masukan nila ASCII untuk mendapat angka yang aktual. (Karena ASCII 30h = angka '0')
    MOV     dl, al          ; melakukan Move terhadap nilai masukan menuju DL
    PUSH    dx              ; melakukan Push DL menuju stack, untuk dapat dibaca masukan berikutnya
    INC     cl              ; melakukan Increment CL (Counter)
 
    JMP while               ; melakukan JUMP kembali menuju label 'while' jika telah sampai
 
endwhile:
; END reading user input
 
    DEC cl                  ; melakukan decrement CL dengan 1(satu) tuntuk mengurangi increament yang dibuat dalam akhir iterasi
 
    CMP cl, 02h             ; melakukan compare CL dengan 02, karena hanya 3 angka yang dapat diterima IN RANGE
    JG  overflow            ; melakukan IF CL (angka dari masukan karakter) jika lebih daripada 3 maka JUMP menuju label 'overflow'
 
    MOV BX, OFFSET cekError ; mendapat alamat dari variabel 'cekError' dalam BX.
    MOV BYTE PTR [BX], cl   ; melakukan set 'cekError' untuk nilai dari CL
 
    MOV cl, 0h              ; melakukan set CL ke 0, karena counter digunakan dalam sesi berikutnya
    
tebak endp

proc cek 
; MULAI memproses masukan user   
; Membuat NUMERIC yang aktual untuk representasi dari angka yang dibaca dari user sebagai 3 karakter
while2:
 
    CMP cl,cekError
    JG endwhile2
 
    POP dx                  ; melaukan POP DX nilai yang dilakukan store dalam stack, (dari least-significant-digit menuju most-significant-digit)
 
    MOV ch, 0h              ; melakukan clear CH yang digunakan dalam inner loop sebagai counter
    MOV al, 1d              ; melakukan inisialisasi  set AL ke 1   (desimal)
    MOV dh, 10d             ; melakukan set DH ke 10  (desimal)
 
 ; MULAI loop untuk membuat perkalian 10 untuk membuat posisi relasi dari digit
 ;  IF CL adalah 2
 ; loop pertama akan menghasilkan 10^0
 ; loop kedua akan menghasilkan  10^1
 ; loop ketiga akan menghasilkan  10^2
 while3:
 
    CMP ch, cl              ; melakukan compare CH dengan CL
    JGE endwhile3           ; melakukan IF CH >= CL, lalu JUMP menuju 'endwhile3
 
    MUL dh                  ; melakukan AX = AL * DH yang mana sama dengan AL dikali dengan 10 (AL * 10)
 
    INC ch                  ; melakukan increment CH
    JMP while3
 
 endwhile3:
 ; END loop perkalian untuk menentukan posisi digit
 
    ; sekarang AL memiliki 10^0, 10^1 atau 10^2 bergantung pada nilai dari CL
 
    MUL dl                  ; AX = AL * DL, yang mana posisi aktual nilai dari angka 
 
    JO  overflow            ; Jika terdapat kesalahan masukan atau overflow maka dilakukan JUMP menuju label 'overflow' (untuk nilai diatas 300)
 
    MOV dl, al              ; melakaukan move restlt untuk perkalian menuju DL
    ADD dl, inputUser           ; melakukan add result (posisi actual nilai dari angka) menuju nilai dalam variable 'inputUser'
 
    JC  overflow            ; Jika terdapat overflow aka JUMP menuju label 'overflow' (untuk nilai diatas 255 sampai 300)
 
    MOV BX, OFFSET inputUser    ; mendapat alamat dari variabel 'inputUser' dalam BX.
    MOV BYTE PTR [BX], dl   ; melakuka set 'cekError' menuju nilai dalam DL
 
    INC cl                  ; melakukan increment CL counter
 
    JMP while2              ; melakukan JUMP kembali menuju label 'while2'
 
endwhile2:
; END proses masukan dari user
 
    MOV ax, @data           ; mendapat alamat dari data menuju AX
    MOV ds, ax              ; melakukan set 'data segment' menuju nilai dari AX yang mana adalah 'alamat dari data (@data)'
 
    MOV dl, angka          ; melakukan load original 'angka' menuju DL
    MOV dh, inputUser      ; melakukan load 'angka' yang mana masukan dari user menuju DH
 
    CMP dh, dl              ; melakukan compare DH dan DL (DH - DL)
 
    JC greater              ; melakukan If DH (inputUser) > DL (angka) perbandingan(comparison) akan menyebabkan sebum Carry. Karena jika carry telah terjadi dilakukan print 'Aku berada diatas angka masukanmu'
    JE equal                ; melakukan IF DH (inputUser) = DL (angka) print inputUser adalah benar
    JG lower                ; melakukan IF DH (inputUser) < DL (angka) print angka adalah kurang
 
equal:
 
    MOV dx, offset sama ; melakukan load alamat dari 'sama' menuju DX
    tampil dx
    call ulang               ; melakukan JUMP menuju akhir program
 
greater:
 
    MOV dx, offset lebih  ; melakukan load alamat dari 'lebih' menuju DX
    tampil dx
    JMP game               ; melakukan JUMP menuju awal program
 
lower:
 
    MOV dx, offset kurang  ; melakukan load alamat dari 'kurang' menuju DX
    tampil dx
    JMP game              ; melakukan JUMP menuju awal program
 
overflow:
 
    MOV dx, offset salahMasukan ; melakukan load alamat dari 'salahMasukan' menuju DX
    tampil dx
    JMP game                ; melakukan JUMP menuju awal program 
    

RET
exit:

cek endp  


proc ulang
    retry_while:            ; Bertanya kepada user jika ingin bermain kembali
 
    MOV dx, offset retry    ; melakukan load alamat dari 'tampilanLayar' menuju DX
    tampil dx
 
    MOV ah, 1h              ; melakukan Read character dari STDIN menuju AL (untuk DOS interrupt)
    INT 21h                 ; DOS INT 21h (DOS interrupt)
 
    CMP al, 6Eh             ; melakukan cek jika masukan user adalah 'n'
    JE return_to_DOS        ; melakukan call label 'return_to_DOS' jika masukan adalah 'n'
  
    CMP al, 79h             ; melakukan cek jika masukan user adalah 'y'
    JE restart              ; melakukan call label 'restart' jika masukan adalah 'y' ..
                            ;   "JE start" tidak digunakan karena diterjemahkan sebagai NOP(No Operand) dalam emu8086
    CMP al, 4Eh             ; melakukan cek jika masukan user adalah 'N'
    JE return_to_DOS        ; melakukan call label 'return_to_DOS' jika masukan adalah 'N'
  
    CMP al, 59h             ; melakukan cek jika masukan user adalah 'Y'
    JE restart              ; melakukan call label 'restart' jika masukan adalah 'Y' ..
                            ;   "JE start" tidak digunakan karena diterjemahkan sebagai NOP(No Operand) dalam emu8086

    JMP retry_while         ; jika input bukan 'y' atau 'n' maka tanyakan petanyaan yang sama

restart:
    JMP start              ; melakukan JUMP menuju awal program
return_to_DOS:
    MOV ax, 4c00h           ; Kembali menuju ms-dos
    INT 21h                 ; DOS INT 21h (DOS interrupt)
    
    ret
    ulang endp   
proc set
     ; MULAI menyimpan variables menuju 0h
    MOV ax, 0h
    MOV bx, 0h
    MOV cx, 0h
    MOV dx, 0h
 
    MOV BX, OFFSET inputUser    ; mendapat alamat dari variabel 'inputUser' dalam BX.
    MOV BYTE PTR [BX], 0d   ; melakukan set 'inputUser' menuju 0 (dalam desimal)
 
    MOV BX, OFFSET cekError ; mendapat alamat dari variabel 'cekError' dalam BX.
    MOV BYTE PTR [BX], 0d   ; melakukan set 'cekError' menuju 0 (dalam desimal)
    ; END restart
    ret
    set endp

 
.startup 
start: 
    call set 
    mov angka,0
    mov dx,offset judul
    tampil dx
    mov dx,offset angkarahasia
    tampil dx
    mov cl,0h
    mov dl,0h
    call input
    

 
game: 
    call set 
    MOV ax, @data           ; mendapat alamat dari data menuju AX
    MOV ds, ax              ; melakukan set 'data segment' menuju nilai AX yang mana meruapakan 'alamat dari data (@data)'
    MOV dx, offset tampilanLayar   ; melakukan load kepada alamat dari 'tampilanLayar' menuju DX
    tampil dx
 
    MOV cl, 0h              ; melakukan set CL menuju 0  (Counter)
    MOV dx, 0h              ; melakukan set DX menuju 0  (Data register digunakan untuk melakukan store masukan dari user)
    call tebak 
    call cek
    
.exit
end  