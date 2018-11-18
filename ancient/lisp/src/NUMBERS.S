Srand	IDNT		numbers

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'
	include	'lisp/math.i'
	include	'lisp/mult.i'

	xdef .reduce
	xref t

	.data
	xdef	pminus
pminus: ds.l 1
seed:	dc.l 0
	.code

plus:
	moveq.l	#0,d1
	moveq.l	#1,d2
	loop.s
		cmp.l d6,a1
		while_ne

		follow a1,a2
		cmpi.w #numtype,(a2)
		bne.s plusrat
		add.l numerator(a2),d1
		bvs aovfl
	end

	newnode a0
	move.l #numtype*65536,d0
	movem.l d0-d2,(a0)
	unlkm a1-a5
	rts

plusrat:
	loop
		cmpi.w #numtype,(a2)
		if_ne.s
			cmpi.w #rattype,(a2)
			if_ne.s
				message <;add unknown data type>
				signal_error
			end
		end

retryplus:
		move.l numerator(a2),d3
		move.l denominator(a2),d4

		push.l d1
		push.l d2
		smult d4,d0,d5,d1,plusovfl
		smult d2,d0,d5,d3,plusovfl
		smult d4,d0,d5,d2,plusovfl
		add.l d3,d1
		bvs plusovfl
		pop.l d0
		pop.l d0

		cmp.l d6,a1
		while_ne

		follow a1,a2
	end

	newnode a0
	move.l #rattype*65536,d0
	movem.l d0-d2,(a0)
	unlkm a1-a5
	rts

plusovfl:
	move.l a2,a0
	jsr .reduce
	pop.l d2
	pop.l d1
	push.l d1
	jsr ..reduce
	pop.l d3
	move.l numerator(a0),d0
	cmp.l numerator(a2),d0
	if_eq.s
		cmp.l d1,d3
		if_eq.s
			message <;reduction failure in addition>
			signal_error
		end
	end
	move.l a0,a2
	bra retryplus

minus:
	cmp.l	d6,a1
	if_eq.s
		newnode a0
		move.l #numtype*65536,d0
		moveq.l #0,d1
		moveq.l #1,d2
		movem.l d0-d2,(a0)
		unlkm a1-a5
		rts
	end

	follow	a1,a2
	movem.l	(a2),d0-d2

	cmp.l	d6,a1
	if_eq.s
		neg.l d1
		newnode a0
		movem.l d0-d2,(a0)
		unlkm a1-a5
		rts
	end

	cmpi.w	#numtype,(a2)
	bne.s	minusrat

	do.s
		follow a1,a2

		cmpi.w #numtype,(a2)
		bne.s minusrat

		sub.l numerator(a2),d1
		bvs sovfl

		cmp.l d6,a1
	until_eq

	newnode a0
	movem.l d0/d1/d2,(a0)
	unlkm a1-a5
	rts

minusrat:
	loop
		cmpi.w #numtype,(a2)
		if_ne.s
			cmpi.w #rattype,(a2)
			if_ne.s
				message <;subtract unknown data type>
				signal_error
			end
		end

retryminus:

		move.l numerator(a2),d3
		move.l denominator(a2),d4

		push.l d1
		push.l d2
		smult d4,d0,d5,d1,minusovfl
		smult d2,d0,d5,d3,minusovfl
		smult d4,d0,d5,d2,minusovfl
		sub.l d3,d1
		bvs minusovfl
		pop.l d0
		pop.l d0

		cmp.l d6,a1
		while_ne

		follow a1,a2
	end

	newnode a0
	move.l #rattype*65536,d0
	movem.l d0-d2,(a0)
	unlkm a1-a5
	rts

minusovfl:
	move.l a2,a0
	jsr	.reduce
	pop.l d2
	pop.l d1
	push.l d1
	jsr ..reduce
	pop.l d3
	move.l numerator(a0),d0
	cmp.l numerator(a2),d0
	if_eq.s
		cmp.l d1,d3
		if_eq.s
			message <;reduction failure in subtraction>
			signal_error
		end
	end
	move.l a0,a2
	bra retryminus


