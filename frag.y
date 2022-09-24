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
// Début du programme
%start programme

%{
    #include<stdio.h>
    #include<string.h>
    #include"tabSymb.h"
    int adresse_glob=0;
    int adresse_loc=0;
    int tmp=0;
    int _context=C_GLO; 
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
listVars: ID listBisVars  {if(existe($1)){printf("La variable %s existe deja !\nErreur\n",$1); return 0;}else{ajouterEntree($1, _context, T_ENT, adresse_glob++, 0); }}
        ; 

listBisVars: %empty 
       | SEPAR listVars
       ;

listVars: %empty
     | list
     ; 


/* Liste pour les délcarations de variables */ 
listDeclarationVar: suiteFunct
                  | TYPE ID PV 
                            {
                                   if(existe($2)){
                                          printf("La variable %s existe deja !\nErreur déclaration de variables\n",$2); 
                                          return 0;
                                   }
                                   else{
                                          printf("La variable %s n'existe pas dans le contexte global, on l'ajoute!\n",$2); 
                                          ajouterEntree($2, _context, T_ENT, adresse_glob++, 0); 
                                   }
                            } listDeclarationVar             
                  | TYPE listVars PV listDeclarationVar 
                  ;

/* Liste pour les déclarations de fonctions */ 
listDecFunct: suiteMain
            | listDeclarationFunct listDecFunct 
            ;

listDeclarationFunct: TYPE ID LPAR {
                                          if(existe($2)){
                                                 printf("La fonction de nom %s existe deja dans le contexte global!\nErreur déclaration de fonctions.\n",$2); 
                                                 return 0;
                                          }
                                          else{
                                                 printf("La fonction de nom %s n'existe pas dans le contexte global, on l'ajoute!\n",$2); 
                                                 ajouterEntree($2, _context, T_ENT, adresse_glob++, param); 
                                          }
                                          param=0;
                                   } listArgs RPAR PV            
                    ; 

/* Lien pour la suite du programme */            
suiteMain: main 
         ; 

suiteFunct: listDecFunct 
          ; 

instructions: %empty // Pas d'instructions 
            | TYPE ID PV 
                     {
                            if(!existe($2)){
                                   printf("La variable %s n'existe pas localement dans la table\n",$2);
                                   tmp=base; 
                                   base=0; 
                                   if(!existe($2)){
                                          printf("La variable %s n'existe pas globalement non plus, on l'ajoute !\n",$2);
                                          ajouterEntree($2, _context, T_ENT, adresse_loc++, 0);
                                          base=tmp;
                                   }else{
                                          printf("La variable %s a déjà été déclarée dans le contexte global\nErreur déclaration de variable.\n",$2);
                                          return 0;
                                   }
                            }
                            else{
                                   printf("La variable %s a déjà été déclarée dans le contexte local\nErreur déclaration de variable.\n",$2);
                                   return 0;
                            }
                     } instructions                          
            | ID LPAR listp RPAR PV  instructions               
            | ID AFF expression PV {if(!existe($1)){printf("La variable que vous voulez modifier n'est pas déclarée localement !\n"); tmp = base; base = 0; if(!existe($1)){printf("La variable que vous voulez modifier n'est pas déclarée globalement non plus !\n");base = tmp;}else{printf(">>La variable %s est declarée dans le context global\n",$1);}}} instructions                
            | condition
            | while   
            | retour                  
            ;
// Conditions
while: WHILE LPAR expression RPAR bloc instructions            // {printf(" while avec bloc d'instructions\n");}

condition: IF LPAR expression RPAR bloc {base=0; adresse_loc=tmp; } instructions                     // {printf(" if sans else\n");}
         | IF LPAR expression RPAR bloc {base=0; adresse_loc=tmp; } ELSE bloc instructions // {printf(" if avec else et blocs d'instructions\n");}

// Bloc d'instructions 
bloc:  ACO {_context=C_LOC; base=sommet; tmp=adresse_loc; adresse_loc=0;} instructions ACF 

// Valeur de retour 

retour: RETURN expression PV instructions 
      ;



programme: listDeclarationVar                                  // {printf("je viens de lire une programme\n"); }
         ; 

// Fonction principale 
main: TYPE MAIN LPAR RPAR bloc {_context=C_GLO; base=0; adresse_loc=tmp; }
    ;

expression: expression expressionBis 
          | ENT                                                // {printf(" J'ai lu %d\n",$1);}
          | ID                                                 // {printf(" J'ai lu %s\n",$1);}
          | ID LPAR listp RPAR
          | LPAR expression RPAR  
          | '!' expression 
          ; 

expressionBis: ADD expression
             | MOINS expression
             | MULT expression
             | EQ expression                                   // {printf(" J'ai lu %s\n",$1);}
             | INFS expression                                 // {printf(" J'ai lu %s\n",$1);}
             | INFE expression                                 // {printf(" J'ai lu %s\n",$1);}
             | ET expression                                   // {printf(" J'ai lu %s\n",$1);}
             | OR expression                                   // {printf(" J'ai lu %s\n",$1);}
             ;

%%
int yyerror(void)
{ 
       fprintf(stderr, "erreur de syntaxe\n"); return 1;
}
