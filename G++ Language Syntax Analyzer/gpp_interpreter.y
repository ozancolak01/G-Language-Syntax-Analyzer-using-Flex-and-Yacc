%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "gpp_interpreter.h"

    int yylex(void);
    void yyerror(const char *);
    float findID(char*);
    float setID(char*, float);
    float defineID(char*, float);
    void init();
    extern FILE *yyin;


    typedef struct Identifier{
        char id[20];
        float value;
    }Identifier;

    typedef struct IdentifierList{
        int size;
        Identifier* ids;
    }IdentifierList;

%}
%union {
    char id[20];
    float val;
}


%token KW_AND KW_OR KW_NOT KW_EQ KW_GT KW_SET KW_DEFV 
%token KW_DEFF KW_WHILE KW_IF KW_EXIT KW_TRUE KW_FALSE KW_PROGN
%token OP_PLUS OP_MINUS OP_DIV OP_MULT OP_OP OP_CP OP_COMMA
%token COMMENT

%type <val> input
%type <val> fcall
%type <val> function
%type <val> exp
%type <val> expb
%type <val> explist
%type <val> asg
%token <val> VALUEF
%token <id> ID

%start input

%%

input:
    OP_OP KW_EXIT OP_CP{
    	exit(0);
    }
    | input OP_OP KW_EXIT OP_CP{
    	exit(0);
    }
    | COMMENT {
    	printf("Syntax OK.\n");
    }
    | input COMMENT {
    	printf("Syntax OK.\n");
    }
    | function {
    	printf("Syntax OK.\nResult: %.2f\n", $$);
    }
    | input function {
    	printf("Syntax OK.\nResult: %.2f\n", $2);
    }
    | exp {
    	printf("Syntax OK.\nResult: %.2f\n", $$);
    }
    | input exp {
    	printf("Syntax OK.\nResult: %.2f\n", $2);
    }
    | explist{
    	printf("Syntax OK.\nResult: %.2f\n", $$);
    }
    | input explist{
    	printf("Syntax OK.\nResult: %.2f\n", $2);
    }
    | expb {
    	printf("Syntax OK.\nResult: %.2f\n", $$);
    }
    | input expb {
    	printf("Syntax OK.\nResult: %.2f\n", $2);
    }
    ;


exp:
    // (if  (eq x 1f1) ((set x (- x 1f1))) ((set x (+ x 1f1))))
    OP_OP KW_IF expb explist explist OP_CP {
        ($3 == 1)? ($$ = $4) : ($$ = $5);
    }
    // (if  (eq x 1f1) ((set x (- x 1f1))))
    | OP_OP KW_IF expb explist OP_CP {
        if($3 == 1){
        	$$ = $4;
        }
    }
    //(while (gt x 2f1) ((set x (- x 1f1))))
    | OP_OP KW_WHILE expb explist OP_CP {
    	
    	while($3 == 1){
    	    $$ = $4;
    	}
    }
    //(+ 2f1 1f1)
    | OP_OP OP_PLUS exp exp OP_CP {
        float val1 = $3, val2 = $4;
        $$ = val1 + val2;
    }
    //(- 2f1 1f1)
    | OP_OP OP_MINUS exp exp OP_CP {
        float val1 = $3, val2 = $4;
        $$ = val1 - val2;
    }
    //(* 2f1 1f1)
    | OP_OP OP_MULT exp exp OP_CP {
        float val1 = $3, val2 = $4;
        $$ = val1 * val2;
    }
    //(/ 2f1 1f1)
    | OP_OP OP_DIV exp exp OP_CP {
        float val1 = $3, val2 = $4;
        if (val2 == 0) {
            yyerror("Can not divide by 0.");
        } 
        else {
            $$ = val1 / val2;
        }
    }
    //(defvar x 3f1)
    | OP_OP KW_DEFV ID exp OP_CP {
        $$ = defineID($3, $4);
    }
    //x
    | ID {$$ = findID($1);}
    //3f1
    | VALUEF { $$ = $1; }
    //(progn x)
    | fcall
    //(set x 4f1)
    | asg
    ;

