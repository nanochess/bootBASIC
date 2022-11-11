# Makefile contributed by jtsiomb

src = basic.asm

.PHONY: all
all: basic.img basic.com basic.rom

basic.rom: $(src) addchecksum
	nasm -f bin -o $@.tmp -Dbootrom $(src)
	dd if=/dev/zero of=$@ bs=1 count=1024
	dd if=$@.tmp of=$@ bs=1 conv=notrunc
	./addchecksum $@ || rm $@
	rm $@.tmp

basic.img: $(src)
	nasm -f bin -o $@ -Dbootsect $(src)

basic.com: $(src)
	nasm -f bin -o $@ -Dcom_file $(src)

addchecksum: addchecksum.c
	gcc -o $@ $< -Wall

.PHONY: clean
clean:
	$(RM) basic.img basic.com basic.rom addchecksum

.PHONY: rundosbox
rundosbox: basic.com
	dosbox $<

.PHONY: runqemufd
runqemufd: basic.img
	qemu-system-i386 -fda basic.img

.PHONY: runqemurom
runqemurom: basic.rom
	qemu-system-i386  -net none -option-rom basic.rom
