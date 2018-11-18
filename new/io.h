#ifndef IO_H
#define IO_H

#include <stdio.h>

static const int peekc(FILE *f)
    {
    int c;

    c = fgetc(f);
    ungetc(c, f);
    return c;
    }


#endif // IO_H

