#ifndef LISPDEFS_H
#define LISPDEFS_H

#include <stdint.h>
#include <stdlib.h>

static const unsigned constype  = 0;
static const unsigned numtype   = 1;
static const unsigned rattype   = 2;
static const unsigned flttype   = 3;
static const unsigned strtype   = 4;
static const unsigned arraytype = 5;
static const unsigned chartype  = 6;
static const unsigned primtype  = 7;
static const unsigned sfuntype  = 8;
static const unsigned symtype   = 9;


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

    struct                          // string
        {
        uint64_t string_placeholder1;
        char data[8];
        uint64_t string_more;
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

    // constructor for a string  with up to  7 characters
    node(char *string) :
        type(stringtype),
        flags(0),
        reserved(0)
        {
        unsigned len = strlen(string);

        if(len<8)length = len
        else length = 8;
        word1 = *(uintptr_t *)string;        
        data[7] = 0;
        }

    // constructor for a symbol
    node(char *string, value *node) :
        {
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

extern node *nil;




#endif // LISPDEFS_H
