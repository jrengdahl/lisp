	IDNT		strdoc

	include	'common/hdr.i'
	include	'common/io.i'

	.code
	xdef	quest
quest:
	move.l	stderr,d1
	move.l	#m1,d2
	move.l	#m1e-m1,d3
	doscall	Write
	message	<struct -h -- for help>
	message	<struct -i -- for release info>	
	moveq.l	#1,d0
	rts

	xdef	help
help:

 message <The preprocessor will copy a file from stdin to stdout>
 message <while translating structured programming constructs>
 message <into assembly language, primarily using label and>
 message <branch statements.>
 message <>
 message <In the following constructs the cc field represents one>
 message <of the following conditions as documented in the 68000>
 message <programmers reference manual:>
 message <>
 message <hi ls cc cs ne eq vc vs pl mi ge lt gt le>
 message <>
 message <In addition the following mnemonics are implemented:>
 message <>
 message <z - zero                    nz - not zero>
 message <ult - unsigned less than    ugt - unsigned greater than>
 message <ule - unsigned less than or equal to>
 message <uge - unsigned greater than or equal to>
 message <>
 message <     if_cc                      if_cc.s >
 message <       (statements)               (statements)>
 message <     end                        end >
 message <>
 message <     if_cc                      if_cc.s >
 message <       (statements)               (statements)>
 message <     else                       else >
 message <       (statements)               (statements)>
 message <     end                        end >
 message <>
 message <     loop                       loop.s>
  message <      (statements)               (statements)>
 message <     end                        end>
 message <>
 message <     do                         do.s>
 message <       (statements)               (statements)>
 message <     until_cc                   until_cc>
 message <>
 message <     repeat count-operand,Dn>
 message <       (statements)>
 message <     end>
 message <>
 message <The variants that contain the characters ".s" will use>
 message <short branches to implement the contruct. The repeat>
 message <construct generates a DJNZ; the operand must be a word.>
 message <>
 message <Within the body of any loop construct the following>
 message <statements can modify the loop execution: >
 message <>
 message <      break - cause loop to terminate immediately>
 message <      continue - immediately jump to loop test>
 message <      while_cc - exit loop if condition is true>
 message <>
 message <Example:>
 message <>
 message <      loop.s>
 message <         (test statements)>
 message <         while_nz>
 message <>
 message <         (more test statements)>
 message <         if_ne.s>
 message <           (statements)>
 message <         else>
 message <            break>
 message <         end>
 message <>
 message <        (statements)>
 message <      end>
 message <>
 message <To use the CONTINUE directive within the DO/UNTIL contruct,>
 message <the directive TEST is used to mark the beginning of the>
 message <test code, for example:>
 message <>
 message <      do>
 message <         (statements)>
 message <      test>
 message <         (test statements)>
 message <      until_cc>
 message <>
 message <The last statement in the program must be an additional END.>

	moveq.l	#1,d0
	rts

	xdef	share
share:

 message <>
 message <Copyright (C) 1986 by Jonathan Engdahl. All rights reserved.>
 message <This software may be distributed and used without charge by>
 message <non-profit users. This notice must be included in all copies.>
 message <Commercial users contact the author.>
 message <>
 message <     Jonathan Engdahl>
 message <     6125 Lodi Lane>
 message <     Saline, MI, 48176>
 message <>
 message <     BIX -        jengdahl>
 message <     COMPUSERVE - 72330,174>
 message <>
	move.w	#1,d0
	rts


m1:	dc.b		'struct <infile >outfile -- process source code',10
m1e:

