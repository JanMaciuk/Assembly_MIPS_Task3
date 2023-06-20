.data
	RAM: .space 4096 # Zak³adamy ¿e tablica nie przekroczy rozmiaru 4096 bajtów.
	
	# Stringi do komunikacji z u¿ytkownikiem:
	podajWiersz:    .asciiz "\nPodaj numer wiersza:\n"
	podajKolumne:   .asciiz "\nPodaj numer kolumny: \n"
	rodzajOperacji: .asciiz "\nOdczyt czy zapis? Liczba ujemna to odczyt, dodatnia to zapis, 0=wyjdz\n"
	wpiszLiczbe:    .asciiz "\nWpisz liczbe do zapisania:\n"
	rozmiarWiersze: .asciiz "\nPodaj ilosc wierszy tablicy:\n"
	rozmiarKolumny: .asciiz "\Podaj ilosc kolumn tablicy:\n"


.text

	#Ustawienie liczby wierszy i kolumn z konsoli:
	li   $v0, 4
	la   $a0, rozmiarWiersze
	syscall 		# Wyœwietl zapytanie o ilosc wierszy
	li   $v0, 5
	syscall 		# Odczytaj ilosc wierszy od uzytkownika
	move $s1, $v0	# Zapisuje ilosc wierszy jako $s1
	
	li   $v0, 4
	la   $a0, rozmiarKolumny
	syscall 		# Wyœwietl zapytanie o ilosc kolumn
	li   $v0, 5
	syscall 		# Odczytaj ilosc kolumn od uzytkownika
	move $s2, $v0	# Zapisuje ilosc kolumn jako $s2
		
		
	# Inicjalizacja wartosci rejestrow:
	la  $s0, RAM 	# Zapisuje odnosnik do RAM w $s0
	sll $s3, $s2, 2	# Zapisuje $s3 jako offset: ilosc kolumn razy 4 (Przesuwam o 2 miejsca)
	
	# Utworzenie pierwszego wiersza, zawierajacego adresy nastepnych wierszy, pseudokod w .txt
	# Zmienne do tablicy adresow:
	la  $t1, RAM 		# $t1 obecnyAdres = adresRAM
	la  $t2, RAM		# $t2 pozycjaZapisu = adresRAM
	sll $t0, $s1, 2		# iloscWierszy * 4 (przesuwam o 2 miejsca)
	add $t1, $t1, $t0 	# Przesuwam obecnyAdres o iloscWierszy*4, aby adresy nie wskazywaly na inne adresy.
	add $t3, $s0, $t0 	# koncowaPozycja = adresRam + iloscWierszy * 4
	
	petlaZapiszAdresy:	
		sw   $t1, ($t2)  	# zapisz obecnyAdres na polu pozycjaZapisu
		add  $t1, $t1, $s3	# obecnyAdres = obecnyAdres + offset (nastepny wiersz)
		addi $t2, $t2, 4		# pozycjaZapisu = pozycjaZapisu + 4 (nastepna kolumna)
		bgt  $t3, $t2, petlaZapiszAdresy	# if (pozycjaZapisu < koncowaPozycja) goto petla
		# Jesli nie bylo skoku to skonczylismy zapisywac adresy
	
	
	# Utworzenie tablicy i wype³nienie jej wartoœciami, pseudokod w .txt:
	# Wartosci poczatkowe:
	la  $t1, RAM 		# $t1 pozycjaAdresuWiersza = adresRAM
	move $t2, $zero		# $t2 wiersz = 0
	petlaZmianaWiersza:
		move $t3, $zero 		# $t3 kolumna = 0 (iteruje od zerowej kolumny po nowym wierszu)
		lw   $t4, ($t1)		# $t4 pozycjaZapisu = (pozycjaAdresuWiersza)
		li   $t0, 100 		# Zapisuje 100 do mnozenia
		mul  $t5, $t2, $t0	# $t5 = wiersz*100, do obliczania wartosci do zapisania
	
		wypelnienieWiersza:
			addi $t0, $t3, 1 	# obliczam kolumna+1, do obliczania wartosci do zapisania
			add  $t6, $t5, $t0 	# $t6 wartoscDoZapisu = (wiersz*100)+(kolumna+1) (tak jak podane w poleceniu)
			sw   $t6, ($t4) 		# zapisz wartoscDoZapisu na polu pozycjaZapisu
			addi $t4, $t4, 4 	# pozycjaZapisu = pozycjaZapisu + 4 (zapis w nastepnej kolumnie)
			move $t3, $t0		# kolumna = kolumna + 1 (kolumna+1 jest juz obliczone wczesniej jako $t0)
			blt  $t3, $s2, wypelnienieWiersza # jesli kolumna < iloscKolumn to ponawiam zapis w nowej kolumnie
			# Jesli nie ma skoku to skonczylem wypelniac kolumne, przechodze do nastepnego wiersza
			addi $t2, $t2, 1 	# Wiersz = Wiersz + 1 (zapisuje w nowym wierszu)
			addi $t1, $t1, 4 	# pozycjaAdresuWiersza = pozycjaAdresuWiersza + 4 (odczytam nastepny adres wiersza)
			blt  $t2, $s1, petlaZmianaWiersza # jezeli wiersz < iloscWierszy to nie skonczylem zapisu, powracam do poczatku tabeli
			# Stosuje ostre nierownosci przy wierszach i kolumnach bo licze wiersze i kolumny od 0.
			# Na przyklad: jezeli ilosc wierszy to 2, to dojde do wiersz = 1 (wiersz=0, wiersz=1: 2 elementy)
			 
	wybor: # pseudokod w .txt
		li   $v0, 4
		la   $a0, rodzajOperacji
		syscall 		 # Wyœwietl zapytanie o rodzaj operacji
		li   $v0, 5
		syscall 		 # Odczytaj rodzaj operacji z konsoli
		beqz $v0, end 	 # 0 to kod na wyjscie z programu
		move $t1, $v0	 # Zapisuje rodzaj operacji jako $t1
		
		li   $v0, 4
		la   $a0, podajWiersz
		syscall 		 # Wyœwietl zapytanie o numer wiersza
		li   $v0, 5
		syscall 		 # Odczytaj numer wiersza z konsoli
		move $t2, $v0	 # Zapisuje numer wiersza jako $t2
		subi $t2, $t2, 1 # Odejmuje 1 od numeru wiersza (bo zaczynam numeracje wierszy od 0)
	
		li   $v0, 4
		la   $a0, podajKolumne
		syscall 		 # Wyœwietl zapytanie o numer kolumny
		li   $v0, 5
		syscall 		 # Odczytaj numer kolumny z konsoli
		move $t3, $v0	 # Zapisuje numer kolumny jako $t3
		subi $t3, $t3, 1 # Odejmuje 1 od numeru kolumny (bo zaczynam numeracje kolumn od 0)
		
		sll  $t0, $t2, 2		# Obliczam numerWiersza*4 (przesuwam o 2 miejsca)
		add  $t0, $t0, $s0	# indeksAdresuWiersza = adresRam + numerWiersza*4
		lw   $t0 ($t0)		# Odczytuje adres wpisanego wiersza z tablicy
		sll  $t3, $t3, 2 	# Oliczam (numerKolumny-1) * 4 (przesuwam o 2 miejsca)
		add  $t0, $t0, $t3 	# adresDanych = adresWiersza + (numerKolumny-1)*4. Pod tym adresem zapisana jest szukana wartosc.
		bltz $t1, odczyt		# if (rodzajOperacji < 0) {goto odczyt}
					# if (rodzajOperacji > 0) {goto zapis}
		
	#zapis: 	(Nie musze stosowac skoku, po prostu przechodze do tego fragmentu kodu)
		li $v0, 4
		la $a0, wpiszLiczbe
		syscall 		# Zapytaj o liczbe do zapisania
		li $v0, 5
		syscall 		# Odczytaj liczbe do zapisania z konsoli
		sw $v0 ($t0) 	# Zapisz wpisana liczbe w tabeli
		j wybor
			
	odczyt:
		lw $a0, ($t0)	# Odczytuje szukana wartosc do wyswietlenia
		li $v0, 1
		syscall		# Wyswietlam szukana wartosc
		j wybor
		
	
	
	end:
		li $v0, 10
		syscall		# Wyjscie z programu
	
	 
