#ifndef LISPDEFS_H
#define LISPDEFS_H

#include <stdio.h>
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
extern node *optional;
extern node *aux;
extern node *lambda;
extern node *macro;
extern node *gcverbose;
extern node *evalhook;

typedef node *primfunc(node *);
typedef node *sfunfunc(node *);

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

    struct                          // primitive
        {
        uint64_t : 64;
        primfunc *primitive;
        uint64_t : 64;
        };

    struct                          // primitive
        {
        uint64_t : 64;
        sfunfunc *sfun;
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

    // constructor for an character
    node(char c) : node()
        {
        type = chartype;
        data[0] = c;
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

    // constructor for a primitive
    node(primfunc *func) : node()
        {
        type = primtype;
        primitive = func;
        }




    };

static const unsigned NODES_PER_BLOCK = 1365;

struct nodeblock
    {
    nodeblock *next;
    node nodes[NODES_PER_BLOCK];
    };


static void signal_error(const char *msg)
    {
    printf("%s\n", msg);
    exit(-1);
    }

extern node *lisp_read();
extern node *eval(node *);
extern void lisp_print(node *);
extern bool cmp_str(node*, node *);
extern bool cmp_str(node *left, const char *right);
extern long gdec();
extern node *get_symbol(node *name);
extern void primitive(const char *, primfunc *);
extern void special(const char *, sfunfunc *);
extern node *interpreter(node *, node *);

extern void init_symbols();
extern void init_evaluator();
extern void init_specials();
extern void init_lists();
extern void init_functions();



#define CONS(l, r) new node(l, r)


#endif // LISPDEFS_H
