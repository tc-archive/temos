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

// declare lval_print
void lval_expr_print(lval* v, char s, char e);
void lval_print(lval* v);
void lval_println(lval* v);

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
    if (strstr(t->tag, "sexpr")) { x = lval_sexpr(); }

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
// evaluation

// extract a single value from an s-expression and shift the rest of the lval list elements backwards 
// such that the lval list no longer contains the element.
lval* lval_pop(lval* v, int i) {
    // find the lval item at i
    lval* x = v->cell[i];
    // shift memory after i over down to fill the removed element
    // => memmove(destinaiton array ptr, source array ptr, number of bytes to copy)
    memmove(&v->cell[i], &v->cell[i+1], sizeof(lval*) * (v->count - i - 1));
    // decrement count
    v->count--;
    // reallocate v cell memory to be consistent with new size
    // => realloc(target array, new size in bytes)
    v->cell = realloc(v->cell, sizeof(lval*) * v->count);
    return x;
}

// 
lval* lval_take(lval* v, int i) {
    lval* x = lval_pop(v, i);
    lval_del(v);
    return x;
}

// execute operation
lval* builtin_op(lval* a, char* op) {
    // ensure all arguments are numbeers
    for (int i = 0; i < a->count; i++) {
        if (a->cell[i]->type != LVAL_NUM) {
            lval_del(a);
            return lval_err("cannot operate on non-number");
        }
    }
    // pop the first element
    lval* x = lval_pop(a, 0);
    // if no arguments and unary sun operation the execute
    if ((strcmp(op, "-") == 0) && a->count == 0) {
        x->num = - x->num;
    }
    // process remaining elements
    while (a->count > 0) {
        lval* y = lval_pop(a, 0);
        if (strcmp(op, "+") == 0 || strcmp(op, "add") == 0) { 
            x->num += y->num; 
        }
        else if (strcmp(op, "-") == 0 || strcmp(op, "sub") == 0) { 
            x->num -= y->num; 
        }
        else if (strcmp(op, "*") == 0 || strcmp(op, "mul") == 0) { 
            x->num *= y->num; 
        }
        else if (strcmp(op, "/") == 0 || strcmp(op, "div") == 0) {
            if (y->num == 0) {
                lval_del(x);
                lval_del(y);
                x = lval_err("division by zero");
                break;
            }
            x->num /= y->num; 
        }
        else if (strcmp(op, "%") == 0 || strcmp(op, "mod") == 0) { 
            x->num = fmod(x->num, y->num); 
        }
        else if (strcmp(op, "^") == 0 || strcmp(op, "pow") == 0) { 
            x->num = pow(x->num, y->num); 
        }
        else if (strcmp(op, "max") == 0) { 
            x->num = (x->num >= y->num) ? x->num : y->num; 
        }
        else if (strcmp(op, "min") == 0) { 
            x->num = (x->num <= y->num) ? x->num : y->num; 
        }
        lval_del(y);
    }
    lval_del(a);
    return x;
}


// declare lval_eval_sexpr
lval* lval_eval_sexpr(lval* v);

// evaluate lval
lval* lval_eval(lval* v) {
    // evaluate s-expression
    if (v->type == LVAL_SEXPR) {
        return lval_eval_sexpr(v);
    }
    // return all other type as is
   return v;
}

// evaluate sexpr
//
lval* lval_eval_sexpr(lval* v) {
    // evaluate child cells
    for (int i = 0; i < v->count; i++) {
        v->cell[i] = lval_eval(v->cell[i]);
    }
    // error checking
    for (int i = 0; i < v->count; i++) {
        if (v->cell[i]->type == LVAL_ERR) {
            return lval_take(v, i);
        }
    }
    // empty expression
    if (v->count == 0) {
        return v;
    }
    // single expression
    if (v->count == 1) {
        return lval_take(v, 0);
    }
    // ensure first element is a symbol
    lval* f = lval_pop(v, 0);
    if (f->type != LVAL_SYM) {
        lval_del(f);
        lval_del(v);
        return lval_err("s-expression does not start with a symbol");
    }
    // call builtin with operator
    lval* result = builtin_op(v, f->sym);
    lval_del(f);
    return result;
}

// main
int main (int argc, char** argv) {

    // Parsers
    mpc_parser_t* Number = mpc_new("number");
    mpc_parser_t* Symbol = mpc_new("symbol");
    mpc_parser_t* Sexpr  = mpc_new("sexpr");
    mpc_parser_t* Expr   = mpc_new("expr");
    mpc_parser_t* Awly   = mpc_new("awly");

    // Grammar
    mpca_lang(MPCA_LANG_DEFAULT,
        "                                                                       \
         number   : /-?[0-9]+\\.?[0-9]*/ ;                                      \
         symbol   : '+' | '-' | '*' | '/' | '%' | '^'                           \
                    | \"add\" | \"sub\" | \"mul\" | \"div\" | \"mod\" | \"pow\" \
                    | \"min\" | \"max\" ;                                       \
         sexpr    : '(' <expr>* ')' ;                                           \
         expr     : <number> | <symbol> | <sexpr> ;                             \
         awly     : /^/ <expr>* /$/ ;                                           \
        ",
        Number, Symbol, Sexpr, Expr, Awly);
   
    // Print Prelude Header
    puts("Awlyspian Version 0.0.7");
    puts("Press Ctrl-C to exit\n");

    // Infinite REPL Loop
    while (1) {
        // Input Buffer
        char* input = readline("awly> ");
        // Store Input History
        add_history(input);
        // ParseInput
        mpc_result_t r;
        if (mpc_parse("<stdin>", input, Awly, &r)) {
            // Success - Print AST 
            // mpc_ast_print(r.output);
            // Print Results
            lval* ast = lval_read(r.output);
            // lval_println(ast);
            lval* e_ast = lval_eval(ast);
            lval_println(e_ast);
            lval_del(e_ast);
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
