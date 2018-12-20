#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"


// interpret a lambda list


node *interpreter(node *func, node *args)
    {
    node *bindings = nil;                               // a list of the original bindings of the args
    follow(func);                                       // skip over the lambda
    node *formal = follow(func);                        // get the list of formal args

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

        node *farg = follow(formal);
        pushalist(farg, farg->value, bindings);
        farg->value = follow(args);
        }

    if(formal->car == optional)
        {
        follow(formal);

        while(formal != nil
        && formal->car != rest
        && formal->car != aux)
            {
            node *farg = follow(formal);
            if(farg->type == constype)
                {
                pushalist(farg->car, farg->car->value, bindings);
                if(args == nil)
                    {
                    farg->car->value = eval(farg->cdr->car);
                    }
                else
                    {
                    farg->car->value = follow(args);
                    }
                }
            else
                {
                pushalist(farg, farg->value, bindings);
                farg->value = follow(args);
                }
            }
        }

    if(formal->car == rest)
        {
        follow(formal);

        if(formal == nil)
            {
            signal_error("missing symbol after &rest");
            }

        node *farg = follow(formal);
        pushalist(farg, farg->value, bindings);
        farg->value = args;
        args = nil;
        }

    if(args != nil)
        {
        signal_error("extraneous actual args");
        }

    if(formal->car == aux)
        {
        follow(formal);

        while(formal != nil)
            {
            node *farg = follow(formal);
            if(farg->type == constype)
                {
                pushalist(farg->car, farg->car->value, bindings);
                farg->car->value = eval(farg->cdr->car);
                }
            else
                {
                pushalist(farg, farg->value, bindings);
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
        retval = eval(follow(func));
        }

    while(bindings != nil)
        {
        bindings->car->car->value = bindings->car->cdr;
        follow(bindings);
        }

    return retval;
    }
