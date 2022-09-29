/* ____                      _ _       _                  
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

%token <intVal> ENT               
%token <stringVal> ID EQ INFS INFE ET OR TYPE IF ELSE WHILE SEPAR PV ACF ACO ADD MOINS MULT AFF NOT RETURN MAIN  RPAR LPAR SUPS SUPE VOID


%left ADD MOINS
%left MULT
%left '!' EQ ET OR  
%left INFS INFE SUPS SUPE

// Début du programme
%start programme

%{
       #include<stdio.h>
       #include<string.h>
       #include"tabSymb.h"
       #include <sys/types.h>
       #include <sys/stat.h>
       #include <fcntl.h>

       int adresse_glob=0;
       int adresse_loc=0;
       int tmp=0;
       int tmpSommet;
       int _context=C_GLO; 
       int _contextTmp;
       int param=0;
       int nbline=0;
       int paramAppel=0; 
       extern int lineno; 
       int sommetGlo;
       char buffer[256];

       int functArgs(char* id){
               int i = sommet-1;
              while ( (i>=base) && (strcmp(id,tsymb[i].identif)!=0) )
                     { i=i-1; }
              return i; 
       }
       int testContextGlobID(char* id){
              tmp=base; 
              base=0;
              for(int i=base; i<sommet; i++){
                     if(strcmp(tsymb[i].identif,id)==0){
                            base=tmp;
                            return tsymb[i].classe==C_GLO;
                     }
              }
              
       }
       int verifDeclarationVar(char* id){
              if(!existe(id)){
                     ajouterEntree(id, _context, T_ENT, adresse_loc++, 0);
                     return 1;
              }
              else{
                     printf("\033[31mLa variable %s a déjà été déclarée dans le contexte local\nErreur déclaration de variable ligne %d.\n\033[0m",id, lineno-1);
                     return 0;
              }
       }
       int verifDeclarationFunctGlobal(char* id){
              if(existe(id)){
                     printf("\033[31mLa fonction de nom %s existe deja dans le contexte global!\nErreur déclaration de fonctions ligne %d.\n\033[0m",id,lineno); 
                     return 0;
              }
              else{
                     ajouterEntree(id, _context, T_ENT, adresse_glob++, param); 
              }
       }
       int verifAppelFunct(char* id){
              tmp = base; 
              base = 0; 
              tmpSommet=sommet; 
              sommet=sommetGlo;
              if(!existe(id)){
                     printf("\033[31mLa fonction %s appelée n'est pas déclarée !\nErreur d'utilisation de fonction non déclarée ligne %d.\n\033[0m",id, lineno-1);
                     return 0;
              }
              base = tmp;
              sommet=tmpSommet;
              return 1;
       }
       void warningParamFunct(char* id){
              if(paramAppel != tsymb[functArgs(id)].complement){
                     printf("\033[36mWarning:La fonction %s attend %d paramètres, vous en avez donné %d ligne %d\n\033[0m",id,tsymb[functArgs(id)].complement,paramAppel,lineno-1);
              }
       }
       int verifUtilVar(char* id){
              if(!existe(id)){
                     tmp = base; 
                     base = 0; 
                     if(!existe(id)){
                            printf("\033[31mLa variable %s n'est pas déclarée !\nErreur d'utilisation de variable non déclarée ligne %d\n\033[0m",id,lineno-1);
                            return 0;
                     }
                     base = tmp;
              }
       }
       
       void warningDefFunct(char* id){
              tmp = base; 
              base = 0; 
              tmpSommet=sommet; 
              sommet=sommetGlo;
              if(!existe(id)){
                     printf("\033[36mWarning: La fonction %s que vous avez définit à la ligne %d n'est pas déclarée\n\033[0m",id, lineno);
              }
              base = tmp;
              sommet=tmpSommet;
       }
       void genCodeENT(int ent){
              printf("\033[33mCode: pushq $%d\n\033[0m",ent);
       }
       int verifUtilVarlocal(char* id){
              if(!existe(id)){
                     tmp = base; 
                     base = 0; 
                     tmpSommet=sommet; 
                     sommet=sommetGlo;
                     if(!existe(id)){
                            printf("\033[31mLa variable %s n'est pas déclarée !\nErreur d'utilisation de variable non déclarée ligne %d\n\033[0m",id,lineno);
                            base = tmp;
                            sommet=tmpSommet;
                            return 0;
                     }
              }
              return 1;
       }
       void genCodeID(char* id){
              printf("\033[33mCode: pushq $%s\n\033[0m",id);
       }
       void genCodeAffectation(char* label){
              printf("\033[33mCode: popq %%rdi\n");
              printf("Code: movq %%rdi, ($%s)\n\033[0m",label);
       }
       void genCodeNot(){
              printf("\033[33mCode: popq %%rsi\n");
              printf("Code: notq %%rsi\n\033[0m");
       }
       void genCodeOP(char* op){
              if(strcmp(op,"+")==0){
                     printf("\033[33mCode: popq %%rsi\n");
                     printf("Code: popq %%rdi\n");
                     printf("Code: addq %%rsi %%rdi\n");
                     printf("Code: pushq %%rdi\n\033[0m");
              }
              else if(strcmp(op,"-")==0){
                     printf("\033[33mCode: popq %%rsi\n");
                     printf("Code: popq %%rdi\n");
                     printf("Code: subq %%rsi %%rdi\n");
                     printf("Code: pushq %%rdi\n\033[0m");
              }
              else if(strcmp(op,"*")==0){
                     printf("\033[33mCode: popq %%rsi\n");
                     printf("Code: popq %%rdi\n");
                     printf("Code: mulq %%rsi %%rdi\n");
                     printf("Code: pushq %%rdi\n\033[0m");
              }
              else if(strcmp(op,"&&")==0){
                     printf("\033[33mCode: popq %%rsi\n");
                     printf("Code: popq %%rdi\n");
                     printf("Code: andq %%rsi %%rdi\n");
                     printf("Code: pushq %%rdi\n\033[0m");
              }
              else if(strcmp(op,"||")==0){
                     printf("\033[33mCode: popq %%rsi\n");
                     printf("Code: popq %%rdi\n");
                     printf("Code: orq %%rsi %%rdi\n");
                     printf("Code: pushq %%rdi\n\033[0m");
              }
       }
       void genCodeVars(char* id){
              if(_context==C_GLO)
                     printf("\033[33mCode: %s:  .zero 8\n\033[0m",id);
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
       
listTmp: TYPE ID listTmpBis {param++;}
       ;
listTmpBis: %empty
          | SEPAR listTmp
          ;

// Liste des arguments pour les définitions de fonctions 
listArgsDef: VOID
           | {base=sommet;} listTmpDef
           ; 

listTmpDef: TYPE ID {
                            if(verifDeclarationVar($2)==0){
                                   return 0;
                            }
                     }
          | TYPE ID  {
                            if(verifDeclarationVar($2)==0){
                                   return 0;
                            }   
                     } SEPAR listTmpDef
          ;

// Liste pour un deuxième type de déclaration de variables 
listVars: ID {
                     if(verifDeclarationVar($1)==0){
                            return 0;
                     }
                     genCodeVars($1);
              }
     | ID {
              if(verifDeclarationVar($1)==0){
                     return 0;
              }
              genCodeID($1);
       } SEPAR listVars
     ; 


/* Liste pour les délcarations de variables */ 
listDeclarationVar: listDecFunct             
                  | TYPE listVars PV listDeclarationVar 
                  ;

