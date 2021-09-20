[bits 16]
; TODO:

; more kinds of A20 enabling
; finish A20 check


;copy data from BIOS Parameter Block

mov ax,0x7c0
mov ds,ax
mov si,3
mov di,parametros_disco
mov cx,0x36+5

rep movsb

mov ax,0x1000 ; bootloader left us at segment 0x1000, so set up registers accordingly
mov ds,ax
mov es,ax

jmp load_main ; load main program into memory (and hope it's not big enough to cause problems)

; enable the A20 line in order to access over 1 mb of memory
prepare_prot_mode:	
	mov ax,0x2401
	int 0x15

	call test_A20
	
	test ax,ax
	jnz A20_fail
	
	; A20 enabled. load gdt and enable protected mode	
	
	cli
	
	mov ah,0
	mov al,0x13 ; 320x200 16 colour
	int 0x10

	lgdt [gdt_desc]
	mov eax, cr0
	or eax, 1
	mov cr0, eax	
	jmp dword 0x8:(prot_mode_entry + 0x10000)



;	returns 0 in ax if the A20 line is enabled

test_A20:

	; compare the bootsector identifier (0x7DFE) with the corresponding memoru location (FFFF:7E0E) to find out if A20 line is enabled
	
	xor ax,ax
	mov es,ax

	not ax
	mov ds,ax
	
	mov di,0x7DFE
	mov si,0x7E0E

	mov ax,[es:di]
	mov bx,[ds:si]

	cmp ax,bx
	jne .enabled

	; check if it's equal by just pure chance


		mov ax,1

	.enabled:
		
		mov ax,0x1000
		mov es,ax
		mov ds,ax

		xor ax,ax
		ret
	
A20_fail:
	
	mov ah,0xE
	mov al,'1'
	int 0x10
	
	cli
	hlt 

; just a bunch of copied shit from the bootloader lmaoooo

parametros_disco:
DiskLabel					db "        "
BytesSetor					dw 0
SetorCluster				db 0
ReservadoParaBoot			dw 0
NumeroFats					db 0
EntradasRaiz				dw 0
SetoresLogicos				dw 0
TipoDeDisco					db 0
SetoresPorFat				dw 0
SetoresPorTrack				dw 0
Lados						dw 0
SetoresOcultos				dd 0
SetoresGrande				dd 0
NumeroBoot					db 0
RESERVADO 					db 0
SinalDeBoot					db 0
IdDeVolume					dd 0
LabelDoVolume				db "           "
SistemaArquivos				db "        "


load_main:
	
	mov bx,0x2000
	mov es,bx
	xor bx,bx

	mov cx,14

	mov ax,19

	call carregar_setores

	mov di,0
	mov cx,224

	.encontrar_arquivo:
		push di
		push cx

		mov cx,11
		mov si, arquivo

		repe cmpsb

		je encontrado

		pop cx
		pop di
		add di,32
		loop .encontrar_arquivo

	mov si,str_erro_nao_encontrado
	call print

	cli
	hlt

encontrado:

	pop cx

	pop bx

	add bx,0x1A
	mov word bx,[ES:BX]
	mov [setoratual],bx

	mov ax, 1
	mov cx, 9

	mov bx,ds
	mov es,bx
	mov bx,file_end

	call carregar_setores

	mov bx,0x2000
	mov es,bx
	xor bx,bx
	push bx

	carregar_setor_fat:

	mov cx,1
	mov ax,[setoratual]
	add ax,31

	pop bx
	push bx

	pusha
	mov ah,1
	mov al,'L'
	mov dx,0
	int 14h
	popa

	call carregar_setores

	mov bx,es
	add bx,0x20
	mov es,bx

	proximo_setor:

	mov ax,[setoratual]
	xor dx,dx
	mov cx,3
	mul cx
	mov cx,2
	div cx

	mov si,file_end
	add si,ax

	mov ax,[ds:si]

	or dx,dx

	jz par

	impar:

		shr ax,4
		jmp fat_proximo

	par:

		and ax,0x0FFF

	fat_proximo:

	mov [setoratual], ax

	cmp ax, 0xFF8
	jae fim_fat

	jmp carregar_setor_fat

fim_fat:
	
	jmp prepare_prot_mode

resetar_disco:
	pusha
	xor ah,ah
	mov dl, [NumeroBoot]

	int 0x13
	popa 
	ret

carregar_setores:

	pusha

	push cx
	push bx

	mov bx,ax

	xor dx,dx
	div word [SetoresPorTrack]
	add dl, 0x01
	mov cl, dl
	mov ax,bx

	xor dx,dx
	div word [SetoresPorTrack]
	xor dx,dx
	div word [Lados]
	mov dh, dl
	mov ch, al
	
	;carregar os dados para o int 13
	
	pop bx
	pop ax
	
	mov dl, [NumeroBoot]
	
	call resetar_disco
	
	mov ah,2
	
	int 0x13
	jc .erro_leitura
	
	
	popa
	ret
	
	.erro_leitura:
		
		mov si, str_erro_leitura
		call print
		
		cli
		hlt


	print:
		pusha

		mov ah,0xE

		.loop:

			lodsb
			cmp al,0
			je .pronto
			int 0x10
			jmp .loop

		.pronto:
			popa
			ret


;---------- v

setoratual: dw 0
arquivo: db "MAIN       "

str_erro_leitura: db "stage2: Error while reading disk!", 0
str_erro_nao_encontrado: db "stage2: File not found!", 0








;	GDT

gdt: 	dq 0 ;null segment
	
	; code

	dw 0xFFFF	; limit 0-15 
	dw 0		; base  0-15

	db 0		; base 16-23
	db 0b10011010	; Present ring-0 code executable non-conforming readable 
	db 0b11001111	; 4k granularity 32bit | limit 16-19
	db 0		; base 24-31


	; data

	dw 0xFFFF	; limit 0-15
	dw 0		; base  0-15
	
	db 0 		; base 0-15
	db 0b10010010	; Present ring-0 data - non-comforming writable
	db 0b11001111	; 4k granularity 32bit | limit 16-19
	db 0 		; base 24-31
gdt_end:

times 10 db 0xFE

gdt_desc: 
dw gdt_end - gdt - 1
dd gdt + 0x10000

; PROTECTED MODE SECTION

[bits 32]

	extern k_main

	prot_mode_entry:
		;hlt
		mov ax,0x10
		mov ds, ax
		mov es, ax
		mov fs, ax
		mov gs, ax
		mov ss, ax
		
		mov ebx,0xB8000
		mov al,'m'
		mov ah,2
		mov [ebx],al
		
		;enable SSE for floating point operations

		mov eax, cr0
		and ax, 0xFFFB
		or ax, 0x2
		mov cr0, eax
		mov eax, cr4
		or ax, 3 << 9
		mov cr4, eax
		

		jmp 0x8:0x20000
		


file_end:
