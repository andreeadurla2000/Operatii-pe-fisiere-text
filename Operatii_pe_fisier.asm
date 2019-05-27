.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern scanf: proc
extern printf: proc
extern fprintf: proc
extern fopen: proc
extern fscanf: proc
extern strcmp: proc
extern fseek: proc
extern fgets: proc
extern strlen: proc
extern fputs: proc
extern fclose: proc
extern remove: proc
extern rename: proc

public start

.data

msg1 db "Introduceti calea spre fisier: ", 10, 0
msg2 db "Operatia: ", 10, 0
msg3 db "Nu exista aceasta operatie!", 10, 0
mode_r_w db "r+", 0
mode_w db "w+", 0

format1 db "%s", 0
format2 db "%*c%c", 0
format3 db "%c", 0
format4 db "%d", 10, 0
format5 db "%d ", 0
format6 db "%d aparitii la index:", 10, 0
format7 db "Nu exista cuvantul %s!", 10, 0

cale_fisier db 100 dup(0)
cale_fisier_auxiliar db  "C:\\Users\\Andreea\\Desktop\\PLA\\fisier_proiect_aux.txt", 0
operatia db 15 dup(0)

findc db "findc", 0
find db "find", 0
replace db "replace", 0
delete db "delete", 0
toUpper db "toUpper", 0
toLower db "toLower", 0
toSentece db "toSentece", 0
afisare_continut db "list", 0
iesire db "exit", 0

car1 dd 0
car2 dd 0

sec1 db 20 dup(0)
sec2 db 20 dup(0)
sec3 db 20 dup(0)

linie db 100 dup(0)
linie_noua db 100 dup(0)
vec_aparitii dd 20 dup(0)

.code

afisare macro mesaj
	push offset mesaj
	call printf
	add esp, 4
endm

citire macro format, parametru
	push parametru
	push offset format
	call scanf
	add esp, 8
endm

comparare macro param1, param2
	push param2
	push param1
	call strcmp
	add esp, 8
endm

gasire_car proc
	
		push offset car1
		push offset format2
		call scanf
		add esp, 8

		xor ebx, ebx

		;punem cursorul la inceputul fisierului
		push 0
		push 0
		push esi
		call fseek
		add esp, 12	
	
cont:	push offset car2
		push offset format3
		push esi
		call fscanf
		add esp, 12
	
		cmp eax, 1
		jne final
		
		mov ecx, car1
		cmp ecx, car2
		jne cont
		inc ebx
		jmp cont
		
final:	mov eax, ebx
		ret	
gasire_car endp



litere_mici proc
		
		xor ebx, ebx
		
my_loop:
		push 0
		push ebx
		push esi
		call fseek
		add esp, 12
		
		inc ebx 
		
		push offset car2
		push offset format3
		push esi
		call fscanf
		add esp, 12
		
		cmp eax, 1
		jne sfarsit
		
		test car2, 40h
		je my_loop
		
		cmp car2, 41h ; "A"
		jl my_loop
		
		cmp car2, 5Ah ; "Z"
		jg my_loop
		
		or car2, 20h
	
		push 1
		push -1
		push esi
		call fseek
		add esp, 12
		
		push car2
		push offset format3
		push esi
		call fprintf
		add esp, 12
		
		jmp my_loop
	
sfarsit: ret
litere_mici endp


litere_mari proc 		
		xor ebx, ebx
		
my_loop:
		push 0
		push ebx
		push esi
		call fseek
		add esp, 12
		
		inc ebx 
		
		push offset car2
		push offset format3
		push esi
		call fscanf
		add esp, 12
		
		cmp eax, 1
		jne sfarsit
		
		test car2, 40h
		je my_loop
		
		cmp car2, 61h ; "a"
		jl my_loop
		
		cmp car2, 7Ah ; "z"
		jg my_loop
		
		xor car2, 20h
	
		push 1
		push -1
		push esi
		call fseek
		add esp, 12
		
		push car2
		push offset format3
		push esi
		call fprintf
		add esp, 12
		
		jmp my_loop
	
sfarsit: ret
litere_mari endp


cautare_secventa proc	
	push ebp
	mov ebp, esp
	sub esp, 4
	
	xor ebx, ebx
	xor edi, edi
	
	push offset sec1
	push offset format1
	call scanf
	add esp, 8
	
	push offset sec1
	call strlen
	add esp, 4
	
	inc eax
	mov [ebp-4], eax ; lungimea secventei citite+1
		 
