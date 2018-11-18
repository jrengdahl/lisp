	IDNT		struct

	include	'common/hdr.i'
	include	'common/io.i'

tnone	equ	0
tif	equ	1
telse	equ	2
tend	equ	3
tloop	equ	4
twhile	equ	5
tdo	equ	6
tuntil	equ	7
trepeat	equ	8
tcontinue equ	9
tbreak	equ	10

ccz	equ	0
ccnz	equ	1
cceq	equ	2
ccne	equ	3
cccc	equ	4
cccs	equ	5
ccvc	equ	6
ccvs	equ	7
ccpl	equ	8
ccmi	equ	9
ccgt	equ	10
ccle	equ	11
ccge	equ	12
cclt	equ	13
ccugt	equ	14
ccule	equ	15
ccuge	equ	16
ccult	equ	17

cctab:
	dc.l		'eq  '
	dc.l		'ne  ' 
	dc.l		'eq  '
	dc.l		'ne  ' 
	dc.l		'cc  '
	dc.l		'cs  '
	dc.l		'vc  '
	dc.l		'vs  '
	dc.l		'pl  '
	dc.l		'mi  '
	dc.l		'gt  '
	dc.l		'le  '
	dc.l		'ge  '
	dc.l		'lt  '
	dc.l		'hi  '
	dc.l		'ls  '
	dc.l		'cc  '
	dc.l		'cs  '
  
getcc:
	jsr	getc
	cmpi.b	#'n',d0
	beq	gcn
	cmpi.b	#'u',d0
	beq	gcu
	cmpi.b	#'z',d0
	beq	gcz
	cmpi.b	#'c',d0
	beq	gcc
	cmpi.b	#'v',d0
	beq	gcv
	cmpi.b	#'p',d0
	beq	gcp
	cmpi.b	#'m',d0
	beq	gcm
	cmpi.b	#'g',d0
	beq	gcg
	cmpi.b	#'l',d0
	beq	gcl
	cmpi.b	#'e',d0
	beq	gce

ilcc:
	newline
	print	<illegal condition code>
	message	<illegal condition code>
	newline
	clr.l	d0
	rts	

gcz:
	move.l	#ccz,d0
	rts

gce:	jsr	getc
	cmpi.b	#'q',d0
	bne	ilcc
	move.l	#cceq,d0
	rts

gcn:	jsr	getc
	cmpi.b	#'z',d0
	beq	gcnz
	cmpi.b	#'e',d0
	beq	gcne
	bra	ilcc

gcnz:
	move.l	#ccnz,d0
	rts

gcne:
	move.l	#ccne,d0
	rts


gcc:	jsr	getc
	cmpi.b	#'s',d0
	beq	gccs
	cmpi.b	#'c',d0
	beq	gccc
	bra	ilcc

gccs:
	move.l	#cccs,d0
	rts

gccc:
	move.l	#cccc,d0
	rts


gcv:	jsr	getc
	cmpi.b	#'s',d0
	beq	gcvs
	cmpi.b	#'c',d0
	beq	gcvc
	bra	ilcc

gcvs:
	move.l	#ccvs,d0
	rts

gcvc:
	move.l	#ccvc,d0
	rts

gcp:
	jsr	getc
	cmpi.b	#'l',d0
	bne	ilcc
	move.l	#ccpl,d0
	rts


gcm:
	jsr	getc
	cmpi.b	#'i',d0
	bne	ilcc
	move.l	#ccmi,d0
	rts


gcg:
	jsr	getc
	cmpi.b	#'t',d0
	beq	gcgt
	cmpi.b	#'e',d0
	beq	gcge
	bra	ilcc

gcgt:
	move.l	#ccgt,d0
	rts



gcge:
	move.l	#ccge,d0
	rts


gcl:
	jsr	getc
	cmpi.b	#'t',d0
	beq	gclt
	cmpi.b	#'e',d0
	beq	gcle
	bra	ilcc

gclt:
	move.l	#cclt,d0
	rts



gcle:
	move.l	#ccle,d0
	rts


gcu:
	jsr	getc
	cmpi.b	#'g',d0
	beq	gcug
	cmpi.b	#'l',d0
	beq	gcul
	bra	ilcc


