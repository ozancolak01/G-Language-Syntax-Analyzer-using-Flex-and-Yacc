/*Definitions*/
%{
	#include <stdio.h>
	#include <string.h>
	#include <ctype.h>
	#include "gpp_interpreter.h"
	extern YYSTYPE yylval;
	void yyerror(const char *);
%}

/*Rules*/
%%

"and" { return KW_AND; }
"or" {return KW_OR;}
"not" {return KW_NOT;}
"eq" {return KW_EQ;}
"gt" {return KW_GT;}
"set" {return KW_SET;}
"deffun" {return KW_DEFF;}
"defvar" {return KW_DEFV;}
"while" {return KW_WHILE;}
"if" {return KW_IF;}
"exit" {return KW_EXIT;}
"true" {return KW_TRUE;}
"false" {return KW_FALSE;}
"progn" {return KW_PROGN;}

[+] {return OP_PLUS;}
[-] {return OP_MINUS;}
[/] {return OP_DIV;}
[*] {return OP_MULT;}
[(] {return OP_OP;}
[)] {return OP_CP;}
[,] {return OP_COMMA;}
[0-9]*[f][0-9]* {
	char a[10] = "";
	char b[10] = "";
	int i, flag = 0;
	for(i = 0; i < strlen(yytext); i++){
		if(yytext[i] == 'f'){
			flag = 1;
		}
		else{
			if(!flag) strncat(a, &yytext[i], 1);
			else strncat(b, &yytext[i], 1);
		}
	}
	yylval.val = atof(a) / atof(b);
	return VALUEF;
}

[a-zA-Z0-9]*[_][a-zA-Z_]* {strcpy(yylval.id, yytext); return ID;}
[a-zA-Z0-9]*[_][a-zA-Z_0-9]* {yyerror("LEXICAL ERROR Wrong ID input");}
[a-zA-Z0-9]* {strcpy(yylval.id, yytext);return ID;}


[;][;][ a-zA-Z0-9_+-/(){}*&.,]* {return COMMENT;}
[ \t\n\0]+ {}

. {yyerror("LEXICAL ERROR Unknown input");}

%%
int yywrap() {}
