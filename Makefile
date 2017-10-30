run: main.bin
	find . -type f -name '*.bin' ! -name 'drive.bin' ! -name 'main.bin' -delete
	qemu-system-x86_64 -drive file=main.bin,format=raw -drive file=drive.bin,cache=none,format=raw
main.bin: loader.bin kernel.bin filesystem.bin editor.bin browser.bin images.bin
	cat $^ > $@
kernel.bin: kernel.asm characters.asm disk.asm splash.asm print.asm
	nasm -f bin kernel.asm -o $@
loader.bin: loader.asm print.asm
	nasm -f bin loader.asm -o $@
filesystem.bin: filesystem.asm
	nasm -f bin filesystem.asm -o $@
editor.bin: editor.asm
	nasm -f bin editor.asm -o $@
browser.bin: $(wildcard browser/*.asm) print.asm
	nasm -f bin browser/browser.asm -o $@
images.bin: $(wildcard images/*.asm) print.asm
	nasm -f bin images/images.asm -o $@
clean:
	find . -type f -name '*.bin' ! -name 'drive.bin' -delete
