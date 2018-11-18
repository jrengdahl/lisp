smult:	macro	;src,sct1,sct2,dst,err
	push.l \1
	push.l \4
	tst.l \1
	bpl.s px\@
	neg.l \1
	tst.l \4
	bpl.s mp\@
mm\@:	neg.l \4
pp\@:	move.l \4,\2
	move.l \4,\3
	mulu \1,\4
	bmi.s ov\@
	swap \2
	tst.w \2
	beq.s pzx\@
	mulu \1,\2
	swap \1
	tst.w \1
	bne.s ov\@
	swap	\2
	tst.w \2
	bne.s ov\@
	add.l \2,\4
	bpl.s dn\@		
	bra.s ov\@

pzx\@:
	swap \1
	tst.w \1
	beq.s dn\@

	mulu \3,\1
	swap	\1
	tst.w \1
	bne.s ov\@

	add.l \1,\4
	bpl.s dn\@

ov\@:	pop.l \4
	pop.l \1
	jmp \5


px\@:	tst.l \4
	bpl.s pp\@
pm\@:	neg.l \4		
mp\@:	move.l \4,\2
	move.l \4,\3

	mulu \1,\4
	bmi.s ov\@
	swap \2
	tst.w \2
	beq.s mzx\@
	mulu \1,\2
	swap \1
	tst.w \1
	bne.s ov\@
	swap	\2
	tst.w \2
	bne.s ov\@
	add.l \2,\4
	bpl.s mi\@		
	bra.s ov\@

mzx\@:
	swap \1
	tst.w \1
	beq.s mi\@

	mulu \3,\1
	swap	\1
	tst.w \1
	bne.s ov\@

	add.l \1,\4
	bmi.s ov\@
mi\@:	neg.l \4
dn\@:
	pop.l \1
	pop.l \1
	endm		


sdiv:	macro	;src,sct,sct,dst
	push.l \1
	tst.l \1
	bpl px\@
	neg.l \1
	tst.l \4
	bpl mp\@
mm\@:	neg.l \4
pp\@:	
	move.l \1,\2
	move.l \4,\3
	cmp.l #65536,\1
	bge.s pbig\@

	clr.w \4
	swap \4
	divu \1,\4
	move.w \4,\2
	swap \2
	move.w \3,\4
	divu \1,\4
	move.w \4,\2
	move.l \2,\4
	bra dn\@

pbig\@:
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\4
psm\@:
	divu \1,\4
	swap \4
	clr.w \4
	swap \4
	move.l \2,\1
	swap \1
	mulu \4,\1
	swap \1
	clr.w \1
	mulu \4,\2
	add.l \2,\1
	cmp.l \1,\3
	bge dn\@
	subq.l #1,\4
	bra dn\@	

px\@:	tst.l \4
	bpl pp\@
pm\@:	neg.l \4		
mp\@:
	move.l \1,\2
	move.l \4,\3
	cmp.l #65536,\1
	bgt.s mbig\@

	clr.w \4
	swap \4
	divu \1,\4
	move.w \4,\2
	swap \2
	move.w \3,\4
	divu \1,\4
	move.w \4,\2
	move.l \2,\4
	neg.l \4
	bra dn\@

mbig\@:
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
	cmpi.l #65536,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\4
msm\@:
	divu \1,\4
	swap \4
	clr.w \4
	swap \4
	move.l \2,\1
	swap \1
	mulu \4,\1
	swap \1
	clr.w \1
	mulu \4,\2
	add.l \2,\1
	cmp.l \1,\3
	bge 1$
	subq.l #1,\4
1$:	neg.l \4	
dn\@:
	pop.l \1
	endm		

smod:	macro	;src,sct,sct,sct,dst
	push.l \1
	tst.l \1
	bpl.s px\@
	neg.l \1
px\@:	tst.l \5
	bmi pm\@
	
	move.l \5,\3
	move.l \1,\4

	moveq.l #1,\2
	swap \2
	cmp.l \2,\1
	bgt.s pbig\@

	clr.w \5
	swap \5
	divu \1,\5
	move.w \3,\5
	divu \1,\5
	clr.w \5
	swap	\5
	bra dn\@

pbig\@:
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s psm\@
	lsr.l #1,\1
	lsr.l #1,\3
psm\@:

	divu \1,\3
	move.l \4,\2
	swap \2
	mulu \3,\2
	swap \2
	clr.w \2
	mulu \3,\4
	add.l \2,\4
	cmp.l \4,\5
	bge.s 1$
	sub.l \3,\4
1$:	sub.l \4,\5
	bra dn\@	

pm\@:	neg.l \5		
	move.l \5,\3
	move.l \1,\4

	moveq.l #1,\2
	swap \2
	cmp.l \2,\1
	bgt.s mbig\@

	clr.w \5
	swap \5
	divu \1,\5
	move.w \3,\5
	divu \1,\5
	clr.w \5
	swap	\5
	neg.l \5	
	bra dn\@

mbig\@:
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
	cmp.l \2,\1
	blt.s msm\@
	lsr.l #1,\1
	lsr.l #1,\3
msm\@:

	divu \1,\3
	move.l \4,\2
	swap \2
	mulu \3,\2
	swap \2
	clr.w \2
	mulu \3,\4
	add.l \2,\4
	cmp.l \4,\5
	bge.s 1$
	sub.l \3,\4
1$:	sub.l \4,\5
	neg.l \5	
dn\@:
	pop.l \1
	endm		
