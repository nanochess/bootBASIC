	;
	; BASIC interpreter
        ;
        ; http://nanochess.org/
        ;
        ; (c) Copyright 2019 Oscar Toledo G.
        ;
        ; Creation date: Jul/19/2019.
	;

        cpu 8086

    %ifdef com_file
	org 0x0100
    %else
        org 0x7c00
    %endif

vars:		equ 0x7e00
stack:          equ 0x7e7c
running:        equ 0x7e7e
line:           equ 0x7e80
program:        equ 0x7f00
max_row:        equ 1000
max_line:	equ 20
max_size:	equ max_row*max_line

start:
	cld
        mov di,vars
        mov al,0x0d
        mov cx,program+max_size-vars
	rep stosb

main_loop:
        mov [stack],sp
        mov word [running],0
	mov al,'>'
	call output
        call input_line
	push si
	call input_number
	or ax,ax
	je f14
        call find_line
	xchg ax,di
	call spaces
	pop ax
f15:
	lodsb
	stosb
	cmp al,0x0d
	jne f15
	jmp main_loop

f14:	pop si
	call statement
	jmp main_loop

list:
        xor ax,ax
f29:    push ax
        call find_line
        xchg ax,si
        cmp byte [si],0x0d
        pop ax
        je f30
        push ax
        call output_number
        mov al,0x20
        call output
f31:    lodsb
        call output
        cmp al,0x0d
        jne f31
        pop ax
f30:    inc ax
        cmp ax,max_row
        jne f29
        ret

statement:
        call spaces
        cmp byte [si],0x0d
        je f27
	mov di,statements
f5:	push si
f16:    cmpsb
	jne f3
	cmp byte [di],0
        jne f16
	pop ax
	call spaces
        call word [di+1]
f27:
        mov ax,[running]
        test ax,ax
        je f6
        add ax,max_line
        mov [running],ax
        cmp ax,program+max_size
        xchg ax,si
        jne statement
        jmp main_loop

f3:	cmp byte [di],0
        je f4
	inc di
	jmp f3

f4:     add di,3
	pop si
        cmp byte [di],0
        jne f5
error:
        mov al,'@'
        call output
        mov al,'#'
        call output
        mov al,'!'
        call output
        mov al,0x0d
        call output
        mov sp,[stack]
        jmp main_loop

spaces:
        cmp byte [si],' '
	jne f6
	inc si
	jmp spaces

f6:	ret

output_number:
f26:
	xor dx,dx
	mov cx,10
	div cx
	or ax,ax
        je f8
	push dx
        call f26
	pop dx
f8:	mov al,dl
	add al,'0'
	jmp output

input_number:
	xor bx,bx
f11:	mov al,[si]
	sub al,'0'
	jc f12
	cmp al,10
	jnc f12
	cbw
        xchg ax,bx
        mov cx,10
        mul cx
        add bx,ax
	inc si
	jmp f11

f12:	xchg ax,bx
	ret

input_statement:
	lodsb
	and al,0x1f
	cbw
        add ax,ax
	add ax,vars
	push ax
	mov al,'?'
	call output
	call input_line
	call expr
	pop di
	stosw
	ret

if:
	call expr
	or ax,ax
        je f6
	call spaces
	jmp statement

run:
	xor ax,ax
	jmp f10

goto:
	call expr
f10:
        call find_line
        mov [running],ax
        xchg ax,si
        jmp statement

find_line:
        mov cx,max_row
        mul cx
        add ax,program
        ret

expr:
        call expr1
f20:    call spaces
        cmp byte [si],'+'
        je f18
        cmp byte [si],'-'
        je f19
        ret

f18:    inc si
        push ax
        call expr1
        pop cx
        add ax,cx
        jmp f20

f19:    inc si
        push ax
        call expr1
        pop cx
        xchg ax,cx
        sub ax,cx
        jmp f20

expr1:
        call expr2
f21:    call spaces
        cmp byte [si],'*'
        je f22
        cmp byte [si],'/'
        je f23
        ret

f22:    inc si
        push ax
        call expr2
        pop cx
        mul cx
        jmp f21

f23:    inc si
        push ax
        call expr2
        pop cx
        xchg ax,cx
        cwd
        div cx
        jmp f21

expr2:
        call spaces
        lodsb
        cmp al,'('
        jne f24
        call expr
        call spaces
        cmp byte [si],')'
        jne error
        inc si
        ret

f24:    cmp al,0x40
        jnc f25
        dec si
        jmp input_number
        
f25:    and al,0x1f
	cbw
        add ax,ax
	add ax,vars
        xchg ax,bx
        mov ax,[bx]
        ret

input_line:
	mov si,line
	push si
	pop di
f1:     call input_key
	cmp al,0x08
	jne f2
	dec di
	jmp f1

f2:
	stosb
	cmp al,0x0d
	jne f1
	ret

print:
	mov al,[si]
	cmp al,0x0d
        je f28
	cmp al,'"'
	jne f7
	inc si
f9:	lodsb
	cmp al,'"'
        je new_line
	call output
	jmp f9

f7:	call expr
        call output_number
        jmp new_line

input_key:
	mov ah,0x00
	int 0x16
output:
	cmp al,0x0d
        jne f17
new_line:
	mov al,0x0a
        call f17
	mov al,0x0d
f17:
	mov ah,0x0e
        int 0x10
f28:    ret

statements:
	db "print",0
	dw print
	db "run",0
	dw run
	db "input",0
        dw input_statement
	db "if",0
	dw if
	db "goto",0
	dw goto
;        db "new",0
;        dw start
;        db "system",0
;        dw 
        db "list",0
        dw list
	db 0
