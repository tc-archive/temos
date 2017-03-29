build: 
	gcc -std=c99 -Wall awly.c mpc.c -ledit -lm -o awly

deps:
	curl -LO https://github.com/orangeduck/mpc/raw/master/mpc.h 
	curl -LO https://github.com/orangeduck/mpc/raw/master/mpc.c

clean:
	rm awly
