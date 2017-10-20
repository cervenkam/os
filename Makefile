run: main
	qemu-system-x86_64 -drive file=main,format=raw -drive file=drive.bin,cache=none,format=raw
main: kernel loader
	cat loader kernel > main
kernel: kernel.asm characters.asm disk.asm splash.asm print.asm
	nasm -f bin kernel.asm -o $@
loader: loader.asm print.asm
	nasm -f bin loader.asm -o $@
clean:
	rm main kernel loader
