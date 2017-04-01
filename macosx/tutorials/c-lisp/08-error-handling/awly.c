#include <stdio.h>
#include <stdlib.h>
#include <math.h>
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

//-------------------------------------------------------------------------------------------------

/* Lisp Value Types */
enum { LVAL_NUM, LVAL_ERR };

/* Error Types */
enum { LERR_DIV_ZERO, LERR_BAD_OP, LERR_BAD_NUM };


union Data {
    double num;
    int err;
};

/* Lisp Value Structure */
typedef struct {
    int type;
    union Data data;
} lval;

/* Create a new lval number type */
lval lval_num(double x) {
    lval v;
    v.type = LVAL_NUM;
    v.data.num = x;
    return v;
}

/* Create a new lval error type */
lval lval_err(int x) {
    lval v;
    v.type = LVAL_ERR;
    v.data.err = x;
    return v;
}

/* Print an lval */
void lval_print(lval v) {
    switch (v.type) {
        case LVAL_NUM:
            printf("%g", v.data.num);
            break;
        case LVAL_ERR:
            switch (v.data.err) {
                case LERR_DIV_ZERO:
                    printf("Error: Division by 0");
                    break;
                case LERR_BAD_OP:
                    printf("Error: Bad Operation");
                    break;
                case LERR_BAD_NUM:
                    printf("Error: Bad Number");
                    break;
            }
        break;
    }
}

/* Println an lval */
void lval_println(lval v) {
    lval_print(v);
    putchar('\n');
}

//-------------------------------------------------------------------------------------------------

/* Execute Operation */
lval eval_op(lval x, char* op, lval y) {
    
    if (x.type == LVAL_ERR) { return x; }
    if (y.type == LVAL_ERR) { return y; }

    if (strcmp(op, "+") == 0) { return lval_num(x.data.num + y.data.num); }
    if (strcmp(op, "-") == 0) { return lval_num(x.data.num - y.data.num); }
    if (strcmp(op, "*") == 0) { return lval_num(x.data.num * y.data.num); }
    if (strcmp(op, "/") == 0) { 
        return  (y.data.num != 0) 
            ? lval_num(x.data.num / y.data.num)
            : lval_err(LERR_DIV_ZERO);
    }
    if (strcmp(op, "%") == 0) { return lval_num(fmod(x.data.num, y.data.num)); }
    if (strcmp(op, "^") == 0) { return lval_num(pow(x.data.num, y.data.num)); }
    if (strcmp(op, "add") == 0) { return lval_num(x.data.num + y.data.num); }
    if (strcmp(op, "sub") == 0) { return lval_num(x.data.num - y.data.num); }
    if (strcmp(op, "mul") == 0) { return lval_num(x.data.num * y.data.num); }
    if (strcmp(op, "div") == 0) { return lval_num(x.data.num / y.data.num); }
    if (strcmp(op, "mod") == 0) { return lval_num(fmod(x.data.num, y.data.num)); }
    if (strcmp(op, "exp") == 0) { return lval_num(pow(x.data.num, y.data.num)); }
    if (strcmp(op, "max") == 0) { return (x.data.num >= y.data.num) ? x : y; }
    if (strcmp(op, "min") == 0) { return (x.data.num <= y.data.num) ? x : y; }
    return lval_num(0);
}

/* Pqrse Tree */
lval  eval(mpc_ast_t* t) {

    /* If tagged as a Number return the value */
    if (strstr(t->tag, "number")) {
        errno = 0;
        char *end;
        double x = strtod(t->contents, &end);
        return errno != ERANGE ? lval_num(x) : lval_err(LERR_BAD_NUM);
    }
    
    /* Operator is always the second child */
    char* op = t->children[1]->contents;

    /* Store the third child in 'x' */
    lval x = eval(t->children[2]);
    
    /* Iterate the remaining children and combining */
    int i = 3;
    while (strstr(t->children[i]->tag, "expr")) {
        x = eval_op(x, op, eval(t->children[i]));
        i++;
    }

    return x;
}

int main (int argc, char** argv) {

    /* Parsers */
    mpc_parser_t* Number   = mpc_new("number");
    mpc_parser_t* Operator = mpc_new("operator");
    mpc_parser_t* Expr     = mpc_new("expr");
    mpc_parser_t* Awly     = mpc_new("awly");

    /* Grammar */
    mpca_lang(MPCA_LANG_DEFAULT,
        "                                                                       \
         number   : /-?[0-9]+\\.?[0-9]*/ ;                                      \
         operator : '+' | '-' | '*' | '/' | '%' | '^'                           \
                    | \"add\" | \"sub\" | \"mul\" | \"div\" | \"mod\" | \"exp\" \
                    | \"min\" | \"max\" ;                                       \
         expr     : <number> | '(' <operator> <expr>+ ')' ;                     \
         awly     : /^/ <operator> <expr>+ /$/ ;                                \
        ",
        Number, Operator, Expr, Awly);
   
    /* Print Prelude Header */
    puts("Awlyspian Version 0.0.6");
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
            // mpc_ast_print(r.output);
            /* Print Results */
            lval result = eval(r.output);
            lval_println(result);
            /* Clean */
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
