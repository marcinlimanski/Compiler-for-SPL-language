/* SPL01.y - SPL01 parser */
/* Author: Peter Parsons */
/* Revision: Oct 08 BCT */

%{

#include <stdio.h>
#include <stdlib.h>

  /* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

  char currentDeclarationType ='\0';
  int boolOutput_list = 0;
  int boolConstant = 0;
  int moreThanOneFor = 0;

  char *ReservedSymbols[] ={"auto","default", "float", "register", "struct", "volatile", 
							"break", "do", "for", "return", "switch", "while", "case",
							"double", "goto", "short", "typedef", "char", "else", "if","signed","union", 	 
							"const", "enum","int","sizeof", "unsigned", "continue", "extern", "long", "static", "void"};
  
  enum ParseTreeNodeType {PROGRAM, BLOCK_1, BLOCK_2, DECLARATION_BLOCK_1, DECLARATION_BLOCK_2, DECLARATION_1, 
  				DECLARATION_2, TYPE, TYPE_INT, TYPE_REAL, STATEMENT_LIST_1,STATEMENT_LIST_2,
				STATEMENT, STATEMENT_ASS, ASSIGMENT_STATMENT, STATEMENT_IF, STATEMENT_DO, STATEMENT_WHILE, 
			    DO_STATEMENT, WHILE_STATEMENT, STATEMENT_FOR, STATEMENT_WRITE, STATEMENT_READ,
				FOR_STATEMENT, WRITE_STATEMENT_1, WRITE_STATEMENT_2, READ_STATEMENT, OUTPUT_LIST_1, OUTPUT_LIST_2, CONDITIONAL_1, 
				CONDITIONAL_2, CONDITIONAL_3,TERM_1, TERM_2, TERM_3,
				CONDITION_1, CONDITION_2,COMPAROTOR_1, COMPAROTOR_2, COMPAROTOR_3, COMPAROTOR_4, COMPAROTOR_5, COMPAROTOR_6,
				EXPRESSION_1 ,EXPRESSION_2,EXPRESSION_3, TERM, VALUE, CONSTANT, NUMBER_CONSTANT,
				MINUS_NUMBER_CONSTANT, 
				TARGET_NUMBER, VALUE_ID, VALUE_CONSTANT, VALUE_EX, CHAR_CONSTANT, TARGET_NUMBER_INT, 
				TARGET_NUMBER_FLO, IF_STATEMENT_1, IF_STATEMENT_2};  
                          /* Add more types here, as more nodes
                                           added to tree */
  char *NodeName[] = {"PROGRAM", "BLOCK_1", "BLOCK_2","DECLARATION_BLOCK_1", "DECLARATION_BLOCK_2", "DECLARATION_1", 
  					"DECLARATION_2" , "TYPE", "TYPE_INT", "TYPE_REAL", "STATEMENT_LIST_1","STATEMENT_LIST_2",
					"STATEMENT", "STATEMENT_ASS","ASSIGMENT_STATMENT", "STATEMENT_IF", "STATEMENT_DO","DO_STATEMENT", 
					"STATEMENT_WHILE","WHILE_STATEMENT", "STATEMENT_FOR", "STATEMENT_WRITE", "STATEMENT_READ",
					"FOR_STATEMENT", "WRITE_STATEMENT_1","WRITE_STATEMENT_2", "READ_STATEMENT", "OUTPUT_LIST_1", "OUTPUT_LIST_2", "CONDITIONAL_1",
					"CONDITIONAL_1", "CONDITIONAL_2","CONDITIONAL_3","TERM_1", "TERM_2", "TERM_3",  
					"CONDITION_1", "CONDITION_2","COMPAROTOR_1", "COMPAROTOR_2", "COMPAROTOR_3", "COMPAROTOR_4", "COMPAROTOR_5", "COMPAROTOR_6",
					"EXPRESSION_1", "EXPRESSION_2", "EXPRESSION_3","TERM", "VALUE", "CONSTANT", "NUMBER_CONSTANT",
					"MINUS_NUMBER_CONSTANT", 
					"TARGET_NUMBER", "VALUE_ID", "VALUE_CONSTANT", "VALUE_EX", "CHAR_CONSTANT", "TARGET_NUMBER_INT", 
					"TARGET_NUMBER_FLO", "IF_STATEMENT_1", "IF_STATEMENT_2"};
#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

/* ------------- parse tree definition --------------------------- */

struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
    struct treeNode *four;
  };

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE        *TERNARY_TREE;

/* ------------- forward declarations --------------------------- */

TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);
#ifdef DEBUG
	void PrintTree(TERNARY_TREE, int);
#endif
	void PrintCode(TERNARY_TREE);
	int FindExpVal(TERNARY_TREE);
	int FindReservedSymbol(char*);

/* ------------- symbol table definition --------------------------- */
enum symType { T_INT, T_CHAR, T_REAL };
struct symTabNode {
    char identifier[IDLENGTH];
    char type;
};

typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE        *SYMTABNODEPTR;

SYMTABNODEPTR  symTab[SYMTABSIZE]; 

