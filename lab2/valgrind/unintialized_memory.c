#include <stdio.h>
#include <stdlib.h>

int main() {
    int *array = malloc(5 * sizeof(int));
    
    // Initialize only first 3 elements
    array[0] = 1;
    array[1] = 0;
    array[2] = 1;
    // array[3] and array[4] are uninitialized
    
    if (array[3] > 0) {  // array[3] is uninitialized!
        printf("array[3] is positive\n");
    } else {
        printf("array[3] is not positive\n");
    }
    
    free(array);
    return 0;
}
