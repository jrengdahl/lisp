	IDNT		spy

	include	'common/hdr.i'
	include	'common/io.i'

	.data

	xdef	snapshot
snapshot:	ds.l	32
sawtable:	ds.l	256
sawptr:	ds.l	1

	.code

	xdef	spy
spy:
	pushm.l	d0-d7/a0-a6
	jsr		flushin
	print	<Amiga Spy 0.0>
	newline
	jsr		rdmp
	bra		mainloop

	xdef		snap
snap:
	push.l	d0
	push.l	a1
	move.l	#snapshot,a1
	repeat	#16,d0
		move.w (a0)+,(a1)+
	end
	pop.l	a1
	pop.l	d0
	rts
	
mainloop:
	putcon	'>'
	jsr		flushout
	jsr		getc

	cmp.b	#'d',d0
	beq		mdump

	cmp.b	#'l',d0
	beq		mdis

	cmp.b	#'f',d0
	beq		mdisf

	cmp.b	#'m',d0
	beq		mpatch

	cmp.b	#'c',d0
	beq		mcont

	cmp.b	#'q',d0
	beq		mquit

	cmp.b	#'e',d0
	beq		merror

	cmp.b	#'f',d0
	beq		mfinish

	cmp.b	#'h',d0
	beq		help

	cmp.b	#'r',d0
	beq		mrdmp

	print	<unrecognized command>
	newline
newcommand:
	jsr		flushin
	bra		mainloop

mcont:	popm.l d0-d7/a0-a6
	rts

mquit:
	doscall	Exit

mfinish:
	xref		exit
	jmp		exit

merror:
	xref		error
	jmp		error

mdump:
	jsr		ghex
	move.l	d0,a0
	jsr		ghex
	cmpa.l	d0,a0
	bgt.s	1$
	sub.l	a0,d0
1$:	tst.l	d0
	bne.s	2$
	move.l	#16,d0
2$:	dump		a0,d0
	bra		newcommand

mrdmp:
	jsr		rdmp
	bra		newcommand

rdmp:
	lea		4(sp),a0
	print	<D:>
	repeat	#8,d1
		move.l (a0)+,d0
		jsr plong
		space
	end
	newline
	print <A:>
	repeat	#7,d1
		move.l (a0)+,d0
		jsr plong
		space
	end
	move.l sp,d0
	add.l #64,d0
	jsr plong
	lea 4(a0),a0
	newline
	print <U:>
	repeat	#15,d1
		move.w (a0)+,d0
		jsr pword
		space
	end
	newline
	print <S:>
	move.l #snapshot,a0
	repeat	#15,d1
		move.w (a0)+,d0
		jsr pword
		space
	end
	newline
	rts




mdisf: moveq.l #1,d7
	bra.s discom
mdis: clr.l d7
discom:

	jsr		ghex
	move.l	d0,a0
	jsr		ghex
	cmpa.l	d0,a0
	bgt.s	1$
	sub.l	a0,d0
1$:	tst.l	d0
	bne.s	2$
	move.l	#16,d0
2$:	jsr		disasm
	bra		newcommand

mpatch:
	jsr		ghex
	move.l	d0,a0
	jsr		ghex
	move.w	d0,(a0)
	bra		newcommand
	
help:
	print	<l ssss eeee      linear disassembly>
	newline
	print	<f ssss eeee      follow disassembly>
	newline
	print	<d ssss eeee      display memory>
	newline
	print	<m aaaa dddd      modify a word>
	newline
	print	<r                register dump>
	newline
	print	<q                quit>
	newline
	bra		newcommand