/* Liste pour les déclarations de fonctions */ 
listDecFunct: main
            | listDeclarationFunct listDecFunct 
            ;

listDeclarationFunct: TYPE ID LPAR  listArgs RPAR PV 
                                   {
                                          if(verifDeclarationFunctGlobal($2)==0){
                                                 return 0;
                                          }
                                          param=0;   
                                   }           
                    ; 
           
instructions: %empty // Pas d'instructions 
            | TYPE listVars PV instructions                         
            | ID LPAR listp RPAR PV 
                            {      
                                   if(verifAppelFunct($1)==0)
                                          return 0;
                                   warningParamFunct($1);
                                   paramAppel=0;
                            } instructions                
            | ID AFF expression PV 
                            {
                                   verifUtilVar($1);
                                   genCodeAffectation($1);
                            } instructions                
            | condition
            | while   
            | retour                  
            ;
// Conditions
while: WHILE LPAR expression RPAR bloc instructions            

condition: IF LPAR expression RPAR  bloc {_contextTmp=_context;adresse_loc=tmp; } instructions                     
         | IF LPAR expression RPAR bloc {adresse_loc=tmp;} ELSE bloc {_contextTmp=_context;adresse_loc=tmp;}  instructions 

// Bloc d'instructions 
bloc:  ACO { tmp=adresse_loc; adresse_loc=0;  } instructions ACF
    ;

blocFunct: ACO {_context=C_LOC;} instructions ACF
         ;




retour: RETURN expression PV instructions 
      ;

programme: listDeclarationVar                                  
         ; 

// Fonction principale 
main: TYPE MAIN LPAR RPAR {sommetGlo=sommet;} bloc {base=0; adresse_loc=tmp; } fonctions
    ;

// Définition des fonctions 
fonctions: %empty
         | TYPE ID LPAR {_context=C_LOC; base=sommet; adresse_loc=0;} listArgsDef RPAR {warningDefFunct($2);} blocFunct fonctions
         ;

expression: expression expressionBis 
          | ENT              {genCodeENT($1);}                                   
          | ID {
                     if(verifUtilVarlocal($1)==0)
                            return 0; 
                     genCodeID($1);
              }                                
          | ID LPAR listp RPAR  
                            {
                                   verifAppelFunct($1);
                            }
          | LPAR expression RPAR  
          | '!' expression {
                               genCodeNot();   
                            }
          ; 

expressionBis: ADD expression                          {genCodeOP($1);}
             | MOINS expression                        {genCodeOP($1);}
             | MULT expression                         {genCodeOP($1);}
             | EQ expression                                   
             | INFS expression                                 
             | INFE expression                                 
             | SUPE expression
             | SUPS expression
             | ET expression                            {genCodeOP($1);}
             | OR expression                            {genCodeOP($1);}
             ;


%%
int yyerror(void)
{ 
       printf("\033[31mErreur de syntaxe\nIndications de debugage:\n- Vous avez peut-être oublié \';\' à une instruction à la ligne %d ou dans un bloc précédant cette dernière %d\n- Symbole incorrecte à la ligne %d ou dans le bloc précédant la ligne %d\n\033[0m",lineno,lineno,lineno,lineno); return 1;
}
