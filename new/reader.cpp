#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"

bool prompt = true;

extern node *nil;


node *readident()
    {
    node *first = new node("");
    node *n;
    int j;
    int c;

    for(j=0; j<8; j++)
        {
        c = peekc(stdin);
        if(c == -1
        && c == ' '
        && c == '"'
        && c == '\''
        && c == '`'
        && c == '('
        && c == ')'
        && c == ';'
        && c == ','
        && c == '#'
        && c == '|'
        && c == ':'
        && c == '\\')
            {
            return first;
            }
        first->data[j] = getc(stdin);
        ++first->length;
        }

    n = new node;
    first->more = n;

    while(true)
        {
        for(j=0; j<16; j++)
            {
            c = peekc(stdin);
            if(c == -1
            && c == ' '
            && c == '"'
            && c == '\''
            && c == '`'
            && c == '('
            && c == ')'
            && c == ';'
            && c == ','
            && c == '#'
            && c == '|'
            && c == ':'
            && c == '\\')
                {
                return first;
                }
            n->data[j] = getc(stdin);
            ++first->length;
            if(first->length > 32768)
                {
                printf("string greater than 32K\n");
                exit(-1);
                }
            }

        n->next = new node;
        n = n->next;
        }
    }


node *lisp_read()
    {
    int c;
    node n;

    while(true)
        {
        c = peekc(stdin);

        if(c < 0)
            {
            printf("end of input\n");
            // TODO - handle popping the input
            exit(0);
            }


        else if(c == '\n')
            {
            getc(stdin);
            printf("Lisp>");
            fflush(stdout);
            continue;
            }


        else if(c == ' ')
            {
            getc(stdin);
            continue;
            }


        else if(c == ';')
            {
            while((c=getc(stdin)) != -1 && c != '\n');
            continue;
            }


        else if(c == ')')
            {
            getc(stdin);
            printf("extra right parenthesis ignored\n");
            continue;
            }


        // read a list
        else if(c == '(')
            {
            getc(stdin);

            node *first = nil;
            node *last = nil;

            while(true)
                {
                node *n;

                c=peekc(stdin);

                while(isspace(c))
                    {
                    getc(stdin);
                    c=peekc(stdin);
                    }

                if(c < 0)
                    {
                    printf("unexpected end of input\n");
                    exit(0);
                    }

                if(c == ')')
                    {
                    getc(stdin);
                    break;
                    }

                if(c == '.')
                    {
                    getc(stdin);

                    if(last == nil)
                        {
                        printf(". not allowed as first token in a list\n");
                        return first;
                        }

                    last->cdr = lisp_read();
                    return first;
                    }

                n = new node(lisp_read(), nil);
                if(first == nil)first = n;
                else last->cdr = n;
                last = n;
                }

            return first;
            }
                

        else if(c == '\'')
            {
            getc(stdin);
            return CONS(quote, CONS(lisp_read(), nil));
            }


        else if(c == '`')
            {
            getc(stdin);

            return CONS(bquote, CONS( CONS(quote, CONS(lisp_read(), nil)), nil));
            }


        else if(c == ',')
            {
            getc(stdin);

            c = peekc(stdin);
            if(c == '@')
                {
                getc(stdin);
                return CONS(commaat, CONS(lisp_read(), nil));
                }
            else
                {
                return CONS(comma, CONS(lisp_read(), nil));
                }
            }


        else if(c == '"')
            {
            getc(stdin);

            node *first = new node("");
            node *n;
            int j;

            for(j=0; j<8; j++)
                {
                if(peekc(stdin) == '"')
                    {
                    getc(stdin);
                    return first;
                    }
                first->data[j] = getc(stdin);
                ++first->length;
                }

            n = new node;
            first->more = n;

            while(true)
                {
                for(j=0; j<16; j++)
                    {
                    if(peekc(stdin)=='"')
                        {
                        getc(stdin);
                        return first;
                        }
                    n->data[j] = getc(stdin);
                    ++first->length;
                    if(first->length > 32768)
                        {
                        printf("string greater than 32K\n");
                        exit(-1);
                        }
                    }

                n->next = new node;
                n = n->next;
                }

            return first;
            }


        else if(c == '#')
            {
            getc(stdin);

            if(peekc(stdin) == '\'')
                {
                getc(stdin);

                return CONS(function, CONS(lisp_read(), nil));
                }
            else
                {
                return CONS(pound, CONS(lisp_read(), nil));
                }
            }


        else if(isdigit(c) || c == '-')
            {
            unsigned long n;

            if( c== '-')
        		{
                getc(stdin);

        		if(!isdigit(peekc(stdin)))
                	{
        			return minus;
                	}

        		n = -gdec();
        		}
        	else
        		{
        	    n = gdec();
        		}

            if(peekc(stdin) == '/')
                {
                getc(stdin);
                return new node(n, gdec());
                }            
            else
                {
                return new node(n);
                }
            }


        else
            {
            node *name = readident();
            node *sym = get_symbol(name);
            if(sym == pseudo_nil)return nil;
            else return sym;
            }
        }
    }