disasm:
	push.l	a6
	move.l	#0,a6
	move.l	#sawtable,sawptr
	move.l	d0,d3
	move.l	a0,a1
	moveq.l	#1,d6
	loop
		tst.l d3				;while not done disassembling
		while_pl

		jsr disone


		tst.b d7
		if_nz
			cmp.w rtsx,d1
			if_eq.s
				break
			end		
			cmp.w rtex,d1
			if_eq.s
				break
			end		

			move.w d1,d0
			lsr.w #8,d0
			cmp.b bsrx,d0
			if_eq.s
				jsr disrtn
			else
				cmp.w jsrx,d1
				if_eq.s
					jsr disrtn
				end
			end
		end
	end
	pop.l	a6
	rts		


bsrx:	bsr bsrx
jsrx:	jsr jsrx
rtsx:	rts
rtex:	rte

disrtn:
	move.l	a6,a0		;check for recursion
	loop
		move.l a0,d0
		while_nz

		cmp.l 4(a0),d5
		if_eq
			print <*** recursion ***>
			newline
			rts
		end

		move.l (a0),a0
	end

	move.l	#sawtable,a0		;check for repeat listing
	loop
		cmp.l sawptr,a0
		while_ult

		cmp.l (a0),d5
		if_eq
			print <*** already listed ***>
			newline
			rts
		end

		addq.l #4,a0
	end


	push.l	d3
	push.l	a1
	push.l	d5
	link		a6,#0

	move.l	sawptr,a0
	cmp.l	#sawtable+256,a0
	if_uge
		print <*** table full ***>
		newline
		rts
	end
	move.l	d5,(a0)+
	move.l	a0,sawptr

	move.l	#1000,d3
	move.l	d5,a1
	addq.l	#2,d6
	loop
		tst.l d3				;while not done disassembling
		while_pl

		jsr disone

		cmp.w rtsx,d1
		if_eq.s
			break
		end		
		cmp.w rtex,d1
		if_eq.s
			break
		end		

		move.w d1,d0
		lsr.w #8,d0
		cmp.b bsrx,d0
		if_eq.s
			jsr disrtn
		else
			cmp.w jsrx,d1
			if_eq.s
				jsr disrtn
			end
		end
	end
	subq.l	#2,d6
	unlk		a6
	pop.l	d5
	pop.l	a1
	pop.l	d3
	rts		




disone:
	move.l	a1,d0		;print address
	jsr		p24

	repeat d6,d2
		space
	end

	move.w	(a1)+,d1		;get first word of opcode
	subq.l	#2,d3		;decrement count
	
	move.l	#optab,a2		;get addr of The Table
	loop
		move.w (a2)+,d0	;get mask from table
		while_nz			;if zero mask - done
		and.w d1,d0		;try the opcode
		cmp.w (a2)+,d0		;
		if_ne			;if no match
			move.b (a2)+,d0	;skip size flag
			loop			;skip to end of string
				move.b (a2)+,d0
				while_nz
			end
			move.l a2,d0		;round to even
			addq.l #1,d0
			bclr #0,d0
			move.l d0,a2
		else					;process format string
			clr.w d4		;get the operation size
			move.b (a2)+,d4
			loop
				move.b (a2)+,d0
				while_nz

				move.l #chartab,a0
				move.l #subtab,a3
				loop
					tst.b (a0)
					if_eq.s
						jsr putc
						break
					end
					cmp.b (a0)+,d0
					if_eq.s
						move.l (a3),a0
						jsr (a0)
						break
					end
					addq.l #4,a3
				end
			end
			break			;stop Table loop
		end
	end
	newline
	rts


putA:
	putcon	'A'
	move.l	d1,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	and.b	#7,d0
	add.b	#'0',d0
	jsr		putc
	rts

putF:
	putcon	'A'
	move.l	d1,d0
	and.b	#7,d0
	add.b	#'0',d0
	jsr		putc
	rts


ari:
	putcon	'('
	putcon	'A'
	move.l	d1,d0
	and.b	#7,d0
	add.b	#'0',d0
	jsr		putc
	putcon	')'
	rts