int currentSymTabSize = 0;
%}

/****************/
/* Start symbol */
/****************/

%start  program

/**********************/
/* Action value types */
/**********************/

%union {
    int iVal;
    TERNARY_TREE tVal;
}

/* We can declare types of tree nodes */

/* These are the types of lexical tokens -> iVal */
%token<iVal> identifier_SPL INTERGER_NUM CHARACTER_CONSTANT FLOAT_NUM

%token COLON DOT SEMICOLON ASSIGMENT BRA KET COMMA EQUALS NOT_EQUALS
		LESS_THAN GREATER_THAN LESS_THAN_OR_EQUAL GREATER_THAN_OR_EQUAL
		PLUS MINUS TIMES DIVIDE APPOSTROP ENDP_SPL DECLARATIONS_SPL CODE_SPL
		CHARACTER_SPL INTEGER_SPL REAL_SPL IF_SPL THEN_SPL ELSE_SPL ENDIF_SPL
		DO_SPL WHILE_SPL ENDDO_SPL ENDWHILE_SPL FOR_SPL IS_SPL BY_SPL TO_SPL
		ENDFOR_SPL WRITE_SPL NEWLINE_SPL READ_SPL AND_SPL OR_SPL NOT_SPL OF_SPL
		TYPE_SPL

%type<tVal> program block declaration_block declaration type statement_list
				statement assignment_statment if_statement do_statement while_statement
				for_statement write_statement read_statement output_list conditional 
				condition comparator expression term value constant number_constant 
				target_number


%%
program : identifier_SPL COLON block ENDP_SPL identifier_SPL DOT
			{ TERNARY_TREE ParseTree;
                  ParseTree = create_node($1, PROGRAM, $3, NULL, NULL,NULL);
                  if($1 != $5) {
					printf("/*Syntax Warrning: check if start ID is matching end ID*/\n");
			      }

#ifdef DEBUG
                  PrintTree(ParseTree, 0);
   
#else
                  PrintCode(ParseTree);
#endif
            }

	;

block : DECLARATIONS_SPL declaration_block CODE_SPL statement_list
			{ 
                $$ = create_node(NOTHING, BLOCK_1, $2, $4, NULL,NULL);
        	}
			| CODE_SPL statement_list
			{ 
                $$ = create_node(NOTHING, BLOCK_2, $2, NULL, NULL, NULL);
        	}
        	/*
        	case (BLOCK_1) :
        		PrintCode(t->first);
        		PrintCode(t->second);
        		return;

        	
        	case (BLOCK_2) : 
        		PrintCode(t->first);
        		return;
        	*/
        	

	;

declaration_block : declaration OF_SPL TYPE_SPL type SEMICOLON
					{ 
                		$$ = create_node(NOTHING, DECLARATION_BLOCK_1, $1, $4, NULL,NULL);
        			}
					| declaration OF_SPL TYPE_SPL type SEMICOLON declaration_block
					{ 
		                $$ = create_node(NOTHING, DECLARATION_BLOCK_2, $1, $4, $6,NULL);
		        	}
		        	/*
		        	case(DECLARATION_BLOCK_1) :
		        		PrintCode(t->second);
		        		PrintCode(t->first);
		        		return;

		        	case(DECLARATION_BLOCK_2) :
		        		PrintCode(t->second);
		        		PrintCode(t->first);
		        		PrintCode(t->third);
		        		return;
		        		*/


	;

declaration : identifier_SPL 
				{ 
		            $$ = create_node($1, DECLARATION_1, NULL, NULL, NULL,NULL);
		        }
				| identifier_SPL COMMA declaration
				{ 
		            $$ = create_node($1, DECLARATION_2, $3, NULL, NULL, NULL);
		        }
		        /*
		        case(DECLARATION_1) :
		        	if(t->nodeIdentifier == VALUE_ID){
					printf("%s ", symTab[t->item]->identifier);
					symTab[t->item]->nodeType = 'i';
					}
					return;

				case(DECLARATION_2) :
					if(t->nodeIdentifier == VALUE_ID){
					printf("%s ", symTab[t->item]->identifier);
					}
					printf(", ");
					PrintCode(t->first);
					return;
				*/
		

	;	

type : CHARACTER_SPL 
		{ 
            $$ = create_node(CHARACTER_SPL, TYPE, NULL, NULL, NULL, NULL);
        }
		| INTEGER_SPL
		{ 
            $$ = create_node(INTEGER_SPL, TYPE, NULL, NULL, NULL, NULL);
        }
		| REAL_SPL
		{ 
            $$ = create_node(REAL_SPL, TYPE, NULL, NULL, NULL, NULL);
        }

        	/*
        		case(TYPE_CHAR) :
        			printf("char ");
        			return;

        		case(TYPE_INT) :
        			printf("int ");
        			return;

        		case(TYPE_REAL) :
        			printf("float ");
        			return;
        	*/

	;

