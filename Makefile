%.bin: $(wildcard *.asm)
	nasm -f bin main.asm -o main.bin
main: main.bin
	qemu-system-x86_64 -drive file=main.bin,format=raw -drive file=drive.bin,cache=none,format=raw
clean:
	rm *.bin
