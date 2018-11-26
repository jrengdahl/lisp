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
        uint8_t type;           // cons
        uint8_t flags;
        uint16_t reserved;
        uint32_t length;
        node *car;
        node *cdr;
        };

    struct
        {
        uint64_t symbol_placeholder;   // first node of symbol
        node *symbol_value;
        node *more;
        };

    struct                          // second node of symbol
        {
        node *symbol_function;
        node *symbol_plist;
        node *symbol_name;
        };

    struct                          // rational number
        {
        uint64_t num_placeholder;
        int64_t numerator;
        uint64_t denominator;
        };

    struct                          // string continuation
        {
        node *next;
        char data[16];
        };

    struct                          // char
        {
        uint64_t char_placeholder;
        uint64_t char_data;
        uint64_t attr;
        };

    struct                          // primitive
        {
        uint64_t prim_placeholder;
        node * (*primitive)(node *arglist);
        uint64_t prim_name;
        };

    struct
        {
        uintptr_t word0;
        uintptr_t word1;
        uintptr_t word2;
        };

    node() : word0(0), word1(0), word2(0) {}

    node(node *n1, node *n2) :
        type(constype),
        flags(0),
        reserved(0),
        length(0),
        car(n1),
        cdr(n2)
        {}

    // constructor for a string
    node(const char *string) :
        type(stringtype),
        flags(0),
        reserved(0),
        length(strlen(string))
        {
        node *n = this;
        int i=0;
        int j;

        for(j=0; j<8 && i<length; i++,j++)
            {
            data1[j] = string[i];
            }
        for(; j<8; j++)
            {
            data1[j] = 0;
            }

        while(i<length)
            {
            n->more = new node;
            n = n->more;
            for(j=0; j<16 && i<length; i++,j++)
                {
                data0[j] = string[i];
                }
            for(; j<16; j++)
                {
                data0[j] = 0;
                }
            }

        n->more = 0;
        }

    // constructor for a symbol
    node(const char *string, node *value) :
        type(symtype),
        flags(0),
        reserved(0),
        length(0)
        {
        symbol_value = value;
        more = new node;
        more->symbol_function = unbound;
        more->symbol_plist = nil;
        more->symbol_name = new node(string);

        oblist->symbol_value = new node(this, oblist->symbol_value);
        }

    node(const char *string, node &value) :
        type(symtype),
        flags(0),
        reserved(0),
        length(0)
        {
        symbol_value = &value;
        more = new node;
        more->symbol_function = unbound;
        more->symbol_plist = nil;
        more->symbol_name = new node(string);

        oblist->symbol_value = new node(this, oblist->symbol_value);
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
