ALL:    swift
 
CC=gcc

OBJ=build/swift_p.o build/swift_s.o build/docgen.o
DEPS=build/docgen.h

swift :	$(DEPS) $(OBJ)
		$(CC) -o $@ $(OBJ) -ll

build/docgen.c :		src/docgen.c
	cp src/docgen.c build/docgen.c

build/docgen.h :		src/docgen.h
	cp src/docgen.h build/docgen.h

build/swift_p.c : 		src/swift_p.y
	bison -v -d -o build/swift_p.c src/swift_p.y

build/swift_s.c :    src/swift_s.l
		flex -I -obuild/swift_s.c src/swift_s.l

clean:
		rm -f build/swift*
		rm -f swift
