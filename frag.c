#include<stdio.h>
#include<stdlib.h> 
#include"tabSymb.h"

int d;
int main(void){
    creerTSymb();
    yyparse();
    afficheTSymb();
    return EXIT_SUCCESS; 
}
