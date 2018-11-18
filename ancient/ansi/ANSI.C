#include <stdio.h>

#define namechar(c) ('0'<=(c)&&(c)<='9' || 'a'<=(c)&&(c)<='z' || 'A'<=(c)&&(c)<='Z' || (c)=='_') 

char *strchr();

char *strstr(s,p)
	char *s,*p;
	{
	int l1;
	int l2;

	l1 = strlen(s);
	l2 = strlen(p);

	while(l1 >= l2)
		{
		if(strncmp(s,p,l2)==0)return(s);
		s++;
		l1--;
		}
	return(0);
	}

void main()
	{
	char line[256];
	char *begin,*end,*comment;
	int linenum=-1;

	while(fgets(line,255,stdin))
		{
		linenum++;
		begin = strchr(line,'(');
		end = strchr(line,')');
		comment = strstr(line,"/*");

		if(line[0]>'A'
		&& begin 
		&& end 
		&& begin<end 
		&& (!comment || comment>begin && comment>end)
		&& strncmp(begin,"(void)",6)==0)
			{
			begin[1]=0;
			printf("%s",line);
			printf("%s",end);
			}
		else if(line[0]>'A'
		&& begin 
		&& end 
		&& begin<end 
		&& (!comment || comment>begin && comment>end)
		&& (end[1] == ';' || end[1] == ','))
			{
			if(end != begin+1)begin[1]=0;
			printf("%s",line);
			if(end != begin+1)printf("%s",end);
			}

		else if(line[0]>'A'
		&& begin 
		&& end 
		&& begin<end 
		&& (!comment || comment>begin && comment>end))
			{
			char *p,*e,*b,*t,*o;
			char tmp[1024];
			char buf[256];
			char scratch[64];

			t = &tmp[0];
			t[0]=0;

			o = &buf[0];
			strncpy(o,line,&begin[1]-&line[0]);
			o += &begin[1]-&line[0];

			b = &begin[0];
			while(b != end)
				{
				e = strchr(b+1,',');
				if(!e)e = end;
				p = e-1;
				while(*p<=' ')p--;
				while(namechar(*p))p--;
				p++;

				strncpy(o,p,e-p+1);
				o += e-p+1;

				p--;
				while(*p<=' ')p--;
				if(p != b)
					{
					sprintf(scratch,"#line %d\n",linenum+1);
					strcpy(t,scratch);
					t += strlen(scratch);
					*t++ = '\t';
					b++;
					while(*b<=' ')b++;
					strncpy(t,b,e-b);
					t += e-b;
					*t++ = ';';
					*t++ = '\n';
					*t=0;
					}
				b = e;
				}				
			strcpy(o,end+1);
			printf("%s",buf);
			printf("%s",tmp);
			}
		else
			{
			printf("%s",line);
			}
		}
	}