gcug:
	jsr	getc
	cmpi.b	#'t',d0
	beq	gcugt
	cmpi.b	#'e',d0
	beq	gcuge
	bra	ilcc

gcugt:
	move.l	#ccugt,d0
	rts

gcuge:
	move.l	#ccuge,d0
	rts


gcul:
	jsr	getc
	cmpi.b	#'t',d0
	beq	gcult
	cmpi.b	#'e',d0
	beq	gcule
	bra	ilcc

gcult:
	move.l	#ccult,d0
	rts

gcule:
	move.l	#ccule,d0
	rts


isshort:
	jsr	peekc
	cmpi.b	#'.',d0
	bne	ishno
	jsr	getc
	jsr	getc
	cmpi.b	#'s',d0
	beq.s	ishyes

	newline
	print	<illegal dot modifier>
	message	<illegal dot modifeir>
	newline	

ishno:	clr.l	d0
	rts

ishyes:	moveq.l	#1,d0
	rts


putshort:
	tst.l	d0
	bne	1$
	rts

1$:	print	<.s>
	rts

	.data
labelnum: ds.l	1
startaddr: ds.l 1
contaddr: ds.l	1
breakaddr: ds.l 1
looplen: ds.l 1

	.code
getnostr:
	jsr	getc
	cmpi.b	#'''',d0
	beq.s	1$
2$:	rts

1$:	jsr	putc
	jsr	getc
	tst.l	d0
	blt	2$
	cmpi.b	#'''',d0
	bne	1$
	jsr	putc
	bra	getnostr

getnobkt:
	jsr	getnostr
	cmpi.b	#'<',d0
	beq.s	1$
2$:	rts

1$:	jsr	putc
	jsr	getc
	tst.l	d0
	blt	2$
	cmpi.b	#'>',d0
	bne	1$
	jsr	putc
	bra	getnobkt

getnocom:
	jsr	getnobkt
	cmp.b	#';',d0
	beq	1$
2$:	rts

1$:	jsr	putc
	jsr	getc		;ignore any quotes in comments
	tst.l	d0
	blt	2$
	cmpi.b	#10,d0
	bne	1$
	rts


;function to get characters from an input file after excluding strings, comments, and label fields.

getop:
	jsr	getnocom		;get a non-comment character
	tst.l	d0
	bge	1$			;return if end-of-file
2$:	rts

1$:	cmpi.b	#10,d0		;check for end-of-line
	beq	5$			;return end-of-line immediately
	cmpi.b	#' ',d0		;if whitespace go skip to start of op
	ble	4$			

3$:	jsr	putc			;else skip over the label until
	jsr	getnocom
	tst.l	d0			;eof
	blt	2$
	cmpi.b	#10,d0		;newline
	beq	5$	
	cmpi.b	#' ',d0		;or space	
	bgt	3$

4$:	jsr	putc			;skip over whitespace until
	jsr	getnocom
	tst.l	d0			;eof
	blt	2$
	cmpi.b	#10,d0		;newline
	beq	5$	
	cmpi.b	#' ',d0		;or nonspace	
	ble	4$
	rts

5$:	jsr	putc
	rts

skiprest:
	jsr	getc
	tst.l	d0
	blt	1$
	jsr	putc
	cmpi.b	#10,d0
	bne	skiprest
1$:	rts


gc:	macro
	jsr	getc
	tst.l	d0
	blt	endgetstruct
	endm

getstruct:
	jsr	getop
	tst.l	d0
	blt	endgetstruct
	cmpi.b	#10,d0
	beq	getstruct

	cmpi.b	#'i',d0
	beq	sti
	cmpi.b	#'e',d0
	beq	ste
	cmpi.b	#'l',d0
	beq	stl
	cmpi.b	#'w',d0
	beq	stw
	cmpi.b	#'d',d0
	beq	std
	cmpi.b	#'u',d0
	beq	stu
	cmpi.b	#'r',d0
	beq	str
	cmpi.b	#'c',d0
	beq	stc
	cmpi.b	#'b',d0
	beq	stb
	cmpi.b	#'t',d0
	beq	stt

