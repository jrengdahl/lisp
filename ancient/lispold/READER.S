	IDNT		read

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'


	.data

	.code

	xdef		lisp_read
lisp_read:
	stackcheck lisp_read
	push.l	d0
	linkm	a1/a2

tryagain:
	jsr		peekc
	tst.l	d0
	if_mi						;end-of-file!
		move.l fileptr,a0
		cmp.l #filetable,a0			;if there are stacked files
		if_ne
			move.l -(a0),d0		;pop a file
			move.l a0,fileptr

			push.l d0
			move.l d0,d1			;see if it is a terminal
			doscall IsInteractive
			tst.l d0
			if_nz.s
				move.b #1,prompt	;if so set the prompt flag
				print <Lisp>
				putcon '>'
				jsr flushout
			else
				move.b #0,prompt	;else clear it
			end
			pop.l d0	
	
			jsr selget			;select the new file, ret old
			move.l d0,d1			;close the old file
			doscall Close

			move.l flagptr,a0		;pop the verbose flag
			move.b -(a0),verbose
			move.l a0,flagptr

			bra tryagain
		else						;EOF on the top level file!
			move.l #conname,d1		;open the console device
			move.l #MODE_OLDFILE,d2
			doscall Open
			jsr selget			;select it
			move.l fileptr,a0		;push the old file
			move.l d0,(a0)+
			move.l a0,fileptr
		doscall IsInteractive		;see if its a terminal
		tst.l d0
		if_nz.s
			move.b #1,prompt		;if so set the prompt flag
			print <Lisp>
			putcon '>'
			jsr flushout
		else
			move.b #0,prompt		;else clear it
		end
			move.l flagptr,a0		;and verbose flag
			move.b verbose,(a0)+
			move.l a0,flagptr
			move.b #1,verbose		;set verbose
			move.b #1,prompt		;and prompt
			print <Lisp>
			putcon '>'
			jsr flushout
			bra tryagain
		end
	end

	cmp.b	#10,d0
	beq		rdnewline
	cmp.b	#' ',d0
	ble		scrap
	cmp.b	#'(',d0
	beq		rdlist
	cmp.b	#')',d0
	beq		extrapar
	cmp.b	#'''',d0
	beq		rdquote
	cmp.b	#'`',d0
	beq		rdbackquote
	cmp.b	#',',d0
	beq		rdcomma
	cmp.b	#'"',d0
	beq		rdstring
	cmp.b	#'#',d0
	beq		rdmacro
	cmp.b	#';',d0
	beq		rdcomment
	cmp.b	#'-',d0
	beq		rdminus
	jsr		isdigit
	beq		rdnum
	bra		rdsym

rdret:
	unlkm	a1/a2
	pop.l	d0
	rts

rdnewline:
	jsr getc
	tst.b prompt
	if_ne.s
		print <Lisp>
		putcon '>'
		jsr flushout
	end
	bra	tryagain

scrap:
	jsr	getc
	bra	tryagain

rdcomment:

	loop
		jsr getc
		cmpi.b #10,d0
		while_ne
	end
	bra tryagain


extrapar:
	jsr	getc
	message <extra right parenthesis ignored>
	bra		tryagain

rdminus:
	jsr		getc
	jsr		isdigit
	if_ne.s
		xref pminus
		move.l pminus,a0
		bra rdret
	else
		jsr gdec
		neg.l d0
		bra.s rdcom
	end

rdnum:
	jsr		gdec
rdcom:
	newnode	a0
	move.l	#numtype*65536,(a0)
	move.l	d0,numerator(a0)
	jsr		peekc
	cmp.b	#'/',d0
	if_eq.s
		jsr getc
		jsr gdec
		move.l d0,denominator(a0)
		move.w #rattype,(a0)
	else
		move.l #1,denominator(a0)
	end

	bra	rdret

rdlist:
	jsr		getc
	move.l	d6,a1
	move.l	d6,a2

	loop
		loop.s
			jsr iswhite
			while_eq
			jsr getc
		end
		jsr peekc
		cmp.b #')',d0
		while_nz

		newnode a0
		move.l #constype*65536,(a0)
		move.l d6,cdr(a0)
		move.l d6,car(a0)

		cmp.l d6,a2
		if_eq.s
			move.l a0,a1
		else
			move.l a0,cdr(a2)
		end
		move.l a0,a2
		jsr lisp_read
		move.l a0,car(a2)
	end
	jsr		getc
	move.l	a1,a0
	bra		rdret

