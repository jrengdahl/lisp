	IDNT		lists

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'

	xdef		init_lists


	.data
	.code


first:
.car:
	move.l	car(a1),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

rest:
.cdr:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	unlkm	a1-a5
	rts

caar:
	move.l	car(a1),a0
	move.l	car(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

second:
cadr:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

cdar:
	move.l	car(a1),a0
	move.l	car(a0),a0
	move.l	cdr(a0),a0
	unlkm	a1-a5
	rts

cddr:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	unlkm	a1-a5
	rts

caaar:
	move.l	car(a1),a0
	move.l	car(a0),a0
	move.l	car(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

caadr:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

cadar:
	move.l	car(a1),a0
	move.l	car(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

third:
caddr:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

cdaar:
	move.l	car(a1),a0
	move.l	car(a0),a0
	move.l	car(a0),a0
	move.l	cdr(a0),a0
	unlkm	a1-a5
	rts

cdadr:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	move.l	cdr(a0),a0
	unlkm	a1-a5
	rts

cddar:
	move.l	car(a1),a0
	move.l	car(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	unlkm	a1-a5
	rts

cdddr:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	unlkm	a1-a5
	rts


fourth:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

fifth:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

sixth:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

seventh:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

eighth:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

ninth:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

tenth:
	move.l	car(a1),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	cdr(a0),a0
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

nth:
	follow	a1,a2
	move.l numerator(a2),d1
	move.l	car(a1),a0
	repeat d1,d0
	    move.l cdr(a0),a0
	end
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

last:
	move.l	car(a1),a0
	loop.s
		move.l cdr(a0),a1
		cmp.l d6,a1
		while_ne
		move.l a1,a0
	end
	move.l	car(a0),a0
	unlkm	a1-a5
	rts

.cons:
	move.l	a1,a0
	move.l	cdr(a1),a1
	move.l	car(a1),cdr(a0)
	unlkm	a1-a5
	rts
	
.list:
	move.l	a1,a0
	unlkm	a1-a5
	rts

.list.:
	move.l	a1,a0

	cmp.l d6,a1
	if_eq.s
		unlkm	a1-a5
		rts
	end

	cmp.l cdr(a1),d6
	if_eq.s
		unlkm	a1-a5
		rts
	end

	loop.s
		move.l cdr(a1),a2
		cmp.l cdr(a2),d6
		while_ne

		move.l a2,a1
	end

	move.l car(a2),cdr(a1)

	unlkm	a1-a5
	rts


append:
	newnode	a3
	clr.l	(a3)
	move.l	d6,car(a3)
	move.l	d6,cdr(a3)
	move.l	a3,a4

	loop.s		
		follow a1,a2
		cmp.l d6,a1
		while_ne

		loop.s
			cmp.l d6,a2
			while_ne

			newnode a0
			clr.l (a0)
			move.l car(a2),car(a0)
			move.l a0,cdr(a4)
			move.l a0,a4
			move.l cdr(a2),a2
		end
	end

	move.l a2,cdr(a4)
	move.l cdr(a3),a0			
	unlkm	a1-a5
	rts

reverse:
	move.l car(a1),a1
	move.l d6,a0

	loop.s		
		cmp.l d6,a1
		while_ne

		newnode a2
		clr.l (a2)
		move.l car(a1),car(a2)
		move.l a0,cdr(a2)
		move.l a2,a0
		move.l cdr(a1),a1
	end

	unlkm	a1-a5
	rts

length:
	move.l car(a1),a0
	move.l #numtype*65536,d0
	clr.l d1
	moveq.l #1,d2

	cmp.w #strtype,(a0)
	if_eq.s
		move.w str_length(a0),d1
		newnode a0
		movem.l d0-d2,(a0)
		unlkm	a1-a5
		rts
	end
	loop.s
		cmp.l d6,a0
		while_ne

		addq.l #1,d1
		move.l cdr(a0),a0
	end
	newnode a0
	movem.l d0-d2,(a0)
	unlkm	a1-a5
	rts

rplaca:
	follow	a1,a0
	move.l	car(a1),car(a0)
	unlkm	a1-a5
	rts

rplacd:
	follow	a1,a0
	move.l	car(a1),cdr(a0)
	unlkm	a1-a5
	rts


mapcar:
	follow a1,a2		;get function
	move.l a1,a3		;save mapcar arg list
	move.l d6,a4		;init return list
	move.l d6,a5		;
	loop.s
		cmp.l car(a3),d6
		while_ne
		
		jsr mapcar_step			;get one result

		cmp.l #mapcar_done,a0		;see if one was returned
		while_ne

		newnode a1			;point a list node to result
		clr.l (a1)
		move.l a0,car(a1)
		move.l d6,cdr(a1)

		cmp.l d6,a4			;put it on list of results
		if_eq.s
			move.l a1,a4
			move.l a1,a5
		else
			move.l a1,cdr(a5)
			move.l a1,a5
		end
	end
	move.l a4,a0		;return list of results
	unlkm a1-a5
	rts

mapcar_done:	;a unique number (this can never be returned from apply)

mapcar_step:
	linkm a1-a5		;save regs
	move.l d6,a1		;init arg list for apply
	move.l d6,a5		;arglist builder
	loop
		cmp.l d6,a3			;if at end of mapcar arglist
		if_eq.s			
			xref int_apply		;do the apply
			jmp int_apply	
		end

		move.l car(a3),a4		;get first item
		cmp.l d6,a4			;if list empty
		if_eq.s
			move.l #mapcar_done,a0	;return the done signal
			unlkm a1-a5
			rts
		end

		move.l cdr(a4),car(a3)	;unlink arg from its list

		newnode a0		;make a new arglist node
		clr.l (a0)		;
		move.l car(a4),car(a0)	;copy arg into it
		move.l d6,cdr(a0)	;terminate it

		cmp.l d6,a1		;if first
		if_eq.s
			move.l a0,a1	;init new arglist
			move.l a0,a5
		else			;else link to end
			move.l a0,cdr(a5)
			move.l a0,a5
		end

		move.l cdr(a3),a3	;follow mapcar arglist
	end


init_lists:
	primitive car,.car
	primitive cdr,.cdr
	primitive caar
	primitive cadr
	primitive cdar
	primitive cddr
	primitive caaar
	primitive caadr
	primitive cadar
	primitive caddr
	primitive cdaar
	primitive cdadr
	primitive cddar
	primitive cdddr
	primitive first
	primitive second
	primitive third
	primitive fourth
	primitive fifth
	primitive sixth
	primitive seventh
	primitive eighth
	primitive ninth
	primitive tenth
	primitive nth
	primitive cons,.cons
	primitive list,.list
	primitive <list*>,.list.
	primitive append
	primitive rplaca
	primitive rplacd
	primitive length
	primitive reverse
	primitive mapcar
	primitive rest
	primitive last
	rts

	end
