	IDNT		conditionals

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'


	.data

	.code

	xref	t

.lif:
	follow a1,a0
	eval
	cmp.l d6,a0
	if_eq
		follow a1,a0
		move.l car(a1),a0
		eval
		unlkm a1-a5
		rts
	else
		move.l car(a1),a0
		eval
		unlkm a1-a5
		rts
	end

.or:
	loop.s
		cmp.l d6,a1
		if_eq.s
			move.l d6,a0
			unlkm a1-a5
			rts
		end	
		follow a1,a0
		eval
		cmp.l d6,a0
		while_eq
	end
	unlkm a1-a5
	rts

.and:
	move.l t,a0
	loop.s
		cmp.l d6,a1
		while_ne
		follow a1,a0
		eval
		cmp.l d6,a0
		while_ne
	end
	unlkm a1-a5
	rts


cond:
	move.l d6,a0
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a2		;get next clause

		follow a2,a0		;get test
		eval			;eval it
		cmp.l d6,a0		;if true
		if_ne.s				
			loop.s
				cmp.l d6,a2	;evaluate each form in the body
				while_ne

				follow a2,a0
				eval
			end
			unlkm a1-a5
			rts
		end
	end
	unlkm a1-a5
	rts

dolist:
	follow a1,a2			;get var and list 
	follow a2,a3			;get var
	move.l sym_value(a3),a4		;save value
	follow a2,a0			;get list
	eval				;eval list
	move.l a0,a2			;this is the list to iterate over

	loop
		cmp.l d6,a2		;while list is not done
		while_ne

		follow a2,a0		;get next item in list
		move.l a0,sym_value(a3)	;bind to loop variable

		move.l a1,a5		;get the body

		loop.s
			cmp.l d6,a5	;evaluate each form in the body
			while_ne
			follow a5,a0
			eval
		end
	end

	move.l a4,sym_value(a3)		;restore binding of loop variable
	move.l d6,a0			;return a nil
	unlkm a1-a5
	rts


do:
	;a1 is left pointing to the original do arguments
	;a2 follows it once per iteration

	;save and initialise the variables

	move.l a1,a2			;point to start of do
	follow a2,a3			;get list of bindings 

	loop
		cmp.l d6,a3
		while_ne

		follow a3,a4		;get a binding
		follow a4,a5		;get the symbol
		move.l sym_value(a5),a0	;save value
		linkm a0		;

		follow a4,a0		;eval the init form
		eval
		move.l a0,sym_value(a5)	;set the init value
	end

	;now start interating

	loop
		follow a2,a3		;get end test and result forms

		follow a3,a0		;get conditional
		eval			;eval it
		cmp.l d6,a0		;if not nil
		if_ne				
			loop.s
				cmp.l d6,a3	;evaluate each form in the body
				while_ne

				follow a3,a0
				eval
			end

			;restore the initial bindings of the loop variables

			move.l a1,a2
			follow a2,a3			;get list of bindings 

			loop
				cmp.l d6,a3
				while_ne

				follow a3,a4		;get a binding
				follow a4,a5		;get the symbol
				unlkm a4		;restore the value
				move.l a4,sym_value(a5)	;
			end

			unlkm a1-a5
			rts
		end

		;now evaluate the body of the do

		loop.s
			cmp.l d6,a2	;evaluate each form in the body
			while_ne

			follow a2,a0
			eval
		end

		;reset back to start of do, and update the variables

		move.l a1,a2			;reset to start
		follow a2,a3			;get list of bindings 

		loop
			cmp.l d6,a3
			while_ne

			follow a3,a4		;get a binding
			follow a4,a5		;get the symbol

			follow a4,a0		;skip the init form
			follow a4,a0		;eval the step form
			eval
			move.l a0,sym_value(a5)	;update the variable
		end
	end


progn:
	move.l d6,a0
	loop
		cmp.l d6,a1
		while_ne

		follow a1,a0
		eval
	end

	unlkm a1-a5
	rts

	xdef	init_conditionals
init_conditionals:
	special cond
	special if,.lif
	special and,.and
	special or,.or
	special dolist
	special do
	special do*,do
	special progn
	
	rts

	end
