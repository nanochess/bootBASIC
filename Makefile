# Makefile contributed by jtsiomb

src = basic.asm

.PHONY: all
all: basic.img basic.com basic.rom

basic.rom: $(src) addchecksum
	nasm -f bin -o $@ -Dbootrom=1 -Dbootsect=0 -Dcom_file=0 $(src)
	./addchecksum $@ || rm $@

basic.img: $(src)
	nasm -f bin -o $@ -Dbootsect=1 -Dbootrom=0 -Dcom_file=0 $(src)

basic.com: $(src)
	nasm -f bin -o $@ -Dcom_file=1 -Dbootsect=0 -Dbootrom=0 $(src)

addchecksum: addchecksum.c
	gcc -o $@ $< -Wall

.PHONY: clean
clean:
	$(RM) basic.img basic.com basic.rom addchecksum

.PHONY: rundosbox
rundosbox: basic.com
	dosbox $<

.PHONY: fdrunqemu
runqemu: basic.img
	qemu-system-i386 -fda basic.img

.PHONY: romrunqemu
runqemu: basic.rom
	qemu-system-i386  -net none -option-rom basic.rom