mult:
	moveq.l	#1,d1
	moveq.l	#1,d2
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a2
		cmpi.w #numtype,(a2)
		bne multrat
		move.l numerator(a2),d3
		smult d3,d4,d5,d1,movfl
	end

	newnode a0
	move.l #numtype*65536,d0
	movem.l d0-d2,(a0)
	unlkm a1-a5
	rts

multrat:
	loop
		cmpi.w #rattype,(a2)
		if_ne.s
			cmpi.w #numtype,(a2)
			bne multnon
		end

retrymult:
		push.l d1
		push.l d2
		move.l numerator(a2),d3
		smult d3,d4,d5,d1,multovfl
		move.l denominator(a2),d3
		smult d3,d4,d5,d2,multovfl
		pop.l d0
		pop.l d0

		cmp.l d6,a1
		while_ne

		follow a1,a2		
	end

	newnode a0
	move.l #rattype*65536,d0
	movem.l d0-d2,(a0)
	unlkm a1-a5
	rts

multovfl:
	move.l a2,a0
	jsr	.reduce
	pop.l d2
	pop.l d1
	push.l d1
	jsr ..reduce
	pop.l d3
	move.l numerator(a0),d0
	cmp.l numerator(a2),d0
	if_eq.s
		cmp.l d1,d3
		if_eq.s
			message <;reduction failure in multiplication>
			signal_error
		end
	end
	move.l a0,a2
	bra retrymult

multnon:
	message <;multiply illegal data type>
	signal_error

div:
	cmp.l	d6,a1
	if_eq.s
		newnode a0
		move.l #numtype*65536,d0
		moveq.l #1,d1
		moveq.l #1,d2
		movem.l d0-d2,(a0)
		unlkm a1-a5
		rts
	end

	follow	a1,a2
	move.l	numerator(a2),d1
	move.l	denominator(a2),d2

	cmp.l	d6,a1
	if_eq.s
		tst.l d1
		if_z.s
			message <;inverse of zero>
			signal_error
		end
		exg d1,d2
		cmpi.l #1,d2
		if_eq.s
			move.l #numtype*65536,d0
		else
			move.l #rattype*65536,d0
		end
		newnode a0
		movem.l d0-d2,(a0)
		unlkm a1-a5
		rts
	end

	do
		follow a1,a2

retrydiv:
		move.l numerator(a2),d4
		if_z.s
			message <;divide by zero>
			signal_error
		end
		move.l denominator(a2),d5
		push.l d1
		push.l d2
		smult d5,d0,d3,d1,divovfl
		smult d4,d0,d3,d2,divovfl
		pop.l d0
		pop.l d0
		cmp.l d6,a1
	until_eq

	cmpi.l #1,d2
	if_eq.s
		move.l #numtype*65536,d0
	else
		move.l #rattype*65536,d0
	end
	newnode a0
	movem.l d0/d1/d2,(a0)
	unlkm a1-a5
	rts

divovfl:
	move.l a2,a0
	jsr	.reduce
	pop.l d2
	pop.l d1
	push.l d1
	jsr ..reduce
	pop.l d3
	move.l numerator(a0),d0
	cmp.l numerator(a2),d0
	if_eq.s
		cmp.l d1,d3
		if_eq.s
			message <;reduction failure in division>
			signal_error
		end
	end
	move.l a0,a2
	bra retrydiv

.numerator:
	move.l car(a1),a0
	jsr .reduce
	move.l a0,a2
	newnode a0
	move.l #numtype*65536,(a0)
	move.l numerator(a2),numerator(a0)
	move.l #1,denominator(a0)
	unlkm a1-a5
	rts


.denominator:
	move.l car(a1),a0
	jsr .reduce
	move.l a0,a2
	newnode a0
	move.l #numtype*65536,(a0)
	move.l denominator(a2),numerator(a0)
	move.l #1,denominator(a0)
	unlkm a1-a5
	rts



