[BITS 16]

STAGE2_LENGTH_IN_SECTORS EQU 1
STAGE2_ENTRY_POINT_SEGMENT EQU 0x50

mov ax, 0x7c0
mov ds, ax

mov si, hello_label
call BIOS_print_string

mov ah, 0x41
mov bx, 0x55aa
mov dl, 0x80
int 0x13

jc extensions_not_supported

mov si, extensions_supported_label
call BIOS_print_string

mov si, loading_stage2_label
call BIOS_print_string

mov ah, 0x42
mov si, stage2_disk_address_packet
mov dl, 0x80
int 0x13

jmp STAGE2_ENTRY_POINT_SEGMENT:0

extensions_not_supported:
	mov si, extensions_not_supported_label
	call BIOS_print_string
	;perform simple read int0x13 ax = 0x2
	jmp $


BIOS_print_string:
		mov ah, 0xe
	.next_byte:
		lodsb
		test al, al
		je .null_byte
		int 0x10
		jmp .next_byte
	.null_byte:
		call BIOS_print_newline
		ret

BIOS_print_newline:
		mov ah, 0xe
		mov al, 0xa
		int 0x10
		mov al, 0xd
		int 0x10
		ret

hello_label: db "Init bootloader", 0
extensions_supported_label: db "Extensions supported", 0
extensions_not_supported_label: db "Extensions not supported", 0
loading_stage2_label: db "Loading stage 2", 0

stage2_disk_address_packet:
	.size_of_dap	db 0x10
	.unused			db 0x0
	.n_sectors		dw STAGE2_LENGTH_IN_SECTORS
	.offset			dw 0x0
	.segment		dw STAGE2_ENTRY_POINT_SEGMENT
	.lba			dd 1
	.lba48			dd 0

times 510 - ($ - $$) db 0
dw 0xaa55