nost:
	jsr	putc
	cmpi.b	#10,d0
	beq	getstruct
nend:
	jsr	skiprest
	bra	getstruct	

endgetstruct:	rts


sti:
	gc
	cmpi.b	#'f',d0
	beq	stif
	move.b	d0,d1
	move.b	#'i',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stif:
	gc
	cmpi.b	#'_',d0
	beq	stif_
	move.b	d0,d1
	move.b	#'i',d0
	jsr	putc
	move.b	#'f',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
ste:
	gc
	cmpi.b	#'l',d0
	beq	stel
	cmpi.b	#'n',d0
	beq	sten
	move.b	d0,d1
	move.b	#'e',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
sten:
	gc
	cmpi.b	#'d',d0
	beq	stendmaybe
	move.b	d0,d1
	move.b	#'e',d0
	jsr	putc
	move.b	#'n',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	

stendmaybe:
	jsr	iswhite
	beq	stend
	move.b	#'e',d0
	jsr	putc
	move.b	#'n',d0
	jsr	putc
	move.b	#'d',d0
	jsr	putc
	bra	nend	


stel:
	gc
	cmpi.b	#'s',d0
	beq	stels
	move.b	d0,d1
	move.b	#'e',d0
	jsr	putc
	move.b	#'l',d0
	jsr	putc
	move.b	#'s',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stels:
	gc
	cmpi.b	#'e',d0
	beq	stelse
	move.b	d0,d1
	move.b	#'e',d0
	jsr	putc
	move.b	#'l',d0
	jsr	putc
	move.b	#'s',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stl:
	gc
	cmpi.b	#'o',d0
	beq	stlo
	move.b	d0,d1
	move.b	#'l',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stlo:
	gc
	cmpi.b	#'o',d0
	beq	stloo
	move.b	d0,d1
	move.b	#'l',d0
	jsr	putc
	move.b	#'o',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stloo:
	gc
	cmpi.b	#'p',d0
	beq	stloop
	move.b	d0,d1
	move.b	#'l',d0
	jsr	putc
	move.b	#'o',d0
	jsr	putc
	move.b	#'o',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stw:
	gc
	cmpi.b	#'h',d0
	beq	stwh
	move.b	d0,d1
	move.b	#'w',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stwh:
	gc
	cmpi.b	#'i',d0
	beq	stwhi
	move.b	d0,d1
	move.b	#'w',d0
	jsr	putc
	move.b	#'h',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stwhi:
	gc
	cmpi.b	#'l',d0
	beq	stwhil
	move.b	d0,d1
	move.b	#'w',d0
	jsr	putc
	move.b	#'h',d0
	jsr	putc
	move.b	#'i',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stwhil:
	gc
	cmpi.b	#'e',d0
	beq	stwhile
	move.b	d0,d1
	move.b	#'w',d0
	jsr	putc
	move.b	#'h',d0
	jsr	putc
	move.b	#'i',d0
	jsr	putc
	move.b	#'l',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stwhile:
	gc
	cmpi.b	#'_',d0
	beq	stwhile_
	move.b	d0,d1
	move.b	#'w',d0
	jsr	putc
	move.b	#'h',d0
	jsr	putc
	move.b	#'i',d0
	jsr	putc
	move.b	#'l',d0
	jsr	putc
	move.b	#'e',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
std:
	gc
	cmpi.b	#'o',d0
	beq	stdomaybe
	move.b	d0,d1
	move.b	#'d',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	

stdomaybe:
	jsr	iswhite
	beq	stdo
	jsr	peekc
	cmpi.b	#'.',d0
	beq	stdo
	move.b	#'d',d0
	jsr	putc
	move.b	#'o',d0
	jsr	putc
	bra	nend	

