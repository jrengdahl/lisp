#include "lispdefs.h"

node *plus(node *args)
    {
    int64_t sum = 0;
    while(args != nil)
        {
        sum += args->car->numerator;
        args = args->cdr;
        }
    return new node(sum);
    }

void init_numbers()
    {
    primitive("+", plus);
    }
