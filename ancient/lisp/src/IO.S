	idnt	io

	include	"common/hdr.i"

fptr:	equ	0
inptr:	equ	4
outptr:	equ	4
incnt:	equ	8
outcnt:	equ	8
nextc:	equ	12
bufst:	equ	16
bufnd:	equ	16+80
fbsize:	equ	16+80

	xdef	logfile
	.data

putsel:	ds.l 1
getsel: ds.l 1
logfile: ds.l 1

	.code

	xdef 	selget
selget:

	push.l	getsel
	move.l	a0,getsel
	pop.l	a0
	rts

	xdef		selput
selput:
	push.l	putsel
	move.l	a0,putsel
	pop.l	a0
	rts		

	xdef		putc
putc:	
	pushm.l a0/a1/a5
	move.l putsel,a5
	move.l	outptr(a5),a0
	move.b	d0,(a0)+
	move.l	a0,outptr(a5)
	lea bufnd(a5),a1
	cmp.l	a1,a0
	beq.s	putout
	cmpi.b	#10,d0
	bne		putex

putout:
	pushm.l	d0-d3
	move.l	fptr(a5),d1
	lea bufst(a5),a0
	move.l a0,d2
	move.l	outptr(a5),d3
	sub.l	d2,d3
	doscall	Write
	move.l logfile,d1
	beq.s 1$
		move.l d1,a0
		move.l	fptr(a0),d1
		lea bufst(a5),a0
		move.l a0,d2
		move.l	outptr(a5),d3
		sub.l	d2,d3
		doscall	Write
1$:
	popm.l	d0-d3
	lea bufst(a5),a0
	move.l	a0,outptr(a5)

putex:
	popm.l a0/a1/a5
	rts

	xdef		flushout
flushout:
	pushm.l	d0-d3/a0-a1/a5
	move.l	putsel,a5
	move.l fptr(a5),d1
	lea.l	bufst(a5),a0
	move.l a0,d2
	move.l	outptr(a5),d3
	sub.l	d2,d3
	doscall	Write
	move.l logfile,d1
	beq.s 1$
		move.l d1,a0
		move.l	fptr(a0),d1
		lea bufst(a5),a0
		move.l a0,d2
		move.l	outptr(a5),d3
		sub.l	d2,d3
		doscall	Write
1$:
	lea bufst(a5),a0
	move.l	a0,outptr(a5)
	popm.l	d0-d3/a0-a1/a5
	rts

	xdef		.newline
.newline:
	push.l	d0
	move.b	#10,d0
	jsr		putc
	pop.l	d0
	rts

	xdef		.space
.space:
	push.l	d0
	move.b	#32,d0
	jsr		putc
	pop.l	d0
	rts

	xdef		.comma
.comma:
	push.l	d0
	move.b	#',',d0
	jsr		putc
	pop.l	d0
	rts

	xdef		pstring
pstring:
	push.l	d0
1$:	move.b	(a0)+,d0
	beq.s	2$
	jsr		putc
	bra.s	1$

2$:	pop.l	d0
	rts

pdigit:
	push.l	d0
	and.b	#15,d0
	cmp.b	#10,d0
	blt.s	1$
	add.b	#7,d0
1$:	add.b	#$30,d0
	jsr		putc
	pop.l	d0
	rts

	xdef		pbyte
pbyte:
	push.l	d0
	lsr.b	#4,d0
	jsr		pdigit
	pop.l	d0
	jsr		pdigit
	rts

	xdef		pword
pword:
	push.l	d0
	lsr.w	#8,d0
	jsr		pbyte
	pop.l	d0
	jsr		pbyte
	rts

	xdef		p24
p24:
	swap		d0
	jsr		pbyte
	swap		d0
	jsr		pword
	rts


	xdef		plong
plong:
	swap		d0
	jsr		pword
	swap		d0
	jsr		pword
	rts


	xdef	pdecs
pdecs:
	tst.l	d0
	bpl.s	pdec
	putcon	'-'
	push.l	d0
	neg.l	d0
	jsr		pdec
	pop.l	d0
	rts

	xdef		pdec
pdec:
	tst.l	d0
	bne.s	pdnz
	putcon	'0'
	rts	

pdnz:
	tst.l	d0
	bne.s	1$
	rts
1$:	push.l	d0
	push.l	d1
	jsr		div10
	jsr		pdnz
	move.b	d1,d0
	jsr		pdigit
	pop.l	d1
	pop.l	d0
	rts


div10:
	clr.l	d1
	swap	d0
	move.w	d0,d1
	divu		#10,d1
	move.w	d1,d0
	swap		d0
	move.w	d0,d1
	divu		#10,d1
	move.w	d1,d0
	clr.w	d1
	swap		d1
	rts	


	xdef	getc
getc:
	push.l a5
	move.l getsel,a5
	move.l nextc(a5),d0
	clr.l nextc(a5)
	tst.l d0
	beq.s 9$
	pop.l a5
	rts

