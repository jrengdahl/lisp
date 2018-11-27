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
                

