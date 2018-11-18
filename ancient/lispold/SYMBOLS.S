	IDNT		symbols

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'


	.data

	xdef		oblist
	xdef	t,pseudo_nil,unbound,quote,rest,optional,aux,lambda,xmacro
	xdef cmma,bquote,commaat,gcverbose,evalhook

t:		ds.l 1
pseudo_nil: ds.l	1
unbound:	ds.l 1	
quote:	ds.l	1
bquote:	ds.l	1
cmma:	ds.l	1
commaat:	ds.l	1
rest:	ds.l 1
optional: ds.l 1
aux:		ds.l 1
lambda:	ds.l 1
xmacro:	ds.l	1
oblist:	ds.l	1
gcverbose ds.l 1
evalhook ds.l 1

	.code


	xdef		init_symbols
init_symbols:

	;create nil
	newnode	a0
	move.l	#constype*65536,(a0)
	move.l	a0,car(a0)
	move.l	a0,cdr(a0)
	move.l	a0,d6

	;create oblist
	move.l	#oblist_name,a0		;make oblist name
	xref		make_str
	jsr		make_str

	newnode	a1					;create the symbol
	newnode	a2
	move.l	#symtype*65536,(a1)
	move.l	a2,sym_more(a1)
	move.l	d6,(a2)				;no function
	move.l	d6,sym_plist(a2)		;no plist
	move.l	a0,sym_name(a2)		;set name

	newnode	a3					;create the list
	move.l	#constype*65536,(a3)
	move.l	a1,car(a3)			;list contains oblist
	move.l	d6,cdr(a3)
	move.l	a3,sym_value(a1)		;value of oblist is list
	move.l	a1,oblist				;remember where it is

	;create unbound
	move.l	#unbound_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,sym_value(a0)
	move.l	a0,unbound

	;create t
	move.l	#t_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,sym_value(a0)	;value of t is t
	move.l	a0,t

	;create pseudo-nil
	move.l	#nil_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,pseudo_nil

	;create quote
	move.l	#quote_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,quote

	;create bquote
	move.l	#bquote_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,bquote

	;create comma
	move.l	#comma_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,cmma

	;create commat
	move.l	#commaat_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,commaat

	;create rest
	move.l	#rest_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,rest

	;create optional
	move.l	#opt_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,optional

	;create aux
	move.l	#aux_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,aux

	;create lambda
	move.l	#lambda_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,lambda

	;create macro
	move.l	#macro_name,a0
	jsr		make_str
	jsr		get_symbol
	move.l	a0,xmacro

	;create *gc-verbose*
	move.l	#gcverb_name,a0
	jsr	make_str
	jsr	get_symbol
	move.l	a0,gcverbose
	move.l  t,sym_value(a0)

	;create *evalhook*
;	move.l	#hook_name,a0
;	jsr	make_str
;	jsr	get_symbol
;	move.l	a0,evalhook

	move.l d6,evalhook	;optimized evalhook, does not use *evalhook*

	rts



;find a symbol in the oblist. If the symbol cannot be found, create ;it, and add it to the oblist

;input: a string node in a0
;output: a symbol in a0

	xdef		get_symbol
get_symbol:
	stackcheck get_symbol
	linkm	a1/a2/a3

	move.l	oblist,a3
	move.l	sym_value(a3),a3

	loop
		cmp.l d6,a3		;see if at end of oblist
		while_ne

		follow a3,a2		;get first symbol

		move.l sym_more(a2),a1	;get symbol name
		move.l sym_name(a1),a1

		xref cmp_str
		jsr cmp_str			;compare symbol names
		if_eq
			move.l a2,a0		;if found return it
			unlkm a1/a2/a3
			rts
		end
	end

	;symbol not found, make new one

	newnode	a2
	move.l	#symtype*65536,(a2)
	move.l	d6,sym_more(a2)
	move.l	unbound,sym_value(a2)	
	newnode	a1
	move.l	unbound,(a1)
	move.l	d6,sym_plist(a1)
	move.l	a0,sym_name(a1)
	move.l	a1,sym_more(a2)
	move.l	a2,a0

	;add new symbol to oblist
	move.l	oblist,a2
	newnode	a1
	move.l	#constype*65536,(a1)
	move.l	a0,car(a1)
	move.l	sym_value(a2),cdr(a1)
	move.l	a1,sym_value(a2)

	unlkm	a1/a2/a3
	rts	



t_name:
	.byte		't',0
oblist_name:
	.byte		'oblist',0
unbound_name:
	.byte		'*unbound*',0
quote_name:
	.byte		'quote',0
bquote_name:
	.byte		'backquote',0
comma_name:
	.byte		'comma',0
commaat_name:
	.byte		'commaat',0
nil_name:
	.byte		'nil',0
lambda_name:
	.byte		'lambda',0
macro_name:
	.byte		'macro',0
rest_name:
	.byte		'&rest',0
opt_name:
	.byte		'&optional',0
aux_name:
	.byte		'&aux',0
gcverb_name:
	.byte		'*gc-verbose*',0
hook_name:
	.byte		'*evalhook*',0

	end
