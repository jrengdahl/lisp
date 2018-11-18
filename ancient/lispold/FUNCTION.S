	IDNT		functions

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'

	.data
	.code


	xref	lambda

	xdef	.unbound
.unbound:
	message <unbound symbol-function>
	signal_error


;input: C string for name in d1
;primitive address in d0

;returns symbol in a0

	xdef	make_primitive
make_primitive:
	linkm	a1/a2

	newnode	a1
	move.l	#primtype*65536,(a1)
	move.l	d0,prim_addr(a1)
	move.l	d1,prim_name(a1)

	xref		make_str,get_symbol
	move.l	d1,a0
	jsr		make_str
	jsr		get_symbol
	move.l	sym_more(a0),a2
	move.l	a1,(a2)
	unlkm	a1/a2
	rts


	xdef	make_special
make_special:
	linkm	a1/a2

	newnode	a1
	move.l	#sfuntype*65536,(a1)
	move.l	d0,prim_addr(a1)
	move.l	d1,prim_name(a1)

	move.l	d1,a0
	jsr		make_str
	jsr		get_symbol
	move.l	sym_more(a0),a2
	move.l	a1,(a2)
	unlkm	a1/a2
	rts


symbol_value:
	move.l car(a1),a0		;get first arg
	cmp.w #symtype,(a0)
	if_ne.s
		message <symbol-value needs a symbol>
		signal_error
	end
	move.l sym_value(a0),a0
	unlkm a1-a5
	rts


symbol_function:
	move.l car(a1),a0		;get first arg
	cmp.w #symtype,(a0)
	if_ne.s
		message <symbol-function needs a symbol>
		signal_error
	end
	move.l sym_more(a0),a0	;get second part of symbol
	move.l (a0),a0
	unlkm a1-a5
	rts

symbol_name:
	move.l car(a1),a0		;get first arg
	cmp.w #symtype,(a0)
	if_ne.s
		message <symbol-name needs a symbol>
		signal_error
	end
	move.l sym_more(a0),a0	;get second part of symbol
	move.l sym_name(a0),a0
	unlkm a1-a5
	rts

symbol_plist:
	move.l car(a1),a0		;get first arg
	cmp.w #symtype,(a0)
	if_ne.s
		message <symbol-plist needs a symbol>
		signal_error
	end
	move.l sym_more(a0),a0	;get second part of symbol
	move.l sym_plist(a0),a0
	unlkm a1-a5
	rts

put_sym_fun:
	follow a1,a2			;get first arg
	move.l car(a1),a0		;get second arg
	move.l sym_more(a2),a2	;get rest of symbol
	move.l a0,(a2)			;put value in symbol
	unlkm  a1-a5
	rts

put_sym_plist:
	follow a1,a2			;get first arg
	move.l car(a1),a0		;get second arg
	move.l sym_more(a2),a2		;get rest of symbol
	move.l a0,sym_plist(a2)		;put value in symbol
	unlkm  a1-a5
	rts

	xdef	init_functions
init_functions:
	primitive <symbol-function>,symbol_function
	primitive <symbol-name>,symbol_name
	primitive <symbol-value>,symbol_value
	primitive <symbol-plist>,symbol_plist
	primitive <put-sym-fun>,put_sym_fun
	primitive <put-sym-plist>,put_sym_plist
	rts

	end