explist:
    //(((+5f1 2f1)) (-4f1 2f1)) -> Result: 2.00 (the last exp)
    OP_OP explist exp OP_CP {
        $$ = $3;
    }
    //((+ 3f1 2f1))
    | OP_OP exp OP_CP {
        $$ = $2;
    }
    ;

asg:
    //(set x 4f1)
    OP_OP KW_SET ID exp OP_CP {
        $$ = setID($3, $4);
    }
    ;

function:
    //(deffun y () (((+ 3f1 2f1)))
    OP_OP KW_DEFF ID OP_OP OP_CP OP_OP explist OP_CP{
    	$$ = defineID($3, $7);
    }
    //(deffun y (x) (((+ 3f1 2f1)))
    | OP_OP KW_DEFF ID OP_OP ID OP_CP OP_OP explist OP_CP{
    	$$ = defineID($3, $8);
    }
    //(deffun y (x z) (((+ 3f1 2f1)))
    | OP_OP KW_DEFF ID OP_OP ID ID OP_CP OP_OP explist OP_CP{
    	$$ = defineID($3, $9);
    }
    //(deffun y (x z a) (((+ 3f1 2f1)))
    | OP_OP KW_DEFF ID OP_OP ID ID ID OP_CP OP_OP explist OP_CP{
    	$$ = defineID($3, $10);
    }
    ;

fcall:
    //(progn x)
    OP_OP KW_PROGN ID OP_CP {
    	$$ = findID($3);
    }
    //(progn x 4f1)
    | OP_OP KW_PROGN ID exp OP_CP{
    	$$ = findID($3);
    }
    | OP_OP KW_PROGN ID exp exp OP_CP{
    	$$ = findID($3);
    }
    | OP_OP KW_PROGN ID exp exp exp OP_CP{
    	$$ = findID($3);
    }
    ;

expb:
    //(eq 1f1 1f1)
    OP_OP KW_EQ exp exp OP_CP {
        $$ = ($3 == $4) ? 1 : 0;
    }
    | OP_OP KW_GT exp exp OP_CP {
        float val1, val2;
        val1 = $3;
        val2 = $4;
        $$ = (val1 > val2) ? 1 : 0;
    }
    | KW_TRUE {
        $$ = 1;
    }
    | KW_FALSE {
        $$ = 0;
    }
    //(and true false)
    | OP_OP KW_AND expb expb OP_CP {
        float val1 = $3, val2 = $4;
        $$ = (val1 && val2) ? 1 : 0;
    }
    //(or true false)
    | OP_OP KW_OR expb expb OP_CP {
        float val1 = $3, val2 = $4;
        $$ = (val1 || val2) ? 1 : 0;
    }
    //(not true)
    | OP_OP KW_NOT expb OP_CP {
        float val = $3;
        $$ = (!val) ? 1 : 0;
    }
    ;


%%

IdentifierList idList;

void init(){
	idList.ids = NULL;
	idList.size = 0;
}

float findID(char* id){
	int i;
	for(i = 0; i < idList.size; i++)
		if(strcmp(idList.ids[i].id, id) == 0) return idList.ids[i].value;
	
    yyerror("ID ERROR This ID does not exist\n");
}

float defineID(char* id, float value){
    int i;
    if(idList.size == 0 || idList.ids == NULL){
        idList.ids = (Identifier*) malloc(1*sizeof(Identifier));
        strcpy(idList.ids[0].id, id);
        idList.ids[0].value = value;
        idList.size++;
        return value;
    }

    for(i = 0; i < idList.size; i++){
        if(strcmp(idList.ids[i].id, id) == 0){
            yyerror("ID ERROR This ID is already defined.\n");
        }
    }

    // If the id is not defined
    idList.ids = (Identifier*) realloc(idList.ids, sizeof(Identifier)*(idList.size+1));
    strcpy(idList.ids[idList.size].id, id);
    idList.ids[idList.size].value = value;
    idList.size++;

    return value;
}

float setID(char* id, float value) {
    int i;
    for(i = 0; i < idList.size; i++){
        if(strcmp(idList.ids[i].id, id) == 0){
            idList.ids[i].value = value;
            return value;
        }
    }

    yyerror("ID ERROR This id is not defined.\n");
}

int main(void) {
    yyin = stdin;
    while(1)
    	yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
    exit(-1);
}
