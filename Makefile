%.bin: $(wildcard *.asm)
	nasm -f bin main.asm -o main.bin
main: main.bin
	qemu-system-x86_64 -hda main.bin
clean:
	rm *.bin
