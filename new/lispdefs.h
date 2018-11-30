#ifndef LISPDEFS_H
#define LISPDEFS_H

#include <stdint.h>
#include <stdlib.h>
#include <string.h>


enum TYPE : uint8_t
    {
    constype   = 0,
    numtype    = 1,
    rattype    = 2,
    flttype    = 3,
    stringtype = 4,
    arraytype  = 5,
    chartype   = 6,
    primtype   = 7,
    sfuntype   = 8,
    symtype    = 9
    };

union node;

extern node *nil;
extern node *oblist;
extern node *t;
extern node *pseudo_nil;
extern node *unbound;
extern node *quote;
extern node *function;
extern node *pound;
extern node *bquote;
extern node *comma;
extern node *commaat;
extern node *minus;
extern node *rest;
extern node *opt;
extern node *aux;
extern node *lambda;
extern node *macro;
extern node *gcverbose;
extern node *evalhook;

union node
    {
    struct
        {
        uint8_t flags;
        TYPE type;                  // cons
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

    // constructor for a cons
    node(node *n1, node *n2) : node()
        {
    	type = constype;
        car = n1;
        cdr = n2;
        }

    // constructor for an integer
    node(int64_t n) : node()
        {
    	type = numtype;
        numerator = n;
        denominator = 1;
        }

    // construction for a rational
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

        int i=0;
        int j;

        for(j=0; j<8; j++,i++)
            {
            if(i>=length)return;
            data[j] = string[i];
            }

        node *n = new node;
        more = n;

        while(true)
            {
            for(j=0; j<16; j++,i++)
                {
                if(i>=length)return;
                n->data[j] = string[i];
                }

            n->next = new node;
            n = n->next;
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


    // constructor for a symbol, given a name, value, function, and plist
    node(node *nam, node *val, node *fun, node *pli) : node()
        {
        type = symtype;

   	    value = val;
        more = new node;
        more->function = fun;
        more->plist = pli;
        more->name = nam;

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
extern long gdec();
extern node *get_symbol(node *name);

#define CONS(l, r) new node(l, r)


#endif // LISPDEFS_H