indexed:
	move.w	(a1)+,d0
	subq.l	#2,d3
	jsr		pword
	putcon	'('
	putcon	'A'
	move.l	d1,d0
	and.b	#7,d0
	add.b	#'0',d0
	jsr		putc
	putcon	')'
	rts

double:
	move.w	(a1),d0
	jsr		pbyte
	putcon	'('
	putcon	'A'
	move.l	d1,d0
	and.b	#7,d0
	add.b	#'0',d0
	jsr		putc
	comma
	move.w	(a1),d0
	btst		#15,d0
	if_nz.s
		putcon 'A'
	else
		putcon 'D'
	end
	lsr.w	#8,d0
	lsr.w	#4,d0
	and.b	#7,d0
	or.b		#'0',d0
	jsr		putc
	putcon	'.'
	move.w	(a1)+,d0
	subq.l	#2,d3
	btst		#11,d0
	if_nz.s
		putcon 'l'
	else
		putcon 'w'
	end
	putcon	')'
	rts

pcrel:
	move.l	a1,d2
	move.w	(a1)+,d0
	subq.l	#2,d3
	ext.l	d0
	add.l	d2,d0
	move.l	d0,d5
	jsr		p24
	putcon	'('
	putcon	'P'
	putcon	'C'
	putcon	')'
	rts

pcind:
	move.w	(a1),d0
	ext.w	d0
	ext.l	d0
	add.l	a1,d0
	jsr		p24
	putcon	'('
	putcon	'P'
	putcon	'C'
	comma
	move.w	(a1),d0
	btst		#15,d0
	if_nz.s
		putcon 'A'
	else
		putcon 'D'
	end
	lsr.w	#8,d0
	lsr.w	#4,d0
	and.b	#7,d0
	or.b		#'0',d0
	jsr		putc
	putcon	'.'
	move.w	(a1)+,d0
	subq.l	#2,d3
	btst		#11,d0
	if_nz.s
		putcon 'l'
	else
		putcon 'w'
	end
	putcon	')'
	rts

aripl:
	putcon	'('
	putcon	'A'
	move.l	d1,d0
	and.b	#7,d0
	add.b	#'0',d0
	jsr		putc
	putcon	')'
	putcon	'+'
	rts

arimi:
	putcon	'-'
	putcon	'('
	putcon	'A'
	move.l	d1,d0
	and.b	#7,d0
	add.b	#'0',d0
	jsr		putc
	putcon	')'
	rts


putC:
	move.l	d1,d0
	lsr.w	#7,d0
	and.b	#$1e,d0
	move.w	d0,a0
	move.b	cctab(a0),d0
	jsr		putc
	move.b	cctab+1(a0),d0
	jsr		putc
	rts

cctab: dc.b 't f hilscccsneeqvcvsplmigeltgtle'


putD:
	putcon	'D'
	move.l	d1,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	and.w	#7,d0
	add.b	#'0',d0
	jsr		putc
	rts

putS:
	putcon	'D'
	move.l	d1,d0
	and.w	#7,d0
	add.b	#'0',d0
	jsr		putc
	rts

putQ:
	putcon	'#'
	move.l	d1,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	and.b	#7,d0
	add.b	#'0',d0
	jsr		putc
	rts


putI:
	putcon	'#'
	move.l	d1,d0
	jsr		pbyte
	rts


putM:
	lea		regtab,a0
	move.w	d5,d2
	loop
		tst.w	d2
		while_nz

		btst		#0,d2
		if_nz.s
			move.b (a0)+,d0
			jsr	putc
			move.b (a0)+,d0
			jsr	putc
			lsr.w #1,d2
			if_ne.s
				putcon '/'
			end
		else
			addq.l #2,a0
			lsr.w #1,d2
		end
	end
	rts	

putZ:
	lea		regtab,a0
	move.w	d5,d2
	loop
		tst.w	d2
		while_nz

		btst		#15,d2
		if_nz.s
			move.b (a0)+,d0
			jsr	putc
			move.b (a0)+,d0
			jsr	putc
			lsl.w #1,d2
			if_ne.s
				putcon '/'
			end
		else
			addq.l #2,a0
			lsl.w #1,d2
		end
	end
	rts	

