HDD = hdd

assemble:
	nasm -f bin stage1.asm
	nasm -f bin stage2.asm
	nasm -f bin kernel.asm
	dd if=stage1 of=$(HDD) conv=notrunc
	dd if=stage2 of=$(HDD) seek=1 conv=notrunc
	dd if=kernel of=$(HDD) seek=2 conv=notrunc

run:
	qemu-system-x86_64 -drive format=raw,file=$(HDD)

clean:
	shred -uz stage1
	shred -uz stage2
	shred -uz kernel