truncate:
	follow a1,a0
	cmp.l d6,a1
	if_eq
		cmp.w #numtype,(a0)
		if_eq
			unlkm a1-a5
			rts
		else
			move.l numerator(a0),d1
			move.l denominator(a0),d4
			sdiv d4,d3,d2,d1
			moveq.l #1,d2
			move.l #numtype*65536,d0
			newnode a0
			movem.l d0-d2,(a0)
			unlkm a1-a5
			rts
		end
	else
		move.l car(a1),a2
		cmp.w #numtype,(a0)
		if_eq
		cmp.w #numtype,(a2)
		if_eq
			move.l numerator(a0),d1
			move.l numerator(a2),d4
			sdiv d4,d3,d2,d1
			moveq.l #1,d2
			move.l #numtype*65536,d0
			newnode a0
			movem.l d0-d2,(a0)
			unlkm a1-a5
			rts
		end
		end
		move.l numerator(a0),d1
		move.l denominator(a2),d4
		smult d4,d2,d3,d1,truncfail
		move.l numerator(a2),d5
		move.l denominator(a0),d4
		smult d4,d2,d3,d5,truncfail
		sdiv d5,d3,d2,d1
		moveq.l #1,d2
		move.l #numtype*65536,d0
		newnode a0
		movem.l d0-d2,(a0)
		unlkm a1-a5
		rts
	end


truncfail:
	message <;sorry, truncate doesnt reduce rationals yet, and it blew up>
	signal_error

rem:
	follow a1,a2
	move.l car(a1),a3
	move.l numerator(a2),d1
	move.l numerator(a3),d0
	smod d0,d2,d3,d4,d1
	moveq.l #1,d2
	move.l #numtype*65536,d0
	newnode a0
	movem.l d0-d2,(a0)
	unlkm a1-a5
	rts




gcd:
	follow a1,a2
	move.l car(a1),a3
	move.l numerator(a2),d0
	move.l numerator(a3),d1
	loop
		cmp.l d0,d1
		if_lt.s
			exg d0,d1
		end

		tst.l d0
		while_nz

		push.l d0
		smod d0,d2,d3,d4,d1
		pop.l d0
	end

	moveq.l #1,d2
	move.l #numtype*65536,d0
	newnode a0
	movem.l d0-d2,(a0)
	unlkm a1-a5
	rts




lcm:
	follow a1,a2
	move.l car(a1),a3
	move.l numerator(a2),d0
	move.l numerator(a3),d1
	move.l d0,d4
	move.l d1,d5
	smult d4,d2,d3,d5,movfl
	tst.l d5
	if_lt.s
		neg.l d5
	end

	
	loop
		cmp.l d0,d1
		if_lt.s
			exg d0,d1
		end

		tst.l d0
		while_nz

		push.l d0
		smod d0,d2,d3,d4,d1
		pop.l d0
	end
	sdiv d1,d2,d3,d5
	move.l d5,d1

	moveq.l #1,d2
	move.l #numtype*65536,d0
	newnode a0
	movem.l d0-d2,(a0)
	unlkm a1-a5
	rts






lreduce:
	move.l car(a1),a0
	jsr .reduce
	unlkm a1-a5
	rts


.reduce:
	move.l numerator(a0),d1
	move.l denominator(a0),d2

	jsr ..reduce

	cmpi.l #1,d2
	if_eq.s
		move.l #numtype*65536,d0
	else
		move.l #rattype*65536,d0
	end
	newnode a0
	movem.l d0-d2,(a0)
	rts


..reduce:
	push.l	d1
	move.l	d2,d5
	loop
		cmp.l d1,d2
		if_lt.s
			exg d1,d2
		end

		tst.l d1
		while_nz

		smod d1,d0,d3,d4,d2
		end
	pop.l d1
	sdiv d2,d0,d3,d1
	sdiv d2,d0,d3,d5
	move.l d5,d2
	rts



equal:
	follow	a1,a2
	cmp.w	#numtype,(a2)
	bne.s	eqrat1

	loop
		cmp.l d6,a1
		while_ne

		follow a1,a3
		cmp.w #numtype,(a3)
		bne.s eqrat2

		move.l numerator(a2),d0
		cmp.l numerator(a3),d0
		if_ne.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l denominator(a2),d0
		cmp.l denominator(a3),d0
		if_ne.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l a3,a2
	end
	move.l t,a0
	unlkm a1-a5
	rts

