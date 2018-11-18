newnode:	macro
	move.l	d7,\1
	move.l	(\1),d7
	endm

follow: macro
	move.l	car(\1),\2
	move.l	cdr(\1),\1
	endm


;add a new node to the head of a list
cons:	macro	;new head, list pointer,scratch
	newnode	\3
	clr.l	(\3)
	move.l	\1,car(\3)
	move.l	\2,cdr(\3)
	move.l	\3,\2
	endm




eval:	macro	;a0 = form to eval
    ifnd evalfun
      xref evalfun
    endc
	move.w	(a0),d0	;get node type
	jmp		y\@(d0.w)

	cnop 0,8
y\@:
;type 0 - a list
	jsr		evalfun
	bra.s	x\@
	cnop 0,8
;type 1 - num	
	bra.s	x\@
	nop
	nop
	nop
;type 2 - rational	
	bra.s	x\@
	nop
	nop
	nop
;type f - float	
	bra.s	x\@
	nop
	nop
	nop
;type 3 - string
	bra.s	x\@
	nop
	nop
	nop
;type 4 - array
	bra.s	x\@
	nop
	nop
	nop
;type 5 - char
	bra.s	x\@
	nop
	nop
	nop
;type 6 - primitive
	bra.s	x\@
	nop
	nop
	nop
;type 6 - special function
	bra.s	x\@
	nop
	nop
	nop
;type 7 - symbol
	move.l	sym_value(a0),a0
x\@:
	endm


signal_error:	macro
		ifnd error
		    xref error
		endc
		jmp	error
		endm


primitive:	macro
		ifnd make_primitive
			xref make_primitive
		endc
		ifeq NARG-2
			move.l	#\2,d0
		endc
		ifne NARG-2
			move.l	#\1,d0
		endc
		move.l	#str\@,d1
		jsr		make_primitive
		bra.s	stn\@
str\@:	dc.b		'\1',0
		cnop		0,2
stn\@:	
		endm



special:	macro
		ifnd make_special
			xref make_special
		endc
		ifeq NARG-2
			move.l	#\2,d0
		endc
		ifne NARG-2
			move.l	#\1,d0
		endc
		move.l	#str\@,d1
		jsr		make_special
		bra.s	stn\@
str\@:	dc.b		'\1',0
		cnop		0,2
stn\@:	
		endm



linkst:	macro
	link		a6,#0
	endm


linknd:	macro
	link		a6,#0
	endm

remlinks:	macro
		unlk		a6
		unlk		a6
		endm

linkm:	macro	;aregs
		link		a6,#0
		movem.l	\1,-(sp)
		link		a6,#0
		endm

unlkm:	macro
		unlk		a6
		movem.l	(sp)+,\1
		unlk		a6
		endm

stackcheck:	macro
		ifnd		stackbot
		  xref	stackbot,stackovfl
		endc

		cmp.l	stackbot,sp
		bgt.s	x\@
		jsr		stackovfl
x\@:
		endm
