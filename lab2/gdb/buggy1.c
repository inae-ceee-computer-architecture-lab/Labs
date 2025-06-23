// segfault.c
#include <stdio.h>
#include <string.h>

int main() {
    char *str = NULL;
    strcpy(str, "Hello World"); 
    printf("String: %s\n", str);
    return 0;
}