9$:	push.l	a0
	tst.l	incnt(a5)
	beq.s	5$
	bpl	x1

5$:	pushm.l	d1-d3/a0-a1
	move.l	fptr(a5),d1
	lea	bufst(a5),a0
	move.l a0,inptr(a5)
	move.l a0,d2
	move.l	#80,d3
	doscall	Read
	popm.l	d1-d3/a0-a1

	move.l	d0,incnt(a5)
	beq.s	3$
	bpl.s	x1
3$:	subq.l	#1,d0
	clr.l	incnt(a5)
	bra.s	x2

x1:	move.l	inptr(a5),a0
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,inptr(a5)
	subq.l	#1,incnt(a5)

x2:	pop.l a0
	pop.l a5
	rts	

	xdef		getupper
getupper:
	jsr		getc
	cmp.l	#'a',d0
	blt.s	1$
	cmp.l	#'z',d0
	bgt.s	1$
	sub.b	#32,d0
1$:	rts


	xdef		peekc
peekc:	push.l a5
	move.l getsel,a5
	move.l	nextc(a5),d0
	tst.l	d0
	beq.s	1$
	pop.l a5
	rts

1$:	jsr	getc
	move.l	d0,nextc(a5)
	pop.l a5
	rts

	xdef		isnext
isnext:
	push.l	d0
	jsr		peekc
	cmp.l	(sp)+,d0
	rts

	xdef		isspace
isspace:
	jsr		peekc
	cmp.b	#' ',d0
	rts

	xdef		iswhite
iswhite:
	jsr		peekc
	cmp.b	#' ',d0
	bgt.s	1$
	cmp.b	d0,d0
1$:	rts



	xdef		isnl
isnl:
	jsr		peekc
	cmp.b	#10,d0
	rts

	xdef		isdigit
isdigit:
	jsr	peekc
	cmp.b	#'0',d0
	blt.s	1$
	cmp.b	#'9',d0
	bgt.s	1$
	cmp.b	d0,d0
1$:	rts


	xdef	ishex
ishex:
	jsr	peekc
	cmp.b	#'0',d0
	blt.s	1$
	cmp.b	#'9',d0
	ble.s	2$
	cmp.b	#'A',d0
	blt.s	1$
	cmp.b	#'F',d0
	ble.s	2$
	cmp.b	#'a',d0
	blt.s	1$
	cmp.b	#'f',d0
	bgt.s	1$
2$:	cmp.b	d0,d0
1$:	rts


	xdef		isalpha
isalpha:
	jsr		peekc
	cmp.b	#'A',d0
	blt.s	1$
	cmp.b	#'Z',d0
	ble.s	2$
	cmp.b	#'a',d0
	blt.s	1$
	cmp.b	#'z',d0
	bgt.s	1$
2$:	cmp.b	d0,d0
1$:	rts


	xdef	skip
skip:
	push.l	d0
2$:	jsr	isspace
	bne.s	1$
	jsr	getc
	bra.s	2$
1$:	pop.l	d0
	rts

	xdef	flushin
flushin:
	push.l	d0
1$:	jsr	getc
	cmp.b	#10,d0
	bne.s	1$
	pop.l	d0
	rts

	xdef	ghex
ghex:
	jsr	skip
	jsr	peekc
	cmp.b	#'-',d0
	bne.s	1$

	jsr	getc
	jsr	ghex
	neg.l	d0
	rts

1$:	push.l	d1
	clr.l	d1
	
2$:	jsr	ishex
	bne.s	3$
	jsr	getupper
	sub.b	#'0',d0
	cmp.b	#9,d0
	ble.s	4$
	sub.b	#7,d0
4$:	lsl.l	#4,d1
	add.l	d0,d1
	bra.s	2$

3$:	move.l	d1,d0
	pop.l	d1
	rts	


	xdef	gdec
gdec:
	jsr	skip
	jsr	peekc
	cmp.b	#'-',d0
	bne.s	1$

	jsr	getc
	jsr	gdec
	neg.l	d0
	rts

1$:	push.l	d1
	push.l	d2
	clr.l	d1
	
2$:	jsr	isdigit
	bne.s	3$
	jsr	getc
	sub.b	#'0',d0
	lsl.l	#1,d1
	move.l	d1,d2
	lsl.l	#2,d1
	add.l	d2,d1
	add.l	d0,d1
	bra.s	2$

3$:	move.l	d1,d0
	pop.l	d2
	pop.l	d1
	rts	

	.code
	xdef	startup
startup:
	pushm.l d0/d1/a0/a1

	clr.l	d0		;get address of amigados libr
	lea	xname,a1
	execcall OpenLibrary
	move.l	d0,dosbase

	doscall	Output		;open stdout
	move.l d0,a0
	jsr mkfb
	move.l	a0,stdout
	jsr	selput

	doscall	Input		;open stdin
	move.l d0,a0
	jsr mkfb
	move.l	a0,stdin

	jsr	selget

	clr.l	logfile

	move.l	#conname,a0	;open stderr

	jsr fwopen
	move.l	a0,stderr

 ;	message	<starting up>

	pop.l	a1
	pop.l	a0
	pop.l	d1
	pop.l	d0

	rts

