node *oblist;

node *t;
node *pseudo_nil;
node *unbound;
node *quote;
node *function;
node *pound;
node *bquote;
node *cmma;
node *commaat;
node *rest;
node *optional;
node *aux;
node *lambda;
node *xmacro;
node *oblist;
node *gcverbose
node *evalhook;

node *nil;


void init_symbols()
    {
    node *n;

    n = new node);
    nil->type = constype;
    nil.car = &nil;
    nil.cdr = &nil;

    unbound = new node;
    unbound->type = symtype;


    t = new node;
    t->type = symtype;
    t->symbol_value = t;
    t->more = new node;
    t->more->symbol_function = unbound;



    oblist = new node("oblist", nil);    

    
    }


        ;create oblist
        move.l  #oblist_name,a0         ;make oblist name
        xref    make_str
        jsr     make_str

        newnode a1                                      ;create the symbol
        newnode a2
        move.l  #symtype*65536,(a1)
        move.l  a2,sym_more(a1)
        move.l  d6,(a2)                         ;no function
        move.l  d6,sym_plist(a2)                ;no plist
        move.l  a0,sym_name(a2)         ;set name

        newnode a3                                      ;create the list
        move.l  #constype*65536,(a3)
        move.l  a1,car(a3)                      ;list contains oblist
        move.l  d6,cdr(a3)
        move.l  a3,sym_value(a1)                ;value of oblist is list
        move.l  a1,oblist                               ;remember where it is

        ;create unbound
        move.l  #unbound_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,sym_value(a0)
        move.l  a0,unbound

        ;create t
        move.l  #t_name,a0

        jsr     make_str
        jsr     get_symbol
        move.l  a0,sym_value(a0)        ;value of t is t
        move.l  a0,t

        ;create pseudo-nil
        move.l  #nil_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,pseudo_nil

        ;create quote
        move.l  #quote_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,quote

        ;create function
        move.l  #function_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,function

        ;create pound
        move.l  #pound_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,pound

        ;create bquote
        move.l  #bquote_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,bquote

        ;create comma
        move.l  #comma_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,cmma

        ;create commat
        move.l  #commaat_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,commaat

        ;create rest
        move.l  #rest_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,rest

        ;create optional
        move.l  #opt_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,optional

        ;create aux
        move.l  #aux_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,aux

        ;create lambda
        move.l  #lambda_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,lambda

        ;create macro
        move.l  #macro_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,xmacro

        ;create *gc-verbose*
        move.l  #gcverb_name,a0
        jsr     make_str
        jsr     get_symbol
        move.l  a0,gcverbose
        move.l  t,sym_value(a0)

        ;create *evalhook*
;       move.l  #hook_name,a0
;       jsr     make_str
;       jsr     get_symbol
;       move.l  a0,evalhook

        move.l d6,evalhook      ;optimized evalhook, does not use *evalhook*

        rts



;find a symbol in the oblist. If the symbol cannot be found, create ;it, and add it to the oblist

;input: a string node in a0
;output: a symbol in a0





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

    // symbol not found, make new one
    candidate = new node();
    candidate->type = symtype;
    candidate->symbol_value = unbound;
    candidate->more - new(node);
    candidate->more->symbol_function = unbound;
    candidate->more->symbol_plist = nil;
    candidate->more->symbol_name = given_name;

    // add the new symbol to the oblist
    oblist->symbol_value = new node(candidate, oblist->symbol_value);

    return candidate;
    }



t_name:
        .byte           't',0
oblist_name:
        .byte           'oblist',0
unbound_name:
        .byte           '*unbound*',0
quote_name:
        .byte           'quote',0
function_name:
        .byte           'function',0
pound_name:
        .byte           'pound',0
bquote_name:
        .byte           'backquote',0
comma_name:
        .byte           'comma',0
commaat_name:
        .byte           'commaat',0
nil_name:
        .byte           'nil',0
lambda_name:
        .byte           'lambda',0
macro_name:
        .byte           'macro',0
rest_name:
        .byte           '&rest',0
opt_name:
        .byte           '&optional',0
aux_name:
        .byte           '&aux',0
gcverb_name:
        .byte           '*gc-verbose*',0
hook_name:
        .byte           '*evalhook*',0

        end
