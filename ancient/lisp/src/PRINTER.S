	IDNT		print

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'


	.data

	.code

lprint:
	stackcheck lprint
	pushm.l	d0/a0/a1

	cmp.l	d6,a0
	if_eq.s
		print <nil>
		bra pdone
	end
	movem.w	(a0),d0
	lsr.w	#1,d0
	move.l	ptab(pc,d0.w),a1
	jmp		(a1)

ptab:
	.long	pcons
	.long	pnum
	.long	prat
	.long	pfloat
	.long	pstr
	.long	parray
	.long	pchar
	.long	pprim
	.long	psfun
	.long	psymbol

lprinc:
	stackcheck lprinc
	pushm.l	d0/a0/a1

	cmp.l	d6,a0
	if_eq.s
		print <nil>
		bra pdone
	end
	movem.w	(a0),d0
	lsr.w	#1,d0
	move.l	pctab(pc,d0.w),a1
	jmp		(a1)

pctab:
	.long	pccons
	.long	pnum
	.long	prat
	.long	pfloat
	.long	pcstr
	.long	parray
	.long	pchar
	.long	pprim
	.long	psfun
	.long	psymbol

pnum:
	move.l	numerator(a0),d0
	jsr		pdecs
	bra		pdone

pfloat:
	print <float not implemented yet>
	bra	pdone

prat:
	xref		.reduce
	jsr		.reduce
	move.l	numerator(a0),d0
	jsr		pdecs
	move.l	denominator(a0),d0
	cmp.l	#1,d0
	if_ne.s
		putcon '/'
		jsr pdecs
	end
	bra		pdone
	
psymbol:
	move.l	sym_more(a0),a0
	move.l	sym_name(a0),a0
	jsr		print_string
	bra		pdone

pcstr:
	jsr		print_string
	bra		pdone

pstr:
	putcon 	'"'
	jsr		print_string
	putcon	'"'
	bra		pdone

parray:
	print 	<#(array: >
	move.l 	a0,d0
	jsr		plong
	putcon 	')'
	bra		pdone

pchar:
	print 	<#\>
	move.l	char_data(a0),d0
	cmpi.b #' ',d0
	if_ult.s
		jsr pbyte
	else
		jsr putc
	end
	bra		pdone


pprim:
	print	<#(primitive: >
	move.l	a0,a1
	move.l	prim_addr(a1),a0
	jsr		plong
	print	< ">
	move.l	prim_name(a1),a0
	jsr		pstring
	print	<")>
	bra		pdone

psfun:
	print	<#(special form: >
	move.l	a0,a1
	move.l	prim_addr(a1),a0
	jsr		plong
	print	< ">
	move.l	prim_name(a1),a0
	jsr		pstring
	print	<")>
	bra		pdone


pcons:
	move.l	a0,a1
	putcon	'('
	loop
		move.l car(a1),a0
		jsr lprint

		move.l cdr(a1),a1
		cmp.l d6,a1
		while_ne
		cmpi.w #constype,(a1)
		while_eq

		space	
	end

	cmp.l	d6,a1
	if_ne.s
		print < . >
		move.l a1,a0
		jsr lprint
	end

	putcon 	')'

	bra		pdone

pccons:
	move.l	a0,a1
	putcon	'('
	loop
		move.l car(a1),a0
		jsr lprinc

		move.l cdr(a1),a1
		cmp.l d6,a1
		while_ne
		cmpi.w #constype,(a1)
		while_eq

		space	
	end

	cmp.l	d6,a1
	if_ne.s
		print < . >
		move.l a1,a0
		jsr lprint
	end

	putcon 	')'

	bra		pdone

pdone:
	popm.l	d0/a0/a1
	rts


print_string:
	stackcheck print_string
	pushm.l	d0/d1/d2/a0/a1

	move.l	str_more(a0),a1
	move.l	(a0)+,d1
	move.w	#4,d2

	loop
		tst.w d1
		while_nz

		tst.w d2
		if_z.s
			move.l a1,a0
			move.l (a0)+,a1
			move.w #8,d2
		end

		move.b (a0)+,d0
		jsr putc
		subq.w #1,d1
		subq.w #1,d2
	end

	popm.l d0/d1/d2/a0/a1
	rts

	xdef		lisp_print

lisp_print:
	jsr		lprint
	newline
	rts

.lprint:
	move.l	car(a1),a0
	jsr	lisp_print
	unlkm	a1-a5
	rts

.lprin1:
	move.l	car(a1),a0
	jsr	lprint
	jsr	flushout
	unlkm	a1-a5
	rts

.lprinc:
	move.l	car(a1),a0
	jsr	lprinc
	jsr	flushout
	unlkm	a1-a5
	rts

terpri:
	newline
	move.l d6,a0
	unlkm	a1-a5
	rts

	xdef	init_printer
init_printer:
	primitive print,.lprint
	primitive prin1,.lprin1
	primitive princ,.lprinc
	primitive terpri,terpri
	rts

	end
