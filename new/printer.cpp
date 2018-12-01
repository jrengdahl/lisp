#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"


void lprint(node *n);

void pcons(node *n)
    {
    printf("(");

    while(true)
        {
        lprint(n->car);
        n = n->cdr;
        if(n==nil || n->type!=constype)break;
        printf(" ");
        }

    if(n!=nil)
        {
        printf(" . ");
        lprint(n);
        }

    printf(")");
    }


void print_string(node *n)
    {
print_string:
	stackcheck print_string
	pushm.l	d0/d1/d2/a0/a1

	move.l	str_more(a0),a1
	move.l	(a0)+,d1
	move.w	#4,d2

	loop
		tst.w d1
		while_nz

		tst.w d2
		if_z.s
			move.l a1,a0
			move.l (a0)+,a1
			move.w #8,d2
		end

		move.b (a0)+,d0
		jsr putc
		subq.w #1,d1
		subq.w #1,d2
	end

	popm.l d0/d1/d2/a0/a1
	rts

    }


void lprint(node *n)
    {
    if(n==nil)
        {
        printf("nil");
        }

    switch(n->type)
        {
    case constype:
        pcons(n);
        break;

    case numtype:
        printf("%ld", n->numerator)
        break;

    case rattype:
        // reduce(n);
        printf("%ld", n->numerator)
        if(n->denominator != 1)
            {
            printf("/%lu", n->denominator)
            }
        break;

    case stringtype:
        printf("\"");
        print_string(n);
        printf("\"");
        break;

    case chartype:
        if(n->char_data <= ' ')
            {
            printf("#\\%x", n->char_data);
            }
        else
            {
            printf("#\\%c", n->char_data);
            }
        break;

    case primtype:
        printf("#(primitive: %zx \"", n->more->function);
        print_string(n->more->name);
        printf("\")");
        break;

    case sfuntype:
        printf("#(special form: %zx \"", n->more->function);
        print_string(n->more->name);
        printf("\")");
        break;

    case symtype:
        
        break;

    default:
        printf("unknown node type in lprint\n");
        exit(-1);
        }
    }




	xdef		lisp_print

lisp_print:
	jsr		lprint
	newline
	rts

.lprint:
	move.l	car(a1),a0
	jsr	lisp_print
	unlkm	a1-a5
	rts

.lprin1:
	move.l	car(a1),a0
	jsr	lprint
	jsr	flushout
	unlkm	a1-a5
	rts

.lprinc:
	move.l	car(a1),a0
	jsr	lprinc
	jsr	flushout
	unlkm	a1-a5
	rts

terpri:
	newline
	move.l d6,a0
	unlkm	a1-a5
	rts

	xdef	init_printer
init_printer:
	primitive print,.lprint
	primitive prin1,.lprin1
	primitive princ,.lprinc
	primitive terpri,terpri
	rts

	end
