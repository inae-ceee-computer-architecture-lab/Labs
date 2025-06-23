#include <stdio.h>
#include <stdlib.h>

int main() {
    for (int i = 0; i < 5; i++) {
        int *ptr = malloc(100 * sizeof(int));
        ptr[0] = i;
        printf("Allocated block %d\n", i);
    }
    return 0;
}
