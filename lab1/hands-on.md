# Code to Executable: Complete GCC Compilation Tutorial

## Overview

This tutorial walks through the complete process of transforming C source code into an executable binary using GCC on x86 architecture. We'll examine each compilation stage and perform hands-on tasks to understand what happens at every step.

## Sample Code

We'll use this C program throughout the tutorial:

```c
#include <stdio.h>
// Function declaration
int addNumbers();
int main() {
    int result;
    
    // Call the function to add numbers 1-10
    result = addNumbers();
    
    // Display the result
    printf("Sum of numbers 1 to 10 is: %d\n", result);
    
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
```

## Prerequisites

- GCC compiler installed
- Text editor
- Basic command line knowledge

---

## Stage 1: Preprocessing

**What happens:** The preprocessor handles directives starting with `#`, includes header files, expands macros, and removes comments.

### Task 1: Generate Preprocessed Output

```bash
# Save the code above as 'program.c'
gcc -E program.c -o program.i
```

**Examine the output:**

```bash
# View the preprocessed file (it will be very long!)
head -n 20 program.i
tail -n 20 program.i
```

**What to observe:**

- The `#include <stdio.h>` is replaced with the entire stdio.h content
- Comments are removed
- The file is much larger (thousands of lines)

### Understanding Task 1:

Open `program.i` and search for your original `main()` function. Notice how it appears at the very end, while the beginning contains all the stdio.h declarations and function prototypes.

- replace `10` with a macro `#define NUM 10` , see the change in preproccessed file. 
- write a small custom header file, include that in the main code and see the changes
`myheader.h` :
```c
#ifndef MYHEADER_H
#define MYHEADER_H

// Define a constant
#define NUM 20
#define MAX_VALUE 100

// Function-like macro 
#define MULTIPLY(x, y) ((x) * (y))

// extern int global_variable;

// int helper_function(int x);

#endif // MYHEADER_H
```
> Bonus add extern variable and a function to in the header file

### Info Block

**What are # line directives?**

The `# line` directives (also written as `#line`) tell the compiler the original source file and line number for each piece of code. Format:

```
# linenum "filename" flags
```

**Example from your preprocessed file:**

c

```c
# 1 "program.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 32 "<command-line>" 2
# 1 "program.c"
# 1 "/usr/include/stdio.h" 1 3 4
# 27 "/usr/include/stdio.h" 3 4
```

**What the flags mean:**

- `1` = Start of a new file
- `2` = Returning to a file after including another
- `3` = System header file
- `4` = Should be treated as wrapped in extern "C" block
---

## Stage 2: Compilation (C to Assembly)

**What happens:** The compiler translates the preprocessed C code into assembly language specific to the target architecture (x86).

### Task 2: Generate Assembly Code

```bash
gcc -S program.c -o program.s
```

**Examine the assembly:**

```bash
cat program.s
```

**What to observe:**

- x86 assembly instructions (mov, add, call, etc.)
- Function labels like `main:` and `addNumbers:`
- Stack operations and register usage

### Understanding Task 2:

Look for these key elements in `program.s`:

- Function prologues (setting up stack frames)
- The loop implementation in `addNumbers`
- The `printf` function call
- Return statements

### Deep Dive Task 2a: Analyze the Loop

Find the `addNumbers` function in the assembly and identify:

```bash
# Look for the loop structure
grep -A 10 -B 5 "addNumbers:" program.s
```

- Loop initialization
- Condition checking
- Increment operation
- Jump instructions

#### Memory Layout (High-Level View on x86-64 Linux)
```pgsql
Address ↑ (Higher)
+--------------------------+  
|     Kernel space         |
+--------------------------+
|    Stack (grows down)    |  ← %rsp (Stack Pointer)
|--------------------------|
|    Heap (grows up)       |  ← malloc/new memory
+--------------------------+
|  BSS                     |  ← global int x;
|--------------------------|
|  Data                    |  ← global int y = 5;
+--------------------------+
|  Text                    |  ← main(), functions, code
Address ↓ (Lower)

```