statement_list : statement SEMICOLON statement_list
				{ 
                	$$ = create_node(NOTHING, STATEMENT_LIST_1, $1, $3, NULL, NULL);
        		}
				| statement 
				{ 
                	$$ = create_node(NOTHING, STATEMENT_LIST_2, $1, NULL, NULL, NULL);
        		}

        		/*
        		case(STATEMENT_LIST_1) :
        			PrintCode(t->first);
        			printf("\n");
        			PrintCode(t->second);
        			return;

        		case(STATEMENT_LIST_2) :
        			PrintCode(t->first);
        			printf("\n");
        			*/
       		
	;

statement : assignment_statment
			{ 
                $$ = create_node(NOTHING, STATEMENT_ASS, $1,NULL, NULL, NULL);
            }
				| if_statement
				{ 
                  $$ = create_node(NOTHING, STATEMENT_IF, $1, NULL, NULL, NULL);
            	}
				| do_statement
				{ 
                  $$ = create_node(NOTHING, STATEMENT_DO, $1, NULL, NULL, NULL);
            	}
				| while_statement
				{ 
                  $$ = create_node(NOTHING, STATEMENT_WHILE, $1, NULL, NULL, NULL);
            	}
				| for_statement
				{ 
                  $$ = create_node(NOTHING, STATEMENT_FOR, $1, NULL, NULL, NULL);
            	}
				| write_statement
				{ 
                  $$ = create_node(NOTHING, STATEMENT_WRITE, $1, NULL, NULL, NULL);
            	}
				| read_statement 
				{ 
                  $$ = create_node(NOTHING, STATEMENT_READ, $1, NULL, NULL, NULL);
            	}
            	/*
            	case(STATEMENT_ASS) :
            		PrintCode(t->first);
            		return;

            	case(STATEMENT_IF) :
            		PrintCode(t->first);
            		return;

            	case(STATEMENT_DO) :
            		PrintCode(t->first);
            		return;

            	case(STATEMENT_WHILE) :
            		PrintCode(t->first);
            		return;

            	case(STATEMENT_FOR) :
            		PrintCode(t->first);
            		return;

            	case(STATEMENT_WRITE) :
            		PrintCode(t->first);
            		return;

            	case(STATEMENT_READ) :
            		PrintCode(t->first);
            		return;
				*/

	;

assignment_statment : expression ASSIGMENT identifier_SPL
					{ 
	                  $$ = create_node($3, ASSIGMENT_STATMENT, $1, NULL, NULL, NULL);
	            	}

	            	/*
	            	case(ASSIGMENT_STATMENT) :
	            		PrintCode(t->second);
	            		printf("=");
	            		PrintCode(t->first);
	            		printf("\n");
	            		return;

	            	*/
	            		


	;

if_statement : IF_SPL conditional THEN_SPL statement_list ELSE_SPL statement_list ENDIF_SPL 
				{ 
	                $$ = create_node(NOTHING, IF_STATEMENT_1, $2, $4, $6, NULL);
	            }
				| IF_SPL conditional THEN_SPL statement_list ENDIF_SPL
				{ 
	                $$ = create_node(NOTHING, IF_STATEMENT_2, $2, $4, NULL, NULL);
	            }

	            /*
	            case(IF_STATEMENT_1) :
	            	printf("if (");
	            	PrintCode(t->first);
	            	printf(") { \n", );
	            	PrintCode(t->second);
	            	printf("\n");
	            	printf("}\n");
	            	printf("else { \n");
	            	PrintCode(t->third);
	            	printf("\n");
	            	printf("}\n");
	            	return;

	           	case(IF_STATEMENT_2) :
	           		printf("if (");
	            	PrintCode(t->first);
	            	printf(") { \n", );
	            	PrintCode(t->second);
	            	printf("\n");
	            	printf("}\n");
	            	return;
	            	*/


	;

do_statement : DO_SPL statement_list WHILE_SPL conditional ENDDO_SPL
				{ 
	                $$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL, NULL);
	            }
	            /*
	            case (DO_STATEMENT) :
            	printf("do{\n");
            	PrintCode(t->first);
            	printf("\n");
            	printf("}\n");
            	printf("while(");
            	PrintCode(t->second);
            	printf(");");
            	printf("\n");
            	break;
	            */


	;

while_statement : WHILE_SPL conditional DO_SPL statement_list ENDWHILE_SPL
				{ 
	                $$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL, NULL);
	            }
	            /*
	            case (WHILE_STATEMENT) :
	            	printf("while(");
	            	PrintCode(t->first);
	            	printf("){\n");
	            	PrintCode(t->second);
	            	printf("}");
				*/


	;

for_statement : FOR_SPL identifier_SPL IS_SPL expression BY_SPL expression 
				TO_SPL expression DO_SPL statement_list ENDFOR_SPL
				{ 
	                $$ = create_node($2, FOR_STATEMENT, $4, $6, $8, $10);
	            }

	            /*
	            case (FOR_STATEMENT) :
	            	printf("for (");
	            	printf("%s",symTab[t->item]->identifier);
	            	printf(" = ", );
	            	PrintCode(t->first);
	            	printf("; ");
	            	printf("%s",symTab[t->item]->identifier);
	            	printf(" <= ", );
	            	PrintCode(t->third);
	            	printf("; ");
	            	printf("%s",symTab[t->item]->identifier);
	            	printf(" = ");
	            	printf("%s",symTab[t->item]->identifier);
	            	printf(" + ");
	            	PrintCode(t->second);
	            	printf("){\n");
	            	PrintCode(t->four);
	            	printf("\n}");
	            */
	            	


	;


write_statement : WRITE_SPL BRA output_list KET
				{ 
	        	    $$ = create_node(NOTHING, WRITE_STATEMENT_1, $3, NULL, NULL, NULL);
	            }	
				| NEWLINE_SPL
				{ 
	        	    $$ = create_node(NEWLINE_SPL, WRITE_STATEMENT_2, NULL, NULL, NULL, NULL);
	            }

	            /*
	            case(WRITE_STATEMENT_1) :
	            	PrintCode(t->first);
	            	return;

	            case(WRITE_STATEMENT_2) :
	            	printf("\n");
	            	return;
	            	*/
	;

read_statement : READ_SPL BRA identifier_SPL KET
				{ 
	        	    $$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL, NULL);
	            }
	;


output_list : value COMMA output_list 
				{ 
	        	    $$ = create_node(NOTHING, OUTPUT_LIST_1, $1, $3, NULL, NULL);
	            }
				|
				value
				{ 
	        	    $$ = create_node(NOTHING, OUTPUT_LIST_2, $1, NULL, NULL, NULL);
	            }
	            /*
	            case(OUTPUT_LIST_1) :
	            	printf("printf(")
	            	PrintCode(t->first);
	            	symTab[t->item]->nodeType = 'i';
	            	printf(") ")
	            	printf("\n")
	            	PrintCode(t->second);
	            	return;

	            case(OUTPUT_LIST_2) :
	            	printf("printf(")
	            	PrintCode(t->first);
	            	printf(") ")
	            	printf("\n")
	            	return;
	            	*/
	;

conditional : conditional AND_SPL condition
				{ 
	        	    $$ = create_node(NOTHING, CONDITIONAL_1, $1, $3, NULL, NULL);
	            }
				| conditional OR_SPL condition
				{ 
	        	    $$ = create_node(NOTHING, CONDITIONAL_2, $1, $3, NULL, NULL);
	            }
				| condition
				{ 
	        	    $$ = create_node(NOTHING, CONDITIONAL_3, $1, NULL, NULL, NULL);
	            }
	            /*
	            case (CONDITIONAL_1) :
	            	PrintCode(t->first);
	            	printf(" && ");
	            	PrintCode(t->second);
	            	return;

	            case (CONDITIONAL_2) :
	            	PrintCode(t->first);
	            	printf(" || ");
	            	PrintCode(t->second);
	            	return;

	            case (CONDITIONAL_3) :
	            	PrintCode(t->first);
	            	return;
	            	*/

	;
				
 
condition : expression comparator expression 
				{ 
	        	    $$ = create_node(NOTHING, CONDITION_1, $1, $2, $3, NULL);
	            }
				| 
				NOT_SPL condition
				{ 
	        	    $$ = create_node(NOTHING, CONDITION_2, $2, NULL, NULL, NULL);
	            }
	            /*
	            case (CONDITION_1) :
	            	PrintCode(t->first);
	            	printf(" ");
	            	PrintCode(t->second);
	            	printf(" ");
	            	PrintCode(t->third);
	            	return;

	            case (CONDITION_2) :
	            	printf("!");
	            	PrintCode(t->first);
	            	return;
				*/

	;


comparator : EQUALS
				{ 
	        	    $$ = create_node(EQUALS, COMPAROTOR_1, NULL, NULL, NULL, NULL);
	            } 
				| NOT_EQUALS 
				{ 
	        	    $$ = create_node(NOT_EQUALS, COMPAROTOR_2, NULL, NULL, NULL, NULL);
	            } 
				| LESS_THAN 
				{ 
	        	    $$ = create_node(LESS_THAN, COMPAROTOR_3, NULL, NULL, NULL, NULL);
	            } 
				| GREATER_THAN 
				{ 
	        	    $$ = create_node(GREATER_THAN, COMPAROTOR_4, NULL, NULL, NULL, NULL);
	            } 
				| LESS_THAN_OR_EQUAL 
				{ 
	        	    $$ = create_node(LESS_THAN_OR_EQUAL, COMPAROTOR_5, NULL, NULL, NULL, NULL);
	            } 
				| GREATER_THAN_OR_EQUAL
				{ 
	        	    $$ = create_node(GREATER_THAN_OR_EQUAL, COMPAROTOR_6, NULL, NULL, NULL, NULL);
	            } 
	            /*
	            case (COMPAROTOR_1) :
	            	printf("==");
	            	return;

	            case (COMPAROTOR_2) :
	            	printf("!=");
	            	return;

	            case (COMPAROTOR_3) :
	            	printf("<");
	            	return;

	            case (COMPAROTOR_4) :
	            	printf(">");
	            	return;

	            case (COMPAROTOR_5) :
	            	printf("<=");
	            	return;

	            case (COMPAROTOR_6) :
	            	printf(">=");
	            	return;
	            */
	;

