#include <stdio.h>
#include <stdlib.h>

// Linux Headers
//
#ifdef linux
#include <editline/readline.h>
#include <editline/history.h>
#endif

// OSX Headers
//
#ifdef __MACH__
#include <editline/readline.h>
#endif

// Windows Headers
//
#ifdef _WIN32
#include <string.h>

#define BUF_SIZE 2048

static char input[BUF_SIZE];

/* Windows Proxy Function */
char* readline(char* prompt) {
    fputs(prompt, stdout);
    fgets(buffer, BUF_SIZE, stdin);
    char* cpy = malloc(strlen(buffer) + 1 );
    cpy[strlen(cpy) - 1] = '\0';
    return cpy;
}

/* Windows Proxy Function */
void add_history(char proxy);
#endif

int main (int argc, char** argv) {

    /* Print Prelude Header */
    puts("Awlyspian Version 0.0.3");
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
