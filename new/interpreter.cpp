#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"


// interpret a lambda list


node *interpreter(node *func, node *args)
    {
    node *bindings = nil;                                               // a list of the original bindings of the args
    func = func->cdr;                                                   // skip over the lambda
    node *formal = func->car;                                           // get the list of formal args
    func = func->cdr;                                                   // skip to the list of forms to evaluate

    // process and bind the formal arg list
    while(formal != nil
    && formal->car != optional
    && formal->car != rest
    && formal->car != aux)
        {
        if(args == nil)
            {
            signal_error("required arg missing");
            }

        node *farg = formal->car;
        formal = formal->cdr;
        bindings = CONS(CONS(farg, farg->value), bindings);
        farg->value = args->car;
        args = args->cdr;
        }

    if(formal->car == optional)
        {
        formal = formal->cdr;

        while(formal != nil
        && formal->car != rest
        && formal->car != aux)
            {
            node *farg = formal->car;
            formal = formal->cdr;
            if(farg->type == constype)
                {
                bindings = CONS(CONS(farg->car, farg->car->value), bindings);
                if(args == nil)
                    {
                    farg->car->value = eval(farg->cdr->car);
                    }
                else
                    {
                    farg->car->value = args->car;
                    }
                }
            else
                {
                bindings = CONS(CONS(farg, farg->value), bindings);
                farg->value = args->car;
                }
            args = args->cdr;
            }
        }

    if(formal->car == rest)
        {
        formal = formal->cdr;

        if(formal == nil)
            {
            signal_error("missing symbol after &rest");
            }

        node *farg = formal->car;
        formal = formal->cdr;
        bindings = CONS(CONS(farg, farg->value), bindings);
        farg->value = args;
        args = nil;
        }

    if(args != nil)
        {
        signal_error("extraneous actual args");
        }

    if(formal->car == aux)
        {
        formal = formal->cdr;

        while(formal != nil)
            {
            node *farg = formal->car;
            formal = formal->cdr;
            if(farg->type == constype)
                {
                bindings = CONS(CONS(farg->car, farg->car->value), bindings);
                farg->car->value = eval(farg->cdr->car);
                }
            else
                {
                bindings = CONS(CONS(farg, farg->value), bindings);
                farg->value = nil;
                }
            }
        }

    if(formal != nil)
        {
        signal_error("extraneous formal args");
        }

    node *retval = nil;
    while(func != nil)
        {
        retval = eval(func->car);
        func = func->cdr;
        }

    while(bindings != nil)
        {
        bindings->car->car->value = bindings->car->cdr;
        bindings = bindings->cdr;
        }

    return retval;
    }
