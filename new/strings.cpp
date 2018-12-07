#include <string.h>
#include "lispdefs.h"

bool cmp_str(node *left, node *right)
    {
    if(left->word0 != right->word0)return false;
    if(left->word1 != right->word1)return false;
    if(left->more==0 && right->more==0)return true;

    while(true)
        {
        if(left->word1 != right->word1)return false;
        if(left->word2 != right->word2)return false;
        if(left->next==0 && right->next==0)return true;
        left = left->next;
        right = right->next;
        }
    }


bool cmp_str(node *left, const char *right)
    {
    int len = left->length;
    node *next = left->more;
    char *p = &left->data[0];
    int rem = 8;

    while(len>0)
        {
        if(rem<=0)
            {
            left = next;
            next = left->next;
            p = &left->data[0];
            rem = 16;
            }

        if(*p++ != *right++)return false;
        --len;
        --rem;
        }

    return *right == 0;
    }


