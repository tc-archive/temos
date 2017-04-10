CCFLAGS = -std=c99 -Wall

debug: CCFLAGS += -g
debug: hellomake

hellomake: helloworld.c helloworld_lib.c
	gcc $(CCFLAGS) -o helloworld helloworld.c helloworld_lib.c -I.

clean:
	rm -f helloworld
	rm -Rf helloworld.dSYM
