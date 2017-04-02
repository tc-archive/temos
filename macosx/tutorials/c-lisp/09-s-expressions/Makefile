CCFLAGS = -std=c99 -Wall

build: mpc.h mpc.c
	gcc $(CCFLAGS) awly.c mpc.c -ledit -lm -o awly

debug: CCFLAGS += -g
debug: build

mpc.h:
	curl -LO https://github.com/orangeduck/mpc/raw/master/mpc.h

mpc.c:	
	curl -LO https://github.com/orangeduck/mpc/raw/master/mpc.c

clean:
	rm -f awly
	rm -Rf awly.dSYM 

clean-all: clean
	rm -f mpc.h
	rm -f mpc.c
