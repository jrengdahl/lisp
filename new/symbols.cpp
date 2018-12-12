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
node *minus;
node *rest;
node *optional;
node *aux;
node *lambda;
node *macro;
node *gcverbose;
node *evalhook;


node *unboundfunc(node *)
    {
    signal_error("unbound function");
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
    unbound->more->function = unboundfunc;
    unbound->more->plist = nil;
    unbound->more->name = new node("*unbound*");
    unbound->value = unbound;

    oblist = new node;
    oblist->type = symtype;
    oblist->more = new node;
    oblist->more->function = unbound;
    oblist->more->plist = nil;
    oblist->more->name = new node("oblist");
    oblist->value = new node(oblist, nil);

    oblist->value = new node(unbound, oblist->value);

    pseudo_nil = new node("nil", nil);

    t = new node("t", nil);
    t->more->value = t;

    // quote = new node("quote", nil);
    function = new node("function", nil);
    pound = new node("pound", nil);
    bquote = new node("backquote", nil);
    comma = new node("comma", nil);
    commaat = new node("commaat", nil);
    minus = new node("-", nil);
    pseudo_nil = new node("nil", nil);
    lambda = new node("lambda", nil);
    macro = new node("macro", nil);
    rest = new node("&rest", nil);
    optional = new node("&optional", nil);
    aux = new node("&aux", nil);
    gcverbose = new node("*gc-verbose*", t);
    evalhook = new node("*evalhook*", nil);
    }


// find a symbol in the oblist. If the symbol cannot be found, create ;it, and add it to the oblist
// input: a string node in a0
// output: a symbol in a0

node *get_symbol(node *given_name)
    {
    node *ob = oblist->value;
    node *candidate;
    node *candidate_name;

    while(ob != nil)
        {
        candidate = ob->car;
        candidate_name = candidate->more->name;
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
    candidate = new node(given_name, unbound, unbound, nil);

    return candidate;
    }

void primitive(const char *string, primfunc *func)
    {
    node *prim = new node(func);
    node *sym = new node(string, unbound, prim, nil);
    oblist->value = CONS(sym, oblist->value);
    }

void special(const char *string, sfunfunc *func)
    {
    node *sfun = new node(func);
    sfun->type = sfuntype;
    node *sym = new node(string, unbound, sfun, nil);
    oblist->value = CONS(sym, oblist->value);
    }

