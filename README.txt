Student: Marcin Limanski (442266)
Assignment: ACW, Languages and Compilers, 08348

Directory structure: 

SPL Binary files|
				 -> compiler.exe
				 -> lexer.exe
				 -> parser.exe
				 -> tree.exe 

SPL C Output|
			 -> a-output.txt
			 -> b-output.txt
			 -> c-output.txt
			 -> d-output.txt
			 -> e-output.txt
			 -> p1-output.txt
			 -> p2-output.txt
			 -> p3-output.txt
			 -> p4-output.txt

SPL Generated C|
				-> a.c
				-> b.c
				-> c.c
				-> d.c
				-> e.c
				-> p1.c
				-> p2.c
				-> p3.c
				-> p4.c

SPL Programs |
			  -> a.SPL
			  -> b.SPL
			  -> c.SPL
			  -> d.SPL
			  -> e.SPL
			  -> p1.SPL
			  -> p2.SPL
			  -> p3.SPL
			  -> p4.SPL

442266-code.txt (Output file from the RunCompiler.bat file
				includes generation of c code for a,b,c,d,e spl programs)

442266-parse.txt (Output file from the RunCompiler.bat file
				includes generation of parser for a,b,c,d,e spl programs)

442266-tokens.txt (Output file from the RunCompiler.bat file
				includes generation of tokens)

442266-tree.txt (Output file from the RunCompiler.bat file
				includes generation of parse-tree)

BNF.txt (Language description for SPL)

spl.l 

spl.y

spl.C

GENERATING COMPILER: (Run the following commands in cmd)
	flex/lex spl.l
	yacc/bison spl.y
	gcc -o compiler.exe spl.tab.c spl.c -ll
	compiler.exe < a.SPL