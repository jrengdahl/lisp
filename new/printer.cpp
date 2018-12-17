#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"


void lprint(node *n);

void pcons(node *n)
    {
    printf("(");

    while(true)
        {
        lprint(n->car);
        n = n->cdr;
        if(n==nil || n->type!=constype)break;
        printf(" ");
        }

    if(n!=nil)
        {
        printf(" . ");
        lprint(n);
        }

    printf(")");
    }


void print_string(node *n)
    {
    unsigned length = n->length;    // length of the string
    char *p = &n->data[0];          // pointer to the string characters
    node *next = n->more;           // pointer to the next block in the chain
    unsigned nlen = 8;              // max number of chars in this node

    while(length)
        {
        if(nlen == 0)
            {
            n = next;
            next = n->next;
            p = &n->data[0];
            nlen = 16;
            }
        printf("%c", *p++);
        --length;
        --nlen;
        }
    }



void lprint(node *n)
    {
    if(n==nil)
        {
        printf("nil");
        return;
        }

    switch(n->type)
        {
    case constype:
        pcons(n);
        return;

    case numtype:
        printf("%ld", n->numerator);
        return;

    case rattype:
        // reduce(n);
        printf("%ld", n->numerator);
        if(n->denominator != 1)
            {
            printf("/%lu", n->denominator);
            }
        return;

    case stringtype:
        printf("\"");
        print_string(n);
        printf("\"");
        return;

    case chartype:
        if(n->data[0] <= ' ')
            {
            printf("#\\%x", n->data[0]);
            }
        else
            {
            printf("#\\%c", n->data[0]);
            }
        return;

    case primtype:
        printf("#(primitive: %zx \"", n->primitive);
        print_string(n->name);
        printf("\")");
        return;

    case sfuntype:
        printf("#(special form: %zx \"", n->primitive);
        print_string(n->name);
        printf("\")");
        return;

    case symtype:
        print_string(n->more->name);
        return;

    default:
        signal_error("unknown node type in lprint");
        return;
        }
    }


void lisp_print(node *n)
    {
    lprint(n);
    printf("\n");
    }


void lprin1(node *n)
    {
    lprint(n);
    fflush(stdout);
    }

void terpri()
    {
    printf("\n");
    }

