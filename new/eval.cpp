#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"


// eval a node, which could be anything

node *eval(node *n)
    {
    switch(n->type)
        {
    case constype:
        return evalfun(n);                  // a list is a function call, go interpret it

    case symtype:                           // a symbol evaluates to its value
        return n->value;

    case numtype:                           // anything else evaluates to itself
    case rattype:
    case stringtype:
    case chartype:
    case primtype:
    case sfuntype:
        return n;

    default:
        printf("unknown node type in eval\n");
        exit(-1);
        }
    }


// mapcar 'eval to each member of a list, and return the result. Used to process
node *evalargs(node *args)
    {
    if(args == nil)return nil;                              // if input is nil return nil

    node *first;
    node *last;

    first = new node(eval(args->car), nil);                 // eval the first arg and make the result the initial list member
    last = first;
    args = args->cdr;

    while(args != nil)                                      // for any other args
        {
        last->cdr = new node(eval(args->car), nil);         // eval and add the result to the end of the list
        last = last->cdr;
        args = args->cdr;
        }
    
    return first;                                           // return the list
    }


node *evalfun(node *n)
    {
    if(evalhook != nil)
        {
		node *tmp;
		tmp = evalhook;
		n = hookfun(n);
		evalhook = tmp;
        return n;
        }
    else return nhook(n);
    }

// evaluate a form after (or without) evalhook processing
node *nhook(node form)
    {
    node *func;
    node *args;

    if(form == nil)return nil;

    // TODO stackcheck

    func = form->car;                                                   // the car is the function, and the cdr is the arglist (fun arg0, arg1, arg...) e.g. (+ 1 2)
    args = form->cdr;

    if(func->type == symtype)                                           // if the function is a symbol, 
        {
        func = func->more->function;                                    // get the symbol-function
        if(func->type == constype)                                      // if it's a list drop through and handle it the same as a lambda
            {   // lambmacro
            }
        else if(func->type == primtype)                                 // if it's a primitive
            {   // evprim
            return (*func->primitive)(evalargs(args));                  // eval the args and call the primitive
            }
        else if(func->type == sfuntype)                                 // if its a special form handle it similarly, except do not eval the args, pass them raw
            {
            return (*func->primitive)(args);
            }
        else    
            {   // notfun
            signal_error("attempt to apply a data object to args");
            }
        }

    if(func->type == constype)                                          // handle a lambda or macro expression
        {
        if(func->car == lambda)                                         // for a lambda list
            {
            return interpreter(evalargs(args), func->cdr);              // eval the args then call the interpreter
            }
        else if(func->car == macro)                                     // handle a macro the same, except do not eval the args, just pass them raw
            {
            return eval(interpreter(args, func->cdr));
            }
        else
            {
            signal_error("car of lambda list must be lambda or macro");
            }
        }
    else
        {
        signal_error("function must be a symbol or lambda list");
        }
    }
    
    


evalfun:
	cmp.l	evalhook,d6	;check for evalhook active
	bne.s	hookjp

nhook:	cmp.l	d6,a0		;check for nil
	beq.s	xret

	cmp.l	stackbot,sp
	blt.s	stkov

	linkm	a1-a5

;a0 form

	move.l	cdr(a0),a1		;put arglist in a1
	move.l	car(a0),a0		;get first item of list

; a1 cdr of form = arglist
; a0 car of form

	cmpi.w	#symtype,(a0) 		;it must be a symbol
	bne.s	evlis

;a0 car of form is symbol

	move.l	sym_more(a0),a0		;get symbol-function
	move.l	(a0),a2			;

;a1 arglist
;a2 symbol-function

	move.w	(a2),d0
	jmp		funtab(d0.w)


evlis:
	move.l a0,a2
	cmpi.w #constype,(a0)	;or a lambda list
	beq lambmacro
	message <;function must be a symbol or lambda list>
	signal_error
 

funtab:
	bra.l		lambmacro
	nop
	nop
	bra.l		notfun
	nop
	nop
	bra.l		notfun
	nop
	nop
	bra.l		notfun
	nop
	nop
	bra.l		notfun
	nop
	nop
	bra.l		notfun
	nop
	nop
	bra.l		notfun
	nop
	nop
	bra.l		evprim
	nop
	nop
	push.l		prim_addr(a2)	;jsr to function without leaving
	rts				;junk in a register
	nop
	bra.l		notfun

macroexpand:
	move.l	car(a1),a1		;get first arg, the macro form
	follow	a1,a0			;get the first element of list

	cmpi.w	#symtype,(a0) 		;it must be a symbol
	if_ne.s
		message <;macro name must be a symbol>
		signal_error
	end

	move.l	sym_more(a0),a0	;get symbol-function
	move.l	(a0),a2			;

	cmp.w	#constype,(a2)
	if_ne.s
		message <;macro must be a macro-form>
		signal_error
	end

	follow a2,a0
	cmp.l xmacro,a0
	if_ne.s
		message <;car of macro function must be macro>
		signal_error
	end	

	jmp	interpreter


