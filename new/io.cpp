#include <stdio.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"

long gdec()
    {
    if(peekc(stdin) == '-')
        {
        getc(stdin);
        return -gdec();
        }

    long n = 0;
    while(isdigit(peekc(stdin)))
        {
        n = n*10 + getc(stdin) - '0';
        }

    return n;    
    }


#if 0

void pushfile(fb *file)
    {
    *fileptr++ = selget(file);      // select new file, put the old one on the stack
    *flagptr++ = verbose;
    verbose = false;
    prompt = false;
    }

void popfile()
    {
    if(fileptr != &filetable[0])
        {

        close(selget(*--fileptr));
        verbose = *--flagptr;
        prompt = fb.fileno == 1;
        }
    else
        {
        selget(1);
        prompt = true;
        verbose = true;
        printf("(lisp)\n");
        putchar('>');
        }
    }


#endif

