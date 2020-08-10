[BITS 16]
[org 0x1000]

mov ax, 0
mov ds, ax
mov es, ax

cli

in al, 0x92
or al, 2
out 0x92, al

lgdt [gdt_descriptor]

mov eax, cr0
or eax, 1
mov cr0, eax

jmp CODE_SEGMENT:PModeMain

[BITS 32]

PModeMain:
	mov eax, 0x654321
	mov edx, 0xb8000
	mov al, 0x41
	mov ah, 0x1B
	mov [edx], ax
	inc edx
	inc edx
	mov al, 0x42
	mov [edx], ax
	inc edx
	inc edx
	mov al, 0x43
	mov [edx], ax

	mov ebx, message
	call print32

	jmp $

print32:
	pusha ;push all registers
	mov edx, 0xb8000 ;start video memory address
	.loop:
	mov al, [ebx] ;get next char
	mov ah, 0xf
	cmp al, 0	;if next char equals 0
	je .done 	;exit
	mov [edx], ax	;video mem <- char
	add ebx, 1		;string_pointer++
	add edx, 2		;video_mem_pointer += 2
	jmp .loop
	.done:
	popa	;pop all registers
	ret

gdt_start:
	gdt_null_segment:
		dq 0
	gdt_code_segment:
		dw 0xffff
		dw 0x0000
		db 0
		db 10011010b
		db 11001111b
		db 0
	gdt_data_segment:
		dw 0xffff
		dw 0x0000
		db 0
		db 10010010b
		db 11001111b
		db 0
gdt_end:

CODE_SEGMENT EQU gdt_code_segment - gdt_start
DATA_SEGMENT EQU gdt_data_segment - gdt_start

message:
	db "Hello world from my operating system", 0

gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

times 512 - ($ - $$) db 0
