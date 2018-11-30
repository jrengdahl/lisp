#include <unistd.h>
#include <stdio.h>
#include "lispdefs.h"

extern void init_symbols();

int main(int argc, char **argv)
    {
    init_symbols();
    lisp_read();

    return 0;
    }