#### Assembly code
```
	.file	"num_add.c"                      # Source file name
	.text                                  # Begin code section (for instructions)

	.section	.rodata                   # Read-only data section (for constants, strings)
	.align 8                               # Align next data to 8-byte boundary
.LC0:
	.string	"Sum of numbers 1 to 10 is: %d\n"  # Format string for first printf
	.align 8
.LC1:
	.string	"This is %d times larger than max: %d\n"  # Format string for second printf

	.text                                  # Back to text/code section
	.globl	main                           # Declare 'main' as global (entry point)
	.type	main, @function                # 'main' is a function symbol
main:
.LFB0:
	.cfi_startproc                         # Start debug frame info for unwinding
	endbr64                                # Intel CET instruction for indirect branch tracking (security)
	pushq	%rbp                          # Save previous base pointer onto the stack
	.cfi_def_cfa_offset 16                 # CFA (Canonical Frame Address) is at RBP + 16
	.cfi_offset 6, -16                     # RBP is saved at offset -16 from CFA
	movq	%rsp, %rbp                    # Set new base pointer to current stack pointer
	.cfi_def_cfa_register 6                # CFA is now based on RBP
	subq	$16, %rsp                      # Reserve 16 bytes on the stack for local variables
	movl	$0, %eax                       # Zero out EAX (safe call practice)
	call	addNumbers                     # Call the 'addNumbers' function
	movl	%eax, -4(%rbp)                 # Store return value of addNumbers into local var [total]
	movl	-4(%rbp), %eax                 # Load [total] into EAX
	movl	%eax, %esi                     # Set up second argument (int value) for printf
	leaq	.LC0(%rip), %rax               # Load address of format string .LC0
	movq	%rax, %rdi                     # Set up first argument (format string) for printf
	movl	$0, %eax                       # Clear EAX (variadic function ABI rule)
	call	printf@PLT                      # Call printf("Sum of numbers 1 to 10 is: %d\n", total)

	movl	-4(%rbp), %eax                 # Load [total] again into EAX
	imull	$100, %eax, %edx               # Multiply total by 100, result in EDX
	movl	-4(%rbp), %eax                 # Load [total] again into EAX
	movl	%eax, %esi                     # Second printf's second argument: total
	leaq	.LC1(%rip), %rax               # Load address of second format string
	movq	%rax, %rdi                     # First argument (format string) for printf
	movl	$0, %eax                       # Clear EAX again for variadic call
	call	printf@PLT                      # Call printf("This is %d times larger than max: %d\n", total*100, total)

	movl	$0, %eax                       # Return 0 from main
	leave                                  # Restore RBP, deallocate stack frame
	.cfi_def_cfa 7, 8                      # Set CFA back to RSP + 8
	ret                                    # Return to caller
	.cfi_endproc                           # End debug frame info
.LFE0:
	.size	main, .-main                   # Size of main function

	.globl	addNumbers                      # Declare addNumbers as global
	.type	addNumbers, @function          # Define addNumbers as a function
addNumbers:
.LFB1:
	.cfi_startproc                         # Start debug frame for addNumbers
	endbr64                                # Intel CET protection
	pushq	%rbp                          # Save caller’s base pointer
	.cfi_def_cfa_offset 16                 # CFA = RBP + 16
	.cfi_offset 6, -16                     # RBP is at offset -16
	movq	%rsp, %rbp                    # New base pointer for this function
	.cfi_def_cfa_register 6                # CFA based on RBP now

	movl	$0, -8(%rbp)                   # sum = 0; at [rbp-8]
	movl	$1, -4(%rbp)                   # i = 1; at [rbp-4]

	jmp	.L4                              # Jump to condition check
.L5:
	movl	-4(%rbp), %eax                 # Load i into EAX
	addl	%eax, -8(%rbp)                 # sum += i
	addl	$1, -4(%rbp)                   # i++
.L4:
	cmpl	$20, -4(%rbp)                  # Compare i <= 20
	jle	.L5                              # If yes, jump back to loop

	movl	-8(%rbp), %eax                 # Load sum into EAX (return value)
	popq	%rbp                          # Restore old base pointer
	.cfi_def_cfa 7, 8                      # CFA = RSP + 8 again
	ret                                    # Return to caller
	.cfi_endproc                           # End frame info
.LFE1:
	.size	addNumbers, .-addNumbers       # Size of addNumbers function

	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"  # Compiler version info

	.section	.note.GNU-stack,"",@progbits  # Tells the linker stack should not be executable

	.section	.note.gnu.property,"a"       # GNU property notes (used for security info)
	.align 8
	.long	1f - 0f                         # Size of the name field
	.long	4f - 1f                         # Size of the descriptor field
	.long	5                               # Type = GNU_PROPERTY_TYPE_0

0:
	.string	"GNU"                          # Vendor = "GNU"
1:
	.align 8
	.long	0xc0000002                      # Property type (e.g., CET/IBT enabled)
	.long	3f - 2f
2:
	.long	0x3                             # IBT + SHST support bits
3:
	.align 8
4:
```

