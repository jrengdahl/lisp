	IDNT		memory

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'

	.data

	xdef	stackbot	
initsp:	ds.l 1
stackbot:	ds.l	1


	.code
	xdef		start

	xdef		exit
exit:
	move.l	initsp,sp
	message	<exiting lisp>
	xref		freeall
	jsr		freeall
	jsr		shutdown
	moveq.l	#1,d0
	rts


	xdef		error
error:
	move.l	initsp,sp
	message	<serious error: restarting>
	jmp		.restart


	xdef		stackovfl
stackovfl:
	move.l	initsp,sp
	message	<stack overflow: restarting>
	jmp		.restart



start:
	jsr		startup	

	message	<(lisp) 1.0 Copyright (C) 1987 by Jonathan Engdahl>

	;save stack for exit and error recovery
	move.l	sp,initsp

	;initialize stack info
	move.l	sp,a0
	sub.l	4(sp),a0
	add.l	#1024,a0
	move.l	a0,stackbot

	xref		init_memory
	jsr		init_memory
	xref		init_symbols
	jsr		init_symbols
	xref		init_specials
	jsr		init_specials
	xref		init_lists
	jsr		init_lists
	xref		init_functions
	jsr		init_functions
	xref		init_evaluator
	jsr		init_evaluator
	xref		init_reader
	jsr		init_reader
	xref		init_printer
	jsr		init_printer
	xref		init_booleans
	jsr		init_booleans
	xref		init_conditionals
	jsr		init_conditionals
	xref		init_numbers
	jsr		init_numbers
	xref		init_files
	jsr		init_files

	primitive	exit
	primitive error

.restart:
	move.l	d6,a0
	move.l	d6,a1
	move.l	d6,a2
	move.l	d6,a3
	move.l	d6,a4
	move.l	d6,a5
	move.l	#0,a6


	loop
		xref	lisp_read,lisp_print,verbose
		jsr	lisp_read
		eval
		tst.b verbose
		if_nz.s
			jsr	lisp_print
		end
	end

	end

