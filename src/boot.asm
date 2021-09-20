; bootloader para SSE

[bits 16] ;estamos rodando no modo real

jmp short inicio

nop

;-----------------------------------------------------
;			  TABELA DESCRITIVA DE DISCO
;-----------------------------------------------------
DiskLabel					db "TEST    "
BytesSetor					dw 512
SetorCluster				db 1
ReservadoParaBoot			dw 1
NumeroFats					db 2
EntradasRaiz				dw 224
SetoresLogicos				dw 2880 ; 1.44mb
TipoDeDisco					db 0xF0
SetoresPorFat				dw 9
SetoresPorTrack				dw 18
Lados						dw 2
SetoresOcultos				dd 0
SetoresGrande				dd 0
NumeroBoot					db 0
RESERVADO 					db 0
SinalDeBoot					db 0x29
IdDeVolume					dd 0xFFFFFFFF
LabelDoVolume				db "BOOT       "
SistemaArquivos				db "FAT12   "

;----------------------------------------------------------

;inicialisar registros de stack e do segmento de dados

inicio:
	
	cli
	mov ax,0x7C0
	mov ds,ax
	mov ss,ax
	mov sp,0x8000 ; 31.5kb stack
	sti
	
	mov [NumeroBoot], dl
	
	mov ah, 8 ;parametros de disco
	int 0x13
	;A FAZER: mensagem de erro
	
	mov dh,dl
	xor dh,dh
	inc dx
	mov [Lados],dx
	
	and cx, 0b00111111 ; setores por track
	mov [SetoresPorTrack],cx
	

	;carregar a pasta raiz para a memoria
	
	mov bx,0x1000
	mov es,bx
	xor bx,bx
	
	mov cx,14 ; 224 * 32 / 512 = 14
	
	mov ax,19 ; setor da pasta raiz no disco 
	
	call carregar_setores
	
	; encontrar o arquivo na pasta raiz
	
	mov di,0
	mov cx,224
	
	.encontrar_arquivo:
		push di
		push cx
		
		mov cx, 11
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

	;a entrada certa estará em es:bx quando dermos pop no bx
	pop cx ; limpar o stack
	
	pop bx
	add bx,0x1A
	mov word bx,[es:bx]
	mov [debug],bx
	mov word [setoratual],bx
	
	; carregar a FAT para a memoria
	
	mov ax, 1 ; FAT está no setor depois dos reservados
	mov cx, 9 ; 9 setores por FAT
	
	mov bx,ds
	mov es,bx
	mov bx,fim_arquivo

	call carregar_setores
	
	mov bx,0x1000
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
	mov dx,0
	int 14h
	popa
	
	call carregar_setores
	
	pop bx
	add bx,512
	push bx
	
proximo_setor:
	
	;calcular o proximo setor
	
	mov ax,[setoratual]
	xor dx,dx
	mov cx,3
	mul cx
	mov cx,2
	div cx
	
	; apontar ds:si para a proxima entrada da FAT
	
	mov si,fim_arquivo 
	add si,ax
	
	;pegar a proxima entrada da fat 
	
	mov ax, [ds:si]
	
	;ver se é par ou impar
	
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
	
	jmp 0x1000:0000 ; far jump para o kernel carregado em memoria
	
	
	
;----------------------------------------------------------
;						SUBROTINAS
;----------------------------------------------------------

resetar_disco:
	pusha
	xor ah,ah ; resetar disco
	mov dl, [NumeroBoot]
	
	int 0x13 ; serviços de disco
	popa
	ret

;----------------------------------------------------------

;ax = LBA do primeiro setor a carregar, cx = numero de setores para carregar, ES:BX = aonde carregar na memoria. 

carregar_setores:
	
	pusha
	
	push cx
	push bx
	
	mov bx,ax
	
	;converter LBA para CHS
	
	mov bx, ax			

	xor dx,dx			
	div word [SetoresPorTrack]
	add dl, 0x01		
	mov cl, dl			
	mov ax, bx

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
		
	
;----------------------------------------------------------

; DS:SI = string terminada com 0

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

;----------------------------------------------------------
;						  Variaveis
;----------------------------------------------------------

setoratual: dw 0

arquivo: db "BOOT2   BIN", 0

str_erro_leitura: db "Erro ao ler disco!", 0
str_erro_nao_encontrado: db "Nao encontrado", 0 

debug: dw 0

;----------------------------------------------------------
;					  Assinatura de boot
;----------------------------------------------------------

times 510-($-$$) db 0
dw 0xAA55

fim_arquivo:
