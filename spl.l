%{
#ifdef PRINT
#define TOKEN(t) printf("Token: " #t "\n");
#define TOKENID(t) printf("Identifier: %s Token: " #t "\n", yytext);
#define TOKENCHAR(t) printf("Char: %s Token: " #t "\n", yytext);
#define TOKENINTEGER(t) printf("Integer: %d Token: " #t "\n", atoi(yytext));
#define TOKENFLOAT(t) printf("Float: %f Token: " #t "\n", atof(yytext)); 
#else
#define TOKEN(t) return(t);
#define TOKENID(t) yylval.iVal = installId(yytext, 0); return (t);
#define TOKENCHAR(t) yylval.iVal = installId(yytext, 1); return (t);
#define TOKENINTEGER(t) yylval.iVal = atoi(yytext); return (t);
#define TOKENFLOAT(t) yylval.iVal = installId(yytext,2); return (t);
#include <strings.h>
extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;
#endif
%}
delim           	[ \t\r\n]
character			[A-Za-z]
character_constant	\'[A-Za-z]\'
digit           [0-9]
floatNum 		[0-9]+(\.[0-9]+)
integerNum 		{digit}+
identifier		{character}({character}|{digit})*
ws              {delim}+
%%
":"		TOKEN(COLON);
"."		TOKEN(DOT);
";"		TOKEN(SEMICOLON);
"->"	TOKEN(ASSIGMENT);
"("		TOKEN(BRA);
")"		TOKEN(KET);
","		TOKEN(COMMA);
"="		TOKEN(EQUALS); 
"<>"	TOKEN(NOT_EQUALS);
"<" 	TOKEN(LESS_THAN);
">" 	TOKEN(GREATER_THAN);
"<=" 	TOKEN(LESS_THAN_OR_EQUAL);
">=" 	TOKEN(GREATER_THAN_OR_EQUAL);
"+"		TOKEN(PLUS);
"-"		TOKEN(MINUS);
"*"		TOKEN(TIMES);
"/"		TOKEN(DIVIDE);
"ENDP"	TOKEN(ENDP_SPL);
"DECLARATIONS" 	TOKEN(DECLARATIONS_SPL);
"CODE" 			TOKEN(CODE_SPL);
"CHARACTER" 	TOKEN(CHARACTER_SPL);
"INTEGER" 		TOKEN(INTEGER_SPL);
"REAL" 			TOKEN(REAL_SPL);
"IF"			TOKEN(IF_SPL);
"THEN"			TOKEN(THEN_SPL);
"ELSE"			TOKEN(ELSE_SPL);
"ENDIF"			TOKEN(ENDIF_SPL);
"DO"			TOKEN(DO_SPL);
"WHILE"			TOKEN(WHILE_SPL);
"ENDDO"			TOKEN(ENDDO_SPL);
"ENDWHILE"		TOKEN(ENDWHILE_SPL);
"FOR"			TOKEN(FOR_SPL);
"IS"			TOKEN(IS_SPL);
"BY"			TOKEN(BY_SPL);
"TO"			TOKEN(TO_SPL);
"ENDFOR"		TOKEN(ENDFOR_SPL);
"WRITE"			TOKEN(WRITE_SPL);
"NEWLINE"		TOKEN(NEWLINE_SPL);
"READ"			TOKEN(READ_SPL);
"AND"			TOKEN(AND_SPL);
"OR"			TOKEN(OR_SPL);
"NOT"			TOKEN(NOT_SPL);
"OF"			TOKEN(OF_SPL);
"TYPE"			TOKEN(TYPE_SPL);
{identifier}	TOKENID(identifier_SPL);
{character_constant}  TOKENCHAR(CHARACTER_CONSTANT);
{integerNum}		TOKENINTEGER(INTERGER_NUM);
{floatNum}			TOKENFLOAT(FLOAT_NUM);
{ws}	;
.     printf("Error: Unexpected symbol in lex: %s (%d)\n", yytext, yytext[0]);
%%
#ifndef PRINT


SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int installId(char *id, int type) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
        return (index);
    }
    else 
       if (currentSymTabSize >= SYMTABSIZE) 
          /* SYMTAB is full */
          return (NOTHING) ;
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
       symTab[currentSymTabSize]->type = type;
       
       return(currentSymTabSize++);
    }
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);    
}
#endif
