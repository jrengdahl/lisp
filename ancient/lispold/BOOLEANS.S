	IDNT		booleans

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'


	.data

	.code

	xref	t

eq:
	follow	a1,a2
	cmp.l	car(a1),a2
	if_eq.s
		move.l t,a0
		unlkm a1-a5
		rts
	else
		move.l d6,a0
		unlkm a1-a5
		rts
	end


eql:
	follow	a1,a2
	cmp.l	car(a1),a2
	if_eq.s
		move.l t,a0
		unlkm a1-a5
		rts
	else
		move.l car(a1),a3
		move.l (a2),a0
		cmp.l (a3),a0
		if_ne.s
			move.l d6,a0
			unlkm a1-a5
			rts
		else
			cmpi.w #numtype,(a2)
			if_ne.s
				cmpi.w #rattype,(a2)
				if_ne.s
					move.l d6,a0
					unlkm a1-a5
					rts
				end
			end
			
			move.l numerator(a2),a0
			cmp.l numerator(a3),a0
			if_eq.s
				move.l denominator(a2),a0
				cmp.l denominator(a3),a0
				if_eq.s
					move.l t,a0
					unlkm a1-a5
					rts
				end
			end
			move.l d6,a0
			unlkm a1-a5
			rts
		end
	end


equal:
	follow	a1,a2
	move.l	car(a1),a3
	jsr	equalfun
	unlkm a1-a5
	rts


equalfun:	
	stackcheck equalfun
	cmp.l	a2,a3
	if_eq.s
		move.l t,a0
		rts
	else
		move.w (a2),a0
		cmp.w (a3),a0
		if_ne.s
			move.l d6,a0
			rts
		else
			jmp equaltab(a0.w)
		end
	end

equaltab:
			bra.s equalcons	;cons
			nop
			nop
			nop
			bra.s equalnum		;number
			nop
			nop
			nop
			bra.s equalnum		;rational
			nop
			nop
			nop
			bra.s equalstr		;string
			nop
			nop
			nop
			move.l d6,a0		;array
			rts
			nop
			nop
			move.l d6,a0		;char
			rts
			nop
			nop
			move.l d6,a0		;prim
			rts
			nop
			nop
			move.l d6,a0		;symbol
			rts


equalnum:
	move.l numerator(a2),a0
	cmp.l numerator(a3),a0
	if_eq.s
		move.l denominator(a2),a0
		cmp.l denominator(a3),a0
		if_eq.s
			move.l t,a0
			rts
		end
	end
	move.l d6,a0
	rts

equalstr:
	move.l a2,a0
	move.l a3,a1
	xref cmp_str
	jsr  cmp_str
	if_eq.s
		move.l t,a0
		rts
	else
		move.l d6,a0
		rts
	end


equalcons:
	push.l	a2
	push.l	a3
	move.l	car(a2),a2
	move.l	car(a3),a3
	jsr		equalfun
	pop.l	a3
	pop.l	a2
	cmp.l	d6,a0
	if_eq.s
		rts
	else
		move.l cdr(a2),a2
		move.l cdr(a3),a3
		bra equalfun
	end


null:
	cmp.l car(a1),d6
	if_eq.s
		move.l t,a0
		unlkm a1-a5
		rts
	else
		move.l d6,a0
		unlkm a1-a5
		rts
	end




	xdef	init_booleans
init_booleans:
	primitive	eq
	primitive	eql
	primitive	equal
	primitive	null
	rts

	end
