/* fichier ea.y */
%token <intVal> ENT
%token <stringVal> ID
%token <stringVal> EQ
%token <stringVal> INFS
%token <stringVal> INFE
%token <stringVal> ET
%token <stringVal> OR
%token <stringVal> TYPE
%token <stringVal> IF
%token <stringVal> ELSE
%token <stringVal> WHILE
%token <stringVal> SEPAR
%token <stringVal> PV
%token <stringVal> ACF
%token <stringVal> ACO
%token <stringVal> LPAR
%token <stringVal> RPAR
%token <stringVal> ADD MOINS MULT AFF NOT RETURN MAIN






%left '+' '-'
%left '*' '/'
%start programme
// %start programme
%{
    #include<stdio.h>
    #include<string.h>
    #include"tabSymb.h"
    int adresse_glob=0;
    int param=0;
%}

%union{
        int intVal; 
        char* stringVal;    
}

%%
/* Grammaire du langage K */ 


// Liste des arguments d'appel aux fonctions
list: expression listBis; 
listBis: %empty 
       | SEPAR list
       ;
listp: %empty
     | list
     ; 

// Liste des arguments pour les declarations de fonctions
listArgs: %empty 
       | listTmp
       ; 
       
listTmp: TYPE ID {param++;}
       | TYPE ID  SEPAR listTmp {param++;}
       ;

// Liste pour un deuxième type de déclaration de variables 
listVars: ID listBisVars  {if(existe($1)){printf("La variable %s existe deja !\nErreur\n",$1); return 0;}else{ajouterEntree($1, T_ENT, T_ENT, adresse_glob++, 0); }}
        ; 
listBisVars: %empty 
       | SEPAR listVars
       ;
listVars: %empty
     | list
     ; 


/* Liste pour les délcarations de variables */ 
listDeclarationVar: listDecFunct
                  | TYPE ID PV listDeclarationVar {if(existe($2)){printf("La variable %s existe deja !\nErreur\n",$2); return 0;}else{ajouterEntree($2, T_ENT, T_ENT, adresse_glob++, 0); }}
                  | TYPE listVars PV listDeclarationVar 
                  ;

/* Liste pour les déclarations de fonctions */ 
listDecFunct: main
            | listDeclarationFunct listDecFunct 
            ;
listDeclarationFunct: TYPE ID LPAR listArgs RPAR PV {if(existe($2)){printf("La variable %s existe deja !\nErreur\n",$2); return 0;}else{ajouterEntree($2, C_FON, T_ENT, adresse_glob++, param); }param=0;}
                    ; 
                    


instructions: %empty // Pas d'instructions 
            | TYPE ID PV instructions  {printf(" Ceci est une declaration de la variable: %s\n",$2); } 
            | ID LPAR listp RPAR PV instructions    {printf(" Ceci est un appel de fonction de nom: %s\n",$1); }
            | ID AFF expression PV instructions  { printf(" Affectation d'une valeur à la variable %s\n", $1);}
            | IF LPAR expression RPAR ACO instructions ACF {printf(" if sans else\n");}
            | IF LPAR expression RPAR ACO instructions ACF ELSE ACO instructions ACF instructions {printf(" if avec else et blocs d'instructions\n");}
            | RETURN expression PV
            | WHILE LPAR expression RPAR ACO instructions ACF instructions {printf(" while avec bloc d'instructions\n");}
            ;

 
expression: expression expressionBis 
          | ENT                 {printf(" J'ai lu %d\n",$1);}
          | ID                  {printf(" J'ai lu %s\n",$1);}
          | ID LPAR listp RPAR
          | LPAR expression RPAR  
          | '!' expression 
          ; 


expressionBis: ADD expression
             | MOINS expression
             | MULT expression
             | EQ expression {printf(" J'ai lu %s\n",$1);}
             | INFS expression {printf(" J'ai lu %s\n",$1);}
             | INFE expression {printf(" J'ai lu %s\n",$1);}
             | ET expression  {printf(" J'ai lu %s\n",$1);}
             | OR expression {printf(" J'ai lu %s\n",$1);}
             ;


programme: listDeclarationVar {printf("je viens de lire une programme\n"); }
         ; 

main: TYPE MAIN LPAR RPAR ACO instructions ACF
    ;

%%
int yyerror(void)
{ 
       fprintf(stderr, "erreur de syntaxe\n"); return 1;
}
