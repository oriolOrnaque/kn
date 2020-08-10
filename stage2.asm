[BITS 16]

STAGE2_ENTRY_POINT_SEGMENT 	EQU 0x50
KERNEL_ENTRY_POINT_SEGMENT 	EQU 0x100
KERNEL_LENGTH_IN_SECTORS	EQU 1

mov ax, STAGE2_ENTRY_POINT_SEGMENT
mov ds, ax

mov si, hello_label
call BIOS_print_string

mov ah, 0x42
mov si, kernel_disk_address_packet
mov dl, 0x80
int 0x13

jc kernel_loading_failed

jmp KERNEL_ENTRY_POINT_SEGMENT:0

kernel_loading_failed:
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

hello_label: db "Bootloader stage 2", 0

kernel_disk_address_packet:
	.size_of_dap	db 0x10
	.unused			db 0x0
	.n_sectors		dw KERNEL_LENGTH_IN_SECTORS
	.offset			dw 0x0
	.segment		dw KERNEL_ENTRY_POINT_SEGMENT
	.lba			dd 2
	.lba48			dd 0

times 512 - ($ - $$) db 0

