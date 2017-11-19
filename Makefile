run: main.bin
	#find . -type f -name '*.bin' ! -name 'drive.bin' ! -name 'main.bin' -delete
	qemu-system-x86_64 -drive file=main.bin,format=raw -drive file=drive.bin,cache=none,format=raw
main.bin: loader.bin kernel.bin info.bin filesystem.bin editor.bin browser.bin 15.bin images.bin
	cat $^ > $@
kernel.bin: kernel.asm disk.asm splash.asm
	nasm -f bin kernel.asm -o $@
loader.bin: loader.asm
	nasm -f bin loader.asm -o $@
filesystem.bin: $(wildcard filesystem/*.asm)
	nasm -f bin filesystem/filesystem.asm -o $@
editor.bin: editor.asm
	nasm -f bin editor.asm -o $@
browser.bin: $(wildcard browser/*.asm)
	nasm -f bin browser/browser.asm -o $@
images.bin: $(wildcard images/*.asm)
	nasm -f bin images/images.asm -o $@
info.bin: $(wildcard info/*.asm)
	nasm -f bin info/info.asm -o $@
15.bin: 15.asm
	nasm -f bin 15.asm -o $@
clean:
	find . -type f -name '*.bin' ! -name 'drive.bin' -delete
