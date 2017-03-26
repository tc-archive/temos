#include <stdio.h>
#include <stdlib.h>

#include <editline/readline.h>
// #include <editline/history.h>


int main (int argc, char** argv) {

    /* Print Prelude Header */
    puts("Awlyspian Version 0.0.2");
    puts("Press Ctrl-C to exit\n");

    /* Infinite REPL Loop */
    while (1) {
        
        /* Input Buffer */
        char* input = readline("awly> ");

        /* Store Input History*/
        add_history(input);
        
        /* Echo Input */
        printf("%s\n", input);

        /* Free Input Buffer */
        free(input);
    }

    return 0;
}
