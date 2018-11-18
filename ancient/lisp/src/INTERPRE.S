	IDNT		interpreter

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'

	.code

	xref 	optional,rest,aux,lisp_print

;jumped to from evaluator with a1-a5 saved
;a1 = evaluated arglist
;a2 = cdr of lambda-list
;returns result in a0


 xref symerr

	xdef		interpreter
interpreter:
	move.l	d6,a5

	follow	a2,a3		;get formal arg list

	;process required args
	loop
		cmp.l	d6,a3		;while not done with formal args
		beq		fargsgone

		follow	a3,a4		;get a formal arg

		cmp.l	rest,a4		;while not a special
		beq		dorest
		cmp.l	optional,a4
		beq		dooptional
		cmp.l	aux,a4
		beq		doaux			

		cmp.l d6,a1	;check for missing args
		if_eq
			message	<;required arg missing>
			signal_error
		end

;process a new binding	
		newnode	a0
		clr.l	(a0)
		move.l	d6,car(a0)
		move.l	a5,cdr(a0)
		move.l	a0,a5
		newnode	a0
		clr.l	(a0)	
		move.l	a4,car(a0)
		move.l	sym_value(a4),cdr(a0)
		move.l	a0,car(a5)
		move.l	car(a1),sym_value(a4)
		move.l	cdr(a1),a1
	end


dooptional:
	;process optional args that have actual args
	loop
		cmp.l	d6,a3	;while not done with formal args
		beq		fargsgone

		cmp.l	d6,a1	;while not out of actual args
		beq		optionalsdone

		follow	a3,a4		;get a formal arg

		cmp.l	rest,a4		;while not a special
		beq		dorest
		cmp.l	aux,a4
		beq		doaux			

		;if formal is a list, get the symbol
		cmpi.w	#constype,(a4)
		if_eq.s
			move.l	car(a4),a4
		end

;process a new binding	
		newnode	a0
		clr.l	(a0)
		move.l	d6,car(a0)
		move.l	a5,cdr(a0)
		move.l	a0,a5
		newnode	a0
		clr.l	(a0)	
		move.l	a4,car(a0)
		move.l	sym_value(a4),cdr(a0)
		move.l	a0,car(a5)
		move.l	car(a1),sym_value(a4)
		move.l	cdr(a1),a1
	end

optionalsdone:
	;process optional args that do not have actual args
	loop
		cmp.l	d6,a3	;while not done with formal args
		beq		binddone

		follow	a3,a4		;get a formal arg

		cmp.l	rest,a4		;while not a special
		beq		nilrest
		cmp.l	aux,a4
		beq		procaux		

		;if formal is a list
		cmpi.w	#constype,(a4)
		if_eq.s
			move.l	cdr(a4),a0	;get expression
			move.l	car(a0),a0
			move.l	car(a4),a4	;get the symbol
			eval
		else
			move.l	d6,a0		;bind to nil
		end

;process a new binding	
		newnode	a1
		clr.l	(a1)
		move.l	d6,car(a1)
		move.l	a5,cdr(a1)
		move.l	a1,a5
		newnode	a1
		clr.l	(a1)	
		move.l	a4,car(a1)
		move.l	sym_value(a4),cdr(a1)
		move.l	a1,car(a5)
		move.l	a0,sym_value(a4)
	end


nilrest:
		move.l	d6,a1	
dorest:	
	cmp.l	d6,a3
	if_eq.s
		message <;missing &rest symbol>
		signal_error
	end

	;process &rest args
	follow	a3,a4

	;process new binding	
	newnode	a0
	clr.l	(a0)
	move.l	d6,car(a0)
	move.l	a5,cdr(a0)
	move.l	a0,a5
	newnode	a0
	clr.l	(a0)	
	move.l	a4,car(a0)
	move.l	sym_value(a4),cdr(a0)
	move.l	a0,car(a5)
	move.l	a1,sym_value(a4)

	;check for more keywords
	cmp.l	d6,a3
	beq		binddone

	follow	a3,a4
	cmp.l	aux,a4
	beq		procaux

	message	<;extraneous formal args>
	signal_error


doaux:
	;at this point there should be no more actual args
	cmp.l	d6,a1
	if_ne
		message	<;extraneous actual args>
		signal_error
	end

procaux:
	loop
		cmp.l	d6,a3	;while not done with formal args
		beq		binddone

		follow	a3,a4		;get a formal arg

		;if formal is a list
		cmpi.w	#constype,(a4)
		if_eq.s
			move.l	cdr(a4),a0	;get expression
			move.l	car(a0),a0
			move.l	car(a4),a4	;get the symbol
			eval
		else
			move.l	d6,a0		;bind to nil
		end

;process a new binding	
		newnode	a1
		clr.l	(a1)
		move.l	d6,car(a1)
		move.l	a5,cdr(a1)
		move.l	a1,a5
		newnode	a1
		clr.l	(a1)	
		move.l	a4,car(a1)
		move.l	sym_value(a4),cdr(a1)
		move.l	a1,car(a5)
		move.l	a0,sym_value(a4)
	end

	
fargsgone:
	cmp.l	d6,a1
	if_ne
		message <;extraneous actual args>
		signal_error
	end

binddone:
;interpret the body
	move.l d6,a0
	loop
		cmp.l d6,a2
		while_ne

		follow a2,a0
		eval
	end

;unbind locals
	loop
		cmp.l d6,a5
		while_ne

		follow a5,a4
		move.l car(a4),a3
		move.l cdr(a4),sym_value(a3)
	end

	unlkm a1-a5
	rts 



	xdef	init_interpreter
init_interpreter:
	rts

	end
