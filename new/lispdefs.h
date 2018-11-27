#ifndef LISPDEFS_H
#define LISPDEFS_H

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static const unsigned constype   = 0;
static const unsigned numtype    = 1;
static const unsigned rattype    = 2;
static const unsigned flttype    = 3;
static const unsigned stringtype = 4;
static const unsigned arraytype  = 5;
static const unsigned chartype   = 6;
static const unsigned primtype   = 7;
static const unsigned sfuntype   = 8;
static const unsigned symtype    = 9;

union node;

extern node *oblist;
extern node *nil;
extern node *t;
extern node *unbound;

union node
    {
    struct
        {
        uint8_t flags;
        uint8_t type;           // cons
        uint16_t :16;
        uint32_t length;
        node *car;
        node *cdr;
        };

    struct
        {
        uint64_t : 64;              // first node of symbol
        node *value;
        node *more;
        };

    struct                          // second node of symbol
        {
        node *function;
        node *plist;
        node *name;
        };

    struct                          // number or rational number
        {
        uint64_t : 64;
        int64_t numerator;
        uint64_t denominator;
        };

    struct                          // string continuation
        {
        node *next;                 // for strings the continuation pointer comes first so that the low order bit can be used as the garbage collection flag
        char data[16];
        };

    struct                          // char
        {
        uint64_t : 64;
        uint64_t char_data;
        uint64_t attr;
        };

    struct                          // primitive
        {
        uint64_t : 64;
        node * (*primitive)(node *arglist);
        uint64_t : 64;
        };

    struct
        {
        uintptr_t word0;
        uintptr_t word1;
        uintptr_t word2;
        };

    node() : word0(0), word1(0), word2(0) {}

    node(node *n1, node *n2) : node()
        {
    	type = constype;
        car = n1;
        cdr = n2;
        }

    node(int64_t n) : node()
        {
    	type = numtype;
        numerator = n;
        denominator = 1;
        }

    node(int64_t n, uint64_t d) : node()
        {
    	type = rattype;
        numerator = n;
        denominator = d;
        }

    // constructor for a string
    node(const char *string) : node()
        {
        type = stringtype;
        length = strlen(string);

        node *n = this;
        int i=0;
        int j;

        for(j=0; j<8 && i<length; i++,j++)
            {
            data[j] = string[i];
            }
        if(i>=length)
            {
            while(j<8)data[j++] = 0;
            more = 0;
            return;
            }

        more = new node;
        n = more;

        while(true)
            {
            for(j=0; j<16 && i<length; i++,j++)
                {
                n->data[j] = string[i];
                }
            if(i>=length)
                {
                while(j<16)n->data[j++] = 0;
                n->next = 0;
                return;
                }

            n->more = new node;
            n = n->more;
            }
        }

    // constructor for a symbol
    node(const char *string, node *val) : node()
        {
        type = symtype;

        value = val;
        more = new node;
        more->function = unbound;
        more->plist = nil;
        more->name = new node(string);

        oblist->value = new node(this, oblist->value);
        }

    node(const char *string, node &val) : node()
        {
        type = symtype;

   	    value = &val;
        more = new node;
        more->function = unbound;
        more->plist = nil;
        more->name = new node(string);

        oblist->value = new node(this, oblist->value);
        }


    };

static const unsigned NODES_PER_BLOCK = 1365;

struct nodeblock
    {
    nodeblock *next;
    node nodes[NODES_PER_BLOCK];
    };

extern node *lisp_read();
extern node *eval(node *);
extern void lisp_print(node *);

extern bool cmp_str(node*, node *);


#endif // LISPDEFS_H
