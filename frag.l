/* fichier ea.l */
%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include"frag.tab.h"

    int lineno=1;

    int in(char* string, char c){
        for(int i=0; i<strlen(string);i++){
            if(string[i]==c){
                return 1;
            }

        }
        return 0;
    }
%}
%%

[0-9]+                          {yylval.intVal=atoi(yytext); return ENT;} //Ceci est un test[(){}] {return yytext[0];}
"if"                            {yylval.stringVal=strdup(yytext); return IF;}
"else"                          {yylval.stringVal=strdup(yytext); return ELSE;}
"while"                         {yylval.stringVal=strdup(yytext); return WHILE;}
"int"[" "]                      {yylval.stringVal=strdup(yytext); return TYPE;}
[" "]*"return "[" "]*                      {yylval.stringVal=strdup(yytext); return RETURN;}
"main"                          {yylval.stringVal=strdup(yytext); return MAIN;}
[" "]*","[" "]*                 {yylval.stringVal=strdup(yytext); return SEPAR;}
[" "]*"+"[" "]*                 {yylval.stringVal=strdup(yytext); return ADD;}
[" "]*"-"[" "]*                 {yylval.stringVal=strdup(yytext); return MOINS;}
[" "]*"="[" "]*                 {yylval.stringVal=strdup(yytext); return AFF;}
[" "]*"*"[" "]*                 {yylval.stringVal=strdup(yytext); return MULT;}
[" "\t\n]*";"[" "\t\n]*         {yylval.stringVal=strdup(yytext); if(in(yytext,'\n'))lineno++; return PV;}
[" "\t\n]*"{"[" "\t\n]*         {yylval.stringVal=strdup(yytext); if(in(yytext,'\n'))lineno++; return ACO;}
[" "\t\n]*"}"[" "\t\n]*         {yylval.stringVal=strdup(yytext); if(in(yytext,'\n'))lineno++;return ACF;}
[a-zA-Z0-9]+                    {yylval.stringVal=strdup(yytext); return ID;}
[" "]*"=="[" "]*                {yylval.stringVal=strdup(yytext); return EQ;}
[" "]*"<"[" "]*                 {yylval.stringVal=strdup(yytext);return INFS;}
[" "]*"<="[" "]*                {yylval.stringVal=strdup(yytext);return INFE;}
[" "]*"&&"[" "]*                {yylval.stringVal=strdup(yytext);return ET;}
[" "]*"||"[" "]*                {yylval.stringVal=strdup(yytext);return OR;}   
[" "]*"("[" "]*                 {yylval.stringVal=strdup(yytext);return LPAR;}
[" "]*")"[" "]*                 {yylval.stringVal=strdup(yytext);return RPAR;}                          
[ \t\n] {lineno++;}/* ignore les blancs et tabulations */
. {yylval.stringVal=strdup(yytext); return yytext[0];} /* Gérer les cas d'erreurs */
%%

//Unité lexicale: (nom, valeur) 
/* Si on reconnait x=19 ; on aura comme Lexemes ID EQ NOMBRE PV */