regtab: dc.b 'd0d1d2d3d4d5d6d7a0a1a2a3a4a5a6a7'
	
putP:
	move.w (a1)+,d5
	subq.l #2,d3
	rts

putO:
	putcon '.'
	move.w d1,d4
	lsr.w #6,d4
	and #3,d4
	move.w d4,a0
	add.l #bwl,a0
	move.b (a0),d0
	jsr putc
	space
	btst #8,d1
	if_nz.s
		jsr putD
		comma
		jsr putE
	else
		jsr putE
		comma
		jsr putD
	end
	rts

bwl: dc.b 'bwl '


putG:
	move.w d1,d0
	lsr.w #3,d0
	and.w #$0038,d0
	move.w d1,d2
	lsr.w #8,d2
	lsr.w #1,d2
	and.w #7,d2
	or.w d2,d0
	push.l d1
	move.w d0,d1
	jsr putE
	pop.l d1
	rts

putE:
	move.w	d1,d0
	lsr.w	#1,d0
	and.w	#$1c,d0
	jmp		etab(d0.w)

etab:
	bra.l		putS
	bra.l		putF
	bra.l		ari
	bra.l		aripl
	bra.l		arimi
	bra.l		indexed
	bra.l		double
	bra.l		misc

misc:
	move.w	d1,d0
	lsl.w	#2,d0
	and.w	#$1c,d0
	jmp		mtab(d0.w)

mtab:
	bra.l		abss	
	bra.l		absl
	bra.l		pcrel
	bra.l		pcind
	bra.l		putpound
	bra.l		resmode
	bra.l		resmode
	bra.l		resmode

abss:
	clr.l	d0
	move.w	(a1)+,d0
	subq.l	#2,d3
	move.l	d0,d5
	jsr		pword
	rts

absl:
	move.l	(a1)+,d0
	subq.l	#4,d3
	move.l	d0,d5
	jsr		p24
	rts

putpound:
	move.w	d4,d0
	lsl.w	#2,d0
	and.w	#$0c,d0
	jmp		imtab(d0.w)

imtab:
	bra.l		imbyte
	bra.l		imword
	bra.l		imlong
	bra.l		imop

imop:
	move.w	d1,d0
	lsr.w	#4,d0
	and.w	#$c,d0
	jmp		imoptab(d0.w)

imoptab:
	bra.l		imbyte
	bra.l		imword
	bra.l		imlong
	bra.l		illsiz

imbyte:
	move.w	(a1)+,d0
	subq.l	#2,d3
	putcon	'#'
	jsr		pbyte
	rts

imword:
	move.w	(a1)+,d0
	subq.l	#2,d3
	putcon	'#'
	jsr		pword
	rts

imlong:
	move.l	(a1)+,d0
	subq.l	#4,d3
	putcon	'#'
	jsr		plong
	rts

illsiz:
	print	< illegal size >
	rts

resmode:
	print	< reserved mode >
	rts

putdot:
	putcon	'.'
	cmpi.b #' ',(a2)
	if_ne.s
		rts
	end
	move.w	d4,d0
	lsl.w	#2,d0
	and.w	#$0c,d0
	jmp		dottab(d0.w)

dottab:
	bra.l		dotbyte
	bra.l		dotword
	bra.l		dotlong
	bra.l		dotop

dotop:
	move.w	d1,d0
	lsr.w	#4,d0
	and.w	#$c,d0
	jmp		dotoptab(d0.w)

dotoptab:
	bra.l		dotbyte
	bra.l		dotword
	bra.l		dotlong
	bra.l		illsiz

dotbyte:
	putcon	'b'
	rts

dotword:
	putcon 'w'
	rts

dotlong:
	putcon	'l'
	rts