eqrat1:
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a3
eqrat2:
		move.l numerator(a2),d0
		move.l denominator(a3),d1
		smult d1,d2,d3,d0,eqovfl
		move.l numerator(a3),d1
		move.l denominator(a2),d2
		smult d2,d3,d4,d1,eqovfl
		cmp.l d1,d0
		if_ne.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l a3,a2
	end
	move.l t,a0
	unlkm a1-a5
	rts

eqovfl:
	move.l a2,a0
	move.l a2,a4
	jsr .reduce
	move.l a0,a2
	move.l a3,a0
	move.l a3,a5
	jsr .reduce
	move.l a0,a3
	move.l numerator(a2),d0
	cmp.l numerator(a4),d0
	if_eq.s
		move.l numerator(a3),d0
		cmp.l numerator(a5),d0
		if_eq.s
			message <;reduction failure in comparison>
			signal_error
		end
	end
	bra eqrat2

nequal:
	follow	a1,a2
	cmp.w	#numtype,(a2)
	bne.s	neqrat1

	loop
		cmp.l d6,a1
		while_ne

		follow a1,a3
		cmp.w #numtype,(a3)
		bne.s neqrat2

		move.l numerator(a2),d0
		cmp.l numerator(a3),d0
		if_ne.s
			move.l t,a0
			unlkm a1-a5
			rts
		end
		move.l denominator(a2),d0
		cmp.l denominator(a3),d0
		if_ne.s
			move.l t,a0
			unlkm a1-a5
			rts
		end
		move.l a3,a2
	end
	move.l d6,a0
	unlkm a1-a5
	rts

neqrat1:
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a3
neqrat2:
		move.l numerator(a2),d0
		move.l denominator(a3),d1
		smult d1,d2,d3,d0,neqovfl
		move.l numerator(a3),d1
		move.l denominator(a2),d2
		smult d2,d3,d4,d1,neqovfl
		cmp.l d1,d0
		if_ne.s
			move.l t,a0
			unlkm a1-a5
			rts
		end
		move.l a3,a2
	end
	move.l d6,a0
	unlkm a1-a5
	rts

neqovfl:
	move.l a2,a0
	move.l a2,a4
	jsr .reduce
	move.l a0,a2
	move.l a3,a0
	move.l a3,a5
	jsr .reduce
	move.l a0,a3
	move.l numerator(a2),d0
	cmp.l numerator(a4),d0
	if_eq.s
		move.l numerator(a3),d0
		cmp.l numerator(a5),d0
		if_eq.s
			message <;reduction failure in comparison>
			signal_error
		end
	end
	bra neqrat2


greater:
	follow	a1,a2
	cmpi.w	#numtype,(a2)
	bne		gtrat1
	move.l	numerator(a2),d0

	loop.s
		cmp.l d6,a1
		while_ne

		follow a1,a3
		cmpi.w #numtype,(a3)
		bne gtrat2

		move.l numerator(a3),d1
		cmp.l d1,d0
		if_le.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l d1,d0
	end
	move.l t,a0
	unlkm a1-a5
	rts


gtrat1:
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a3
gtrat2:
		move.l numerator(a2),d0
		move.l denominator(a3),d1
		smult d1,d2,d3,d0,gtovfl
		move.l numerator(a3),d1
		move.l denominator(a2),d2
		smult d2,d3,d4,d1,gtovfl
		cmp.l d1,d0
		if_le.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l a3,a2
	end
	move.l t,a0
	unlkm a1-a5
	rts

gtovfl:
	move.l a2,a0
	move.l a2,a4
	jsr .reduce
	move.l a0,a2
	move.l a3,a0
	move.l a3,a5
	jsr .reduce
	move.l a0,a3
	move.l numerator(a2),d0
	cmp.l numerator(a4),d0
	if_eq.s
		move.l numerator(a3),d0
		cmp.l numerator(a5),d0
		if_eq.s
			message <;reduction failure in comparison>
			signal_error
		end
	end
	bra gtrat2


