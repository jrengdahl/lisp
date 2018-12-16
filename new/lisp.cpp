#include <unistd.h>
#include <stdio.h>
#include "lispdefs.h"

int main(int argc, char **argv)
    {
    init_symbols();
    init_evaluator();
    init_specials();
    init_functions();

    node *n;

    while(true)
        {
        printf("Lisp>");
        fflush(stdout);
        n = lisp_read();
//        lisp_print(n); // for debug only
//        lisp_print(oblist->value); // for debug only
        n = eval(n);
        lisp_print(n);
        }

    return 0;
    }
