#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"


static node *nhook(node *);


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
    if(n == nil)return nil;

    if(evalhook->value == nil) return nhook(n);

    node *tmp = evalhook;
    node *func = evalhook;
    node *args = cons(n, cons(nil, nil));
    evalhook = nil;

    if(func->type == symtype)
        {
        func = func->more->function;
        }
    if(func->type == constype
    && func->car == lambda)
        {
        return interpreter(func, args);
        }
    else if(func->type == primtype)
        {
        return (*func->primitive)(args);
        }
    else signal_error("attempt to apply a non-function object to args");

    evalhook = tmp;
    return n;
    }

// evaluate a form after (or without) evalhook processing
node *nhook(node *form)
    {
    if(form == nil)return nil;

    // TODO stackcheck

    node *func = form->car;                                             // the car is the function, and the cdr is the arglist (fun arg0, arg1, arg...) e.g. (+ 1 2)
    node *args = form->cdr;

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
            return interpreter(func, evalargs(args));                   // eval the args then call the interpreter
            }
        else if(func->car == macro)                                     // handle a macro the same, except do not eval the args, just pass them raw
            {
            return eval(interpreter(func, args));
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

// (macroexpand form) will expand the macro call and return the expansion
node *macroexpand(node *form)
    {
    node *func = form->car;
    node *args = form->cdr;

    if(func->type != symtype)
        {
        signal_error("macro name must be a symbol");
        }

    func = func->more->function;
    if(func->type != constype)
        {
        signal_error("macro must be a macro-form");
        }

    if(func->car != macro)
        {
        signal_error("car of macro function must be the symbol macro");
        }

    return interpreter(func, args);
    }

// (funcall fn a1 a2 ... an) applies the function fn to the arguments a1, a2, ..., an.
node *funcall(node *args)
    {
    node *func = args->car;
    args = args->cdr;
    if(func->type == symtype)
        {
        func = func->more->function;
        }
    if(func->type == constype
    && func->car == lambda)
        {
        return interpreter(func, args);
        }
    else if(func->type == primtype)
        {
        return (*func->primitive)(args);
        }
    else signal_error("attempt to apply a non-function object to args");
    }


// (apply fun a1 a2 a3 ... an) applies the function to (a1 a2 a3 . an)
// TODO this is an abbreviated apply, which only takes one arg
// which is the most useful form: (apply fn '(a1 a2 a3) is like (fn a1 a2 a3)
node *apply(node *func, node *args)
    {
    if(func->type == symtype)
        {
        func = func->more->function;
        }
    if(func->type == constype
    && func->car == lambda)
        {
        return interpreter(func, args);
        }
    else if(func->type == primtype)
        {
        return (*func->primitive)(args);
        }
    else signal_error("attempt to apply a non-function object to args");
    }

node *applyprim(node *args)
    {
    return apply(first(args), second(args));
    }


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
        signal_error("unknown node type in eval\n");
        return nil;
        }
    }


node *evalprim(node *n)
    {
    return eval(n->car);
    }

// (evalhook form evalhookfn) the form is evaluated with *evalhook* bound to evalhookfn

node *evalhookprim(node *args)
    {
    node *retval;
    node *tmp = evalhook;
    evalhook = args->cdr->car;

    node *n = args->car;
    switch(n->type)
        {
    case constype:
        retval = nhook(n);                  // a list is a function call, go interpret it (without evalhook processing)
        break;

    case symtype:                           // a symbol evaluates to its value
        retval = n->value;
        break;

    case numtype:                           // anything else evaluates to itself
    case rattype:
    case stringtype:
    case chartype:
    case primtype:
    case sfuntype:
        retval = n;
        break;

    default:
        signal_error("unknown node type in evalhook\n");
        }

    evalhook = tmp;
    return retval;
    }


void init_evaluator()
    {
    primitive("eval", evalprim);
    primitive("apply", applyprim);
    primitive("funcall", funcall);
    primitive("macroexpand", macroexpand);
    primitive("evalhook", evalhookprim);
    }
