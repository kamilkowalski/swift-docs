ALL:    swift
 
CC=gcc

OBJ=build/swift_p.o build/swift_s.o build/tree.o build/shell_formatter.o build/html_formatter.o
DEPS=build/tree.h build/shell_formatter.h build/html_formatter.h

swift :	$(DEPS) $(OBJ)
		$(CC) -o $@ $(OBJ) -ll

build/tree.c :		src/tree.c
	cp src/tree.c build/tree.c

build/tree.h :		src/tree.h
	cp src/tree.h build/tree.h

build/shell_formatter.c :		src/shell_formatter.c
	cp src/shell_formatter.c build/shell_formatter.c

build/shell_formatter.h :		src/shell_formatter.h
	cp src/shell_formatter.h build/shell_formatter.h

build/html_formatter.c :		src/html_formatter.c
	cp src/html_formatter.c build/html_formatter.c

build/html_formatter.h :		src/html_formatter.h
	cp src/html_formatter.h build/html_formatter.h

build/swift_p.c : 		src/swift_p.y
	bison -v -d -o build/swift_p.c src/swift_p.y

build/swift_s.c :    src/swift_s.l
		flex -I -obuild/swift_s.c src/swift_s.l

clean:
		rm -f build/{swift,tree,shell_formatter,html_formatter}*
		rm -f swift
