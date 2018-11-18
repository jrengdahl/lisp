fptr:	equ	0
inptr:	equ	4
incnt:	equ	8
nextc:	equ	12
bufst:	equ	16
bufnd:	equ	16+80
fbsize:	equ	16+80

	xref	 	selget
	xref		selput
	xref		putc
	xref		flushout
	xref		.newline
	xref		.space
	xref		.comma
	xref		pstring
	xref		pbyte
	xref		pword
	xref		p24
	xref		plong
	xref		pdec
	xref		pdecs
	xref		getc
	xref		getupper
	xref		peekc
	xref		isnext
	xref		isspace
	xref		iswhite
	xref		isnl
	xref		isdigit
	xref		ishex
	xref		isalpha
	xref		skip
	xref		flushin
	xref		ghex
	xref		gdec
	xref		startup
	xref		dosbase
	xref		stdin
	xref		stdout
	xref		stderr
	xref		shutdown
	xref		.rdump
	xref		.dump
	xref		logfile
	xref		fropen
	xref		fwopen
	xref		fclose
	xref		malloc
	xref		free
