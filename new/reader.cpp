#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "lispdefs.h"
#include "io.h"

bool prompt = true;

extern node nil;


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
            exit(0);
            }

        else if(c=='\n')
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

            node *first = &nil;
            node *last = &nil;

            while(true)
                {
                node *n;

                while(isspace(c=peekc(stdin)))
                    {
                    getc(stdin);
                    }

                if(c < 0)
                    {
                    printf("unexpected end of input\n");
                    exit(0);
                    }

                if(c == ')')break;

                n = new(&nil, &nil);
                if(first == &nil)first = n;
                else last->cdr = n;
                last = n;
                n->car = lisp_read();
                }
                
                
    cmp.b    #'''',d0
    beq        rdquote
    cmp.b    #'`',d0
    beq        rdbackquote
    cmp.b    #',',d0
    beq        rdcomma
    cmp.b    #'"',d0
    beq        rdstring
    cmp.b    #'#',d0
    beq        rdmacro
    cmp.b    #'-',d0
    beq        rdminus
    jsr        isdigit
    beq        rdnum
    bra        rdsym

rdret:
    unlkm    a1/a2
    pop.l    d0
    rts


rdminus:
    gc
    jsr        isdigit
    if_ne.s
        xref pminus
        move.l pminus,a0
        bra rdret
    else
        jsr gdec
        neg.l d0
        bra.s rdcom
    end

rdnum:
    jsr        gdec
rdcom:
    newnode    a0
    move.l    #numtype*65536,(a0)
    move.l    d0,numerator(a0)
    jsr        peekc
    cmp.b    #'/',d0
    if_eq.s
        gc
        jsr gdec
        move.l d0,denominator(a0)
        move.w #rattype,(a0)
    else
        move.l #1,denominator(a0)
    end

    bra    rdret


rdquote:
    gc
    jsr        lisp_read
    newnode    a1
    move.l    #constype*65536,(a1)
    move.l    d6,cdr(a1)
    move.l    a0,car(a1)
    newnode    a0
    move.l    #constype*65536,(a0)
    move.l    a1,cdr(a0)
    xref    quote
    move.l    quote,car(a0)
    bra    rdret

rdbackquote:
    gc
    jsr        lisp_read

    newnode    a1
    move.l    #constype*65536,(a1)
    move.l    d6,cdr(a1)
    move.l    a0,car(a1)

    newnode    a0
    move.l    #constype*65536,(a0)
    move.l    quote,car(a0)
    move.l    a1,cdr(a0)

    newnode    a1
    move.l    #constype*65536,(a1)
    move.l    d6,cdr(a1)
    move.l    a0,car(a1)

    newnode    a0
    move.l    #constype*65536,(a0)
    move.l    a1,cdr(a0)
    xref    bquote
    move.l    bquote,car(a0)
    bra    rdret

rdcomma:
    xref        cmma,commaat
    gc
    jsr        peekc
    cmp.b    #'@',d0
    if_ne.s
        jsr        lisp_read
        newnode    a1
        move.l    #constype*65536,(a1)
        move.l    d6,cdr(a1)
        move.l    a0,car(a1)
        newnode    a0
        move.l    #constype*65536,(a0)
        move.l    cmma,car(a0)
        move.l    a1,cdr(a0)
    else
        gc
        jsr        lisp_read
        newnode    a1
        move.l    #constype*65536,(a1)
        move.l    d6,cdr(a1)
        move.l    a0,car(a1)

        newnode    a0
        move.l    #constype*65536,(a0)
        move.l    commaat,car(a0)
        move.l    a1,cdr(a0)
    end
    bra    rdret

    xref    function,pound
rdmacro:
    gc
    jsr        peekc
    cmp.b    #'''',d0
    if_eq.s
        gc
        jsr    lisp_read
        newnode    a1
        move.l    #constype*65536,(a1)
        move.l    d6,cdr(a1)
        move.l    a0,car(a1)
        newnode    a0
        move.l    #constype*65536,(a0)
        move.l    function,car(a0)
        move.l    a1,cdr(a0)
    else
        jsr        lisp_read
        newnode    a1
        move.l    #constype*65536,(a1)
        move.l    d6,cdr(a1)
        move.l    a0,car(a1)

        newnode    a0
        move.l    #constype*65536,(a0)
        move.l    pound,car(a0)
        move.l    a1,cdr(a0)
    end
    bra    rdret


rdsym:
    jsr    readident
    xref    get_symbol
    jsr    get_symbol
    xref    pseudo_nil
    cmp.l    pseudo_nil,a0
    if_eq.s
        move.l d6,a0
    end
    bra    rdret

rdstring:
    gc
    jsr    readstr
    jsr    peekc
    cmp.b    #'"',d0
    if_eq.s
        gc
    else
        message <illegal string termination>
        signal_error
    end
    bra    rdret    