greateq:
	follow	a1,a2
	cmpi.w	#numtype,(a2)
	bne		gerat1
	move.l	numerator(a2),d0

	loop.s
		cmp.l d6,a1
		while_ne

		follow a1,a3
		cmpi.w #numtype,(a3)
		bne gerat2

		move.l numerator(a3),d1
		cmp.l d1,d0
		if_lt.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l d1,d0
	end
	move.l t,a0
	unlkm a1-a5
	rts


gerat1:
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a3
gerat2:
		move.l numerator(a2),d0
		move.l denominator(a3),d1
		smult d1,d2,d3,d0,geovfl
		move.l numerator(a3),d1
		move.l denominator(a2),d2
		smult d2,d3,d4,d1,geovfl
		cmp.l d1,d0
		if_lt.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l a3,a2
	end
	move.l t,a0
	unlkm a1-a5
	rts

geovfl:
	move.l a2,a0
	move.l a2,a4
	jsr .reduce
	move.l a0,a2
	move.l a3,a0
	move.l a3,a5
	jsr .reduce
	move.l a0,a3
	move.l numerator(a2),d0
	cmp.l numerator(a4),d0
	if_eq.s
		move.l numerator(a3),d0
		cmp.l numerator(a5),d0
		if_eq.s
			message <;reduction failure in comparison>
			signal_error
		end
	end
	bra gerat2


lessthan:
	follow	a1,a2
	cmpi.w	#numtype,(a2)
	bne		ltrat1
	move.l	numerator(a2),d0

	loop.s
		cmp.l d6,a1
		while_ne

		follow a1,a3
		cmpi.w #numtype,(a3)
		bne ltrat2

		move.l numerator(a3),d1
		cmp.l d1,d0
		if_ge.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l d1,d0
	end
	move.l t,a0
	unlkm a1-a5
	rts


ltrat1:
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a3
ltrat2:
		move.l numerator(a2),d0
		move.l denominator(a3),d1
		smult d1,d2,d3,d0,ltovfl
		move.l numerator(a3),d1
		move.l denominator(a2),d2
		smult d2,d3,d4,d1,ltovfl
		cmp.l d1,d0
		if_ge.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l a3,a2
	end
	move.l t,a0
	unlkm a1-a5
	rts

ltovfl:
	move.l a2,a0
	move.l a2,a4
	jsr .reduce
	move.l a0,a2
	move.l a3,a0
	move.l a3,a5
	jsr .reduce
	move.l a0,a3
	move.l numerator(a2),d0
	cmp.l numerator(a4),d0
	if_eq.s
		move.l numerator(a3),d0
		cmp.l numerator(a5),d0
		if_eq.s
			message <;reduction failure in comparison>
			signal_error
		end
	end
	bra ltrat2


lesseq:
	follow	a1,a2
	cmpi.w	#numtype,(a2)
	bne		lerat1
	move.l	numerator(a2),d0

	loop.s
		cmp.l d6,a1
		while_ne

		follow a1,a3
		cmpi.w #numtype,(a3)
		bne lerat2

		move.l numerator(a3),d1
		cmp.l d1,d0
		if_gt.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l d1,d0
	end
	move.l t,a0
	unlkm a1-a5
	rts


lerat1:
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a3
lerat2:
		move.l numerator(a2),d0
		move.l denominator(a3),d1
		smult d1,d2,d3,d0,leovfl
		move.l numerator(a3),d1
		move.l denominator(a2),d2
		smult d2,d3,d4,d1,leovfl
		cmp.l d1,d0
		if_gt.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end
		move.l a3,a2
	end
	move.l t,a0
	unlkm a1-a5
	rts

leovfl:
	move.l a2,a0
	move.l a2,a4
	jsr .reduce
	move.l a0,a2
	move.l a3,a0
	move.l a3,a5
	jsr .reduce
	move.l a0,a3
	move.l numerator(a2),d0
	cmp.l numerator(a4),d0
	if_eq.s
		move.l numerator(a3),d0
		cmp.l numerator(a5),d0
		if_eq.s
			message <;reduction failure in comparison>
			signal_error
		end
	end
	bra lerat2


