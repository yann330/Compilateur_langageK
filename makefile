frag: frag.tab.o lex.yy.o 
	gcc -o frag frag.c frag.tab.o lex.yy.o  -ll

frag.o: frag.c
	gcc -c frag.c

frag.tab.c frag.tab.h: frag.y
	bison -d frag.y --report=all

frag.tab.o: frag.tab.c 
	gcc -c frag.tab.c

lex.yy.o: frag.tab.h lex.yy.c 
	gcc -c lex.yy.c

lex.yy.c: frag.l 
	flex frag.l