#include "lispdefs.h"

node *car(node *args)
    {
    return args->car->car;
    }

node *cdr(node *args)
    {
    return args->car->cdr;
    }

node *caar(node *args)
    {
    return args->car->car->car;
    }

node *cadr(node *args)
    {
    return args->car->cdr->car;
    }

node *cdar(node *args)
    {
    return args->car->car->cdr;
    }

node *cddr(node *args)
    {
    return args->car->cdr->cdr;
    }

node *caaar(node *args)
    {
    return args->car->car->car->car;
    }

node *caadr(node *args)
    {
    return args->car->cdr->car->car;
    }

node *cadar(node *args)
    {
    return args->car->car->cdr->car;
    }

node *caddr(node *args)
    {
    return args->car->cdr->cdr->car;
    }

node *cdaar(node *args)
    {
    return args->car->car->car->cdr;
    }

node *cdadr(node *args)
    {
    return args->car->cdr->car->cdr;
    }

node *cddar(node *args)
    {
    return args->car->car->cdr->cdr;
    }

node *cdddr(node *args)
    {
    return args->car->cdr->cdr->cdr;
    }

node *fourth(node *args)
    {
    return args->car->cdr->cdr->cdr->car;
    }

node *fifth(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->car;
    }

node *sixth(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->car;
    }

node *seventh(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->cdr->car;
    }

node *eighth(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->cdr->cdr->car;
    }

node *ninth(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->cdr->cdr->cdr->car;
    }

node *tenth(node *args)
    {
    return args->car->cdr->cdr->cdr->cdr->cdr->cdr->cdr->cdr->cdr->car;
    }

node *nth(node *args)
    {
    unsigned count = FIRST(args)->numerator;
    node *list = SECOND(args);
    while(count--)
        {
        list = list->cdr;
        }
    return list->car;
    }

node *last(node *args)
    {
    node *list = FIRST(args);
    while(list->cdr != nil)
        {
        list = list->cdr;
        }
    return list->car;
    }

node *cons(node *args)
    {
    return CONS(FIRST(args), SECOND(args));
    }

node *list(node *args)
    {
    return args;
    }

node *list_(node *args)
    {
    if(CAR(args) == nil)return nil;
    if(CDR(args) == nil)return args;
    node *n = args;
    while(CDR(CDR(n)) != nil)
        {
        n = CDR(n);
        }
    n->cdr = n->cdr->car;
    return args;
    }

void init_lists()
    {
    primitive("car",   car  );
    primitive("cdr",   cdr  );
    primitive("caar",  caar );
    primitive("cadr",  cadr );
    primitive("cdar",  cdar );
    primitive("cddr",  cddr );
    primitive("caaar", caaar);
    primitive("caadr", caadr);
    primitive("cadar", cadar);
    primitive("caddr", caddr);
    primitive("cdaar", cdaar);
    primitive("cdadr", cdadr);
    primitive("cddar", cddar);
    primitive("cdddr", cdddr);

    primitive("first",   car    );
    primitive("second",  cadr   );
    primitive("third",   caddr  );
    primitive("fourth",  fourth );
    primitive("fifth",   fifth  );
    primitive("sixth",   sixth  );
    primitive("seventh", seventh);
    primitive("eighth",  eighth );
    primitive("ninth",   ninth  );
    primitive("tenth",   tenth  );

    primitive("nth",     nth);
    primitive("last",    last); 

    primitive("cons",    cons);
    primitive("list",    list);
    primitive("list*",    list_);
    }