### Task 2a: Adding Inline Assembly with Intrinsics

Let's add some inline assembly to see how the compiler handles embedded assembly code.

```c
#include <stdio.h>
#include "myheader.h"

// Function declaration
int addNumbers();

int main() {
    int result;
    int dummy_var = 999; // Dummy variable 
	
	// Inline assembly: clear a register and use it
    asm volatile (
        "xor %%eax, %%eax"          // Clear EAX register (XOR with itself = 0)
        : "=a" (dummy_var)          // Output: put EAX content into dummy_var
        :                           // No inputs
        : "memory"                  // Clobber memory (tells compiler memory might change)
    );
	printf("Dummy variable after inline assembly: %d\n", dummy_var);
    
    // Call the function to add numbers 1-10
    result = addNumbers();
    
    // Display the result
    printf("Sum of numbers 1 to 10 is: %d\n", result);
	// Another inline assembly example: add 5 to result using assembly
    asm volatile (
        "addl $5, %0"               // Add immediate value 5 to operand 0
        : "=r" (result)             // Output: result (any general register)
        : "0" (result)              // Input: same as output 0 (result)
        :                           // No clobbers
    );
    
    // Display the result
    printf("Sum of numbers 1 to 10 plus 5 is: %d\n", result);
	
	printf("This is %d times larger than max: %d\n", 
	       result, MULTIPLY(result, MAX_VALUE));
    
    return 0;
}

// Function definition - adds numbers from 1 to 10
int addNumbers() {
    int sum = 0;
    int i;
    
    // Add numbers from 1 to 10
    for(i = 1; i <= NUM; i++) {
        sum += i;
    }
    
    return sum;
}
```

#### Understanding the output
> Observe the changes in the assembly code.


---

## Stage 3: Assembly (Assembly to Object Code)

**What happens:** The assembler converts assembly language into machine code (binary), creating an object file with relocatable code.

### Task 3: Generate Object File

```bash
gcc -c program.c -o program.o
```

**Examine the object file:**

```bash
# View file information
file program.o

# Display symbols in the object file
nm program.o

# Show detailed object file information
objdump -h program.o
```

**What to observe:**

- Binary format (ELF on Linux)
- Undefined symbols (like `printf`)
- Defined symbols (`main`, `addNumbers`)
- Different sections (.text, .data, .bss)

### Understanding Task 3:

The object file contains machine code but isn't executable yet because:

- External references (like `printf`) aren't resolved
- Memory addresses aren't finalized

### Deep Dive Task 3a: Examine Machine Code

```bash
# Disassemble the object file to see machine code
objdump -d program.o
```

Compare this with the assembly from Stage 2. Notice the hexadecimal machine code alongside assembly instructions.

## Something is not right !!

#### What does `call 31` mean?

This instruction tells the CPU to:

- **Push the address of the next instruction (`0x31`) onto the stack** (for return)    
- **Jump to the instruction at address `0x31`**
    

So `call 31` is simply a **call to the instruction located at address `0x31` within `main`**.

#### Wait, isn’t that weird?

Yes, **it is strange to call a label that is right after the `call` instruction itself**.

Let's look at the surrounding instructions:

```asm
2c:	e8 00 00 00 00       	call   31 <main+0x31>
31:	b8 00 00 00 00       	mov    $0x0,%eax
36:	e8 00 00 00 00       	call   3b <main+0x3b>

```

The `call 31` just jumps to the **very next instruction** (`mov $0x0, %eax`).

