#include <stdio.h>
#include <unistd.h>
#include "lispdefs.h"

node nil;



#if 0

int exit()
    {
    printf("; exiting lisp\n");

    // cleanup memory system is needed
    // shutdown

    return 1;
    }


void error()
    {
    printf("; serious error: restarting\n");

    // longjmp to restart
    }


void stackovfl()
    {
    printf("; stack overflow: restarting\n");

    // longjmp to restart
    }

#endif



int main()
    {
    nil.type = constype;
    nil.car = &nil;
    nil.cdr = &nil;


//    startup();

    printf("; (lisp) 2.0 Copyright (c) 1987, 2018 by Jonathan Engdahl\n");

//    init_memory();
//    init_symbols();
//    init_specials();
//    init_lists();
//    init_functions();
//    init_evaluator();
//    init_reader();
//    init_printer();
//    init_booleans();
//    init_conditionals();
//    init_numbers();
//    init_files();

    // setjmp restart

    // primitive exit jumps to here
    // primitive error jumps to here


    while(true)
        {
        node *list;

        list = lisp_read();
//        list = eval(list);
//        if(verbose)
//            {
//            lisp_print(list);
//            }
        }
    }
