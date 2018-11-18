	IDNT		numbers

	include	'common/hdr.i'
	include	'common/io.i'
	include	'lisp/lispdefs.i'
	include	'lisp/lispmacros.i'
	include	'lisp/math.i'
	include	'lisp/mult.i'
	include 'intuition/intuition.i'
	include 'exec/ports.i'
	include 'exec/tasks.i'
	include 'others.i'
	include 'graphics/gfxbase.i'
	include 'graphics/display.i'



s:	macro
	see \1
	newline
	endm


intuition macro
	move.l	intuitionbase,a6
	jsr	_LVO\1(a6)
	endm

graphics macro
	move.l	graphicsbase,a6
	jsr	_LVO\1(a6)
	endm

exec macro
	move.l	4,a6
	jsr	_LVO\1(a6)
	endm



init:
	clr.l	d0		;get address of intuition library
	lea	iname,a1
	exec	OpenLibrary
	move.l	d0,intuitionbase

	clr.l	d0		;get address of intuition library
	lea	gname,a1
	exec	OpenLibrary
	move.l	d0,graphicsbase

	move.l	#newscreen,a0
	intuition OpenScreen
	move.l d0,screen
	move.l d0,nws
	move.l d0,a0
	lea.l sc_RastPort(a0),a1
	move.l a1,rpt
	jsr fillrows

	move.l	#newwindow,a0
	intuition OpenWindow
	move.l d0,window

	move.l window,a0
	move.l wd_UserPort(a0),a1
	move.l a1,idcmp
	move.b MP_SIGBIT(a1),sigbit 
	move.l MP_SIGTASK(a1),thetcb
	rts

finish:
	move.l	window,a0
	intuition CloseWindow	

	move.l	screen,a0
	intuition CloseScreen	

	move.l	intuitionbase,a1
	exec	CloseLibrary
	move.l	graphicsbase,a1
	exec	CloseLibrary
	rts


	
clocktest:

	loop
		move.l thetcb,a0
		move.b sigbit,d0
		btst d0,TC_SIGRECVD(a0)
		while_z

		move.l d2,d0
		move.l d3,d1
		move.l rpt,a1
		graphics Draw
	end



	xdef	init_pictures
init_pictures:
	rts




iname:	dc.b	'intuition.library',0
gname:	dc.b	'graphics.library',0
stitle:	dc.b	'MyScreen',0
wtitle:	dc.b	'MyWindow',0



	.data

intuitionbase: ds.l 1
graphicsbase: ds.l 1
screen:	ds.l	1
window:	ds.l	1
rpt:	ds.l	1
idcmp:	ds.l	1
thetcb:	ds.l	1
bitmap:	ds.l	1
plane:	ds.l	1

sigbit:	ds.b	1

	.even

newscreen:
	dc.w 0			;ns_LeftEdge
	dc.w 0			;ns_TopEdge
	dc.w 640		;ns_Width
	dc.w 400		;ns_Height
	dc.w 1			;ns_Depth
	dc.b 1			;ns_DetailPen
	dc.b 1			;ns_BlockPen
	dc.w V_HIRES+V_LACE	;ns_ViewModes
	dc.w CUSTOMSCREEN	;ns_Type
	dc.l 0			;ns_Font
	dc.l stitle	 	;ns_DefaultTitle
	dc.l 0			;ns_Gadgets
	dc.l 0			;ns_CustomBitMap

WFL: equ WINDOWSIZING!WINDOWDEPTH!WINDOWCLOSE!WINDOWDRAG!SMART_REFRESH
WFLAGS: equ WFL!RMBTRAP!NOCAREREFRESH!SIZEBRIGHT

newwindow:
	dc.w 100		;nw_LeftEdge
	dc.w 50			;nw_TopEdge
	dc.w 100		;nw_Width
	dc.w 50 		;nw_Height
	dc.b 0 			;nw_DetailPen
	dc.b 1			;nw_BlockPen
	dc.l CLOSEWINDOW	;nw_IDCMPFlags
	dc.l WFLAGS	 	;nw_FLAGS
	dc.l 0			;nw_FirstGadget
	dc.l 0			;nw_CheckMark
	dc.l wtitle	 	;nw_Title
nws:	dc.l 0			;nw_Screen
	dc.l 0			;nw_BitMap
	dc.w 10			;nw_Minwidth
	dc.w 10			;nw_MinHeight
	dc.w 100		;nw_MaxWidth
	dc.w 50			;nw_MaxHeight
	dc.w WBENCHSCREEN	;nw_Type

	end