#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"


node *symbol_value(node *args)
    {
    if(args->car->type != symtype)
        {
        signal_error("symbol-value needs a symbol");
        }

    return args->car->value;
    }

node *symbol_function(node *args)
    {
    if(args->car->type != symtype)
        {
        signal_error("symbol-function needs a symbol");
        }

    return args->car->more->function;
    }

node *symbol_plist(node *args)
    {
    if(args->car->type != symtype)
        {
        signal_error("symbol-plist needs a symbol");
        }

    return args->car->more->plist;
    }

node *symbol_name(node *args)
    {
    if(args->car->type != symtype)
        {
        signal_error("symbol-name needs a symbol");
        }

    return args->car->more->name;
    }

node *put_sym_fun(node *args)
    {
    if(args->car->type != symtype)
        {
        signal_error("put-sym-fun needs a symbol");
        }

    first(args)->more->function = second(args);
    return second(args);
    }

node *put_sym_plist(node *args)
    {
    if(args->car->type != symtype)
        {
        signal_error("put-sym-plist needs a symbol");
        }

    first(args)->more->plist = second(args);
    return second(args);
    }

void init_functions()
    {
    primitive("symbol-function", symbol_function);
    primitive("symbol-name",     symbol_name);
    primitive("symbol-value",    symbol_value);
    primitive("symbol-plist",    symbol_plist);
    primitive("put-sym-fun",     put_sym_fun);
    primitive("put-sym-plist",   put_sym_plist);
    }