expression : expression PLUS term 
				{ 
	        	    $$ = create_node(NOTHING, EXPRESSION_1, $1, $3, NULL, NULL);
	            } 
				| expression MINUS term
				{ 
	        	    $$ = create_node(NOTHING, EXPRESSION_2, $1, $3, NULL, NULL);
	            } 
				| term 
				{ 
	        	    $$ = create_node(NOTHING, EXPRESSION_3, $1, NULL, NULL, NULL);
	            } 
	            /*
	            case(EXPRESSION_1) :
	            	PrintCode(t->first);
	            	printf(" + ");
	            	PrintCode(t->second);

	            case(EXPRESSION_2) :
	            	PrintCode(t->first);
	            	printf(" - ");
	            	PrintCode(t->second);

	            
	            case(EXPRESSION_3) :
	            	PrintCode(t->first);
	            	return;
	            */
	;

term : term TIMES value
		{ 
	       	$$ = create_node(NOTHING, TERM_1, $1, $3, NULL, NULL);
	    } 
		| term DIVIDE value
		{ 
	       	$$ = create_node(NOTHING, TERM_2, $1, $3, NULL, NULL);
	    } 
		| value
		{ 
	       	$$ = create_node(NOTHING, TERM_3, $1, NULL, NULL, NULL);
	    } 
	    		/*
	    		case(TERM_1) :
	    			PrintCode(t->first);
	    			printf(" * ");
	    			PrintCode(t->second);
	    			return;

	    		case(TERM_2) :
	    			PrintCode(t->first);
	    			printf(" / ");
	    			PrintCode(t->second);
	    			return;

	    		
	    		case(TERM_3) :
	    			PrintCode(t->first);
	    			return;
	    			*/

	;

value : identifier_SPL 
		{ 
	       	$$ = create_node($1, VALUE_ID, NULL, NULL, NULL, NULL);
	    }
		| constant
		{ 
	       	$$ = create_node(NOTHING, VALUE_CONSTANT, $1, NULL, NULL, NULL);
	    }	
		| BRA expression KET
		{ 
	       	$$ = create_node(NOTHING, VALUE_EX, $2, NULL, NULL, NULL);
	    }
	    		/*
	    		case(VALUE_ID) :
	    			if(t->item  >= 0 && t->item < SYMTABSIZE)
					{

						printf("%s", symTab[t->item]->identifier);

					}
					else
					{
						printf("Uknown Identifier %s", symTab[t->item]->identifier);
					}
	    			return;

	    		case(VALUE_EX) :
	    			printf(" (");
	    			PrintCode(t->first);
	    			printf(") ");
	    			return;

	    		
	    		case(VALUE_CONSTANT) :
	    			PrintCode(t->first);
	    			return;
	    		*/
	;

constant : number_constant 
		{ 
	       	$$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL, NULL);
	    }
		| CHARACTER_CONSTANT
		{ 
	       	$$ = create_node($1, CHAR_CONSTANT, NULL, NULL, NULL, NULL);
	    }
	    		/*
	    		case(CONSTANT) :
	    			PrintCode(t->first);
	    			return;
	    		*/

	    		/*NO CHAR !!!!!!!!!!!!!!!! */
	;

number_constant : target_number 
				{ 
			       	$$ = create_node(NOTHING, NUMBER_CONSTANT, $1, NULL, NULL, NULL);
			    }
				| MINUS target_number
				{ 
			       	$$ = create_node(NOTHING, MINUS_NUMBER_CONSTANT,$2, NULL, NULL, NULL);
			    }

			    /*
			    case(NUMBER_CONSTANT) :
			    	PrintCode(t->first);
			    	return;
			    

			    case(MINUS_NUMBER_CONSTANT) :
			    	printf(" -");
			    	PrintCode(t->first);
			    	return;
			    	*/

	;

target_number : INTERGER_NUM 
				{ 
			       	$$ = create_node($1, TARGET_NUMBER_INT, NULL, NULL, NULL, NULL);
			    }
				| FLOAT_NUM
				{ 
			       	$$ = create_node($1, TARGET_NUMBER_FLO, NULL, NULL, NULL, NULL);
			    }
			    /*
			    case(TARGET_NUMBER_INT) :
					printf("%d ", t->item);
					return;
				
				
			    case(TARGET_NUMBER_FLO) :
					printf("%f ", t->itemf);
					return;
				*/

	;

%%
/* Code for routines for managing the Parse Tree */

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3, TERNARY_TREE  p4)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    t->four = p4;
    return (t);
}