my_loop: push 0
		 push ebx
		 push esi
		 call fseek
		 add esp, 12
		 
		 inc ebx
		 
		 push esi
		 push [ebp-4]
		 push offset sec2
		 call fgets
		 add esp, 12
		 
		 cmp eax, 0
		 je sfarsit
		 
		 comparare offset sec1, offset sec2 
		 cmp eax, 0
		 jne my_loop
		 
		 dec ebx
		 mov vec_aparitii[edi*4], ebx
		 
		 inc ebx
		 inc edi
		 jmp my_loop
			
sfarsit:	mov esp, ebp
			pop ebp
			ret
cautare_secventa endp

gasire_secventa proc

	call cautare_secventa
	
	xor ebx, ebx

	cmp edi, 0
	jne aici
	
	push offset sec1
	push offset format7
	call printf
	add esp, 8
	jmp sfarsit

aici:   push edi 
		push offset format6
		call printf
		add esp, 8	
		
my_loop: cmp ebx, edi
		 jae sfarsit
		
		 push vec_aparitii[ebx*4]
		 push offset format4
		 call printf 
		 add esp, 8
			
		 inc ebx
		 jmp my_loop
		 
sfarsit:	
		ret
gasire_secventa endp


propozitii proc

		call litere_mici ;facem toate literele mici
		xor ebx, ebx
		
my_loop:
		push 0
		push ebx
		push esi
		call fseek
		add esp, 12	
		
		push offset car2
		push offset format3
		push esi
		call fscanf
		add esp, 12
		
		cmp ebx, 0 ;este primul caracter
		je aici
		
		inc ebx
		
		cmp eax, 1
		jne sfarsit
		
		mov edi, 21h
		cmp edi, car2 ; "!"
		je aici
		
		mov edi, 3Fh
		cmp edi, car2 ; "?"
		je aici
		
		mov edi, 2Eh
		cmp edi, car2 ; "."
		jne my_loop
	
aici:	push 0
		push ebx
		push esi
		call fseek
		add esp, 12
		
		push offset car2
		push offset format3
		push esi
		call fscanf
		add esp, 12
		
		cmp eax, 1
		jne sfarsit
		
		inc ebx
		
		mov edi, 10 ;newline
		xor edi, car2
		je aici
		
		mov edi, 20h ;space
		xor edi, car2
		je aici
		
		test car2, 40h ;este litera
		je my_loop
		
		;facem litera mare
		cmp car2, 61h ; "a"
		jl my_loop
		
		cmp car2, 7Ah ; "z"
		jg my_loop
		
		xor car2, 20h
		
		push 1
		push -1
		push esi
		call fseek
		add esp, 12
		
		push car2
		push offset format3
		push esi
		call fprintf
		add esp, 12
		
		jmp my_loop
	
sfarsit: ret
propozitii endp


afisare_continut_fisier proc	
	push 0
	push 0
	push esi
	call fseek
	add esp, 12
	
my_loop: push offset car1
		 push offset format3
		 push esi
		 call fscanf
		 add esp, 12
		 
		 cmp eax, 1
		 jne sfarsit
		 
		 push car1
		 push offset format3
		 call printf
		 add esp, 8
		 
		 jmp my_loop	 
sfarsit: 
		 ret
afisare_continut_fisier endp


inlocuire proc	
	push ebp
	mov ebp, esp
	sub esp, 4
	
	push offset sec1
	push offset format1
	call scanf
	add esp, 8
	
	push offset sec2
	push offset format1
	call scanf
	add esp, 8
	
	push offset sec1
	call strlen
	add esp, 4
	
	inc eax
	mov [ebp-4], eax ;lungimea primului sir+1
	
	;deschidem fisierul auxiliar
	push offset mode_w
	push offset cale_fisier_auxiliar
	call fopen
	add esp, 8
	mov edi, eax
	
	cmp eax, 0
	je sfarsit
	
	xor ebx, ebx
	
my_loop: 
	push 0
	push ebx
	push esi
	call fseek
	add esp, 12
	
	push esi
	push [ebp-4]
	push offset sec3
	call fgets
	add esp, 12
	
	cmp eax, 0
	je sfarsit
	
	comparare offset sec3, offset sec1
	cmp eax, 0
	jne afis_c
	
	push offset sec2
	push offset format1
	push edi
	call fprintf
	add esp, 12
	
	add ebx, [ebp-4]
	dec ebx
	jmp my_loop
	
