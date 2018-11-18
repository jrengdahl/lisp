mul:	macro	;src,dst
	move.l	\1,d0		;4
	swap	d0		;4
	move.l	\2,d1		;4
	swap	d1		;4
	mulu	\1,d1		;70
	mulu	\2,d0		;70
	add.w	d0,d1		;4
	swap	d1		;4
	clr.w	d1		;4
	mulu	\1,\2		;70
	add.l	d1,\2		;6
	endm			;(34 usec)

mul3:	macro	;src,src,dst
	move.l	\1,d0		;4
	swap	d0		;4
	move.l	\2,d1		;4
	swap	d1		;4
	mulu	\1,d1		;70
	mulu	\2,d0		;70
	add.w	d0,d1		;4
	swap	d1		;4
	clr.w	d1		;4
	move.l	\2,\3		;4
	mulu	\1,\3		;70
	add.l	d1,\3		;6
	endm			;(35 usec)


cmul:	macro	;imm,dst
	move.l	\2,d1		;4
	swap	d1		;4
	move.w	\1&65535,d0	;8
	mulu	d0,d1		;70
	mulu	\2,d0		;70
	add.w	d0,d1		;4
	swap	d1		;4
	clr.w	d1		;4
	mulu	\1>>16,\2	;74
	add.l	d1,\2		;6
	endm			;(35 usec)


cmul3:	macro	;imm,src,dst
	move.l	\2,d1		;4
	swap	d1		;4
	move.w	\1&65535,d0	;8
	mulu	d0,d1		;70
	mulu	\2,d0		;70
	add.w	d0,d1		;4
	swap	d1		;4
	clr.w	d1		;4
	move.l	\2,\3		;4
	mulu	\1>>16,\3	;74
	add.l	d1,\3		;6
	endm			;(35 usec)

rnd:	macro	;dst
	move.l	\1,d1		;4
	swap	d1		;4
	move.w	#1664525&65535,d0 ;8
	mulu	d0,d1		;70
	mulu	\1,d0		;70
	add.w	d0,d1		;4
	swap	d1		;4
	clr.w	d1		;4
	mulu	#1664525>>16,\1	;74
	add.l	d1,\1		;6
	addq.l	#1,\1		;8
	endm			;(36 usec)