putB:
	move.b	d1,d0
	if_nz
		putcon '.'
		putcon 's'
		ext.w d0
		ext.l d0
		add.l a1,d0
	else
		move.w (a1)+,d0
		subq.l #2,d3
		ext.l d0
		add.l a1,d0
		subq.l #2,d0
	end
	space
	move.l d0,d5
	jsr p24
	rts

putK:
	move.w (a1)+,d0
	subq.l #2,d3
	ext.l d0
	add.l a1,d0
	subq.l #2,d0
	jsr p24
	rts


putJ:
	move.w (a1)+,d0
	subq.l #2,d3
	putcon '#'
	jsr pbyte	
	rts

putV:
	move.l d1,d0
	and.b #15,d0
	putcon '#'
	jsr pbyte
	rts

putW:
	move.w (a1)+,d0
	subq.l #2,d3
	jsr pword
	rts

putR:
	move.w d1,d0
	and.w #$c0,d0
	cmp.w #$c0,d0
	if_ne
		move.w d1,d2
		lsr.w #2,d2
		and.w #6,d2
		lea shtab,a0
		move.b 0(a0,d2.w),d0
		jsr putc
		move.b 1(a0,d2.w),d0
		jsr putc
		cmp.w #4,d2
		if_eq.s
			putcon 'x'
		end

		btst #8,d1
		if_z.s
			putcon 'r'
		else
			putcon 'l'
		end

		putcon '.'
		move.w d1,d2
		lsr.w #6,d2
		and.w #3,d2
		lea bwl,a0
		move.b 0(a0,d2.w),d0
		jsr putc

		space
		btst #5,d1
		if_z.s
			jsr putQ
		else
			jsr putD
		end

		comma
		jsr putS
	else
		move.w d1,d2
		lsr.w #8,d2
		and.w #6,d2
		lea shtab,a0
		move.b 0(a0,d2.w),d0
		jsr putc
		move.b 1(a0,d2.w),d0
		jsr putc
		cmp.w #4,d2
		if_eq.s
			putcon 'x'
		end

		btst #8,d1
		if_z.s
			putcon 'r'
		else
			putcon 'l'
		end

		space
		jsr putE
	end
	rts

shtab: dc.b 'aslsroro'

chartab:	dc.b 'ABCDEFGIJKMOPQRSVWZ#.',0,0
	.even
subtab:
		dc.l	putA
		dc.l putB
		dc.l putC
		dc.l putD
		dc.l putE
		dc.l putF
		dc.l putG
		dc.l putI
		dc.l	putJ
		dc.l	putK
		dc.l putM
		dc.l putO
		dc.l putP
		dc.l putQ
		dc.l	putR
		dc.l putS
		dc.l putV
		dc.l putW
		dc.l putZ
		dc.l putpound
		dc.l putdot

defop:	macro	g1,g2,g3,g4,g5,sz,str

mask:	set	0
match:	set	0

		ifnc	'\1','x'
mask:	set	mask+$f000
match:	set	match+$\1<<12
		endc		

		ifnc	'\2','x'
mask:	set	mask+$0e00
match:	set	match+$\2<<9
		endc		

		ifnc	'\3','x'
mask:	set	mask+$01c0
match:	set	match+$\3<<6
		endc		

		ifnc	'\4','x'
mask:	set	mask+$0038
match:	set	match+$\4<<3
		endc		

		ifnc	'\5','x'
mask:	set	mask+$0007
match:	set	match+$\5
		endc		


		dc.w	mask
		dc.w	match	
		dc.b \6
		dc.b	'\7'
		dc.b	0
		endm

defbop:	macro	;g1,sz,str
		dc.w	$ff00
		dc.w	$\1<<8	
		dc.b \2
		dc.b	'\3'
		dc.b	0
		endm

b	equ	0
w	equ	1
l	equ	2
m	equ	3


