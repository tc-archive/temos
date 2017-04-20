#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

// forward struct definitions
//
struct lval;
struct lenv;
typedef struct lval lval;
typedef struct lenv lenv;

// define a functin pointer type 'builtin'
//  * inputs: pointer to lenv struct,  pointer to lval sturct
//  * output: pointer to lval struct
//
typedef lval*(*lbuiltin)(lenv*, lval*);

/* Lisp Value Types */
enum { LVAL_NUM, LVAL_ERR, LVAL_SYM, LVAL_FUN, LVAL_SEXPR, LVAL_QEXPR };

// declare lval_print
void lval_expr_print(lval* v, char s, char e);
void lval_print(lval* v);
void lval_println(lval* v);

// Lisp Value Structure
struct lval {
    int type;
    // lval data variables
    float num;      // number
    char* err;      // errors
    char* sym;      // symbol
    
    // function
    lbuiltin builtin;   // builtin function pointer
    lenv* env;          // function environment
    lval* formals;      // function formal parameters
    lval* body;         // function body
    
    // expression.
    int count;
    lval** cell;
};

// Create a new lval number type/
lval* lval_num(double x) {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_NUM;
    v->num = x;
    return v;
}

lval* lval_err(char* fmt, ...) {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_ERR;
    // create and initialise va list
    va_list va;
    va_start(va, fmt);
    v->err = malloc(512);
    // print/truncate error string
    vsnprintf(v->err, 511, fmt, va);
    v->err = realloc(v->err, strlen(v->err) + 1);
    // cleanup va list
    va_end(va);
    return v;
}

// Create a new lval symbol type
lval* lval_sym(char* s) {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_SYM;
    v->sym = malloc(strlen(s) + 1);
    strcpy(v->sym, s);
    return v;
}

// lval function pointer type constructor
lval* lval_fun(lbuiltin func, char* name) {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_FUN;
    v->sym = malloc(strlen(name) + 1);
    strcpy(v->sym, name);
    v->builtin = func;
    return v;
}

lenv* lenv_new(void);

lval* lval_lambda(lval* formals, lval* body) {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_FUN;
    v->builtin = NULL;      // not a builtin
    v->env = lenv_new();    // new environment
    v->formals = formals;   // set formals
    v->body = body;         // set body
    return v;
}

// Create a new lval sexpr type
lval* lval_sexpr() {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_SEXPR;
    v->count = 0;
    v->cell = NULL;
    return v;
}

// Create a new lval qexpr type
lval* lval_qexpr() {
    lval* v = malloc(sizeof(lval));
    v->type = LVAL_QEXPR;
    v->count = 0;
    v->cell = NULL;
    return v;
}

void lenv_del(lenv* e);

// Free the memoory allocated to the lval struct
void lval_del(lval* v) {
    switch (v->type) {
        case LVAL_NUM:
            // nothing to free
            break;
        case LVAL_SYM:
            free(v->sym);
            break;
        case LVAL_ERR:
            free(v->err);
            break;
        case LVAL_FUN:
            if (v->builtin) {
                // function name bound to sym..
                free(v->sym);
            } else {
                lenv_del(v->env);
                lval_del(v->formals);
                lval_del(v->body);
            }
            break;
        case LVAL_QEXPR:
        case LVAL_SEXPR:
            // free each referenced child lval cell
            for (int i = 0; i < v->count; i++) {
                lval_del(v->cell[i]);
            }
            break;
            // free memory used to allocate the pointers
            free(v->cell);
    }
    // free the lval struct itself
    free(v);
}

lenv* lenv_copy(lenv* v);

// copy an lval to a new location
lval* lval_copy(lval* v) {

    lval* x = malloc(sizeof(lval));
    x->type = v->type;

    switch (v->type) {
        // copy functions and numbers directly
        case LVAL_NUM:
            x->num = v->num;
            break;
        // copy error anc symbol strings using malloc and strcpy
        case LVAL_ERR:
            x->err = malloc(strlen(v->err) + 1);
            strcpy(x->err, v->err);
            break;
        case LVAL_SYM:
            x->sym = malloc(strlen(v->sym) + 1);
            strcpy(x->sym, v->sym);
            break;
        case LVAL_FUN: 
            if (v->builtin) {
                x->builtin = v->builtin;
                x->sym = malloc(strlen(v->sym) + 1);
                strcpy(x->sym, v->sym);
            }
            else {
                x->builtin = NULL;
                x->env = lenv_copy(v->env);
                x->formals = lval_copy(v->formals);
                x->body = lval_copy(v->body);
            }
            break;
        // copy lists by copying each sub expression
        case LVAL_SEXPR:
        case LVAL_QEXPR:
            x->count = v->count;
            x->cell = malloc(sizeof(lval*) * x->count);
            for (int i = 0; i < x->count; i++) {
                x->cell[i] = lval_copy(v->cell[i]);
            }
            break;
    }
    return x;
}

