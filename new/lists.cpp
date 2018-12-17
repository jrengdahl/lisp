#include "lispdefs.h"

node *carfunc(node *args)
    {
    return args->car->car;
    }

node *cdrfunc(node *args)
    {
    return args->car->cdr;
    }

node *caarfunc(node *args)
    {
    return args->car->car->car;
    }

node *cadrfunc(node *args)
    {
    return args->car->cdr->car;
    }

node *cdarfunc(node *args)
    {
    return args->car->car->cdr;
    }

node *cddrfunc(node *args)
    {
    return args->car->cdr->cdr;
    }

node *caaarfunc(node *args)
    {
    return args->car->car->car->car;
    }

node *caadrfunc(node *args)
    {
    return args->car->cdr->car->car;
    }

node *cadarfunc(node *args)
    {
    return args->car->car->cdr->car;
    }

node *caddrfunc(node *args)
    {
    return args->car->cdr->cdr->car;
    }

node *cdaarfunc(node *args)
    {
    return args->car->car->car->cdr;
    }

node *cdadrfunc(node *args)
    {
    return args->car->cdr->car->cdr;
    }

node *cddarfunc(node *args)
    {
    return args->car->car->cdr->cdr;
    }

node *cdddrfunc(node *args)
    {
    return args->car->cdr->cdr->cdr;
    }

node *fourthfunc(node *args)
    {
    return args->car->cdr->cdr->cdr->car;
    }

node *fifthfunc(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->car;
    }

node *sixthfunc(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->car;
    }

node *seventhfunc(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->cdr->car;
    }

node *eighthfunc(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->cdr->cdr->car;
    }

node *ninthfunc(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->cdr->cdr->cdr->car;
    }

node *tenthfunc(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->cdr->cdr->cdr->cdr->car;
    }

node *nth(node *args)
    {
    unsigned count = first(args)->numerator;
    node *list = second(args);
    while(count--)
        {
        list = list->cdr;
        }
    return list->car;
    }

node *last(node *args)
    {
    node *list = first(args);
    while(list->cdr != nil)
        {
        list = list->cdr;
        }
    return list->car;
    }

node *consfunc(node *args)
    {
    return cons(first(args), first(args));
    }

node *list(node *args)
    {
    return args;
    }

node *list_(node *args)
    {
    if(car(args) == nil)return nil;
    if(cdr(args) == nil)return args;
    node *n = args;
    while(cdr(cdr(n)) != nil)
        {
        n = cdr(n);
        }
    n->cdr = n->cdr->car;
    return args;
    }

node *append(node *args)
    {
    node *first;
    node **last = &first;

    while(args->cdr != nil)
        {
        node *list = follow(args);
        while(list != nil)
            {
            *last = cons(follow(list), nil);
            last = &(*last)->cdr;
            }
        }
    
    *last = args->car;
    return first;
    }

node *reverse(node *args)
    {
    node *retval = nil;
    node *list = first(args);
    while(list != nil)
        {
        retval = cons(follow(list), retval);
        }
    return retval;
    }

node *length(node *args)
    {
    node *arg = first(args);
    node *retval = new node((int64_t)0);

    if(arg->type == stringtype)
        {
        retval->numerator = arg->length;
        }

    else if(arg->type == constype)
        {
        while(arg != nil)
            {
            ++retval->numerator;
            arg = cdr(arg);
            }
        }

    else
        {
        signal_error("incorrect arg for length");
        }

    return retval;
    }

void init_lists()
    {
    primitive("car",   carfunc  );
    primitive("cdr",   cdrfunc  );
    primitive("caar",  caarfunc );
    primitive("cadr",  cadrfunc );
    primitive("cdar",  cdarfunc );
    primitive("cddr",  cddrfunc );
    primitive("caaar", caaarfunc);
    primitive("caadr", caadrfunc);
    primitive("cadar", cadarfunc);
    primitive("caddr", caddrfunc);
    primitive("cdaar", cdaarfunc);
    primitive("cdadr", cdadrfunc);
    primitive("cddar", cddarfunc);
    primitive("cdddr", cdddrfunc);

    primitive("first",   carfunc    );
    primitive("second",  cadrfunc   );
    primitive("third",   caddrfunc  );
    primitive("fourth",  fourthfunc );
    primitive("fifth",   fifthfunc  );
    primitive("sixth",   sixthfunc  );
    primitive("seventh", seventhfunc);
    primitive("eighth",  eighthfunc );
    primitive("ninth",   ninthfunc  );
    primitive("tenth",   tenthfunc  );

    primitive("nth",     nth);
    primitive("last",    last); 

    primitive("cons",    consfunc);
    primitive("list",    list);
    primitive("list*",   list_);
    primitive("append",  append);
    primitive("reverse", reverse);
    primitive("length",  length);
    }