optab:
	defop	0,0,0,7,4,b,<or.b #,ccr>
	defop	0,1,0,7,4,b,<and.b #,ccr>
	defop	0,5,0,7,4,b,<eor.b #,ccr>
	defop	0,0,1,7,4,w,<or.w #,sr>
	defop	0,1,1,7,4,w,<and.w #,sr>
	defop	0,5,1,7,4,w,<eor.w #,sr>
	defbop	00,m,<or. #,E>
	defbop	02,m,<and. #,E>
	defbop	04,m,<sub. #,E>
	defbop	06,m,<add. #,E>
	defop	0,4,0,x,x,b,<btst J,E>
	defop	0,4,1,x,x,b,<bchg J,E>
	defop	0,4,2,x,x,b,<bclr J,E>
	defop	0,4,3,x,x,b,<bset J,E>
	defbop	0a,m,<eor. #,E>
	defbop	0C,m,<cmp. #,E>
	defop	0,x,4,1,x,w,<movep.w W(E),D>
	defop	0,x,5,1,x,l,<movep.l W(E),D>
	defop	0,x,6,1,x,w,<movep.w D,W(E)>
	defop	0,x,7,1,x,l,<movep.l D,W(E)>
	defop	0,x,4,x,x,b,<btst D,E>
	defop	0,x,5,x,x,b,<bchg D,E>
	defop	0,x,6,x,x,b,<bclr D,E>
	defop	0,x,7,x,x,b,<bset D,E>
	defop	1,x,x,x,x,b,<move.b E,G>
	defop	2,x,x,x,x,l,<move.l E,G>
	defop	3,x,x,x,x,w,<move.w E,G>
	defop	4,4,0,x,x,b,<nbcd E>
	defop	4,4,1,0,x,w,<swap E>
	defop	4,4,1,x,x,l,<pea E>
	defop	4,7,1,0,x,0,<trap V>
	defop	4,7,1,1,x,0,<trap V>
	defop	4,7,1,2,x,w,<link F,#>
	defop	4,7,1,3,x,l,<unlk F>
	defop	4,7,1,4,x,l,<move.l F,usp>
	defop	4,7,1,5,x,l,<move.l usp,F>
	defop	4,7,1,6,0,0,<reset>
	defop	4,7,1,6,1,0,<nop>
	defop	4,7,1,6,2,w,<stop #>
	defop	4,7,1,6,3,0,<rte>
	defop	4,7,1,6,5,0,<rts>
	defop	4,7,1,6,6,0,<trapv>
	defop	4,4,2,0,x,w,<ext.w E>
	defop	4,4,2,4,x,w,<movem.w PZ,E>
	defop	4,4,2,x,x,w,<movem.w PM,E>
	defop	4,6,2,x,x,w,<movem.w PE,M>
	defop 	4,7,2,6,7,0,<rtr>
	defop	4,7,2,x,x,0,<jsr E>
	defop	4,0,3,x,x,w,<move.w sr,E>
	defop	4,2,3,x,x,b,<move.b E,ccr>
	defop	4,3,3,x,x,b,<move.w E,sr>
	defop	4,4,3,0,x,l,<ext.l E>
	defop	4,4,3,4,x,l,<movem.l PZ,E>
	defop	4,4,3,x,x,l,<movem.l PM,E>
	defop	4,5,3,7,4,0,<illegal>
	defop	4,5,3,x,x,b,<tas E>
	defop	4,6,3,x,x,l,<movem.l PE,M>
	defop	4,7,3,x,x,0,<jmp E>
	defbop	40,m,<negx. E>
	defbop	42,m,<clr. E>
	defbop	44,m,<neg. E>
	defbop	46,m,<not. E>
	defbop	4a,m,<tst. E>
	defop	4,x,6,x,x,l,<chk E,D>
	defop	4,x,7,x,x,l,<lea E,A>
	defop	5,x,0,x,x,b,<addq.b Q,E>
	defop	5,x,1,x,x,w,<addq.w Q,E>
	defop	5,x,2,x,x,l,<addq.l Q,E>
	defop	5,x,3,1,x,w,<dbC S,K>
	defop	5,x,3,x,x,b,<sC E>
	defop	5,x,4,x,x,b,<subq.b Q,E>
	defop	5,x,5,x,x,w,<subq.w Q,E>
	defop	5,x,6,x,x,l,<subq.l Q,E>
	defop	5,0,7,1,x,w,<dbra S,K>
	defop	5,x,7,1,x,w,<dbC S,K>
	defop	5,x,7,x,x,b,<sC E>
	defbop	60,0,<braB>
	defbop	61,0,<bsrB>
	defop 	6,x,x,x,x,0,<bCB>
	defop	7,x,x,x,x,l,<moveq.l I,D>
	defop	8,x,3,x,x,w,<divu E,D>
	defop	8,x,4,0,x,b,<sbcd S,D>
	defop	8,x,4,1,x,b,<sbcd (F)+,(A)+>
	defop	8,x,7,x,x,w,<divs E,S>
	defop	8,x,x,x,x,m,<orO>
	defop	9,x,3,x,x,w,<sub.w E,A>
	defop	9,x,4,0,x,b,<subx.b S,D>
	defop	9,x,4,1,x,b,<subx.b (F)+,(A)+>
	defop	9,x,5,0,x,w,<subx.w S,D>
	defop	9,x,5,1,x,w,<subx.w (F)+,(A)+>
	defop	9,x,6,0,x,l,<subx.l S,D>
	defop	9,x,6,1,x,l,<subx.l (F)+,(A)+>
	defop	9,x,7,x,x,l,<sub.l E,A>
	defop	9,x,x,x,x,m,<subO>
	defop	A,x,x,x,x,0,<line 1010>
	defop	B,x,0,x,x,b,<cmp.b E,D>
	defop	B,x,1,x,x,w,<cmp.w E,D>
	defop	B,x,2,x,x,l,<cmp.l E,D>
	defop	B,x,3,x,x,w,<cmp.w E,A>
	defop	B,x,4,1,x,b,<cmpm.b (F)+,(A)+>
	defop	B,x,4,x,x,b,<eor.b D,E>
	defop	B,x,5,1,x,w,<cmpm.w (F)+,(A)+>
	defop	B,x,5,x,x,w,<eor.w D,E>
	defop	B,x,6,1,x,l,<cmpm.l (F)+,(A)+>
	defop	B,x,6,x,x,l,<eor.l D,E>
	defop	B,x,7,x,x,l,<cmp.l E,A>
	defop	C,x,3,x,x,w,<mulu E,D>
	defop	C,x,4,0,x,b,<abcd S,D>
	defop	C,x,4,1,x,b,<abcd (F)+,(A)+>
	defop	C,x,5,0,x,l,<exg E,D>
	defop	C,x,5,1,x,l,<exg E,A>
	defop	C,x,6,1,x,l,<exg E,D>
	defop	C,x,7,x,x,w,<muls E,D>
	defop	C,x,x,x,x,m,<andO>
	defop	D,x,3,x,x,w,<add.w E,A>
	defop	D,x,4,0,x,b,<addx.b S,D>
	defop	D,x,4,1,x,b,<addx.b (F)+,(A)+>
	defop	D,x,5,0,x,w,<addx.w S,D>
	defop	D,x,5,1,x,w,<addx.w (F)+,(A)+>
	defop	D,x,6,0,x,l,<addx.l S,D>
	defop	D,x,6,1,x,l,<addx.l (F)+,(A)+>
	defop	D,x,7,x,x,l,<add.l E,A>
	defop	D,x,x,x,x,m,<addO>
	defop	E,x,x,x,x,0,<R>
	defop	F,x,x,x,x,0,<line 1111>
	dc.w		0

	end
