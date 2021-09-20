[bits 32]

extern pmain

mov ebx,0xB8000
mov ah,2
mov al,'K'
mov [ebx],ax

call pmain

hlt
