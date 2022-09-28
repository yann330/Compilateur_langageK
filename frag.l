
%{
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
   _ 
  | |
  | |
 _| |
(_)_|
     
*/
    
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include"frag.tab.h"

    int lineno=1;
    int cpt;
    extern int error; 

    int in(char* string, char c){
        int cpt=0;
        for(int i=0; i<strlen(string);i++){
            if(string[i]==c){
                cpt++;
            }
        }
        return cpt;
    }
%}
%%
[0-9]+                          {yylval.intVal=atoi(yytext); return ENT;} //Ceci est un test[(){}] {return yytext[0];}
"if"                            {yylval.stringVal=strdup(yytext); return IF;}
"else"                          {yylval.stringVal=strdup(yytext); return ELSE;}
"while"                         {yylval.stringVal=strdup(yytext); return WHILE;}
"int"[" "]                      {yylval.stringVal=strdup(yytext); return TYPE;}
[" "]*"return "[" "]*           {yylval.stringVal=strdup(yytext); return RETURN;}
"main"                          {yylval.stringVal=strdup(yytext); return MAIN;}
"void"                          {yylval.stringVal=strdup(yytext); return VOID;}
[" "]*","[" "]*                 {yylval.stringVal=strdup(yytext); return SEPAR;}
[" "]*"+"[" "]*                 {yylval.stringVal=strdup(yytext); return ADD;}
[" "]*"-"[" "]*                 {yylval.stringVal=strdup(yytext); return MOINS;}
[" "]*"="[" "]*                 {yylval.stringVal=strdup(yytext); return AFF;}
[" "]*"*"[" "]*                 {yylval.stringVal=strdup(yytext); return MULT;}
[" "\t\n]*";"[" "\t\n]*         {yylval.stringVal=strdup(yytext); if(cpt=in(yytext,'\n')){lineno=lineno+cpt;} cpt=0;return PV;}
[" "\t\n]*"{"[" "\t\n]*         {yylval.stringVal=strdup(yytext); if(cpt=in(yytext,'\n')){lineno=lineno+cpt;} cpt=0;return ACO;}
[" "\t\n]*"}"[" "\t\n]*         {yylval.stringVal=strdup(yytext); if(cpt=in(yytext,'\n')){lineno=lineno+cpt;} cpt=0;return ACF;}
[a-zA-Z0-9_]+                    {yylval.stringVal=strdup(yytext); return ID;}
[" "]*"=="[" "]*                {yylval.stringVal=strdup(yytext); return EQ;}
[" "]*"<"[" "]*                 {yylval.stringVal=strdup(yytext);return INFS;}
[" "]*">"[" "]*                 {yylval.stringVal=strdup(yytext);return SUPS;}
[" "]*">="[" "]*                 {yylval.stringVal=strdup(yytext);return SUPE;}
[" "]*"<="[" "]*                {yylval.stringVal=strdup(yytext);return INFE;}
[" "]*"&&"[" "]*                {yylval.stringVal=strdup(yytext);return ET;}
[" "]*"||"[" "]*                {yylval.stringVal=strdup(yytext);return OR;}   
[" "]*"("[" "]*                 {yylval.stringVal=strdup(yytext);return LPAR;}
[" "]*")"[" "]*                 {yylval.stringVal=strdup(yytext);return RPAR;}                    
[ \t\n]; /* ignore les blancs et tabulations */
. {yylval.stringVal=strdup(yytext); return yytext[0];} /* Gérer les cas d'erreurs */
%%


