# Makefile contributed by jtsiomb

src = basic.asm

.PHONY: all
all: basic.img basic.com

basic.img: $(src)
	nasm -f bin -o $@ $(src)

basic.com: $(src)
	nasm -f bin -o $@ -Dcom_file=1 $(src)

.PHONY: clean
clean:
	$(RM) basic.img basic.com

.PHONY: rundosbox
rundosbox: basic.com
	dosbox $<

.PHONY: runqemu
runqemu: basic.img
	qemu-system-i386 -fda basic.img
