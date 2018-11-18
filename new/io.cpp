

#if 0
gc:    macro
    jsr getc
    endm
#endif

void pushfile(fb *file)
    {
    *fileptr++ = selget(file);      // select new file, put the old one on the stack
    *flagptr++ = verbose;
    verbose = false;
    prompt = false;
    }

void popfile()
    {
    if(fileptr != &filetable[0])
        {

        close(selget(*--fileptr));
        verbose = *--flagptr;
        prompt = fb.fileno == 1;
        }
    else
        {
        selget(1);
        prompt = true;
        verbose = true;
        printf("(lisp)\n");
        putchar('>');
        }
    }




