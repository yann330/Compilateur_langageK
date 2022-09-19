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

%left '+' '-'
%left '*' '/'

%{
    #include<stdio.h>
%}

%union{
        int intVal; 
        char* stringVal; 
}
 
%%
/* Grammaire du langage K */ 

list: expression listBis; 

listBis: %empty 
       | ',' list
       ;

listp: %empty
     | list
     ; 



listArgs: %empty 
       | listTmp
       ; 

listTmp: TYPE ID 
       | TYPE ID  ',' listTmp
       ;


instructions: %empty // Pas d'instructions 
            | TYPE ID '(' listArgs ')' ';' {printf("Ceci est une declaration de la fonction: %s\n",$2); }
            | TYPE ID ';' {printf("Ceci est une declaration de la variable: %s\n",$2); }    
            | ID '=' expression';' {printf("Affectation d'une valeur à la variable %s\n", $1);}
            | '{' instructions '}'
            | IF '(' expression ')' '{' instructions '}' {printf("if sans else\n");}
            | IF '(' expression ')' '{' instructions '}' ELSE '{' instructions '}' {printf("if avec else et blocs d'instructions\n");}
            | WHILE '(' expression ')' '{' instructions '}' {printf("while avec bloc d'instructions\n");}
            ;

 
expression: expression expressionBis  
          | ENT                 {printf("J'ai lu %d\n",$1);}
          | ID                  {printf("J'ai lu %s\n",$1);}
          | ID '(' listp ')' 
          | '(' expression ')'   
          | '!' expression 
          | instructions  
          ; 


expressionBis: '+' expression
             | '-' expression
             | '*' expression
             | EQ expression {printf("J'ai lu %s\n",$1);}
             | INFS expression {printf("J'ai lu %s\n",$1);}
             | INFE expression {printf("J'ai lu %s\n",$1);}
             | ET expression  {printf("J'ai lu %s\n",$1);}
             | OR expression {printf("J'ai lu %s\n",$1);}
             ;







%%
int yyerror(void)
{ fprintf(stderr, "erreur de syntaxe\n"); return 1;}