// Add lval x as a child of lval v.
lval* lval_add(lval* v, lval* x) {
    v->count++;
    v->cell = realloc(v->cell, sizeof(lval*) * v->count);
    v->cell[v->count-1] = x;
    return v;
}

// Add the cells of lval 'x' to the cells of lval 'v'.
lval* lval_join(lval* x, lval* y) {
    // add each cell in x to the cells in v,
    for (int i = 0; i < y->count; i++) {
        x = lval_add(x, y->cell[i]);
    }
    // delete the now empty x and return v
    free(y->cell);
    free(y);
    return x;
}

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


void lval_print(lval* v);

void lval_print_expr(lval* v, char open, char close) {
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

void lval_print(lval* v) {
    switch (v->type) {
        case LVAL_FUN:   
            if (v->builtin) {
                printf("<function>: %s", v->sym);
            } else {
                printf("(\\ "); 
                lval_print(v->formals);
                putchar(' ');
                lval_print(v->body);
                putchar(')');
            }
            break;
        case LVAL_NUM:   printf("%g", v->num); break;
        case LVAL_ERR:   printf("error: %s", v->err); break;
        case LVAL_SYM:   printf("%s", v->sym); break;
        case LVAL_SEXPR: lval_print_expr(v, '(', ')'); break;
        case LVAL_QEXPR: lval_print_expr(v, '{', '}'); break;
    }
}

//Println an lval
void lval_println(lval* v) {
    lval_print(v);
    putchar('\n');
}


char* ltype_name(int t) {
    switch (t) {
        case LVAL_FUN:   return "Function";
        case LVAL_NUM:   return "Number";
        case LVAL_ERR:   return "Error";
        case LVAL_SYM:   return "Symbol";
        case LVAL_SEXPR: return "S-Expression";
        case LVAL_QEXPR: return "Q-Expression";
        default:         return "Unknown";
    }
}



//-------------------------------------------------------------------------------------------------
// lenv - environment

struct lenv {
    lenv* par;
    int count;
    char** syms;
    lval** vals;
};

lenv* lenv_new(void) {
    lenv* e = malloc(sizeof(lenv));
    e->par = NULL;
    e->count = 0;
    e->syms = NULL;
    e->vals = NULL;
    return e;
}

void lenv_del(lenv* e) {
    for (int i = 0; i < e->count; i++) {
        free(e->syms[i]);
        lval_del(e->vals[i]);
    }
    free(e->syms);
    free(e->vals);
    free(e);
}

lenv* lenv_copy(lenv* e) {
    lenv* n = malloc(sizeof(lenv));
    n->par = e->par;
    n->count = e->count;
    n->syms = malloc(sizeof(char*) * n->count);
    n->vals = malloc(sizeof(lval*) * n->count);
    for (int i = 0; i < e->count; i++) {
        n->syms[i] = malloc(strlen(e->syms[i]) + 1);
        strcpy(n->syms[i], e->syms[i]);
        n->vals[i] = lval_copy(e->vals[i]);
    }
    return n;
}

lval* lenv_get(lenv* e, lval* k) {
    for (int i = 0; i < e->count; i++) {
        if (strcmp(e->syms[i], k->sym) == 0) {
            return lval_copy(e->vals[i]);
        }
    }
    if (e->par) {
        return lenv_get(e->par, k);
    } else {
        return lval_err("unbound symbol '%s'", k->sym);
    }
}

// enivronment, key, value
void lenv_put(lenv* e, lval* k, lval* v) {
    // if the environment key  is in use delete the current value and replace it with the new one
    for (int i = 0; i < e->count; i++) {
        if (strcmp(e->syms[i], k->sym) == 0) {
            lval_del(e->vals[i]);
            e->vals[i] = lval_copy(v);
            return;
        }
    }
    // otherwise create space for the new key value pair in the environment
    e->count++;
    e->vals = realloc(e->vals, sizeof(lval*) * e->count);
    e->syms = realloc(e->syms, sizeof(char*) * e->count);
    // copy contents of new key-value pair to environment
    e->vals[e->count - 1] = lval_copy(v);
    e->syms[e->count - 1] = malloc(strlen(k->sym) + 1);
    strcpy(e->syms[e->count - 1], k->sym);
}

void lenv_def(lenv* e, lval* k, lval* v) {
    // iterate till e has no parent
    while (e->par) {
        e = e->par;
    }
    lenv_put(e, k, v);
}

void lenv_print(lenv* e) {
    for (int i = 0; i < e->count; i++) {
        char* sym = e->syms[i];
        lval* lval = e->vals[i];
        printf("env[%i]: %s => ", i, sym);
        lval_println(lval);
    }
}

//-------------------------------------------------------------------------------------------------
// built-ins
//

#define LASSERT(args, cond, fmt, ...)               \
    if (!(cond)) {                                  \
        lval* err = lval_err(fmt, ##__VA_ARGS__);   \
        lval_del(args);                             \
        return err;                                 \
    }

#define LASSERT_TYPE(func, args, index, expect)                                         \
    LASSERT(args, args->cell[index]->type == expect,                                    \
    "Function '%s' passsed incorrect type for arguments %i. Got %s, but, expected %s.", \
    func, index, ltype_name(args->cell[index]->type), ltype_name(expect))

#define LASSERT_NUM(func, args, num)                                                    \
    LASSERT(args, args->count == num,                                                   \
    "Function '%s' passsed incorrect type for arguments %i. Got %i, but, expected %i.", \
    func, args->count, num)

#define LASSERT_NOT_EMPTY(func, args, index)      \
    LASSERT(args, args->cell[index]->count != 0,  \
    "Function '%s' passsed {} for arguments %i.", \
    func, index);

lval* lval_eval(lenv* e, lval* v);

lval* builtin_lambda(lenv* e, lval* a) {
    // check two arguments - both must be q-expressions
    LASSERT_NUM("\\", a, 2);
    LASSERT_TYPE("\\", a, 0, LVAL_QEXPR);
    LASSERT_TYPE("\\", a, 1, LVAL_QEXPR);
    // check first expression contains only synbols
    for (int i = 0; i < a->cell[0]->count; i++) {
        LASSERT(a, (a->cell[0]->cell[i]->type == LVAL_SYM),
                "Cannot define non-symbol. Got %s, expected %s.",
                ltype_name(a->cell[0]->cell[i]->type), ltype_name(LVAL_SYM));
    }
    // pop first two aruments and pass them to lval_lambda
    lval* formals = lval_pop(a, 0);
    lval* body = lval_pop(a, 0);
    lval_del(a);

    return lval_lambda(formals, body);
}

lval* lval_eval(lenv* e, lval* v);

lval* builtin_list(lenv* e, lval* a) {
    a->type = LVAL_QEXPR;
    return a;
}

lval* builtin_head(lenv* e, lval* a) {
    LASSERT_NUM("head", a, 1);
    LASSERT_TYPE("head", a, 0, LVAL_QEXPR);
    LASSERT_NOT_EMPTY("head", a, 0);

    lval* v = lval_take(a, 0);
    while (v->count > 1) { lval_del(lval_pop(v, 1)); }
    return v;
}

lval* builtin_tail(lenv* e, lval* a) {
    LASSERT_NUM("tail", a, 1);
    LASSERT_TYPE("tail", a, 0, LVAL_QEXPR);
    LASSERT_NOT_EMPTY("tail", a, 0);

    lval* v = lval_take(a, 0);
    lval_del(lval_pop(v, 0));
    return v;
}

lval* builtin_eval(lenv* e, lval* a) {
    LASSERT_NUM("eval", a, 1);
    LASSERT_TYPE("eval", a, 0, LVAL_QEXPR);
    
    lval* x = lval_take(a, 0);
    x->type = LVAL_SEXPR;
    return lval_eval(e, x);
}

lval* builtin_join(lenv* e, lval* a) {
    for (int i = 0; i < a->count; i++) {
        LASSERT_TYPE("join", a, i, LVAL_QEXPR);
    }

    lval* x = lval_pop(a, 0);

    while (a->count) {
        x = lval_join(x, lval_pop(a, 0));
    }

    lval_del(x);
    return x;
}

lval* builtin_op(lenv* e, lval* a, char* op) {
    // ensure all arguments are numbeers
    for (int i = 0; i < a->count; i++) {
        LASSERT_TYPE(op, a, i, LVAL_NUM);
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
        if (strcmp(op, "+") == 0) { 
            x->num += y->num; 
        }
        else if (strcmp(op, "-") == 0) { 
            x->num -= y->num; 
        }
        else if (strcmp(op, "*") == 0) { 
            x->num *= y->num; 
        }
        else if (strcmp(op, "/") == 0) {
            if (y->num == 0) {
                lval_del(x);
                lval_del(y);
                x = lval_err("division by zero");
                break;
            }
            x->num /= y->num; 
        }
        else if (strcmp(op, "%") == 0) { 
            x->num = fmod(x->num, y->num); 
        }
        else if (strcmp(op, "^") == 0) { 
            x->num = pow(x->num, y->num); 
        }
        else { 
            x = lval_err("unknown builtin_op");
        }
        lval_del(y);
    }
    lval_del(a);
    return x;
}

lval* builtin_add(lenv* e, lval* a) {
    return builtin_op(e, a, "+");
}

lval* builtin_sub(lenv* e, lval* a) {
    return builtin_op(e, a, "-");
}

lval* builtin_mul(lenv* e, lval* a) {
    return builtin_op(e, a, "*");
}

lval* builtin_div(lenv* e, lval* a) {
    return builtin_op(e, a, "/");
}

lval* builtin_mod(lenv* e, lval* a) {
    return builtin_op(e, a, "%");
}

lval* builtin_pow(lenv* e, lval* a) {
    return builtin_op(e, a, "^");
}

// define an environment variable
lval* builtin_var(lenv* e, lval* a, char* func) {
    LASSERT_TYPE("def", a, 0, LVAL_QEXPR);
    // first argument is symbol list
    lval* syms = a->cell[0];
    // ensure all elements of first list are symbols
    for (int i = 0; i < syms->count; i++) {
        LASSERT(a, syms->cell[i]->type == LVAL_SYM,
                "Function '%s' cannot define non-symbol. Got %s. expected %s.",
                func,
                ltype_name(syms->cell[i]->type),
                ltype_name(LVAL_SYM));
    }
    // check correct number of symbols and values
    LASSERT(a, (syms->count == a->count - 1),
            "Function '%s' passed too many arguments for symbols. Got %i, expected %i.",
            func,
            syms->count,
            a->count - 1);
    // add copies of key value pairs to environment
    for (int i = 0; i < syms->count; i++) {
        if (strcmp(func, "def") == 0) {
            lenv_def(e, syms->cell[i], a->cell[i + 1]);
        }
        if (strcmp(func, "=") == 0) {
            lenv_put(e, syms->cell[i], a->cell[i + 1]);
        }
    }
    lval_del(a);
    return lval_sexpr();
}


lval* builtin_def(lenv* e, lval* a) {
    return builtin_var(e, a, "def");
}

lval* builtin_put(lenv* e, lval* a) {
    return builtin_var(e, a, "=");
}

void lenv_add_builtin(lenv* e, char* name, lbuiltin func) {
    lval* k = lval_sym(name);
    lval* v = lval_fun(func, name);
    lenv_put(e, k, v);
    lval_del(k);
    lval_del(v);
}

void lenv_add_builtins(lenv* e) {
    lenv_add_builtin(e, "\\",  builtin_lambda);
    lenv_add_builtin(e, "def", builtin_def);
    lenv_add_builtin(e, "=", builtin_put); // local variable assignment
    // list functions
    lenv_add_builtin(e, "list", builtin_list);
    lenv_add_builtin(e, "head", builtin_head);
    lenv_add_builtin(e, "tail", builtin_tail);
    lenv_add_builtin(e, "eval", builtin_eval);
    lenv_add_builtin(e, "join", builtin_join);
    // register mathematical funtions
    lenv_add_builtin(e, "+", builtin_add);
    lenv_add_builtin(e, "-", builtin_sub);
    lenv_add_builtin(e, "*", builtin_mul);
    lenv_add_builtin(e, "/", builtin_div);
    lenv_add_builtin(e, "%", builtin_mod);
    lenv_add_builtin(e, "^", builtin_pow);
}

lval* builtin(lenv* e, lval* a, char* func) {
    if (strcmp("list", func) == 0) { return builtin_list(e, a); }
    if (strcmp("head", func) == 0) { return builtin_head(e, a); }
    if (strcmp("tail", func) == 0) { return builtin_tail(e, a); }
    if (strcmp("join", func) == 0) { return builtin_join(e, a); }
    if (strcmp("eval", func) == 0) { return builtin_eval(e, a); }
    if (strstr("+-/*%^", func)) { return builtin_op(e, a, func); }
    lval_del(a);
    return lval_err("unknown function");
}

// evaluate sexpr
lval* lval_call(lenv* e, lval* f, lval* a) {
    // if a buitlin then aply it
    if (f->builtin) {
        return f->builtin(e, a);
    }
    // record argumrnt counts
    int given = a->count;
    int total = f->formals->count;
    // while arguments remain to be processed
    while (a->count) {
        // return an error if we run out of formal arguments to bind
        if (f->formals->count == 0) {
            lval_del(a);
            return lval_err(
                    "Function passed too many arguments. Got %i, expected %i.",
                    given,
                    total);
        }
        // otherwise pop the first symbol from the formals
        lval* sym = lval_pop(f->formals, 0);
        // deal with the & special case
        if (strcmp(sym->sym, "&") == 0) {
            // ensure '&' is followed by another symbol
            if (f->formals->count != 1) {
                lval_del(a);
                return lval_err(
                        "Function format invalid. Symbol '&' not followed by a single symbol.");
            }
            // next formal should be bound to remaining arguments
            lval* nsym = lval_pop(f->formals, 0);
            lenv_put(f->env, nsym, builtin_list(e, a));
            lval_del(sym);
            lval_del(nsym);
            break;
        }
        // pop the next argument from the list
        lval* val = lval_pop(a, 0);
        // bind a copy into the function environment
        lenv_put(f->env, sym, val);
        // delete symbol and value
        lval_del(sym);
        lval_del(val);
    }
    // argument list is now bound and can be cleaned up
    lval_del(a);
    // if '&' remains in formal list bind to empty list
    if (f->formals->count > 0 
            && strcmp(f->formals->cell[0]->sym, "&") == 0) {
        // check to ensure & is not passed invalidly
        if (f->formals->count != 2) {
            return lval_err(
                    "Function format invalid. Symbol '&' not followed by a single symbol."
                    );
        }
        // pop and delete '&" symbol
        lval_del(lval_pop(f->formals, 0));
        // pop the enxt symbol and create an empty list
        lval* sym = lval_pop(f->formals, 0);
        lval *val = lval_qexpr();
        // bind to environment and delete
        lenv_put(f->env, sym, val);
        lval_del(sym);
        lval_del(val);
    }
    // if all formals have been vound then evaluate
    if (f->formals->count == 0) {
        // set environment parent to evaluation environment
        f->env->par = e;
        // evaluate and return
        return builtin_eval(
                f->env,
                lval_add(lval_sexpr(), lval_copy(f->body))
                );
    } else {
        // otherwise return partially evaluated function
        return lval_copy(f);
    }
}



lval* lval_eval_sexpr(lenv* e, lval* v) {
    // evaluate child cells
    for (int i = 0; i < v->count; i++) {
        v->cell[i] = lval_eval(e, v->cell[i]);
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
    // ensure first element is a function after evaluation
    lval* f = lval_pop(v, 0);
    if (f->type != LVAL_FUN) {
        lval* err = lval_err(
                "S-Expression starts with incorrect type. Got %s, expected %s.",
                ltype_name(f->type),
                ltype_name(LVAL_FUN));
        lval_del(v);
        lval_del(f);
        return err;
        // return lval_err("s-expression does not start with a function");
    }
    // if so call the builtin function and get the result.
    lval* result = lval_call(e, f, v);
    lval_del(f);
    return result;
}

// evaluate lval
lval* lval_eval(lenv* e, lval* v) {
    // return symbol
    if (v->type == LVAL_SYM) {
        lval* x = lenv_get(e, v);
        lval_del(v);
        return x;
    }
    // evaluate s-expression
    if (v->type == LVAL_SEXPR) {
        return lval_eval_sexpr(e, v);
    }
    // return all other type as is
   return v;
}

// -------------------------------------------------------------------------------------------------
// reading

lval* lval_read_num(mpc_ast_t* t) {
    errno = 0;
    char *end;
    double x = strtod(t->contents, &end);
    return errno != ERANGE 
        ? lval_num(x) 
        : lval_err("invalid number");
}

lval* lval_read(mpc_ast_t* t) {
    // handle numbers and synbols
    if (strstr(t->tag, "number")) { return lval_read_num(t) ; }
    if (strstr(t->tag, "symbol")) { return lval_sym(t->contents) ; }
    // handle root ('>') and sexpr 
    lval* x = NULL;
    if (strcmp(t->tag, ">") == 0) { x = lval_sexpr(); }
    if (strstr(t->tag, "sexpr")) { x = lval_sexpr(); }
    if (strstr(t->tag, "qexpr")) { x = lval_qexpr(); }
    // handle child nodes...  
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

// -------------------------------------------------------------------------------------------------
// repl commands

char* lisp_fun     = "def {fun} (\\ {args body} {def (head args) (\\ (tail args) body)})";
char* lisp_pack    = "fun {pack f & xs} {f xs}";
char* lisp_unpack  = "fun {unpack f xs} {eval (join (list f) xs)}";
char* lisp_curry   = "def {curry} pack";
char* lisp_uncurry = "def {uncurry} unpack";

void lenv_add_lisp_fn(mpc_parser_t* parser, lenv* e, char* lisp_fn_expr) {
    mpc_result_t r;
    mpc_parse("<stdin>", lisp_fn_expr, parser, &r);
    lval* ast = lval_read(r.output);
    lval* e_ast = lval_eval(e, ast);
    lval_del(e_ast);
    mpc_ast_delete(r.output);
}

void lenv_add_lisp_fns(mpc_parser_t* parser, lenv* env) {
    lenv_add_lisp_fn(parser, env, lisp_fun);
    lenv_add_lisp_fn(parser, env, lisp_pack);
    lenv_add_lisp_fn(parser, env, lisp_unpack);
    lenv_add_lisp_fn(parser, env, lisp_curry);
    lenv_add_lisp_fn(parser, env, lisp_uncurry);
}

// -------------------------------------------------------------------------------------------------
// repl commands

enum repl_state_t {EXIT, CMD, EVAL};
typedef enum repl_state_t repl_state;

repl_state handle_repl_commands(lenv* env, char* input) {
    repl_state result = EVAL;
    if (strcmp(input, "exit") == 0) {
        puts("Bye bye!");
        result = EXIT;
    }
    else if (strcmp(input, "env") == 0) {
        lenv_print(env);
        result = CMD;
    }
    return result;
}



// -------------------------------------------------------------------------------------------------
// main

int main (int argc, char** argv) {

    // Parsers
    mpc_parser_t* Number = mpc_new("number");
    mpc_parser_t* Symbol = mpc_new("symbol");
    mpc_parser_t* Sexpr  = mpc_new("sexpr");
    mpc_parser_t* Qexpr  = mpc_new("qexpr");
    mpc_parser_t* Expr   = mpc_new("expr");
    mpc_parser_t* Awly   = mpc_new("awly");

    // Grammar
    
    mpca_lang(MPCA_LANG_DEFAULT,
        "                                                                       \
         number   : /-?[0-9]+\\.?[0-9]*/ ;                                      \
         symbol   : /[a-zA-Z0-9_^%+\\-*\\/\\\\=<>!&]+/ ;                        \
         sexpr    : '(' <expr>* ')' ;                                           \
         qexpr    : '{' <expr>* '}' ;                                           \
         expr     : <number> | <symbol> | <sexpr> | <qexpr>  ;                  \
         awly     : /^/ <expr>* /$/ ;                                           \
        ",
        Number, Symbol, Sexpr, Qexpr, Expr, Awly);
    
    
    // Print Prelude Header
    puts("Awlyspian Version 0.0.9");
    puts("Press Ctrl-C to exit\n");

    lenv* e = lenv_new();
    lenv_add_builtins(e);
    lenv_add_lisp_fns(Awly, e);

    // Infinite REPL Loop
    int loop_4evah = 1;
    while (loop_4evah) {
        // Input Buffer
        char* input = readline("awly> ");
        // Store Input History
        add_history(input);

        mpc_result_t r;
        switch (handle_repl_commands(e, input)) {
            case EXIT:
                loop_4evah = 0;
                break;
            case CMD:
                break;
            case EVAL:
                // ParseInput
                if (mpc_parse("<stdin>", input, Awly, &r)) {
                    // Success - Print AST 
                    // mpc_ast_print(r.output);
                    // Print Results
                    lval* ast = lval_read(r.output);
                    // lval_println(ast);
                    lval* e_ast = lval_eval(e, ast);
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
                break;
            default:
                printf("Could not process: %s", input);
        }
    }
    // tidy environmet
    lenv_del(e);
    // Clean-up Parsers
    mpc_cleanup(6, Number, Symbol, Sexpr, Qexpr, Expr, Awly);

    return 0;
}
