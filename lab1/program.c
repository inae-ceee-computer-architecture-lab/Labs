#include <stdio.h>

// Function declaration
int addNumbers();

int main() {
    int result;
    int dummy_var = 999; // Dummy variable 
	
    // Call the function to add numbers 1-10
    result = addNumbers();

    // Display the result
    printf("Sum of numbers 1 to 10 plus 5 is: %d\n", result);
	
	// printf("This is %d times larger than max: %d\n", 
	//        result, MULTIPLY(result, MAX_VALUE));
    
    return 0;
}

// Function definition - adds numbers from 1 to 10
int addNumbers() {
    int sum = 0;
    int i;
    
    // Add numbers from 1 to 10
    for(i = 1; i <= 10; i++) {
        sum += i;
    }
    
    return sum;
}