/* 
  ____                      _ _       _                  
 / ___|___  _ __ ___  _ __ (_) | __ _| |_ ___ _   _ _ __ 
| |   / _ \| '_ ` _ \| '_ \| | |/ _` | __/ _ \ | | | '__|
| |__| (_) | | | | | | |_) | | | (_| | ||  __/ |_| | |   
 \____\___/|_| |_| |_| .__/|_|_|\__,_|\__\___|\__,_|_|   
                     |_|                                 
 _                                         _  __   __ _      _     _           
| |    __ _ _ __   __ _  __ _  __ _  ___  | |/ /  / _(_) ___| |__ (_) ___ _ __ 
| |   / _` | '_ \ / _` |/ _` |/ _` |/ _ \ | ' /  | |_| |/ __| '_ \| |/ _ \ '__|
| |__| (_| | | | | (_| | (_| | (_| |  __/ | . \  |  _| | (__| | | | |  __/ |   
|_____\__,_|_| |_|\__, |\__,_|\__, |\___| |_|\_\ |_| |_|\___|_| |_|_|\___|_|   
                  |___/       |___/                                            
        
  _   _ 
 | | | |
 | |_| |
(_)__, |
  |___/ 
*/
/* fichier ea.y */
%token <intVal> ENT               
%token <stringVal> ID EQ INFS INFE ET OR TYPE IF ELSE WHILE SEPAR PV ACF ACO ADD MOINS MULT AFF NOT RETURN MAIN  RPAR LPAR SUPS SUPE VOID


%left ADD MOINS
%left MUL 
// Début du programme
%start programme

%{
       #include<stdio.h>
       #include<string.h>
       #include"tabSymb.h"
       int adresse_glob=0;
       int adresse_loc=0;
       int tmp=0;
       int tmpSommet;
       int _context=C_GLO; 
       int param=0;
       int nbline=0;
       int paramAppel=0; 
       extern int lineno; 
       int sommetGlo;

       int functArgs(char* id){
               int i = sommet-1;
              while ( (i>=base) && (strcmp(id,tsymb[i].identif)!=0) )
                     { i=i-1; }
              return i; 
       }
%}

%union{
        int intVal; 
        char* stringVal;    
}

%%
/* Grammaire du langage K */ 
// Liste des arguments d'appel aux fonctions
list: expression {paramAppel++;} listBis; 

listBis: %empty 
       | SEPAR  list  
       ;

listp: %empty
     | list 
     ; 

// Liste des arguments pour les declarations de fonctions
listArgs: VOID
        | listTmp 
       ; 
       
listTmp: TYPE ID {param++;} 
       | TYPE ID  SEPAR listTmp {param++;}
       ;

// Liste des arguments pour les définitions de fonctions 
listArgsDef: VOID
           | {base=sommet;} listTmpDef
           ; 
       
listTmpDef: TYPE ID {
                            if(!existe($2)){
                                   // printf("La variable %s n'existe pas localement dans la table\n",$2);
                                   tmp=base; 
                                   base=0; 
                                   tmpSommet=sommet;
                                   sommet=sommetGlo;
                                   
                                   if(!existe($2)){
                                          // printf("La variable %s n'existe pas globalement non plus, on l'ajoute !\n",$2);
                                          sommet=tmpSommet;
                                          base=tmp;
                                          ajouterEntree($2, _context, T_ENT, adresse_loc++, 0);
                                   }else{
                                          printf("\033[31mLa variable %s a déjà été déclarée dans le contexte global\nErreur déclaration de variable ligne %d.\n\033[0m",$2, lineno-1);
                                          return 0;
                                   }
                            }
                            else{
                                   printf("\033[31mLa variable %s a déjà été déclarée dans le contexte local\nErreur déclaration de variable ligne %d.\n\033[0m",$2, lineno-1);
                                   return 0;
                            }
                     }
          | TYPE ID  {
                            if(!existe($2)){
                                   // printf("La variable %s n'existe pas localement dans la table\n",$2);
                                   tmp=base; 
                                   base=0; 
                                   tmpSommet=sommet;
                                   sommet=sommetGlo;
                                   
                                   if(!existe($2)){
                                          // printf("La variable %s n'existe pas globalement non plus, on l'ajoute !\n",$2);
                                          sommet=tmpSommet;
                                          base=tmp;
                                          ajouterEntree($2, _context, T_ENT, adresse_loc++, 0);
                                   }else{
                                          printf("\033[31mLa variable %s a déjà été déclarée dans le contexte global\nErreur déclaration de variable ligne %d.\n\033[0m",$2, lineno-1);
                                          return 0;
                                   }
                            }
                            else{
                                   printf("\033[31mLa variable %s a déjà été déclarée dans le contexte local\nErreur déclaration de variable ligne %d.\n\033[0m",$2, lineno-1);
                                   return 0;
                            }
                     } SEPAR listTmpDef
          ;

