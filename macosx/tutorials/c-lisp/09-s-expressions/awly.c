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
enum { LVAL_NUM, LVAL_ERR, LVAL_SYM, LVAL_SEXPR };

/* Lisp Value Structure */
typedef struct lval {
    int type;
    // lval data variables
    float num;   // number
    char* sym;   // symbol strings
    char* err;   // errors
    // pointer to list of pointers to lvals.
    int count;
    struct lval** cell;
} lval;

/* Create a new lval number type */
lval* lval_num(double x) {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_NUM;
    v->num = x;
    return v;
}

/* Create a new lval symbol type */
lval* lval_sym(char* s) {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_SYM;
    v->sym = malloc(strlen(s) +1);
    strcpy(v->sym, s);
    return v;
}

/* Create a new lval error type */
lval* lval_err(char* e) {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_ERR;
    v->err = malloc(strlen(e) +1);
    strcpy(v->err, e);
    return v;
}

/* Create a new lval sexpr type */
lval* lval_sexpr() {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_SEXPR;
    v->count = 0;
    v->cell = NULL;
    return v;
}

/* read the lval from the */
lval* lval_read_num(mpc_ast_t* t) {
    errno = 0;
    char *end;
    double x = strtod(t->contents, &end);
    return errno != ERANGE 
        ? lval_num(x) 
        : lval_err("invalid number");
}

/* Add lval x as a child of lval v.*/
lval* lval_add(lval* v, lval* x) {
    v->count++;
    v->cell = realloc(v->cell, sizeof(lval*) * v->count);
    v->cell[v->count-1] = x;
    return v;
}

/* reader - create empty lval expression from ast node */
lval* lval_read(mpc_ast_t* t) {
    
    /* handle numbers and synbols */
    if (strstr(t->tag, "number")) { return lval_read_num(t) ; }
    if (strstr(t->tag, "symbol")) { return lval_sym(t->contents) ; }
    
    /* handle root ('>') and sexpr */
    lval* x = NULL;
    if (strcmp(t->tag, ">") == 0) { x = lval_sexpr(); }
    if (strcmp(t->tag, "sexpr")) { x = lval_sexpr(); }

    for (int i = 0; i < t->children_num; i++) {
        if (strcmp(t->children[i]->contents, "(") == 0) { continue; }
        if (strcmp(t->children[i]->contents, ")") == 0) { continue; }
        if (strcmp(t->children[i]->contents, "{") == 0) { continue; }
        if (strcmp(t->children[i]->contents, "}") == 0) { continue; }
        if (strcmp(t->children[i]->tag,  "regex") == 0) { continue; }
        x = lval_add(x, lval_read(t->children[i]));
    }

    return x;
}

/* Free the memoory allocated to the lval struct */
void lval_del(lval* v) {

    switch (v->type) {
        case LVAL_NUM:
            // nothing to free
            break;
        case LVAL_ERR:
            // free the error string
            free(v->err);
            break;
        case LVAL_SYM:
            // free the symbol string
            free(v->sym);
            break;
        case LVAL_SEXPR:
            // free each referenced child lval cell
            for (int i = 0; i < v->count; i++) {
                lval_del(v->cell[i]);
            }
            break;
    }
    // free the lval struct itself
    free(v);
}

// declare lval_print
void lval_print(lval* v);

/* print lval sexpr */
void lval_expr_print(lval* v, char open, char close) {
    putchar(open);
    for (int i = 0; i < v->count; i++) {
        lval_print(v->cell[i]);
        // print space between each element except th elast
        if (i != (v->count-1)) {
            putchar(' ');
        }
    }
    putchar(close);
}

/* Print an lval */
void lval_print(lval* v) {
    switch (v->type) {
        case LVAL_NUM:   printf("%g", v->num); break;
        case LVAL_ERR:   printf("error: %s", v->err); break;
        case LVAL_SYM:   printf("%s", v->sym); break;
        case LVAL_SEXPR: lval_expr_print(v, '(', ')'); break;
    }
}

/* Println an lval */
void lval_println(lval* v) {
    lval_print(v);
    putchar('\n');
}

//-------------------------------------------------------------------------------------------------