stu:
	gc
	cmpi.b	#'n',d0
	beq	stun
	move.b	d0,d1
	move.b	#'u',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stun:
	gc
	cmpi.b	#'t',d0
	beq	stunt
	move.b	d0,d1
	move.b	#'u',d0
	jsr	putc
	move.b	#'n',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stunt:
	gc
	cmpi.b	#'i',d0
	beq	stunti
	move.b	d0,d1
	move.b	#'u',d0
	jsr	putc
	move.b	#'n',d0
	jsr	putc
	move.b	#'t',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stunti:
	gc
	cmpi.b	#'l',d0
	beq	stuntil
	move.b	d0,d1
	move.b	#'u',d0
	jsr	putc
	move.b	#'n',d0
	jsr	putc
	move.b	#'t',d0
	jsr	putc
	move.b	#'i',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
stuntil:
	gc
	cmpi.b	#'_',d0
	beq	stuntil_
	move.b	d0,d1
	move.b	#'u',d0
	jsr	putc
	move.b	#'n',d0
	jsr	putc
	move.b	#'t',d0
	jsr	putc
	move.b	#'i',d0
	jsr	putc
	move.b	#'l',d0
	jsr	putc
	move.b	d1,d0
	bra	nost	
str:
	gc
	cmpi.b	#'e',d0
	beq	stre
	print	<r>
	bra	nost	
stre:
	gc
	cmpi.b	#'p',d0
	beq	strep
	print	<re>
	bra	nost	
strep:
	gc
	cmpi.b	#'e',d0
	beq	strepe
	print	<rep>
	bra	nost	
strepe:
	gc
	cmpi.b	#'a',d0
	beq	strepea
	print	<repe>
	bra	nost	
strepea:
	gc
	cmpi.b	#'t',d0
	beq	strepeat
	print	<repea>
	bra	nost	

stc:
	gc
	cmpi.b	#'o',d0
	beq	stco
	print	<c>
	bra	nost	
stco:
	gc
	cmpi.b	#'n',d0
	beq	stcon
	print	<co>
	bra	nost	
stcon:
	gc
	cmpi.b	#'t',d0
	beq	stcont
	print	<con>
	bra	nost	
stcont:
	gc
	cmpi.b	#'i',d0
	beq	stconti
	print	<cont>
	bra	nost	
stconti:
	gc
	cmpi.b	#'n',d0
	beq	stcontin
	print	<conti>
	bra	nost	
stcontin:
	gc
	cmpi.b	#'u',d0
	beq	stcontinu
	print	<contin>
	bra	nost	
stcontinu:
	gc
	cmpi.b	#'e',d0
	beq	stcontinue
	print	<continu>
	bra	nost	
stb:
	gc
	cmpi.b	#'r',d0
	beq	stbr
	print	<b>
	bra	nost	
stbr:
	gc
	cmpi.b	#'e',d0
	beq	stbre
	print	<br>
	bra	nost	
stbre:
	gc
	cmpi.b	#'a',d0
	beq	stbrea
	print	<bre>
	bra	nost	
stbrea:
	gc
	cmpi.b	#'k',d0
	beq	stbreak
	print	<brea>
	bra	nost	
stt:
	gc
	cmpi.b	#'e',d0
	beq	stte
	print	<t>
	bra	nost	
stte:
	gc
	cmpi.b	#'s',d0
	beq	sttes
	print	<te>
	bra	nost	
sttes:
	gc
	cmpi.b	#'t',d0
	beq	sttest
	print	<tes>
	bra	nost	


stif_:
	jsr	getcc
	moveq.l	#1,d1
	eor.b	d1,d0
	move.l	d0,d1
	jsr	isshort
	move.l	d0,d2
	putcon	'b'
	move.l	d1,d0
	jsr	putcc
	move.l	d2,d0
	jsr	putshort
	putcon	9
	putcon	'.'
	jsr	getlabel
	move.l	d0,d3
	jsr	pword
	jsr	skiprest
	push.l	d2
	push.l	d3
	jsr	getstruct
	pop.l	d3
	pop.l	d2
	cmpi.l	#telse,d0
	bne	nelse
	print	<bra>
	move.l	d2,d0
	jsr	putshort
	print	< .>
	jsr	getlabel
	move.l	d0,d4
	jsr	pword
	jsr	skiprest
	putcon	'.'
	move.l	d3,d0
	jsr	pword
	putcon	':'
	newline
	move.l	d4,d3
	push.l	d2
	push.l	d3
	jsr	getstruct
	pop.l	d3
	pop.l	d2
