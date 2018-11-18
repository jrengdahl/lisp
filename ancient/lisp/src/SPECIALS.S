	IDNT		specials

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'

	xdef		init_specials


	.data
	.code


quote:
	move.l	car(a1),a0
	unlkm	a1-a5
	rts

.set:
	move.l	a1,a0		;get args
	move.l	car(a0),a1	;get symbol
	move.l	cdr(a0),a0	;get value
	move.l	car(a0),a0
	move.l	a0,sym_value(a1)
	unlkm	a1-a5
	rts

setq:
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a2
		follow a1,a0
		eval
		move.l a0,sym_value(a2)
	end
	unlkm	a1-a5
	rts
	
	
init_specials:
	primitive set,.set
	special	setq
	special	setf,setq
	special	quote
	rts

	end
