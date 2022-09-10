/* fichier ea.y */
%token <intVal> ENT
%token <stringVal> ID
%token <stringVal> EQ
%token <stringVal> INFS
%token <stringVal> INFE
%token <stringVal> ET
%token <stringVal> OR

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
 
expression: expression expressionBis  
          | ENT                 {printf("J'ai lu %d\n",$1);}
          | ID                  {printf("J'ai lu %s\n",$1);}
          | ID '(' listp ')' 
          | '(' expression ')'   
          | '!' expression  
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
