frag: frag.tab.o lex.yy.o tabSymb.o tabSymb.c
	gcc -o frag frag.c  frag.tab.o lex.yy.o tabSymb.o  -ll

frag.o: frag.c tabSymb.c
	gcc -c frag.c tabSymb.c

frag.tab.c frag.tab.h: frag.y
	bison -d frag.y --report=all -Wall

frag.tab.o: frag.tab.c tabSymb.c 
	gcc -c frag.tab.c 

lex.yy.o: frag.tab.h lex.yy.c tabSymb.c
	gcc -c lex.yy.c

lex.yy.c: frag.l 
	flex frag.l

tabSymb.o: tabSymb.h tabSymb.c
	gcc -c tabSymb.c
clean: 
	rm -rf *.o 