xname:	DOSNAME
conname:
	dc.b	'*',0

	.data

	xdef		dosbase
	xdef		stdin
	xdef		stdout
	xdef		stderr
dosbase:	ds.l		1
stdin:	ds.l		1
stdout	ds.l		1
stderr	ds.l		1

	code
	xdef		shutdown
shutdown:

;	message	<shutting down>

	move.l stderr,a0
	jsr fclose

	move.l stdin,a0
	jsr free
	move.l stdout,a0
	jsr free

	move.l	dosbase,a1
	execcall CloseLibrary

	clr.l	d0
	rts

	xdef		.rdump
.rdump:
	push.l	d0
	print	< d0=>
	jsr		plong
	print	< d1=>
	move.l	d1,d0
	jsr		plong
	print	< d2=>
	move.l	d2,d0
	jsr		plong
	print	< d3=>
	move.l	d3,d0
	jsr		plong
	newline
	print	< d4=>
	move.l	d4,d0
	jsr		plong
	print	< d5=>
	move.l	d5,d0
	jsr		plong
	print	< d6=>
	move.l	d6,d0
	jsr		plong
	print	< d7=>
	move.l	d7,d0
	jsr		plong
	newline
	print	< a0=>
	move.l	a0,d0
	jsr		plong
	print	< a1=>
	move.l	a1,d0
	jsr		plong
	print	< a2=>
	move.l	a2,d0
	jsr		plong
	print	< a3=>
	move.l	a3,d0
	jsr		plong
	newline
	print	< a4=>
	move.l	a4,d0
	jsr		plong
	print	< a5=>
	move.l	a5,d0
	jsr		plong
	print	< a6=>
	move.l	a6,d0
	jsr		plong
	print	< a7=>
	move.l	a7,d0
	jsr		plong
	newline
	pop.l	d0	
	rts

;dump hex words
;input : d0 = number of bytes
;a0 = address to dump

	xdef	.dump
.dump:
	pushm.l	d0-d2	;save registers

	move.w	d0,d2	;use d2 for  line counter
	add.w	#15,d2	;round up
	lsr.w	#4,d2	;calc number of lines
	bra.s	4$

2$:	move.l	a0,d0	;print address at beginning of line
	jsr		p24
	putcon	':'
	space

	push.l	a0		;save address for ii dump

	move.w	#8,d1	;start line loop
	bra.s	3$

1$:	move.w	(a0)+,d0	;print a word
	jsr		pword

	space			;space and loop for eight words
3$:	dbra		d1,1$

	space
	space

	pop.l	a0		;get address back
	move.w	#16,d1	;16 ascii characters
	bra.s	5$

6$:	move.b	(a0)+,d0
	cmpi.b	#' ',d0
	blt.s	7$
	cmpi.b	#$7f,d0
	bge.s	7$
	jsr		putc
	bra.s	5$
7$:	putcon	'.'
5$:	dbra		d1,6$

	newline			;finish line and loop on line count
4$:	dbra		d2,2$

	popm.l	d0-d2	;finish up and leave
	rts



	xdef malloc
malloc:
	addq.l #4,d0
	push.l d1
	push.l d0
	push.l a1
	move.l #0,d1
	execcall AllocMem
	move.l d0,a0
	pop.l a1
	pop.l d0
	move.l d0,(a0)+
	pop.l d1
	subq.l #4,d0
	rts

	xdef free
free:
	pushm.l d0/d1/a0/a1
	move.l a0,a1
	move.l -(a1),d0
	execcall FreeMem
	popm.l d0/d1/a0/a1
	rts


	xdef fropen
fropen:
	pushm.l d0/d1/d2/a1
	move.l #MODE_OLDFILE,d2
	bra.s frw

	xdef fwopen
fwopen:
	pushm.l d0/d1/d2/a1
	move.l #MODE_NEWFILE,d2

frw:	move.l a0,d1
	doscall Open
	tst.l d0
	beq.s nopn
	move.l d0,a0
	jsr mkfb
	popm.l d0/d1/d2/a1
	rts

nopn:
	lea 0,a0
	popm.l d0/d1/d2/a1
	rts


 xdef mkfb
mkfb:
	pushm.l d0/d1/a1
	move.l a0,a1
	move.l #fbsize,d0
	jsr malloc
	move.l a1,fptr(a0)
	lea bufst(a0),a1
	move.l a1,inptr(a0)
	clr.l incnt(a0)
	clr.l nextc(a0)	
	popm.l d0/d1/a1
	rts


	xdef fclose
fclose:
	pushm.l d0/d1/a0/a1
	move.l fptr(a0),d1
	jsr free
	doscall Close
	popm.l d0/d1/a0/a1
	rts


