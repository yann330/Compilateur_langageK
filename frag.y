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
listTmp: TYPE ID {printf("J'ai lu un parametre %s\n",$2);}
       | TYPE ID  SEPAR listTmp {printf("J'ai lu un parametre %s\n",$2);}
       ;


/* Liste pour les délcarations de variables */ 
listDeclarationVar: listDeclarationFunct
                  | TYPE ID PV listDeclarationVar {printf("declaration d'une variable dont le nom est %s\n", $2);}
                  ;

/* Liste pour les déclarations de fonctions */ 
listDeclarationFunct: fonction
                    | TYPE ID '(' listArgs ')' PV listDeclarationFunct {printf("declaration d'une fonction dont le nom est %s\n",$2);}
                    ; 
                    


instructions: %empty // Pas d'instructions 
            | TYPE ID PV instructions  {printf("Ceci est une declaration de la variable: %s\n",$2); }    
            | ID '=' expression PV instructions  {printf("Affectation d'une valeur à la variable %s\n", $1);}
            | IF '(' expression ')' ACO instructions ACF {printf("if sans else\n");}
            | IF '(' expression ')' ACO instructions ACF ELSE ACO instructions ACF instructions {printf("if avec else et blocs d'instructions\n");}
            | WHILE '(' expression ')' ACO instructions ACF instructions {printf("while avec bloc d'instructions\n");}
            ;

 
expression: expression expressionBis 
          | ENT                 {printf("J'ai lu %d\n",$1);}
          | ID                  {printf("J'ai lu %s\n",$1);}
          | ID '(' listp ')' 
          | '(' expression ')'   
          | '!' expression 
          | programme
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
       
fonction: TYPE ID '(' listArgs ')' ACO  instructions ACF  {printf("Ceci est une définition de fonction de type %s et de nom %s\n",$1, $2); return 0; }
        ; 

programme: listDeclarationVar programme 
         | listDeclarationFunct programme
         | fonction {printf("je viens de lire une programme\n"); }
         ; 








     

%%
int yyerror(void)
{ 
       fprintf(stderr, "erreur de syntaxe\n"); return 1;
}