aovfl:
	message <;add overflow>
	signal_error

sovfl:
	message <;subtract underflow>
	signal_error

movfl:
	message <;multiply overflow>
	signal_error


incf:
	follow a1,a2
	move.l sym_value(a2),a3
	cmp.l d6,a1
	if_eq.s
		movem.l (a3),d0-d2
		add.l d2,d1
	else
		follow a1,a0
		eval
		movem.l (a3),d0-d2
		add.l numerator(a0),d1
	end
	newnode a0
	movem.l d0-d2,(a0)
	move.l a0,sym_value(a2)
	unlkm a1-a5
	rts


decf:
	follow a1,a2
	move.l sym_value(a2),a3
	cmp.l d6,a1
	if_eq.s
		movem.l (a3),d0-d2
		sub.l d2,d1
	else
		follow a1,a0
		eval
		movem.l (a3),d0-d2
		sub.l numerator(a0),d1
	end
	newnode a0
	movem.l d0-d2,(a0)
	move.l a0,sym_value(a2)
	unlkm a1-a5
	rts

random:
	follow a1,a2
	cmp.l d6,a1
	if_eq.s
		move.l seed,d3
		rnd d3
		move.l d3,seed
	else
		move.l car(a1),a0
		move.l numerator(a0),d3
		rnd d3
		move.l d3,numerator(a0)
	end
	clr.w d3
	swap d3
	move.l numerator(a2),d2
	mulu d2,d3
	clr.w d3
	swap d3
	newnode a0
	move.l #numtype*65536,(a0)
	move.l d3,numerator(a0)
	move.l #1,denominator(a0)
	unlkm a1-a5
	rts

isqrt:
	move.l car(a1),a0
	move.l numerator(a0),d0
	jsr sqr
	newnode a0
	move.l #numtype*65536,(a0)
	move.l d0,numerator(a0)
	move.l #1,denominator(a0)
	unlkm a1-a5
	rts

sqstep: macro log_2(k)
	cmp.l	d0,d1
	bgt.s gt\@
		move.l d2,d3
		ifgt \1-7
		swap d3
		lsr.l #15-\1,d3
		endc
		ifle \1-7
		lsl.l #\1+1,d3
		endc
		add.l d3,d1
		add.l #(1<<\1)*(1<<\1),d1
		add.w #1<<\1,d2
	bra.s le\@
gt\@:		move.l d2,d3
		ifgt \1-7
		swap d3
		lsr.l #15-\1,d3
		endc
		ifle \1-7
		lsl.l #\1+1,d3
		endc
		sub.l d3,d1
		add.l #(1<<\1)*(1<<\1),d1
		sub.w #1<<\1,d2
le\@:
	endm

sqr:	push.l	d2
	push.l	d3
	move.l	#32768,d2
	move.l	#32768*32768,d1

	sqstep	14
	sqstep	13
	sqstep	12
	sqstep	11
	sqstep	10
	sqstep	9
	sqstep	8
	sqstep	7
	sqstep	6
	sqstep	5
	sqstep	4
	sqstep	3
	sqstep	2
	sqstep	1
	sqstep	0

	cmp.l	d0,d1
	if_le.s
		add.l d2,d1
		cmp.l d0,d1
		if_le.s
			addq.l #1,d2
		end
	else	
		sub.l d2,d1
		cmp.l d0,d1
		if_gt.s
			subq.l #1,d2
		end
	end

sqdone:	move.l	d2,d0
	pop.l	d3
	pop.l	d2
	rts




	xdef	init_numbers
init_numbers:
	primitive +,plus
	primitive -,minus
	move.l	a0,pminus
	primitive *,mult
	primitive /,div
	primitive numerator,.numerator
	primitive denominator,.denominator
	primitive =,equal
	primitive /=,nequal
	primitive >,greater
	primitive <<>,lessthan
	primitive >=,greateq
	primitive <<=>,lesseq
	primitive truncate
	primitive rem
	primitive gcd
	primitive lcm
	primitive reduce,lreduce
	special incf
	special decf
	primitive random
	primitive isqrt
	rts

	end
