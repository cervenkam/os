%.bin: main.asm  hello.asm gdt.asm print.asm protected.asm
	nasm -f bin $< -o $@
main: main.bin
	qemu-system-x86_64 -hda main.bin