rdquote:
	jsr		getc
	jsr		lisp_read
	newnode	a1
	move.l	#constype*65536,(a1)
	move.l	d6,cdr(a1)
	move.l	a0,car(a1)
	newnode	a0
	move.l	#constype*65536,(a0)
	move.l	a1,cdr(a0)
	xref		quote
	move.l	quote,car(a0)
	bra	rdret

rdbackquote:
	jsr		getc
	jsr		lisp_read

	newnode	a1
	move.l	#constype*65536,(a1)
	move.l	d6,cdr(a1)
	move.l	a0,car(a1)

	newnode	a0
	move.l	#constype*65536,(a0)
	move.l	quote,car(a0)
	move.l	a1,cdr(a0)

	newnode	a1
	move.l	#constype*65536,(a1)
	move.l	d6,cdr(a1)
	move.l	a0,car(a1)

	newnode	a0
	move.l	#constype*65536,(a0)
	move.l	a1,cdr(a0)
	xref	bquote
	move.l	bquote,car(a0)
	bra	rdret

rdcomma:
	xref		cmma,commaat
	jsr		getc
	jsr		peekc
	cmp.b	#'@',d0
	if_ne.s
		jsr		lisp_read
		newnode	a1
		move.l	#constype*65536,(a1)
		move.l	d6,cdr(a1)
		move.l	a0,car(a1)
		newnode	a0
		move.l	#constype*65536,(a0)
		move.l	cmma,car(a0)
		move.l	a1,cdr(a0)
	else
		jsr		getc
		jsr		lisp_read
		newnode	a1
		move.l	#constype*65536,(a1)
		move.l	d6,cdr(a1)
		move.l	a0,car(a1)

		newnode	a0
		move.l	#constype*65536,(a0)
		move.l	commaat,car(a0)
		move.l	a1,cdr(a0)
	end
	bra	rdret

rdmacro:
rdsym:
	jsr		readident
	xref		get_symbol
	jsr		get_symbol
	xref		pseudo_nil
	cmp.l	pseudo_nil,a0
	if_eq.s
		move.l d6,a0
	end
	bra		rdret

rdstring:
	jsr		getc
	jsr		readstr
	jsr		peekc
	cmp.b	#'"',d0
	if_eq.s
		jsr getc
	else
		message <illegal string termination>
		signal_error
	end
	bra		rdret	


readstr:
	stackcheck readstr
	pushm.l	d0/d1/d2
	linkm	a1/a2

	newnode	a0
	move.l	a0,a2
	clr.l	4(a0)
	clr.l	8(a0)
	lea		str_more(a0),a1
	move.l	#strtype*65536,(a0)+

	move.w	#4,d1
	clr.l	d2

	loop
		jsr peekc
		cmpi.b #'"',d0
		while_nz

		tst.w d1
		if_eq.s
			move.l d6,a0
			newnode a0
			move.l a0,(a1)
			move.l a0,a1
			clr.l 4(a0)
			clr.l 8(a0)
			clr.l (a0)+	
			move.w #8,d1
		end
	
		jsr getc
		move.b d0,(a0)+
		subq.w #1,d1
		addq.w #1,d2
		if_mi
			message <string greater than 32K>
			signal_error
		end
	end

	move.w	d2,str_length(a2)
	move.l	a2,a0
	unlkm	a1/a2
	popm.l	d0/d1/d2
	rts


readident:
	stackcheck readident
	pushm.l	d0/d1/d2
	linkm	a1/a2

	newnode	a0
	move.l	a0,a2
	clr.l	4(a0)
	clr.l	8(a0)
	lea		str_more(a0),a1
	move.l	#strtype*65536,(a0)+

	move.w	#4,d1
	clr.l	d2

	loop
		jsr isalpha
		if_ne
		  jsr isdigit
		  if_ne
		    jsr iswhite
		    if_eq
		      break
		    else
		      jsr peekc
		      cmpi.b #'"',d0
                if_eq.s
                  break
                else
                cmpi.b #'''',d0
                if_eq.s
                  break
                else
                cmpi.b #'(',d0
                if_eq.s
                  break
                else
                cmpi.b #')',d0
                if_eq.s
                  break
                else
                cmpi.b #';',d0
                if_eq.s
                  break
                else
                cmpi.b #'`',d0
                if_eq.s
                  break
                else
                cmpi.b #',',d0
                if_eq.s
                  break
                end
                end
                end
                end
                end
                end
                end
		    end
		  end
		end

		tst.w d1
		if_eq.s
			move.l d6,a0
			newnode a0
			move.l a0,(a1)
			move.l a0,a1
			clr.l 4(a0)
			clr.l 8(a0)
			clr.l (a0)+	
			move.w #8,d1
			end
	
		jsr getc
		move.b d0,(a0)+
		subq.w #1,d1
		addq.w #1,d2
		if_mi
			message <string greater than 32K>
			signal_error
		end
	end

	move.w	d2,str_length(a2)
	move.l	a2,a0
	unlkm	a1/a2
	popm.l	d0/d1/d2
	rts


