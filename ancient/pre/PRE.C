#include <stdio.h>

#define iswhite(c) ((c)<=' ')
#define isnum(c) ('0'<=(c)&&(c)<='9' || 'a'<=(c)&&(c)<='z' || 'A'<=(c)&&(c)<='Z')
#define issym(c) ('0'<=(c)&&(c)<='9' || 'a'<=(c)&&(c)<='z' || 'A'<=(c)&&(c)<='Z' \
	|| (c)=='_' || (c)=='$' || (c)=='?')
#define isstart(c) ('a'<=(c)&&(c)<='z' || 'A'<=(c)&&(c)<='Z' \
	|| (c)=='_' || (c)=='$' || (c)=='?')

typedef struct
	{
	char sym[32];
	char *def;
	}SYM;

SYM symtab[500]={0};
int nsym = 0;


int unchar=0;

char *malloc();


error(s)
	char *s;
	{
	printf("%s\n",s);
	fprintf(stderr,"%s\n",s);
	}


int gtc()
	{
	int tmp;

	if(unchar)
		{
		tmp=unchar;
		unchar=0;
		return(tmp);
		}		
	else return(getchar());
	}

int peekc()
	{
	return(unchar=gtc());
	}



/* the following is a pipelined input stream, with multiple filters */

/* first filter out single quoted strings */

int getnostr()
	{
	int c;

	while((c=gtc()) == '\'')
		{
		putchar(c);
		while((c=gtc())!= EOF && c!='\'' && c!='\n')putchar(c);
		putchar(c);
		}
	return(c);
	}


/* then filter out double quoted strings */

int getnobkt()		/* on the Amiga, strings are delimited by < > */
	{
	int c;

	while((c=getnostr()) == '"')
		{
		putchar(c);
		while((c=gtc())!= EOF && c!='"' && c!='\n')putchar(c);
		putchar(c);
		}
	return(c);
	}


/* then filter out comments */

int getnocom()	
	{
	int c;

	while((c=getnobkt()) == ';')
		{
		putchar(c);
		while((c=gtc())!= EOF && c!=10)putchar(c);
		putchar(c);
		}
	return(c);
	}




/* then take care of definitions */

int getdef()	
	{
	int c;
	static char last = '\n';
	char *d;

	while(1)
		{
		c=getnocom();
		if(last == '\n' && c=='#')
			{
			int i;
	
			putchar(';');

			i=0;
			while((c=gtc())!=EOF && issym(c))
				{
				putchar(c);
				symtab[nsym].sym[i++] = c;
				}
			symtab[nsym].sym[i]=0;
			putchar(c);
	
			
			symtab[nsym].def = d = malloc(512);
			while((c=gtc())!=EOF && (c!='\n' || last=='\\'))
				{
				putchar(c);
				if(c=='\n' && last=='\\')
					{
					d[-1]=c;
					putchar(';');
					}
				else *d++ = c;
				last = c;
				}
			*d=0;

			nsym++;

/*printf("\n%d %s %s\n",nsym,&symtab[nsym-1].sym,symtab[nsym-1].def);
*/

			last = c;
			if(c!=EOF)putchar(c);
			}
		else
			{
			last = c;
			return(c);
			}
		}
	}


main(argc,argv)
	int argc;
	char **argv;
	{
	char buffer[256];
        int i;
        int c;
        int cnt;
        int sym;
	int last=0;

	if(argc != 3)
		{
		printf("usage: sym <infile> <outfile>\n");
		exit(0);
		}
	else
		{
		if(freopen(argv[1],"r",stdin)==0)
			{
			printf("could not open %s\n",argv[1]);
			exit(0);
			}
 		if(freopen(argv[2],"w",stdout)==0)
			{
			printf("could not open %s\n",argv[2]);
			exit(0);
			}

		while((c=getdef())!=EOF)
                	{
			if(isstart(c))
				{
				cnt=0;
				buffer[cnt++]=c;
				while((c=gtc())!=EOF && issym(c))
					{
					buffer[cnt++]=c;
					}
				buffer[cnt]=0;

				sym=0;
				while(sym<nsym)
					{
/*printf("\n%s == %s [%d]?\n",buffer,&symtab[sym].sym,sym);
*/					if(strcmp(buffer,&symtab[sym].sym)==0)
						{
/*						if(last=='#' || last=='+' || last=='-' || c=='(' || c=='+' || c=='-')putchar('_');
*/						printf("%s",symtab[sym].def);
						cnt=0;
						break;
						}
					else sym++;
					}

				i=0;
				while(i<cnt)putchar(buffer[i++]);
				cnt=0;
				if(c!=EOF)putchar(c);
				last=c;
				}
			else if(isnum(c))
				{
				putchar(c);
				while((c=getdef())!=EOF && issym(c))
					{
					putchar(c);
					}
				if(c!=EOF)putchar(c);
				last=c;
				}
			else
				{
				putchar(c);
				last=c;
				}
                	}
		}
	return(0);
	}

