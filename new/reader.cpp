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
        || c == ' '
        || c == '\t'
        || c == '\n'
        || c == '\r'
        || c == '"'
        || c == '\''
        || c == '`'
        || c == '('
        || c == ')'
        || c == ';'
        || c == ','
        || c == '#'
        || c == '|'
        || c == ':'
        || c == '\\')
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
            || c == ' '
            || c == '\t'
            || c == '\n'
            || c == '\r'
            || c == '"'
            || c == '\''
            || c == '`'
            || c == '('
            || c == ')'
            || c == ';'
            || c == ','
            || c == '#'
            || c == '|'
            || c == ':'
            || c == '\\')
                {
                return first;
                }
            n->data[j] = getc(stdin);
            ++first->length;
            if(first->length > 32768)
                {
                signal_error("string greater than 32K");
                }
            }

        n->next = new node;
        n = n->next;
        }
    }


node *lisp_read()
    {
    int c;

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
            //printf("Lisp>");
            //fflush(stdout);
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
                node *elem;

                c=peekc(stdin);

                while(isspace(c))
                    {
                    getc(stdin);
                    c=peekc(stdin);
                    }

                if(c < 0)
                    {
                    signal_error("unexpected end of input");
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

                    while(isspace(c = getc(stdin)));
                    if(c != ')')
                        {
                        signal_error("illegal end of dotted list");
                        }

                    return first;
                    }

                elem = new node(lisp_read(), nil);
                if(first == nil)first = elem;
                else last->cdr = elem;
                last = elem;
                }

            return first;
            }


        else if(c == '\'')
            {
            getc(stdin);
            return cons(quote, cons(lisp_read(), nil));
            }


        else if(c == '`')
            {
            getc(stdin);

            return cons(bquote, cons( cons(quote, cons(lisp_read(), nil)), nil));
            }


        else if(c == ',')
            {
            getc(stdin);

            c = peekc(stdin);
            if(c == '@')
                {
                getc(stdin);
                return cons(commaat, cons(lisp_read(), nil));
                }
            else
                {
                return cons(comma, cons(lisp_read(), nil));
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
                        signal_error("string greater than 32K");
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

            if(peekc(stdin) == '\\')
                {
                getc(stdin);

                node *n = readident();
                if(n->length == 1)
                    {
                    n->type = chartype;
                    return n;
                    }
                else if(cmp_str(n, "Newline"))
                    {
                    return new node('\n');
                    }
                else if(cmp_str(n, "Space"))
                    {
                    return new node(' ');
                    }
                else if(cmp_str(n, "Tab"))
                    {
                    return new node('\t');
                    }
                else if(cmp_str(n, "Linefeed"))
                    {
                    return new node('\n');
                    }
                else if(cmp_str(n, "Return"))
                    {
                    return new node('\r');
                    }
                else if(cmp_str(n, "Backspace"))
                    {
                    return new node('\b');
                    }
                else
                    {
                    signal_error("illegal character name");
                    }
                }
            else if(peekc(stdin) == '\'')
                {
                getc(stdin);

                return cons(function, cons(lisp_read(), nil));
                }
            else
                {
                return cons(pound, cons(lisp_read(), nil));
                }
            }


        else if(isdigit(c) || c == '-')
            {
            long num;

            if( c== '-')
        		{
                getc(stdin);

        		if(!isdigit(peekc(stdin)))
                	{
        			return minus;
                	}

        		num = -gdec();
        		}
        	else
        		{
        	    num = gdec();
        		}

            if(peekc(stdin) == '/')
                {
                getc(stdin);
                return new node(num, gdec());
                }
            else
                {
                return new node(num);
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

