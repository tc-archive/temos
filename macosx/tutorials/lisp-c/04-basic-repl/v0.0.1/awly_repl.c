#include <stdio.h>

/* Input Buffer */
#define BUF_SIZE 2048

static char input[BUF_SIZE]; 

int main (int argc, char** argv) {

    /* Print Prelude Header */
    puts("Awlyspian Version 0.0.1");
    puts("Press Ctrl-C to exit\n");

    /* Infinite REPL Loop */
    while (1) {

        /* Display Prompt */
        fputs("awly> ", stdout);
        
        /* Read User Input */
        fgets(input, BUF_SIZE, stdin);

        /* Echo Input */
        printf("%s\n", input);
    }

    return 0;
}
