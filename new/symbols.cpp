#include "lispdefs.h"

node *nil;
node *oblist;
node *t;
node *pseudo_nil;
node *unbound;
node *quote;
node *function;
node *pound;
node *bquote;
node *comma;
node *commaat;
node *rest;
node *opt;
node *aux;
node *lambda;
node *macro;
node *gcverbose;
node *evalhook;


bool cmp_str(node *l, node *r)
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



void init_symbols()
    {
    nil = new node;
    nil->type = constype;
    nil->car = nil;
    nil->cdr = nil;

    unbound = new node;
    unbound->type = symtype;
    unbound->more = new node;
    unbound->more->symbol_function = unbound;
    unbound->more->symbol_plist = nil;
    unbound->more->symbol_name = new node("*unbound*");
    unbound->symbol_value = unbound;

    oblist = new node;
    oblist->type = symtype;
    oblist->more = new node;
    oblist->more->symbol_function = unbound;
    oblist->more->symbol_plist = nil;
    oblist->more->symbol_name = new node("oblist");
    oblist->symbol_value = new node(oblist, nil);

    oblist->symbol_value = new node(unbound, oblist->symbol_value);

    pseudo_nil = new node("nil", nil);

    t = new node("t", nil);
    t->more->symbol_value = t;

    quote = new node("quote", nil);    
    function = new node("function", nil);
    pound = new node("pound", nil);
    bquote = new node("backquote", nil);
    comma = new node("comma", nil);
    commaat = new node("commaat", nil);
    nil = new node("nil", nil);
    lambda = new node("lambda", nil);
    macro = new node("macro", nil);
    rest = new node("&rest", nil);
    opt = new node("&optional", nil);
    aux = new node("&aux", nil);
    gcverbose = new node("*gc-verbose*", t);
    evalhook = new node("*evalhook*", nil);
    }


// find a symbol in the oblist. If the symbol cannot be found, create ;it, and add it to the oblist
// input: a string node in a0
// output: a symbol in a0

node *get_symbol(node *given_name)
    {
    node *ob = oblist->symbol_value;
    node *candidate;
    node *candidate_name;

    while(ob != nil)
        {
        candidate = ob->car;
        candidate_name = candidate->more->symbol_name;
        if(cmp_str(given_name, candidate_name))
            {
            return candidate;
            }
        else
            {
            ob = ob->cdr;
            }
        }

    // symbol not found, make new one and add it to the oblist
    candidate = new node(given_name, unbound);

    return candidate;
    }
