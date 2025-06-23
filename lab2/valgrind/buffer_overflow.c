#include <stdio.h>
#include <stdlib.h>

int main() {
    char *buffer = malloc(10);
    
    for (int i = 0; i <= 15; i++) {  
        buffer[i] = 'A' + (i % 26);
    }
    
    printf("Buffer: %.10s\n", buffer);
    free(buffer);
    return 0;
}
