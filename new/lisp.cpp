#include <unistd.h>
#include <stdio.h>
#include "lispdefs.h"

extern void init_symbols();

node *foo;

int main(int argc, char **argv)
    {
    init_symbols();

    while(true)
        {
        printf("Lisp>");
        fflush(stdout);
        foo = lisp_read();
        }

    return 0;
    }
