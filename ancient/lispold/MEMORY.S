	IDNT	memory

	
	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'
	include	'exec/tasks.i'

	xref	spy,snap,gcverbose

	.data

	xdef	nodeblocklist
nodeblocklist:	ds.l	1
least:		ds.l 1
greatest:	ds.l 1

	.code

	xdef	init_memory
init_memory:

	clr.l	nodeblocklist		;clear root of mem list

	move.l	#0,greatest		;address of highest freeblock
	move.l	#$ffffff,least		;address of lowest freeblock

	move.l	#1,d7
	jsr		getmore
	jsr		getmore
	jsr		getmore
	jsr		getmore

	move.l		#0,a1		;get address of tcb
	execcall 	FindTask
	move.l		d0,a2
	move.l		#traps,TC_TRAPCODE(a2) ;point it to trap routine

; move.l #traceb,tracep ;init trace buffer
; see #tracep
; newline

	rts



traps:
	cmpi.l	#9,(sp)				;if this is a trace interrupt
	if_eq.s
		push.l a0
		move.l tracep,a0
		move.l 10(sp),(a0)+
		cmp.l #tracee,a0
		if_uge.s
			move.l #traceb,a0
		end
		move.l a0,tracep
		pop.l	a0
		lea	4(sp),sp		;get rid of exception number
		rte
	end
	cmpi.l	#3,(sp)				;if this is an address error
	if_eq.s
		cmpi.l #1,6(sp)			;and the address is 00000001
		if_eq.s
			push.l	a0
			push.l	a1
			move.l	usp,a0		;get the user stack pointer
			move.l	22(sp),a1	;get return address from trap frame
			subq.l	#4,a1		;adjust to repeat newnode macro
			move.l	a1,-(a0)	;push return addr on user stack
			move.l	a0,usp		;save user stack pointer
			move.l	#makemore,22(sp) ;force call to garbage collector
			pop.l	a1
			pop.l	a0
			lea	12(sp),sp	;get rid of exception stuff (inc. exc #)
; or.w #$8000,(sp)	;turn on trace bit
			rte
		else
			push.l	a0
			push.l	a1
			lea 8(sp),a0		;
			jsr snap		;snapshot the exception frame
			move.l	usp,a0		;get the user stack pointer
			move.l	22(sp),a1	;get return address from trap frame
			move.l	a1,-(a0)	;push return addr on user stack
			move.l	a0,usp		;save user stack pointer
			move.l	#aderr,22(sp) 	;force call to debugger
			pop.l	a1
			pop.l	a0
			lea	12(sp),sp	;get rid of exception stuff (inc. exc #)
 and.w #$7fff,(sp)	;turn off tracing
			rte
		end
	end
	cmpi.l	#2,(sp)				;if this is a bus error
	if_eq.s
		push.l	a0
		push.l	a1
		lea	8(sp),a0		;
		jsr	snap			;snapshot the exception frame
		move.l	usp,a0			;get the user stack pointer
		move.l	22(sp),a1		;get return address from trap frame
		move.l	a1,-(a0)		;push return addr on user stack
		move.l	a0,usp			;save user stack pointer
		move.l	#buserr,22(sp) 		;force call to debugger
		pop.l	a1
		pop.l	a0
		lea	12(sp),sp		;get rid of exception stuff (inc. exc #)
 and.w #$7fff,(sp)	;turn off tracing
		rte
	else					;some other type of trap
		push.l	a0
		push.l	a1
		lea	8(sp),a0		;
		jsr	snap			;snapshot the exception frame
		move.l	usp,a0			;get the user stack pointer
		move.l	14(sp),a1		;get return address from trap frame
		move.l	a1,-(a0)		;push return addr on user stack
		move.l	a0,usp			;save user stack pointer
		move.l	#others,14(sp) 		;force call to debugger
		pop.l	a1
		pop.l	a0
		lea	4(sp),sp		;get rid of exception number
 and.w #$7fff,(sp)	;turn off tracing
		rte
	end

aderr:
	message <address error>
	jmp spy

buserr:
	message <bus error>
	jmp spy

others:
	message <trap >
	jmp spy	


	.data
	.even
tracep: ds.l 1
traceb: ds.l 1024
tracee: ds.l 0
 
	.code




makemore:

markandsweep:
; see (sp)
; see sp
; newline

	pushm.l d0-d3/a0-a2	
; message <starting garbage collector>
; message <a0>
	jsr mark
; message <a1>
	move.l a1,a0
	jsr mark
; message <a2>
	move.l a2,a0
	jsr mark
; message <a3>
	move.l a3,a0
	jsr mark
; message <a4>
	move.l a4,a0
 	jsr mark
; message <a5>
	move.l a5,a0
	jsr mark
; message <oblist>
	xref oblist
	move.l oblist,a0
	jsr mark
; message <stack>

;do the stack
	move.l a6,a2
	loop.s
		move.l a2,d0
		while_nz

		move.l a2,a1
		move.l (a1)+,a2

		loop.s
			cmp.l a1,a2
			while_ne

			move.l (a1)+,a0
			jsr mark
		end
		move.l (a1)+,a2
	end	

; message <sweeping>

;go through all the nodes 
;freeing all that have not been touched
	move.l	nodeblocklist,a0
	clr.l d2
	clr.l d1
	move.w #7,d0

	loop.s
		move.l a0,d3
		while_nz

		lea nodeblockstuff(a0),a1
		repeat #nodesperblock,d3
			bclr d0,(a1)
			if_z.s
				move.l d7,(a1)
				move.l a1,d7
				addq.l #1,d1
			else
				addq.l #1,d2
			end
			add.l #nodesize,a1
		end
		move.l nextnodeblock(a0),a0
	end	

	move.l gcverbose,a0
	cmp.l sym_value(a0),d6
	if_ne.s
		print <used nodes = >
		move.l d2,d0
		jsr pdec
		print <, free nodes = >
		move.l d1,d0
		jsr pdec
		newline
	end

	cmp.l #5000,d1
	if_lt.s
		move.l gcverbose,a0
		cmp.l sym_value(a0),d6
		if_ne.s
			message <getting more memory>
		end
		jsr getmore
	end

; message <garbage collection complete>
	popm.l d0-d3/a0-a2

; see sp
; newline
	rts


mkret: rts

mark:
	cmp.l #1,a0		;check for end-of-free-mem marker
	beq.s mkret
	bset #7,(a0)		;mark
	bne.s mkret		;skip if already marked

	pushm.l d0-d5/a0-a2

	move.w (a0),d0
	and.w #$7fff,d0
	cmp.w #symtype,d0
	if_gt.s
		message <illegal node value>
		jmp spy
	end
	and.w #7,d0
	if_nz.s
		message <node type has low 3 bits set>
		jmp spy
	end

	cmp.l least,a0
	if_ult.s
		message <node is less than least>
		jmp spy
	end
	cmp.l greatest,a0
	if_ugt.s
		message <node is greater than greatest>
		jmp spy
	end

	move.l sp,a2
	move.w #7,d1
	move.w #constype+$8000,d3
	move.w #symtype+$8000,d4
	move.w #strtype+$8000,d5

	bra.s mknext

mkcons:
	move.l car(a0),a1	;mark the car
	bset d1,(a1)
	if_z.s
		push.l a1
		stackcheck
	end
	move.l cdr(a0),a0
	bset d1,(a0)
	beq.s mknext
mklp:
	cmp.l a2,sp
	if_eq.s
		popm.l d0-d5/a0-a2
		rts
	end
	pop.l a0
mknext:
	cmp.w (a0),d3			;mark a cons
	beq.s mkcons

	cmp.w (a0),d4			;mark a sym
	if_eq.s
		move.l sym_value(a0),a1
		bset d1,(a1)
		if_z.s
			push.l a1
			stackcheck
		end

		move.l sym_more(a0),a0
		bset d1,(a0)
		bne.s mklp

		move.l sym_function(a0),a1
		bset d1,(a1)
		if_z.s
			push.l a1
			stackcheck
		end

		move.l sym_plist(a0),a1
		bset d1,(a1)
		if_z.s
			push.l a1
			stackcheck
		end

		move.l sym_name(a0),a1
		bset d1,(a1)
		if_z.s
			push.l a1
			stackcheck
		end
		bra mklp
	end		

	cmp.w (a0),d5
	if_eq.s
		move.l str_more(a0),d2
		beq.s 2$
1$:		move.l d2,a0
		bset d1,(a0)
		bne.s 2$
		move.l (a0),d2	
		bne.s 1$
2$:		bra mklp	
	end
	bra mklp	



getmore:
	pushm.l d0-d2/a0-a2

	move.l	#nodeblocksize,d0
	move.l	#0,d1
	execcall	AllocMem

	tst.l	d0
	if_z.s
		message <cannot allocate any more memory>
		signal_error
	end

	move.l	d0,a0			;get addr of memory
	move.l	nodeblocklist,nextnodeblock(a0) ;link to last
	move.l	a0,nodeblocklist	;save new list

	cmp.l	least,a0
	if_ult.s
		move.l a0,least
	end
	move.l #nodeblocksize,d0
	add.l a0,d0
	cmp.l greatest,d0
	if_ugt.s
		move.l d0,greatest
	end

	lea	nodeblockstuff(a0),a0		;get addr of nodes
	repeat	#nodesperblock,d1		;do all nodes
		move.l	d7,(a0)			;new node points to list
		move.l	a0,d7			;save new list
		add.l	#nodesize,a0		;get addr of new node
	end

	popm.l	d0-d2/a0-a2
	rts


	xdef	freeall
freeall:
	move.l nodeblocklist,a2
	loop
		move.l a2,d0
		while_nz

		move.l a2,a1
		move.l (a2),a2
		move.l #nodeblocksize,d0
		execcall FreeMem
	end
	rts

	end