readstr:
    stackcheck readstr
    pushm.l    d0/d1/d2
    linkm    a1/a2

    newnode    a0
    move.l    a0,a2
    clr.l    4(a0)
    clr.l    8(a0)
    lea        str_more(a0),a1
    move.l    #strtype*65536,(a0)+

    move.w    #4,d1
    clr.l    d2

    loop
        jsr peekc
        cmp.l #-1,d0
        while_ne
        cmpi.b #'"',d0
        while_nz

        tst.w d1
        if_eq.s
            move.l d6,a0
            newnode a0
            move.l a0,(a1)
            move.l a0,a1
            clr.l 4(a0)
            clr.l 8(a0)
            clr.l (a0)+    
            move.w #8,d1
        end
    
        gc
        move.b d0,(a0)+
        subq.w #1,d1
        addq.w #1,d2
        if_mi
            message <string greater than 32K>
            signal_error
        end
    end

    move.w    d2,str_length(a2)
    move.l    a2,a0
    unlkm    a1/a2
    popm.l    d0/d1/d2
    rts


readident:
    stackcheck readident
    pushm.l    d0/d1/d2
    linkm    a1/a2

    newnode    a0
    move.l    a0,a2
    clr.l    4(a0)
    clr.l    8(a0)
    lea        str_more(a0),a1
    move.l    #strtype*65536,(a0)+

    move.w    #4,d1
    clr.l    d2

    loop
        jsr isalpha
        if_ne
          jsr isdigit
          if_ne
            jsr iswhite
            if_eq
              break
            else
              jsr peekc
              cmp.l #-1,d0
                      if_eq.s
                        break
                      end
              cmpi.b #'"',d0
                if_eq.s
                  break
                else
                cmpi.b #'''',d0
                if_eq.s
                  break
                else
                cmpi.b #'(',d0
                if_eq.s
                  break
                else
                cmpi.b #')',d0
                if_eq.s
                  break
                else
                cmpi.b #';',d0
                if_eq.s
                  break
                else
                cmpi.b #'`',d0
                if_eq.s
                  break
                else
                cmpi.b #',',d0
                if_eq.s
                  break
                end
                end
                end
                end
                end
                end
                end
            end
          end
        end

        tst.w d1
        if_eq.s
            move.l d6,a0
            newnode a0
            move.l a0,(a1)
            move.l a0,a1
            clr.l 4(a0)
            clr.l 8(a0)
            clr.l (a0)+    
            move.w #8,d1
            end
    
        gc
        move.b d0,(a0)+
        subq.w #1,d1
        addq.w #1,d2
        if_mi
            message <string greater than 32K>
            signal_error
        end
    end

    move.w    d2,str_length(a2)
    move.l    a2,a0
    unlkm    a1/a2
    popm.l    d0/d1/d2
    rts


l_read:
    jsr    lisp_read
    unlkm a1-a5
    rts
    

    xdef    prompt,verbose
    .data
filetable:    ds.l        32
ftend:        ds.l        0
fileptr:    ds.l        1
filename:    ds.l        32
flagtable:    ds.b        32
flagptr:    ds.l        1
prompt:        ds.b        1
verbose:    ds.b        1

    .code
    xdef        init_files
init_files:
; message <init_files>
    move.l #filetable,fileptr
    move.l #flagtable,flagptr

    jsr selget                ;fudge an initial newline to get
    move.l a0,a1                ;the first prompt
    jsr selget
    move.l #10,nextc(a1)

    move.l a1,d1                ;don't echo if reading file
    doscall IsInteractive
    tst.l d0
    if_nz.s
        move.b #1,verbose
    else
        move.b #0,verbose
    end

; message <open lisp.lsp>
    string <lisp.lsp>,a0            ;try to open "lisp.lsp"
    jsr fropen
; message <back>
    cmp.l #0,a0
    if_ne                    ;it its there
        jsr pushfile
    else
        message <Cant find lisp.lsp>
        xref exit
        jmp exit
    end

    move.l d6,a0
    move.l d6,a1
    rts



load:
; message <load>
    cmp.l #ftend,fileptr            ;see if overflowed
    if_eq
        message <too many nested LOADs>
        signal_error
    end

    move.l car(a1),a0            ;get the filename
    cmp.w #symtype,(a0)
    if_eq.s
        move.l sym_more(a0),a0
        move.l sym_name(a0),a0
    end
    cmp.w #strtype,(a0)
    if_ne
        message <load arg not a file name>
        signal_error
    end

    move.l #filename,a1            ;convert to C string
    xref    string2c
    jsr    string2c

    move.l #filename,a0            ;try to open the file
    jsr fropen
    cmp.l #0,a0
    if_z                        ;if can't; complain about it
        print <Cant open file >
        move.l #filename,a0
        jsr pstring
        newline
        signal_error
    end

    jsr pushfile

    unlkm a1-a5
    rts


.pound:
    follow a1,a0
    unlkm a1-a5
    rts

quiet:
    move.b #0,verbose
    move.l d6,a0
    unlkm a1-a5
    rts

readchar:
    gc
    newnode a0
    move.l #numtype*65536,(a0)
    move.l d0,numerator(a0)
    move.l #1,denominator(a0)
    unlkm a1-a5
    rts

peekchar:
    jsr peekc
    newnode a0
    move.l #numtype*65536,(a0)
    move.l d0,numerator(a0)
    move.l #1,denominator(a0)
    unlkm a1-a5
    rts

    xdef        init_reader
init_reader:
    primitive    load
    primitive    quiet
    primitive    read,l_read
    primitive    pound,.pound
    primitive    <read-char>,readchar
    primitive    <peek-char>,peekchar
    rts

    end
