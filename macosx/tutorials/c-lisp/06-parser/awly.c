#include <stdio.h>
#include <stdlib.h>

#include "mpc.h"

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

// Windows Headers and Proxy Functions
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

    /* Parsers */
    mpc_parser_t* Number   = mpc_new("number");
    mpc_parser_t* Operator = mpc_new("operator");
    mpc_parser_t* Expr     = mpc_new("expr");
    mpc_parser_t* Awly     = mpc_new("awly");

    /* Grammar */
    mpca_lang(MPCA_LANG_DEFAULT,
        "                                                                                           \
         number   : /-?[0-9]+\\.?[0-9]*/ ;                                                          \
         operator : '+' | '-' | '*' | '/' | '%' | \"add\" | \"sub\" | \"mul\" | \"div\" | \"mod\" ; \
         expr     : <number> | '(' <operator> <expr>+ ')' ;                                         \
         awly     : /^/ <operator> <expr>+ /$/ ;                                                    \
        ",
        Number, Operator, Expr, Awly);
   
    /* Print Prelude Header */
    puts("Awlyspian Version 0.0.4");
    puts("Press Ctrl-C to exit\n");

    /* Infinite REPL Loop */
    while (1) {
        /* Input Buffer */
        char* input = readline("awly> ");
        /* Store Input History*/
        add_history(input);
        /* ParseInput */
        mpc_result_t r;
        if (mpc_parse("<stdin>", input, Awly, &r)) {
            /* Success - Print AST */
            mpc_ast_print(r.output);
            mpc_ast_delete(r.output);
        } else {
            /* Error */
            mpc_err_print(r.error);
            mpc_err_delete(r.error);
        }
        /* Free Input Buffer */
        free(input);
    }

    /* Clean-up Parsers */
    mpc_cleanup(4, Number, Operator, Expr, Awly);

    return 0;
}