nelse:
	cmpi.l	#tend,d0
	bne	ntend
	jsr	skiprest
	putcon	'.'
	move.l	d3,d0
	jsr	pword
	putcon	':'
	newline
	bra	getstruct

ntend:
	push.l	d0
	newline
	print	<unexpected end of construct>
	message	<unexpected end of construct>
	newline
	pop.l	d0
	tst.l	d0
	bge	1$
	rts

1$:	jsr	skiprest
	bra	getstruct

stelse:
	move.l	#telse,d0
	rts
stend
	move.l	#tend,d0
	rts

stloop:
	push.l	startaddr
	push.l	contaddr
	push.l	breakaddr
	push.l	looplen
	jsr	getlabel
	move.l	d0,contaddr
	move.l	d0,startaddr
	jsr	getlabel
	move.l	d0,breakaddr
	jsr	isshort
	move.l	d0,looplen
	jsr	skiprest

	putcon	'.'
	move.l	contaddr,d0
	jsr	pword
	putcon	':'
	newline

looploop:
	jsr	getstruct
	cmpi.l	#tend,d0
	beq	loopend
	cmpi.l	#twhile,d0
	bne	nwhile

	putcon	'b'
	jsr	getcc
	moveq.l	#1,d1
	eor.b	d1,d0
	move.l	d0,d1
	move.l	d1,d0
	jsr	putcc
 	move.l	looplen,d0
	jsr	putshort
	print	< .>
	move.l	breakaddr,d0
	jsr	pword
	jsr	skiprest
	bra	looploop

loopend:
	print	<bra>
	move.l	looplen,d0
	jsr	putshort
	print	< .>
	move.l	contaddr,d0
	jsr	pword
	jsr	skiprest
	putcon	'.'
	move.l	breakaddr,d0
	jsr	pword
	putcon	':'
	newline
	pop.l	looplen
	pop.l	breakaddr
	pop.l	contaddr
	pop.l	startaddr
	bra	getstruct

nwhile:
	pop.l	looplen
	pop.l	breakaddr
	pop.l	contaddr
	pop.l	startaddr
	push.l	d0
	newline
	print	<unexpected end of construct>
	message	<unexpected end of construct>
	newline
	pop.l	d0
	tst.l	d0
	bge	1$
	rts

1$:	jsr	skiprest
	bra	getstruct


stwhile_:
	move.l	#twhile,d0
	rts

stdo:
	push.l	startaddr
	push.l	contaddr
	push.l	breakaddr
	push.l	looplen
	jsr	getlabel
	move.l	d0,contaddr
	jsr	getlabel
	move.l	d0,startaddr
	jsr	getlabel
	move.l	d0,breakaddr
	jsr	isshort
	move.l	d0,looplen
	jsr	skiprest

	putcon	'.'
	move.l	startaddr,d0
	jsr	pword
	putcon	':'
	newline

	jsr	getstruct
	cmpi.l	#tuntil,d0
	bne	nuntil

	putcon	'b'
	jsr	getcc
	moveq.l	#1,d1
	eor.b	d1,d0
	move.l	d0,d1
	move.l	d1,d0
	jsr	putcc
 	move.l	looplen,d0
	jsr	putshort
	print	< .>
	move.l	startaddr,d0
	jsr	pword
	jsr	skiprest
	putcon	'.'
	move.l	breakaddr,d0
	jsr	pword
	putcon	':'
	newline
	pop.l	looplen
	pop.l	breakaddr
	pop.l	contaddr
	pop.l	startaddr
	bra	getstruct

nuntil:
	pop.l	looplen
	pop.l	breakaddr
	pop.l	contaddr
	pop.l	startaddr
	push.l	d0
	newline
	print	<unexpected end of construct>
	message	<unexpected end of construct>
	newline
	pop.l	d0
	tst.l	d0
	bge	1$
	rts

1$:	jsr	skiprest
	bra	getstruct


stuntil_:
	move.l	#tuntil,d0
	rts

