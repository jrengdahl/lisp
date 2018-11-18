	IDNT		read

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'


	.data

	.code

	xdef		make_str

;make a lisp string from a C type string
;input: a0 = pointer to zero terminated string
;output: a0 = a lisp string

make_str:
	stackcheck make_str
	linkm	a1/a2/a3
	pushm.l	d0/d1/d2

	move.l	a0,d0 ;save string pointer in D register while allocating
	move.l	d6,a0 ;make sure registers are kosher while allocating

	newnode	a0
	move.l	a0,a2
	clr.l	4(a0)
	clr.l	8(a0)
	lea		str_more(a0),a1
	move.l	#strtype*65536,(a0)+

	move.w	#4,d1
	clr.l	d2

	move.l	d0,a3		;restore pointer to string

	loop
		tst.b (a3)		;test for end of string
		while_nz

		tst.w d1			;if need new node extend the string
		if_eq.s
			move.l a3,d0	;registers must be clean
			move.l d6,a3
			move.l d6,a0

			newnode a0
			move.l a0,(a1)
			move.l a0,a1
			clr.l 4(a0)
			clr.l 8(a0)
			clr.l (a0)+	
			move.w #8,d1
			move.l d0,a3
		end
	
	
		move.b (a3)+,(a0)+
		subq.w #1,d1
		addq.w #1,d2
		if_mi
			message <string greater than 32K>
			signal_error
		end
	end

	move.w	d2,str_length(a2)
	move.l	a2,a0
	popm.l	d0/d1/d2
	unlkm	a1/a2/a3
	rts


;input: lisp string in a0
;output: C string pointer to by a1

	xdef		string2c
string2c:
	push.l d0
	push.l d1
	push.l a2

	move.w str_length(a0),d0
	cmp.w #32,d0
	if_ge
		message <cannot convert string greater than 31>
		signal_error
	end

	move.l str_more(a0),a2
	lea 4(a0),a0
	move.w #4,d1
	loop
		tst.w d0
		while_nz

		tst.w d1
		if_z.s
			move.l a2,a0
			move.l (a0)+,a2
			move.w #8,d1
		end

		move.b (a0)+,(a1)+
		subq.w #1,d0
		subq.w #1,d1
	end
	clr.b (a1)

	pop.l a2
	pop.l d1
	pop.l d0
	rts

		


	xdef		cmp_str
cmp_str:
	pushm.l	d0/a0/a1/a2/a3

	cmp.l (a0)+,(a1)+
	bne.s nocomp
	cmp.l (a0)+,(a1)+
	bne.s nocomp

	move.l (a0)+,a0
	move.l (a1)+,a1

	loop.s
		move.l	a0,d0
		while_nz
			
		move.l (a0)+,a2
		move.l (a1)+,a3

		cmpm.l	(a0)+,(a1)+
		bne.s	nocomp
		cmpm.l	(a0)+,(a1)+
		bne.s	nocomp
	
		move.l	a2,a0
		move.l	a3,a1
	end

	popm.l	d0/a0/a1/a2/a3
	cmp.l	d0,d0
	rts
	
nocomp:
	popm.l	d0/a0/a1/a2/a3
	tst.l	d6
	rts
	
	end
