# spusteni OS v qemu
run: ../compiled/main.bin
	# smazani vsech jiz nepotrebnych binarnich souboru
	 find . -type f -name '*.bin' ! -name 'drive.bin' ! -name 'main.bin' -delete
	# spusteni programu v qemu
	qemu-system-x86_64 -drive file=../compiled/main.bin,format=raw -drive file=../compiled/drive.bin,cache=none,format=raw # -rtc base='2017-11-23T20:00:00'
# vytvoreni binarniho obrazu OS
../compiled/main.bin: loader.bin kernel.bin info.bin filesystem.bin editor.bin browser.bin 15.bin images.bin menu.bin
	# k tomu pouzijeme "linker" - proste vlozime dane soubory za sebe
	cat $^ > ../compiled/$@
# kompilace jadra FailOSu
kernel.bin: kernel.asm disk.asm splash.asm
	# preklad jadra FailOSu assemblerem "nasm"
	nasm -f bin kernel.asm -o $@
# kompilace loaderu FailOSu
loader.bin: loader.asm
	# preklad loaderu FailOSu assemblerem "nasm"
	nasm -f bin loader.asm -o $@
# kompilace menu FailOSu
menu.bin: menu.asm
	# preklad menu FailOSu assemblerem "nasm"
	nasm -f bin menu.asm -o $@
# kompilace programu FailFATky
filesystem.bin: $(wildcard filesystem/*.asm)
	# preklad FailFATky assemblerem "nasm"
	nasm -f bin filesystem/filesystem.asm -o $@
# kompilace editoru FailOSu
editor.bin: editor.asm
	# preklad editoru assemblerem "nasm"
	nasm -f bin editor.asm -o $@
# kompilace prohlizece souboru FailOSu
browser.bin: $(wildcard browser/*.asm)
	# preklad prohlizece assemblerem "nasm"
	nasm -f bin browser/browser.asm -o $@
# kompilace graficke knihovny FailOSu
images.bin: $(wildcard images/*.asm)
	# preklad graficke knihovny assemblerem "nasm"
	nasm -dSTYLES=doom -f bin images/images.asm -o $@
# kompilace informativni obrazovky FailOSu
info.bin: $(wildcard info/*.asm)
	# preklad info obrazovky assemblerem "nasm"
	nasm -f bin info/info.asm -o $@
# kompilace Lloydovy 15ky
15.bin: 15.asm
	# preklad Lloydovy 15ky assemblerem "nasm"
	nasm -f bin 15.asm -o $@
# smazani prelozenych souboru
clean:
	# smazani vsech nepotrebnych binarnich souboru
	find . -type f -name '*.bin' -delete
	rm ../compiled/main.bin
