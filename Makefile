%.bin: %.asm
	nasm -f bin $< -o $@
run: hello.bin
	qemu-system-x86_64 -hda hello.bin
