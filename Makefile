run: main
	qemu-system-x86_64 -drive file=main,format=raw -drive file=drive.bin,cache=none,format=raw
main: kernel loader
	cat loader kernel > main
kernel: kernel.asm
	nasm -f bin $< -o $@
loader: loader.asm
	nasm -f bin $< -o $@
clean:
	rm main kernel loader
