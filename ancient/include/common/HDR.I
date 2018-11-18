	NOPAGE
	NOLIST


	include	'exec/types.i'
	include	'exec/libraries.i'
	include	'exec/nodes.i'
	include	'exec/funcdef.i'
	include	'exec/exec_lib.i'
	include	'libraries/dos.i'
	include	'libraries/dos_lib.i'

	LIST

.code:	macro
		section stuff,code
		endm

.data:	macro
		section things,data
		endm

.bss:	macro
		section junk,bss
		endm

.even:	macro
		cnop 0,2
		endm

.long:	macro
		dc.l		\1
		ifgt NARG-1
		dc.l \2
		endc
		endm

.word:	macro
		dc.w		\1
		ifgt NARG-1
		dc.w \2
		endc
		endm

.byte:	macro
		dc.b		\1
		ifgt NARG-1
		dc.b \2
		endc
		endm


execcall:	macro
		push.l	a6
		move.l	4,a6
		jsr		_LVO\1(a6)
		pop.l	a6
		endm

doscall:	macro
		push.l	a6
		move.l	dosbase,a6
		jsr		_LVO\1(a6)
		pop.l	a6
		endm

message:	macro
		pushm.l	d0-d3/a0-a1
		move.l	stderr,a0		;do the write
		move.l	fptr(a0),d1
		move.l	#str\@,d2
		move.l	#stnd\@-str\@,d3
		doscall	Write
		popm.l	d0-d3/a0-a1
		bra.s	stn\@
str\@:	dc.b		'\1',10,0
stnd\@:
		cnop		0,2
stn\@:	
		endm


print:	macro
		push.l	a0
		move.l	#str\@,a0
		jsr		pstring
		pop.l	a0
		bra.s	stn\@
str\@:	dc.b		'\1',0
		cnop		0,2
stn\@:	
		endm

newline:	macro
		jsr	.newline
		endm

space:	macro
		jsr	.space
		endm

comma:	macro
		jsr	.comma
		endm

putcon:	macro
		push.l	d0
		move.b	#\1,d0
		jsr		putc
		pop.l	d0	
		endm


push:	macro
		move.\0	\1,-(sp)
		endm

pop:	macro
		move.\0	(sp)+,\1
		endm

pushm:	macro
		ifne NARG-1
		fail -pushm requires one arg-
		endc
		movem.\0	\1,-(sp)
		endm

popm:	macro
		ifne NARG-1
		fail -popm requires one arg-
		endc
		movem.\0	(sp)+,\1
		endm

rdump:	macro
		jsr		.rdump
		endm

dump:	macro
		push.l	d0
		push.l	a0
		move.l	\1,a0
		move.l	\2,d0
		jsr		.dump
		pop.l	a0
		pop.l	d0
		endm

see:		macro
		print	<\1 = >
		push.l	d0
		move.l	\1,d0
		jsr		plong
		pop.l	d0
		space
		endm


string:	macro
		move.l	#str\@,\2
		bra.s	stn\@
str\@:	dc.b		'\1',0
stnd\@:
		cnop		0,2
stn\@:	
		endm


