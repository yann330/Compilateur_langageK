#include<stdio.h>
#include<stdlib.h> 
#include"tabSymb.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(void){
    creerTSymb();
    yyparse();
    afficheTSymb();
    return EXIT_SUCCESS; 
}
