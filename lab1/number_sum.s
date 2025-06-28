# This example shows an implementation of adding 10 numbers
# using RISC-V assembly language

.data
numbers: .word 5, 12, 8, 23, 15, 7, 19, 4, 11, 6  # Array of 10 numbers
count: .word 10                                     # Number of elements
str1: .string "Sum of 10 numbers is: "

.text
main:
    la a0, numbers      # Load address of numbers array
    lw a1, count        # Load count of numbers
    jal ra, sum         # Jump-and-link to the 'sum' function

    # Print the result to console
    mv a1, a0           # Move sum result to a1 for printing
    jal ra, printResult

    # Exit program
    li a7, 10
    ecall

sum:
    # Function to calculate sum of array elements
    # a0: address of array
    # a1: number of elements
    # Returns: sum in a0
    
    addi sp, sp, -16    # Allocate stack space
    sw ra, 8(sp)        # Save return address
    sw s0, 0(sp)        # Save s0 register
    
    mv s0, a0           # s0 = array address
    li t0, 0            # t0 = sum (initialize to 0)
    li t1, 0            # t1 = loop counter (i = 0)

loop:
    bge t1, a1, end_loop    # if i >= count, exit loop
    
    slli t2, t1, 2          # t2 = i * 4 (word size)
    add t3, s0, t2          # t3 = address of numbers[i]
    lw t4, 0(t3)            # t4 = numbers[i]
    add t0, t0, t4          # sum += numbers[i]
    
    addi t1, t1, 1          # i++
    j loop                  # jump back to loop

end_loop:
    mv a0, t0               # Return sum in a0
    lw s0, 0(sp)            # Restore s0
    lw ra, 8(sp)            # Restore return address
    addi sp, sp, 16         # Deallocate stack space
    ret                     # Return to caller

# --- printResult ---
# a1: Sum result
printResult:
    mv t0, a1           # Save sum value
    la a0, str1         # Load address of string
    li a7, 4            # System call for print string
    ecall
    
    mv a0, t0           # Move sum to a0
    li a7, 1            # System call for print integer
    ecall
    
    # Print newline
    li a0, 10           # ASCII code for newline
    li a7, 11           # System call for print character
    ecall
    
    ret
