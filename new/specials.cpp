#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"

node *quotefunc(node *args)
    {
    return args->car;
    }

node *set(node *args)
    {
    args->car->value = args->cdr->car;
    return args->cdr->car;
    }

node *setq(node *args)
    {
    node *retval;

    while(args != nil)
        {
        retval = eval(args->cdr->car);
        args->car->value = retval;
        args = args->cdr->cdr;
        }

    return retval;
    }

void init_specials()
    {
    primitive("set", set);
    special("setq", setq);
    special("setf", setq);
    special("quote", quotefunc, &quote);
    }
