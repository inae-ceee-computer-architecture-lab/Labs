// Online C compiler to run C program online
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *ptr = (int*)malloc(sizeof(int)*4);
    ptr[0] = 10;
    printf("%d\n",ptr[0]);
    free(ptr);
    printf("%d\n",ptr[0]);
    printf("Try programiz.pro");

    return 0;
}