void PrintCode(TERNARY_TREE t)
{
	if (t == NULL) return;
	
	switch (t->nodeIdentifier)
        {
/*PROGRAM*/
            /*All nodes must have a case !!!! other wise a tree cant be made*/
        	case(PROGRAM) :
        		printf("#include <stdio.h>\n");
        		printf("int main(void) {\n");
        		PrintCode(t->first);
        		printf("\n");
        		printf("return 0;\n");
        		printf("}");
        		break;

        	/*DECLARATIONS i,i,i,i, OF TYPE integer 
        	CODE 
			statment 
        	 */

/*BLOCK*/
			/*
        	case (BLOCK_1) :
        		PrintCode(t->first);
        		PrintCode(t->second);
        		break;

			*/
        	/*
        	case (BLOCK_2) : 
        		PrintCode(t->first);
        		break;
        	*/

/*DECLARATION_BLOCK*/
        	
        	case(DECLARATION_BLOCK_1) :
        		PrintCode(t->second);
        		PrintCode(t->first);
        		break;

        	

        	case(DECLARATION_BLOCK_2) :
        		PrintCode(t->second);
        		PrintCode(t->first);
        		PrintCode(t->third);
        		break;

/*DECLARATION*/
        	case(DECLARATION_1) :
				if(FindReservedSymbol(symTab[t->item]->identifier) == 1)
				{
					
					printf("%s", symTab[t->item]->identifier);
					symTab[t->item]->type = currentDeclarationType;
					printf("; ");
					printf("/*Error: you have used a varible name that is reserved for C language*/\n");
					printf("\n");
					
				}
				else
				{
					printf("%s", symTab[t->item]->identifier);
					symTab[t->item]->type = currentDeclarationType;
					printf(";");
					printf("\n");
				}
				break;

			case(DECLARATION_2) :
				if(FindReservedSymbol(symTab[t->item]->identifier) == 1)
				{
					printf("_");
					printf("%s", symTab[t->item]->identifier);
					symTab[t->item]->type = currentDeclarationType;
					printf(", ");
					printf("/*Error: you have used a varible name that is reserved for C language*/\n");
					PrintCode(t->first);
				}
				else
				{
					printf("%s", symTab[t->item]->identifier);
					symTab[t->item]->type = currentDeclarationType;
					printf(", ");
					PrintCode(t->first);
				}
				break;

/*TYPE*/
			case TYPE:
			switch(t->item)
			{
				case CHARACTER_SPL:
					currentDeclarationType ='c';
					printf("char ");
					break;
				case REAL_SPL:
					currentDeclarationType ='f';
					printf("float ");
					break;
				case INTEGER_SPL:
					currentDeclarationType ='i';
					printf("int ");
					break;
			}
			break;

/*STATMENT_LIST*/
    		/*
    		case(STATEMENT_LIST_1) :
    			PrintCode(t->first);
    			PrintCode(t->second);
    			break;

    		case(STATEMENT_LIST_2) :
    			PrintCode(t->first);
    			printf("\n");
    			*/
    		/*
    		case(STATEMENT_ASS) :
	    		PrintCode(t->first);
	    		break;

	    	case(STATEMENT_IF) :
	    		PrintCode(t->first);
	    		break;

	    	case(STATEMENT_DO) :
	    		PrintCode(t->first);
	    		break;

	    	case(STATEMENT_WHILE) :
	    		PrintCode(t->first);
	    		break;

	    	case(STATEMENT_FOR) :
	    		PrintCode(t->first);
	    		break;
	    	*/

/*DO STATMENT*/
	    	case (DO_STATEMENT) :
            	printf("do{\n");
            	PrintCode(t->first);
            	printf("\n");
            	printf("}\n");
            	printf("while(");
            	PrintCode(t->second);
            	printf(");");
            	printf("\n");
            	break;

/*WHILE STATMENT*/
        	case (WHILE_STATEMENT) :
            	printf("while(");
            	PrintCode(t->first);
            	printf("){\n");
            	PrintCode(t->second);
            	printf("}");
            	break;

/*FOR STATEMENT*/

        	 	/* 
			 FOR a IS 2 BY 2 TO 10 DO
			     ....
			  ENDFOR;

            for (i=is; _by=by, (i-to)*((_by > 0) - (_by < 0)) <= 0 ; a += _by) {

           FOR_SPL identifier_SPL IS_SPL expression BY_SPL expression TO_SPL expression DO_SPL 
           statement_list ENDFOR_SPL
			*/
        	 case (FOR_STATEMENT) :
        	 	if (moreThanOneFor == 0)
        	 	{
        	 		printf("register int _by%d;", moreThanOneFor);
        	 	}
        	 	else
        	 	{
        	 		printf("register int _by%d;", moreThanOneFor);
        	 	}
        	 	printf("\n");
            	printf("for (");
            	printf("%s",symTab[t->item]->identifier);
            	printf(" = ");
            	PrintCode(t->first);
            	printf("; ");
            	printf("_by%d=", moreThanOneFor);
            	PrintCode(t->second);
            	printf(", (");
            	printf("%s",symTab[t->item]->identifier);
            	printf("-(");
            	PrintCode(t->third);
       			printf("))");
            	printf("*");
            	printf("((");
            	printf("_by%d > 0)", moreThanOneFor);
            	printf(" - ");
            	printf("(_by%d < 0)) ", moreThanOneFor);
            	printf("<= 0; ");
            	printf("%s",symTab[t->item]->identifier);
            	printf(" += _by%d", moreThanOneFor);
            	printf("){\n");
            	PrintCode(t->four);
            	printf("\n}");
            	moreThanOneFor++;
            	break;

/*ASSIGMENT_STATMENT*/
            case(ASSIGMENT_STATMENT) :
        		if(t->item  >= 0 && t->item < SYMTABSIZE)
				{
					printf("%s", symTab[t->item]->identifier);
				}
				else
				{
					printf("Uknown Identifier %s", symTab[t->item]->identifier);
				}
        		printf(" = ");
        		PrintCode(t->first);
        		printf(";");
        		printf("\n");
        		break;

/*IF STATMENT*/
    		case(IF_STATEMENT_1) :
            	printf("if (");
            	PrintCode(t->first);
            	printf(") { \n");
            	PrintCode(t->second);
            	printf("}\n");
            	printf("else { \n");
            	PrintCode(t->third);
            	printf("}\n");
            	break;

           	case(IF_STATEMENT_2) :
           		printf("if (");
            	PrintCode(t->first);
            	printf(") { \n");
            	PrintCode(t->second);
            	printf("}\n");
            	break;

/*WRITE_STATEMENT*/
    		case(WRITE_STATEMENT_1) :
            	PrintCode(t->first);
            	break;

            case(WRITE_STATEMENT_2) :
            	printf("printf(\"\\n\");\n");
            	break;

            case(READ_STATEMENT) :
            	printf("scanf(\"");
				switch(symTab[t->item]->type)
				{
					case 'c':
						printf(" %%[^\\n]c");
						break;
					case 'i':
						printf("%%d");
						break;
					case 'f':
						printf("%%f"); 
						break;
				}
				printf("\",");
				printf(" &%s", symTab[t->item]->identifier);
				printf(");\n");
				break;

/*OUTPUT_LIST*/
            case(OUTPUT_LIST_1) :
            	if(t->first != NULL && t->first->nodeIdentifier == VALUE_ID )
            	{
            		printf("printf(\"");
            		switch(symTab[t->first->item]->type)
					{
						case 'c':
							printf(" %%c,\""", ");
							break;
						case 'i':
							printf("%%d,\""", ");
							break;
						case 'f':
							printf("%%f\""", "); 
							break;
					}
            		PrintCode(t->first);
            		printf(");\n");
	            	PrintCode(t->second);
            	} 
            	else if(t->first != NULL && t->first->nodeIdentifier == VALUE_CONSTANT)
            	{
            		printf("printf(\"");
            		boolConstant = 1;
            		PrintCode(t->first);
	            	printf(");\n");
	            	PrintCode(t->second);
	            	boolConstant = 0;

            	}
            	else
            	{
            		if(FindExpVal(t) == 1)
            		{
            			printf("printf(\"");
            			printf("%%f\", ");
	            		PrintCode(t->first);
		            	printf(");\n");
		            	PrintCode(t->second);
            		}
            		else
            		{
            			printf("printf(\"");
            			printf("%%d\", ");
	            		PrintCode(t->first);
		            	printf(");\n");
		            	PrintCode(t->second);
            		}
            		
            	}
            	break;
            
            	
            case(OUTPUT_LIST_2) :
            	if(t->first != NULL && t->first->nodeIdentifier == VALUE_ID)
            	{
            		printf("printf(\"");
            		switch(symTab[t->first->item]->type)
					{
						case 'c':
							printf("%%c\""", ");
							break;
						case 'i':
							printf("%%d\""", ");
							break;
						case 'f':
							printf("%%f\""", "); 
							break;
					}
            		PrintCode(t->first);
            		printf(");\n");

            	}
            	else if(t->first != NULL && t->first->nodeIdentifier == VALUE_CONSTANT)
            	{
            		printf("printf(\"");
            		boolConstant = 1;
            		PrintCode(t->first);
	            	printf(");\n");
	            	boolConstant = 0;
            	}
            	else
            	{
            		if(FindExpVal(t) == 1)
            		{
            			printf("printf(\"");
            			printf("%%f\", ");
	            		PrintCode(t->first);
		            	printf(");\n");
            		}
            		else
            		{
            			printf("printf(\"");
            			printf("%%d\", ");
	            		PrintCode(t->first);
		            	printf(");\n");
            		}
            		
            	}
            	
            	
            	break;
            	
/*CONDITIONAL*/
        	case (CONDITIONAL_1) :
            	PrintCode(t->first);
            	printf(" && ");
            	PrintCode(t->second);
            	break;

            case (CONDITIONAL_2) :
            	PrintCode(t->first);
            	printf(" || ");
            	PrintCode(t->second);
            	break;

            case (CONDITIONAL_3) :
            	PrintCode(t->first);
            	break;

/*CONDITION*/
            case (CONDITION_1) :
            	PrintCode(t->first);
            	printf(" ");
            	PrintCode(t->second);
            	printf(" ");
            	PrintCode(t->third);
            	break;

            case (CONDITION_2) :
            	printf("!(");
				PrintCode(t->first);
				printf(")");
            	break;

/*COMPARATOR*/
            case (COMPAROTOR_1) :
            	printf("==");
            	break;

            case (COMPAROTOR_2) :
            	printf("!=");
            	break;

            case (COMPAROTOR_3) :
            	printf("<");
            	break;

            case (COMPAROTOR_4) :
            	printf(">");
            	break;

            case (COMPAROTOR_5) :
            	printf("<=");
            	break;

            case (COMPAROTOR_6) :
            	printf(">=");
            	break;

/*EXPRESION*/
        	case(EXPRESSION_1) :
            	PrintCode(t->first);
            	printf(" + ");
            	PrintCode(t->second);
            	break;

            case(EXPRESSION_2) :
            	PrintCode(t->first);
            	printf(" - ");
            	PrintCode(t->second);
            	break;

        	case(EXPRESSION_3) :
            	PrintCode(t->first);
            	break;

/*TERM*/    		
            case(TERM_1) :
    			PrintCode(t->first);
    			printf(" * ");
    			PrintCode(t->second);
    			break;

    		case(TERM_2) :
    			PrintCode(t->first);
    			printf(" / ");
    			PrintCode(t->second);
    			break;

            case(TERM_3) :
    			PrintCode(t->first);
    			break;

/*VALUE*/
    		case(VALUE_CONSTANT) :
    			PrintCode(t->first);
    			break;

    		case(VALUE_ID) :
				printf("%s", symTab[t->item]->identifier);
				break;

    		case(VALUE_EX) :
    			printf(" (");
    			PrintCode(t->first);
    			printf(") ");
    			break;
/*CONSTANT*/
    		case(CONSTANT) :
    			PrintCode(t->first);
    			break;

    		case(CHAR_CONSTANT) :
    			if(boolConstant == 1)
    			{
    				printf("%%c\""", ");
    				printf("%s", symTab[t->item]->identifier);
    			}
    			else
    			{
    				printf("%s", symTab[t->item]->identifier);
    			}
				break;
				

	    	case(NUMBER_CONSTANT) :
		    	PrintCode(t->first);
		    	break;
    		
    		case(MINUS_NUMBER_CONSTANT) :
		    	printf("-");
		    	PrintCode(t->first);
		    	break;

/*TARGET_NUMBER*/
		    case(TARGET_NUMBER_INT) :
				if(boolConstant == 1)
    			{
    				printf("%%d\""", ");
    				printf("%d", t->item);
    			}
    			else
    			{
    				printf("%d", t->item);
    			}
				
				break;

			case(TARGET_NUMBER_FLO) :
				if(boolConstant == 1)
    			{
    				printf("%%f\""", ");
    				printf("%s", symTab[t->item]->identifier);
    			}
    			else
    			{
   					printf("%s", symTab[t->item]->identifier);
    			}
				
				break;

			
			case (identifier_SPL):
				printf("%s",symTab[t->item]->identifier);
			break;
			
			default:
			PrintCode(t->first);
			PrintCode(t->second);
			PrintCode(t->third);
			PrintCode(t->four);
			break;
        }
        
}

