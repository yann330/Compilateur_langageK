/* fichier ea.l */
%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include"frag.tab.h"
%}
%%
[0-9]+                      {yylval.intVal=atoi(yytext); return ENT;} //Ceci est un test 
"int"[" "]+                  {yylval.stringVal=strdup(yytext); return TYPE;}
"if"                          {yylval.stringVal=strdup(yytext); return IF;}
"else"                          {yylval.stringVal=strdup(yytext); return ELSE;}
"while"                         {yylval.stringVal=strdup(yytext); return WHILE;}
[a-zA-Z0-9]+  {yylval.stringVal=strdup(yytext); return ID;}
"=="                        {yylval.stringVal=strdup(yytext); return EQ;}
"<"                         {yylval.stringVal=strdup(yytext);return INFS;}
"<="                        {yylval.stringVal=strdup(yytext);return INFE;}
"&&"                        {yylval.stringVal=strdup(yytext);return ET;}
"||"                        {yylval.stringVal=strdup(yytext);return OR;}
[ \t\n]; /* ignore les blancs et tabulations */
. {yylval.stringVal=strdup(yytext); return yytext[0];} /* Gérer les cas d'erreurs */
%%

//Unité lexicale: (nom, valeur) 
/* Si on reconnait x=19 ; on aura comme Lexemes ID EQ NOMBRE PV */