/* Execute Operation */
/*
lval* eval_op(lval x, char* op, lval y) {
    
    if (x.type == LVAL_ERR) { return x; }
    if (y.type == LVAL_ERR) { return y; }

    if (strcmp(op, "+") == 0) { return lval_num(x.num + y.num); }
    if (strcmp(op, "-") == 0) { return lval_num(x.num - y.num); }
    if (strcmp(op, "*") == 0) { return lval_num(x.num * y.num); }
    if (strcmp(op, "/") == 0) { 
        return  (y.num != 0) 
            ? lval_num(x.num / y.num)
            : lval_err(LERR_DIV_ZERO);
    }
    if (strcmp(op, "%") == 0) { return lval_num(fmod(x.num, y.num)); }
    if (strcmp(op, "^") == 0) { return lval_num(pow(x.num, y.num)); }
    if (strcmp(op, "add") == 0) { return lval_num(x.num + y.num); }
    if (strcmp(op, "sub") == 0) { return lval_num(x.num - y.num); }
    if (strcmp(op, "mul") == 0) { return lval_num(x.num * y.num); }
    if (strcmp(op, "div") == 0) { return lval_num(x.num / y.num); }
    if (strcmp(op, "mod") == 0) { return lval_num(fmod(x.num, y.num)); }
    if (strcmp(op, "exp") == 0) { return lval_num(pow(x.num, y.num)); }
    if (strcmp(op, "max") == 0) { return (x.num >= y.num) ? x : y; }
    if (strcmp(op, "min") == 0) { return (x.num <= y.num) ? x : y; }
    return lval_num(0);
}
*/

/* Pqrse Tree */
/*
lval  eval(mpc_ast_t* t) {

    // If tagged as a Number return the value
    if (strstr(t->tag, "number")) {
        errno = 0;
        char *end;
        double x = strtod(t->contents, &end);
        return errno != ERANGE ? lval_num(x) : lval_err(LERR_BAD_NUM);
    }
    
    // Operator is always the second child
    char* op = t->children[1]->contents;

    // Store the third child in 'x'
    lval x = eval(t->children[2]);
    
    // Iterate the remaining children and combining
    int i = 3;
    while (strstr(t->children[i]->tag, "expr")) {
        x = eval_op(x, op, eval(t->children[i]));
        i++;
    }

    return x;
}
*/

int main (int argc, char** argv) {

    /* Parsers */
    mpc_parser_t* Number = mpc_new("number");
    mpc_parser_t* Symbol = mpc_new("symbol");
    mpc_parser_t* Sexpr  = mpc_new("sexpr");
    mpc_parser_t* Expr   = mpc_new("expr");
    mpc_parser_t* Awly   = mpc_new("awly");

    /* Grammar */
    mpca_lang(MPCA_LANG_DEFAULT,
        "                                                                       \
         number   : /-?[0-9]+\\.?[0-9]*/ ;                                      \
         symbol   : '+' | '-' | '*' | '/' | '%' | '^'                           \
                    | \"add\" | \"sub\" | \"mul\" | \"div\" | \"mod\" | \"exp\" \
                    | \"min\" | \"max\" ;                                       \
         sexpr    : '(' <expr>* ')' ;                                           \
         expr     : <number> | <symbol> | <sexpr> ;                             \
         awly     : /^/ <expr>* /$/ ;                                           \
        ",
        Number, Symbol, Sexpr, Expr, Awly);
   
    /* Print Prelude Header */
    puts("Awlyspian Version 0.0.6");
    puts("Press Ctrl-C to exit\n");

    /* Infinite REPL Loop */
    while (1) {
        // Input Buffer
        char* input = readline("awly> ");
        // Store Input History
        add_history(input);
        // ParseInput
        mpc_result_t r;
        if (mpc_parse("<stdin>", input, Awly, &r)) {
            // Success - Print AST 
            mpc_ast_print(r.output);
            /* Print Results */
            lval* x = lval_read(r.output);
            lval_println(x);
            lval_del(x);
            // lval result = eval(r.output);
            // lval_println(result);
            // Clean
            mpc_ast_delete(r.output);
        } else {
            // Error
            mpc_err_print(r.error);
            mpc_err_delete(r.error);
        }
        // Free Input Buffer
        free(input);
    }

    // Clean-up Parsers
    mpc_cleanup(5, Number, Symbol, Sexpr, Expr, Awly);

    return 0;
}
