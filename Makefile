ALL:    swift
 
CC=gcc

OBJ=	swift_p.o swift_s.o

swift :	$(OBJ)
		$(CC) -o $@ $(OBJ) -ll

swift_p.c : 		swift_p.y
	bison -v -d -o swift_p.c swift_p.y

swift_s.c :    swift_s.l
		flex -I -oswift_s.c swift_s.l

clean:
		rm -f swift_p.output swift_p.h swift_p.c swift_s.c swift
		rm -f *~
		rm -f *.o
		rm -f core