// Liste pour un deuxième type de déclaration de variables 
listVars: ID listBisVars  
                     {
                            if(!existe($1)){
                                   // printf("La variable %s n'existe pas localement dans la table\n",$2);
                                   tmp=base; 
                                   base=0; 
                                   tmpSommet=sommet;
                                    
                                   sommet=sommetGlo;
                                   
                                   if(!existe($1)){
                                          // printf("La variable %s n'existe pas globalement non plus, on l'ajoute !\n",$2);
                                          sommet=tmpSommet;
                                          ajouterEntree($1, _context, T_ENT, adresse_loc++, 0);
                                          base=tmp;
                                          
                                   }else{
                                          printf("\033[31mLa variable %s a déjà été déclarée dans le contexte global\nErreur déclaration de variable ligne %d.\n\033[0m",$1, lineno-1);
                                          return 0;
                                   }
                            }
                            else{
                                   printf("\033[31mLa variable %s a déjà été déclarée dans le contexte local\nErreur déclaration de variable ligne %d.\n\033[0m",$1, lineno-1);
                                   return 0;
                            }
                     }
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
                                          printf("\033[31mLa variable %s existe deja !\nErreur déclaration de variables ligne %d\n\033[0m",$2, lineno); 
                                          return 0;
                                   }
                                   else{
                                          // printf("La variable %s n'existe pas dans le contexte global, on l'ajoute!\n",$2); 
                                          ajouterEntree($2, _context, T_ENT, adresse_glob++, 0); 
                                   }
                            } listDeclarationVar             
                  | TYPE listVars PV listDeclarationVar 
                  ;

/* Liste pour les déclarations de fonctions */ 
listDecFunct: suiteMain
            | listDeclarationFunct listDecFunct 
            ;

listDeclarationFunct: TYPE ID LPAR  listArgs RPAR PV 
                                   {
                                          if(existe($2)){
                                                 printf("\033[31mLa fonction de nom %s existe deja dans le contexte global!\nErreur déclaration de fonctions ligne %d.\n\033[0m",$2,lineno); 
                                                 return 0;
                                          }
                                          else{
                                                 // printf("La fonction de nom %s n'existe pas dans le contexte global, on l'ajoute!\n",$2); 
                                                 ajouterEntree($2, _context, T_ENT, adresse_glob++, param); 
                                          }
                                          param=0;
                                          
                                   }           
                    ; 

/* Lien pour la suite du programme */            
suiteMain: main 
         ; 

suiteFunct: listDecFunct
          ;

instructions: %empty // Pas d'instructions 
            | TYPE listVars PV instructions
            | TYPE ID PV 
                     {
                            if(!existe($2)){
                                   // printf("La variable %s n'existe pas localement dans la table\n",$2);
                                   tmp=base; 
                                   base=0; 
                                   tmpSommet=sommet;
                                    
                                   sommet=sommetGlo;
                                   
                                   if(!existe($2)){
                                          // printf("La variable %s n'existe pas globalement non plus, on l'ajoute !\n",$2);
                                          sommet=tmpSommet;
                                          ajouterEntree($2, _context, T_ENT, adresse_loc++, 0);
                                          base=tmp;
                                          
                                   }else{
                                          printf("\033[31mLa variable %s a déjà été déclarée dans le contexte global\nErreur déclaration de variable ligne %d.\n\033[0m",$2, lineno-1);
                                          return 0;
                                   }
                            }
                            else{
                                   printf("\033[31mLa variable %s a déjà été déclarée dans le contexte local\nErreur déclaration de variable ligne %d.\n\033[0m",$2, lineno-1);
                                   return 0;
                            }
                     } instructions                          
            | ID LPAR listp RPAR PV 
                            {      
                                   tmp = base; 
                                   base = 0; 
                                   tmpSommet=sommet; 
                                   sommet=sommetGlo;
                                   
                                   if(!existe($1)){
                                          printf("\033[31mLa fonction %s appeler n'est pas déclarée !\nErreur d'utilisation de fonction non déclarée ligne %d.\n\033[0m",$1, lineno);
                                          return 0;
                                   }
                                   base = tmp;
                                   sommet=tmpSommet;
                                   // Fonction existe
                                   if(paramAppel != tsymb[functArgs($1)].complement){
                                          printf("\033[36mWarning:La fonction %s attend %d paramètres, vous en avez donné %d ligne %d\n\033[0m",$1,tsymb[functArgs($1)].complement,paramAppel,lineno);
                                   }
                                   paramAppel=0;
                            } instructions                
            | ID AFF expression PV 
                            {
                                   if(!existe($1)){
                                          // printf("La variable que vous voulez modifier n'est pas déclarée localement !\n");
                                          tmp = base; 
                                          base = 0; 
                                          tmpSommet=sommet; 
                                          sommet=sommetGlo;
                                          
                                          if(!existe($1)){
                                                 printf("\033[31mLa variable %s n'est pas déclarée !\nErreur d'utilisation de variable non déclarée ligne %d\n\033[0m",$1,lineno-1);
                                                 return 0;
                                          }
                                          base = tmp;
                                          sommet=tmpSommet;
                                   }
                            } instructions                
            | condition
            | while   
            | retour                  
            ;