eval_macro:
	linkm	a1-a5
	jmp		interpreter

 
;a1 arglist
;a2 symbol-function

lambmacro:
	follow a2,a0

;a0 car of function
;a1 arglist
;a2 cdr of function

	cmp.l lambda,a0
	if_ne
		cmp.l xmacro,a0
		if_ne.s
			message <;car of lambda list must be lambda or macro>
			signal_error
		end
		jsr	eval_macro
		eval
		unlkm	a1-a5	
		rts
	end


;a1 arglist
;a2 cdr of function

	cmp.l d6,a1
	if_ne
		move.l a1,a3
		follow a3,a0
		eval
		newnode a1
		clr.l (a1)
		move.l a0,car(a1)
		move.l d6,cdr(a1)
		move.l a1,a5
 
		loop
			cmp.l d6,a3
			while_ne
	
			follow a3,a0
			eval
 			newnode a4
			clr.l (a4)	
			move.l a0,car(a4)
			move.l d6,cdr(a4)
			move.l a4,cdr(a5)
			move.l a4,a5
		end
	end
	jmp interpreter

evprim:
	cmp.l d6,a1
	if_ne
		move.l a1,a3
		follow a3,a0
		eval
		newnode a1
		clr.l (a1)
		move.l a0,car(a1)
		move.l d6,cdr(a1)
		move.l a1,a5
 
		loop
			cmp.l d6,a3
			while_ne
	
			follow a3,a0
			eval
 			newnode a4
			clr.l (a4)	
			move.l a0,car(a4)
			move.l d6,cdr(a4)
			move.l a4,cdr(a5)
			move.l a4,a5
		end
	end
	push.l	prim_addr(a2)		;jsr to function without leaving
	rts				;junk in a register

;a later optimization will use a jump through a0, and
;all primitives will copy d6 to a0. Each primitive will also
;do the popm and rts.

funcall:
	follow	a1,a2
	cmpi.w	#symtype,(a2)
	if_eq.s
		move.l sym_more(a2),a2
		move.l (a2),a2
	end
	move.w	(a2),a0
	jmp		aptab(a0.w)

	xdef int_apply
apply:
	follow	a1,a2
	move.l	car(a1),a1
int_apply:
	cmpi.w	#symtype,(a2)
	if_eq.s
		move.l sym_more(a2),a2
		move.l (a2),a2
	end
	move.w	(a2),a0
	jmp		aptab(a0.w)

aptab:
	bra.l		apcons
	nop
	nop
	bra.l		apint
	nop
	nop
	bra.l		aprat
	nop
	nop
	bra.l		apfloat
	nop
	nop
	bra.l		apstring
	nop
	nop
	bra.l		aparray
	nop
	nop
	bra.l		apchar
	nop
	nop
	push.l		prim_addr(a2)	;jsr to function without leaving
	rts				;junk in a register
	nop
	bra.l		apsfun
	nop
	nop
	bra.l		apsym
	
apint:
aprat:
apfloat:
apstring:
apchar:
aparray:
apsym:
notfun:
	message <;attempt to apply a data object to args>
	signal_error

apsfun:
	message <;attempt to apply special form to args>
	signal_error



;a1 = args
;a2 = symbol-function

apcons:
	follow	a2,a0	
	jmp		interpreter
 

.eval:
	move.l car(a1),a0
	eval
	unlkm a1-a5
	rts


.evalhook:
	follow	a1,a0			;get form to be evaluated

	move.l	evalhook,a2		;rebind evalhook
	move.l	car(a1),evalhook

	tst.w	(a0)			;if its a list
	if_eq.s	
		jsr nhook		;bypass the hook
	else
		eval			;else the eval can't be hooked
	end

	move.l a2,evalhook		;replace evalhook

	unlkm a1-a5
	rts
		

hook:
	push.l evalhook
	jsr hookfun
	pop.l evalhook
	rts

hookfun:
	cmp.l	d6,a0		;check for nil
	beq	xret

	cmp.l	stackbot,sp
	blt	stkov

	linkm	a1-a5

	newnode a2
	clr.l (a2)
	move.l d6,car(a2)
	move.l d6,cdr(a2)

	newnode a1
	clr.l (a1)
	move.l a0,car(a1)
	move.l a2,cdr(a1)

	move.l evalhook,a2
	move.l d6,evalhook

	jmp int_apply



	xdef	init_evaluator
init_evaluator:
	primitive eval,.eval
	primitive apply
	primitive funcall
	primitive macroexpand
	primitive evalhook,.evalhook
	rts

	end
