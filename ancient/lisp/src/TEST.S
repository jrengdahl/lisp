	IDNT		memory

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'

	.data



	.code
	xdef		start



start:

	jsr		startup	

	loop.s
		jsr getc
		tst.l d0
		while_ge

		jsr putc
	end

	jsr		shutdown

	moveq.l	#1,d0
	rts

str:	dc.b 'test.s',0

	end