afis_c:
	push 0
	push ebx
	push esi
	call fseek
	add esp, 12
	
	push offset car1
	push offset format3
	push esi
	call fscanf
	add esp, 12
	
	inc ebx
	cmp car1, 10
	jne cont
	inc ebx
cont:	push car1
	push offset format3
	push edi
	call fprintf
	add esp, 12
	
	jmp my_loop
	
sfarsit:

	push esi
	call fclose
	add esp, 4
	
	push edi
	call fclose
	add esp, 4
	
	push offset cale_fisier
	call remove
	add esp, 4
	
	push offset cale_fisier
	push offset cale_fisier_auxiliar
	call rename
	add esp, 8
	
	push offset mode_r_w
	push offset cale_fisier
	call fopen
	add esp, 8
	mov esi, eax
	
		mov esp, ebp
		pop ebp
		ret
inlocuire endp

stergere proc	
	push ebp
	mov ebp, esp
	sub esp, 4
	
	push offset sec1
	push offset format1
	call scanf
	add esp, 8
	
	push offset sec1
	call strlen
	add esp, 4
	
	inc eax
	mov [ebp-4], eax ;lungimea primului sir
	
	;deschidem fisierul auxiliar
	push offset mode_w
	push offset cale_fisier_auxiliar
	call fopen
	add esp, 8
	mov edi, eax
	
	cmp eax, 0
	je sfarsit
	
	xor ebx, ebx
	
my_loop: 
	push 0
	push ebx
	push esi
	call fseek
	add esp, 12
	
	push esi
	push [ebp-4]
	push offset sec2
	call fgets
	add esp, 12
	
	cmp eax, 0
	je sfarsit
	
	
	comparare offset sec2, offset sec1
	cmp eax, 0
	jne afis_c
	
	add ebx, [ebp-4]
	dec ebx
	jmp my_loop
	
afis_c:
	push 0
	push ebx
	push esi
	call fseek
	add esp, 12
	
	push offset car1
	push offset format3
	push esi
	call fscanf
	add esp, 12
	
	inc ebx
	cmp car1, 10
	jne cont
	inc ebx
cont:	push car1
	push offset format3
	push edi
	call fprintf
	add esp, 12
	
	jmp my_loop
	
sfarsit:

	push esi
	call fclose
	add esp, 4
	
	push edi
	call fclose
	add esp, 4
	
	push offset cale_fisier
	call remove
	add esp, 4
	
	push offset cale_fisier
	push offset cale_fisier_auxiliar
	call rename
	add esp, 8
	
	push offset mode_r_w
	push offset cale_fisier
	call fopen
	add esp, 8
	mov esi, eax
	
		mov esp, ebp
		pop ebp
		ret
stergere endp

start:
	
	afisare msg1
	citire format1, offset cale_fisier
	
	push offset mode_r_w
	push offset cale_fisier
	call fopen
	add esp, 8
	mov esi, eax
	
	cmp eax, 0
	je sfarsit_program
	
	;MENIU:
my_menu:	afisare msg2
			citire format1, offset operatia
			
			comparare offset operatia, offset iesire
			cmp eax, 0
			je sfarsit_program
			
			comparare offset operatia, offset findc
			cmp eax, 0
			jne cont1
			
			call gasire_car
			push eax
			push offset format4
			call printf 
			add esp, 8
			jmp my_menu
			
cont1: 		comparare offset operatia, offset toLower
			cmp eax, 0
			jne cont2
			call litere_mici
			jmp my_menu
			
cont2:		comparare offset operatia, offset toUpper
			cmp eax, 0
			jne cont3
			call litere_mari
			jmp my_menu
			
cont3:		comparare offset operatia, offset find
			cmp eax, 0
			jne cont4
			call gasire_secventa
			jmp my_menu

cont4: 		comparare offset operatia, offset replace
			cmp eax, 0
			jne cont5
			call inlocuire
			jmp my_menu
			
cont5: 		comparare offset operatia, offset delete
			cmp eax, 0
			jne cont6
			call stergere
			jmp my_menu
			
cont6: 		comparare offset operatia, offset toSentece 
			cmp eax, 0
			jne cont7
			call propozitii
			jmp my_menu
			
cont7: 		comparare offset operatia, offset afisare_continut
			cmp eax, 0
			jne cont8
			call afisare_continut_fisier
			;afisam si un \n
			push 10
			push offset format3
			call printf
			add esp, 8
			jmp my_menu
			
cont8: 		afisare msg3
			jmp my_menu

sfarsit_program:
	push 0
	call exit
end start