#include <stdio.h>

#define FIVE 5

void helloworld(void) {
    puts("Hello World!");
    return;
}

void helloworld_for_5(void) {
    for (int i = 0; i < FIVE; i++) {
        helloworld();
    }
}

void helloworld_for_n(int n) {
    int i = 0;
    for (i = 0; i < n; i++) {
        helloworld();
        i += 1;
    }
}

void helloworld_while_5(void) {
    int i = 0;
    while (i < FIVE) {
        helloworld();
        i++;
    }
}

void helloworld_do_5(void) {
    int i = 0;
    do {
        helloworld();
        i++;
    } while (i < FIVE);
}