#### Why would a compiler emit `call 31`?

Because this is **unresolved** in the `.o` file (object file). What you're seeing is a **placeholder** in **unlinked code**.

### In object files (`.o`), calls look like:

```asm
e8 00 00 00 00   → call <some unresolved symbol>
```

This will be patched (relocated) later by the **linker** when the final address of the called function (e.g., `printf`, `addNumbers`) is known.

So:

- `call 31` doesn't actually mean **call to 0x31** in the original source code    
- It’s a **placeholder**    
- In the `.o` file, these addresses are relative and unfinalized    
- When linked (`ld`, `gcc main.o`), these will become:
```
call printf@PLT
call addNumbers

```


---

---

## Stage 4: Linking

**What happens:** The linker combines object files, resolves external references, and creates the final executable.

### Task 4: Create Executable

```bash
gcc program.o -o program
```

**Examine the executable:**

```bash
# View file information
file program

# Show symbols (note: some may be stripped)
nm program

# Show dynamic dependencies
ldd program

# Compare size with object file
ls -lha program program.o
```

**What to observe:**

- Executable format
- Resolved external symbols
- Linked libraries (libc)
- Larger file size due to additional metadata

### Understanding Task 4:

The linker has:

- Resolved the `printf` reference to the C library
- Set up the program entry point
- Arranged code and data in memory layout

### Deep Dive Task 4a: Compare Object vs Executable

```bash
# Compare symbols before and after linking
echo "=== Object file symbols ==="
nm program.o
echo "=== Executable symbols ==="
nm program
```

To see the resolved disassembly 
```
objdump -d program > dump
```
---

## Stage 5: Execution

**What happens:** The operating system loader loads the executable into memory and starts execution.

### Task 5: Run and Analyze

```bash
# Run the program
./program

# Analyze runtime behavior with strace (Linux)
strace ./program

# Check memory layout during execution
pmap $(pgrep program) &  # May need to modify for your system
```

---

## Complete One-Step Compilation

### Task 6: Compare with Direct Compilation

```bash
# Compile directly (all stages in one command)
gcc program.c -o program_direct

# Compare with our step-by-step result
diff program program_direct
echo $?  # Should output 0 (files are identical)
```

---

## Advanced Analysis Tasks

### Task 7: Optimization Comparison

```bash
# Compile with optimization
gcc -O2 -S program.c -o program_optimized.s

# Compare optimized vs unoptimized assembly
diff program.s program_optimized.s
```

### Task 8: Debug Information

```bash
# Compile with debug symbols
gcc -g program.c -o program_debug

# Compare sizes
ls -lha program program_debug

# View debug information
objdump -g program_debug | head -20
```

### Task 9: Architecture-Specific Code

```bash
# Generate 32-bit code (if supported)
gcc -m32 program.c -o program_32bit

# Compare assembly for different architectures
gcc -S -m32 program.c -o program_32bit.s
diff program.s program_32bit.s
```

---

## Summary of the Complete Process

1. **Preprocessing** (`program.c` → `program.i`)
    
    - Expands includes and macros
    - Removes comments
    - Creates pure C code
2. **Compilation** (`program.i` → `program.s`)
    
    - Translates C to assembly
    - Applies optimizations
    - Generates human-readable assembly
3. **Assembly** (`program.s` → `program.o`)
    
    - Converts assembly to machine code
    - Creates relocatable object file
    - Leaves external references unresolved
4. **Linking** (`program.o` → `program`)
    
    - Combines object files
    - Resolves external references
    - Creates executable binary
5. **Execution**
    
    - OS loads program into memory
    - Sets up runtime environment
    - Transfers control to main()

## Key Takeaways

- Each stage transforms the code into a format closer to what the processor can execute
- Object files contain machine code but aren't complete programs
- Linking is crucial for resolving external dependencies
- The same source code can generate different machine code based on target architecture and optimization settings

## Further Exploration

Try these variations with the sample code:

- Add more functions and observe symbol tables
- Use different optimization levels (-O0, -O1, -O2, -O3)
- Compile for different architectures
- Create static vs dynamic executables
- Examine how different compilers (clang vs gcc) handle the same code