// Conditions
while: WHILE LPAR expression RPAR bloc instructions            // {printf(" while avec bloc d'instructions\n");}

condition: IF LPAR expression RPAR bloc { adresse_loc=tmp; } instructions                     // {printf(" if sans else\n");}
         | IF LPAR expression RPAR bloc { adresse_loc=tmp; } ELSE bloc instructions // {printf(" if avec else et blocs d'instructions\n");}

// Bloc d'instructions 
bloc:  ACO {_context=C_LOC; base=sommet; tmp=adresse_loc; adresse_loc=0;  } instructions ACF
    ;

blocFunct: ACO {_context=C_LOC;} instructions ACF
         ;

// Valeur de retour 

retour: RETURN expression PV instructions 
      ;



programme: listDeclarationVar                                  // {printf("je viens de lire une programme\n"); }
         ; 

// Fonction principale 
main: TYPE MAIN LPAR RPAR {sommetGlo=sommet;} bloc {_context=C_GLO; base=0; adresse_loc=tmp; } fonctions
    ;

fonctions: %empty
         | TYPE ID LPAR {_context=C_LOC; base=sommet; adresse_loc=0;} listArgsDef RPAR {      
                                   tmp = base; 
                                   base = 0; 
                                   tmpSommet=sommet; 
                                   sommet=sommetGlo;
                                   if(!existe($2)){
                                          printf("\033[36mWarning: La fonction %s que vous avez définit à la ligne %d n'est pas déclarée\n\033[0m",$2, lineno);
                                   }
                                   base = tmp;
                                   sommet=tmpSommet;
                            } blocFunct fonctions
         ;

expression: expression expressionBis 
          | ENT                                                // {printf(" J'ai lu %d\n",$1);}
          | ID {
                     if(!existe($1)){
                            // printf("La variable %s n'est pas déclarée localement !\n", $1);
                            tmp = base; 
                            base = 0; 
                            tmpSommet=sommet; 
                            sommet=sommetGlo;
                            if(!existe($1)){
                                   printf("\033[31mLa variable %s n'est pas déclarée !\nErreur d'utilisation de variable non déclarée ligne %d\n\033[0m",$1,lineno);
                                   base = tmp;
                                   sommet=tmpSommet;
                                   return 0;
                                   
                            }
                     }
              }                                
          | ID LPAR listp RPAR  
                            {
                                   tmp = base; 
                                   base = 0; 
                                   tmpSommet=sommet; 
                                   sommet=sommetGlo;
                                   if(!existe($1)){
                                          printf("\033[31mLa fonction %s n'est pas déclarée !\nErreur d'utilisation de fonction non déclarée ligne %d.\n\033[0m",$1, lineno-1);
                                          base = tmp;
                                          sommet=tmpSommet;
                                          return 0;
                                   }
                            }
          | LPAR expression RPAR  
          | '!' expression 
          ; 

expressionBis: ADD expression
             | MOINS expression
             | MULT expression
             | EQ expression                                   // {printf(" J'ai lu %s\n",$1);}
             | INFS expression                                 // {printf(" J'ai lu %s\n",$1);}
             | INFE expression                                 // {printf(" J'ai lu %s\n",$1);}
             | SUPE expression
             | SUPS expression
             | ET expression                                   // {printf(" J'ai lu %s\n",$1);}
             | OR expression                                   // {printf(" J'ai lu %s\n",$1);}
             ;


%%
int yyerror(void)
{ 
       printf("\033[31mErreur de syntaxe\nIndications de debugage:\n- Vous avez peut-être oublié \';\' à une instruction sans un bloc précédant la ligne %d\n- Symbole incorrecte à la ligne %d ou dans le bloc précédant la ligne %d\n\033[0m",lineno,lineno,lineno); return 1;
}
