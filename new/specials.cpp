#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"

node *quote(node *args)
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

    while(args)
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
    special("quote", quote);
    }
