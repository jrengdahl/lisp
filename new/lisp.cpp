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
        n = eval(n);
        lisp_print(n);
        }

    return 0;
    }