strepeat:
	push.l	startaddr
	push.l	contaddr
	push.l	breakaddr
	jsr	getlabel
	move.l	d0,startaddr
	jsr	getlabel
	move.l	d0,contaddr
	jsr	getlabel
	move.l	d0,breakaddr

	print	<move.w>
1$:	jsr	getc
	tst.l	d0
	blt	badrep
	jsr	putc
	cmpi.b	#',',d0
	bne	1$
	jsr	getc
	jsr	putc
	jsr	getc
	jsr	putc
	move.b	d0,d2
	jsr	skiprest	
	print	< bra .>
	move.l	contaddr,d0
	jsr	pword
	newline

	putcon	'.'
	move.l	startaddr,d0
	jsr	pword
	putcon	':'
	newline

	push.l	d2
	jsr	getstruct
	pop.l	d2
	cmpi.l	#tend,d0
	bne	nrepend

	putcon	'.'
	move.l	contaddr,d0
	jsr	pword
	putcon	':'
	print	< dbra d>
	move.b	d2,d0
	jsr	putc
	print	<,.>
	move.l	startaddr,d0
	jsr	pword
	jsr	skiprest
	putcon	'.'
	move.l	breakaddr,d0
	jsr	pword
	putcon	':'
	newline
	pop.l	breakaddr
	pop.l	contaddr
	pop.l	startaddr
	bra	getstruct

nrepend:
	pop.l	breakaddr
	pop.l	contaddr
	pop.l	startaddr
	push.l	d0
	newline
	print	<unexpected end of repeat>
	message	<unexpected end of repeat>
	newline
	pop.l	d0
	tst.l	d0
	bge	1$
	rts

1$:	jsr	skiprest
	bra	getstruct

badrep:
	pop.l	breakaddr
	pop.l	contaddr
	pop.l	startaddr
	push.l	d0
	newline
	print	<bad repeat construct>
	message	<bad repeat construct>
	newline
	pop.l	d0
	tst.l	d0
	bge	1$
	rts

1$:	jsr	skiprest
	bra	getstruct



stbreak:
	print	<bra>
	move.l	looplen,d0
	jsr	putshort
	print	< .>
	move.l	breakaddr,d0
	jsr	pword
	jsr	skiprest
	bra	getstruct

stcontinue:
	print	<bra>
	move.l	looplen,d0
	jsr	putshort
	print	< .>
	move.l	contaddr,d0
	jsr	pword
	jsr	skiprest
	bra	getstruct

sttest:
	jsr	skiprest
	putcon	'.'
	move.l	contaddr,d0
	jsr	pword
	putcon	':'
	newline
	bra	getstruct



putcc:
	push.l	d1
	add.l	d0,d0
	add.l	d0,d0
	lea	cctab,a0	
	add.l	d0,a0
	move.l	(a0),d1
	move.l	d1,d0
	swap	d0
	lsr.w	#8,d0
	jsr	putc
	move.l	d1,d0
	swap	d0
	and.l	#255,d0
	cmpi.b	#' ',d0
	beq	1$
	jsr	putc
	move.l	d1,d0
	lsr.w	#8,d0
	and.l	#255,d0
	cmpi.b	#' ',d0
	beq	1$
	jsr	putc
	move.l	d1,d0
	and.l	#255,d0
	cmpi.b	#' ',d0
	beq	1$
	jsr	putc
1$:	pop.l	d1
	rts

getlabel:
	move.l	labelnum,d0
	add.l	#1,labelnum
	rts


	xdef	start
start:
	jsr	startup

	message	<MC68000 structured assembler preprocessor 1.0>
	message	<Copyright (C) 1986 by Jonathan Engdahl>

	xref	quest
	xref	help
	xref	share

	cmpi.b	#'?',(a0)
	beq	quest
	cmpi.b	#'-',(a0)
	bne	run
	cmpi.b	#'h',1(a0)
	beq	help
	cmpi.b	#'i',1(a0)
	beq	share
	cmpi.b	#'?',1(a0)
	beq	quest

run:	jsr	getstruct
	cmp.l	#tend,d0
	beq	pend

	newline
	print	<abnormal end of program>
	message	<abnormal end of program>
	newline

pend:
	print	<end>
	newline

	jsr	shutdown

	clr.l	d0
	rts