int FindReservedSymbol(char *id)
{
	int i;
	for (i=0; i<32; i++)
	{
		if(strcmp(id, ReservedSymbols[i]) == 0)
		{
			return 1;
		}	
	}
	return 0;
	
}
/*Looping through the tree to find the value of a constant*/
int FindExpVal(TERNARY_TREE t)
{
	if(t == NULL){
		return 0;
	}
	int floatFound = 0;
	if(t->nodeIdentifier == TARGET_NUMBER_FLO){
		floatFound = 1;
	}
	if(FindExpVal(t->first)){
		floatFound = 1;
	}
	if(FindExpVal(t->second)){
		floatFound = 1;
	}
	return floatFound;
}

#ifdef DEBUG
/* Put other auxiliary functions here */
void PrintTree(TERNARY_TREE t, int indent)
{
	int i;
	if(t == NULL) return;
	// do the indenting
	for(i=indent;i;i--)printf(" ");
	printf("Node identifier %s\n", NodeName[t->nodeIdentifier]);
	/* Val printing */
	if (t->item != NOTHING){
		for(i=indent;i;i--)printf(" ");
		if(t->nodeIdentifier == TARGET_NUMBER_INT)
		{
			printf(" INTEGER: %d ", t->item);

		}
		if(t->nodeIdentifier == TARGET_NUMBER_FLO)
		{
			printf(" FLOAT: %s ", symTab[t->item]->identifier);

		}
		else if(t->nodeIdentifier == VALUE_ID){
			printf(" VAL IDENTIFIER: %s\n", symTab[t->item]->identifier);

		}
		else if(t->nodeIdentifier == CHAR_CONSTANT)
		{
			printf(" CHAR CONSTANT: %s\n", symTab[t->item]->identifier);
			
		}
		else if(t->nodeIdentifier == identifier_SPL)
		{
			printf(" ID_SPL: %s\n", symTab[t->item]->identifier);
			
		}
	}
	PrintTree(t->first,indent+2);
	PrintTree(t->second,indent+2);
	PrintTree(t->third,indent+2);
	PrintTree(t->four,indent+2);
}
#endif 
#include "lex.yy.c"


































			