l_read:
	jsr	lisp_read
	unlkm a1-a5
	rts
	

	xdef		prompt,verbose
	.data
filetable:	ds.l		32
ftend:		ds.l		0
fileptr:		ds.l		1
filename:		ds.l		32
flagtable:	ds.b		32
flagptr:		ds.l		1
prompt:		ds.b		1
verbose:		ds.b		1

	.code
	xdef		init_files
init_files:
	primitive	load

	move.l #filetable,fileptr
	move.l #flagtable,flagptr
	move.b #1,verbose

	move.l #initname,d1			;try to open "lisp.lsp"
	move.l #MODE_OLDFILE,d2
	doscall Open
	tst.l d0
	if_nz					;it its there
		jsr selget
		move.l fileptr,a0		;push the stdin
		move.l d0,(a0)+
		move.l a0,fileptr
		move.l flagptr,a0		;and verbose
		move.b verbose,(a0)+
		move.l a0,flagptr
		clr.b verbose			;go to file mode
		clr.b prompt
	else
		clr.l d0					;find the std-in file
		jsr selget
		move.l d0,d1
		jsr selget
	
		doscall IsInteractive		;see if its a terminal
		tst.l d0
		if_nz.s
			move.b #1,prompt		;if so set the prompt flag
			print <Lisp>
			putcon '>'
			jsr flushout
		else
			move.b #0,prompt		;else clear it
		end
	end

	rts



load:
	move.l fileptr,a0			;see if overflowed
	cmp.l #ftend,a0
	if_eq
		message <too many nested LOADs>
		signal_error
	end

	move.l car(a1),a0			;get the filename
	cmp.w #symtype,(a0)
	if_eq.s
		move.l sym_more(a0),a0
		move.l sym_name(a0),a0
	end
	cmp.w #strtype,(a0)
	if_ne
		message <load arg not a file name>
		signal_error
	end

	move.l #filename,a1			;convert to C string
	xref	string2c
	jsr	string2c

	move.l #filename,d1			;try to open the file
	move.l #MODE_OLDFILE,d2
	doscall Open
	tst.l d0
	if_z						;if can't; complain about it
		print <Cant open file >
		move.l #filename,a0
		jsr pstring
		newline
		signal_error
	end

	push.l d0
	doscall IsInteractive		;see if its a terminal
	tst.l d0
	if_nz.s
		move.b #1,prompt		;if so set the prompt flag
		print <Lisp>
		putcon '>'
		jsr flushout
	else
		move.b #0,prompt		;else clear it
	end
	pop.l d0

	jsr selget				;select the file
	move.l fileptr,a0			;push the old one
	move.l d0,(a0)+
	move.l a0,fileptr
	move.l flagptr,a0			;and its verbosity flag
	move.b verbose,(a0)+
	move.l a0,flagptr
	clr.b verbose				;default to verbose for now
	move.l d6,a0
	move.l d6,a1
	unlkm a1-a5
	rts


readchar:
	jsr getc
	newnode a0
	move.l #numtype*65536,(a0)
	move.l d0,numerator(a0)
	move.l #1,denominator(a0)
	unlkm a1-a5
	rts

peekchar:
	jsr peekc
	newnode a0
	move.l #numtype*65536,(a0)
	move.l d0,numerator(a0)
	move.l #1,denominator(a0)
	unlkm a1-a5
	rts

	xdef		init_reader
init_reader:
	primitive	read,l_read
	primitive	<read-char>,readchar
	primitive	<peek-char>,peekchar
	rts


initname:	dc.b 'lisp.lsp',0
conname: dc.b '*',0	

	end
