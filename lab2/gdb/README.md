# GDB Tutorial: Debugging C Programs Interactively

This tutorial demonstrates how to use GDB (GNU Debugger) to debug common programming bugs in C. We'll examine two different types of issues and learn how to identify and fix them using GDB's interactive debugging features.

## Prerequisites

- GCC compiler
- GDB installed on your system
- Basic knowledge of C programming

### Installing GDB

**Ubuntu/Debian:**
```bash
sudo apt-get install gdb
```

**CentOS/RHEL:**
```bash
sudo yum install gdb
```

**macOS:**
```bash
# GDB on macOS requires additional setup due to code signing
brew install gdb
# Follow additional codesigning instructions
```

## The Two Bug Examples

### 1. Segmentation Fault (`buggy1.c`)

**What it demonstrates:** Null pointer dereference causing a segmentation fault.

**The Bug:** The program tries to copy a string to a NULL pointer using `strcpy()`.

**Understanding the Problem:**
```c
char *str = NULL;           // str points to nothing (NULL)
strcpy(str, "Hello World"); // Trying to write to NULL address - CRASH!
```

#### Debugging with GDB

**Step 1: Compile with Debug Information**
```bash
gcc -g -o buggy1 buggy1.c
```

**Step 2: Run the Program (it will crash)**
```bash
./buggy1
```
Expected output:
```
Segmentation fault (core dumped)
```

**Step 3: Debug with GDB**
```bash
gdb ./buggy1
```

**GDB Commands to Use:**
```gdb
(gdb) run                    # Run the program
(gdb) bt                     # Show backtrace (call stack)
(gdb) list                   # Show source code around crash
(gdb) print str              # Examine the str variable
(gdb) info locals            # Show all local variables
```

**Expected GDB Session:**
```
(gdb) run
Starting program: ./buggy1

Program received signal SIGSEGV, Segmentation fault.
0x00007ffff7e9a1c0 in strcpy () from /lib/x86_64-linux-gnu/libc.so.6

(gdb) bt
#0  0x00007ffff7e9a1c0 in strcpy () from /lib/x86_64-linux-gnu/libc.so.6
#1  0x0000555555555169 in main () at buggy1.c:6

(gdb) list
1	#include <stdio.h>
2	#include <string.h>
3	
4	int main() {
5	    char *str = NULL;
6	    strcpy(str, "Hello World");
7	    printf("String: %s\n", str);
8	    return 0;
9	}

(gdb) print str
$1 = 0x0

(gdb) info locals
str = 0x0
```

**How to Fix:**
```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main() {
    char *str = malloc(20);  // Allocate memory
    strcpy(str, "Hello World");
    printf("String: %s\n", str);
    free(str);              // Don't forget to free!
    return 0;
}
```

**Alternative Fix (using array):**
```c
#include <stdio.h>
#include <string.h>

int main() {
    char str[20];           // Static array allocation
    strcpy(str, "Hello World");
    printf("String: %s\n", str);
    return 0;
}
```

### 2. Logic Error in Factorial Function (`buggy2.c`)

**What it demonstrates:** A logic bug that produces incorrect results.

**The Bug:** The factorial function initializes `result` to 0 instead of 1, making any multiplication result in 0.

**Understanding the Problem:**
```c
int result = 0;      // Wrong! Should be 1
result *= i;         // 0 * anything = 0
```

#### Debugging with GDB

**Step 1: Compile with Debug Information**
```bash
gcc -g -o buggy2 buggy2.c
```

**Step 2: Run the Program**
```bash
./buggy2
```
Expected output:
```
5! = 0
```
(This is wrong! 5! should be 120)

**Step 3: Debug with GDB**
```bash
gdb ./buggy2
```

**GDB Commands for Interactive Debugging:**
```gdb
(gdb) break factorial        # Set breakpoint at factorial function
(gdb) run                    # Run the program
(gdb) step                   # Step through line by line
(gdb) next                   # Execute next line (don't step into functions)
(gdb) print result           # Check result variable
(gdb) print i                # Check loop counter
(gdb) continue               # Continue execution
(gdb) watch result           # Watch when result changes
```

**Detailed GDB Session:**
```
(gdb) break factorial
Breakpoint 1 at 0x1149: file buggy2.c, line 4.

(gdb) run
Breakpoint 1, factorial (n=5) at buggy2.c:4
4	    int result = 0;

(gdb) next
5	    for (int i = 1; i <= n; i++) {

(gdb) print result
$1 = 0

(gdb) next
6	        result *= i;

(gdb) print i
$2 = 1

(gdb) next
5	    for (int i = 1; i <= n; i++) {

(gdb) print result
$3 = 0

(gdb) print result
$4 = 0
```

You'll notice that `result` stays 0 throughout the loop because 0 × anything = 0.

**How to Fix:**
```c
int factorial(int n) {
    int result = 1;  // Change from 0 to 1
    for (int i = 1; i <= n; i++) {
        result *= i;
    }
    return result;
}
```

## Essential GDB Commands

### Basic Commands
| Command | Description |
|---------|-------------|
| `gdb program` | Start GDB with program |
| `run` or `r` | Run the program |
| `quit` or `q` | Exit GDB |
| `help` | Show help information |

### Breakpoints
| Command | Description |
|---------|-------------|
| `break function_name` | Set breakpoint at function |
| `break line_number` | Set breakpoint at line |
| `break file:line` | Set breakpoint at specific file:line |
| `info breakpoints` | List all breakpoints |
| `delete N` | Delete breakpoint N |
| `clear` | Clear all breakpoints |

### Execution Control
| Command | Description |
|---------|-------------|
| `step` or `s` | Step into functions |
| `next` or `n` | Step over functions |
| `continue` or `c` | Continue execution |
| `finish` | Run until current function returns |
| `until line` | Run until specified line |

### Examining Variables and Memory
| Command | Description |
|---------|-------------|
| `print variable` | Print variable value |
| `print *pointer` | Print value pointed to |
| `print array[index]` | Print array element |
| `info locals` | Show all local variables |
| `info args` | Show function arguments |
| `watch variable` | Watch variable for changes |

### Code Examination
| Command | Description |
|---------|-------------|
| `list` or `l` | Show source code |
| `list function` | Show function source |
| `backtrace` or `bt` | Show call stack |
| `frame N` | Switch to frame N |
| `info stack` | Show stack information |

## Advanced GDB Techniques

For more advanced debugging techniques including conditional breakpoints, memory examination, variable modification during debugging, and core dump analysis, refer to:
- [GDB Advanced Features Documentation](https://sourceware.org/gdb/current/onlinedocs/gdb/Advanced-Features.html)
- [GDB Memory Examination Guide](https://sourceware.org/gdb/current/onlinedocs/gdb/Memory.html)

## Complete Debugging Workflow

### For Segmentation Faults:
1. **Compile with `-g`**
2. **Run in GDB**
3. **Use `bt` to see where it crashed**
4. **Use `list` to see the problematic code**
5. **Use `print` to examine variables**
6. **Identify null pointers or invalid memory access**

### For Logic Errors:
1. **Set breakpoints at suspected locations**
2. **Step through code line by line**
3. **Watch variable values change**
4. **Compare expected vs actual values**
5. **Trace the logic flow**

## Compilation Tips

**Always compile with debugging information:**
```bash
gcc -g -Wall -Wextra -std=c99 -o program program.c
```

**For extra debugging help:**
```bash
gcc -g -O0 -Wall -Wextra -DDEBUG -o program program.c
```
- `-O0`: Disable optimization (easier debugging)
- `-DDEBUG`: Define DEBUG macro for conditional debug code

## GDB Scripts

For information on creating and using GDB script files to automate debugging sessions, see:
- [GDB Command Files Documentation](https://sourceware.org/gdb/current/onlinedocs/gdb/Command-Files.html)

## Common Debugging Scenarios

### Finding Segmentation Faults
1. Run program in GDB
2. When it crashes, use `bt` to see call stack
3. Use `frame` to examine different stack frames
4. Look for NULL pointers, array bounds violations

### Tracing Logic Errors
1. Set breakpoints at function entry/exit
2. Step through suspicious loops
3. Watch critical variables
4. Compare expected vs actual behavior

### Memory Corruption Issues
1. Use `watch` on variables that change unexpectedly
2. Examine memory around pointers with `x` command
3. Check array bounds and pointer arithmetic

## Testing Your Fixes

After fixing the bugs, test with GDB:

**For buggy1 (fixed):**
```bash
gcc -g -o buggy1_fixed buggy1_fixed.c
gdb ./buggy1_fixed
(gdb) run
# Should complete successfully
```

**For buggy2 (fixed):**
```bash
gcc -g -o buggy2_fixed buggy2_fixed.c
gdb ./buggy2_fixed
(gdb) break factorial
(gdb) run
(gdb) watch result
(gdb) continue
# Watch result change from 1 to 1, 2, 6, 24, 120
```

## Additional Resources

- [GDB Documentation](https://www.gnu.org/software/gdb/documentation/)
- [GDB Quick Reference](https://users.ece.utexas.edu/~adnan/gdb-refcard.pdf)
- [DDD (Data Display Debugger)](https://www.gnu.org/software/ddd/) - GUI frontend for GDB

## Pro Tips

1. **Use meaningful variable names** - easier to debug
2. **Add debug prints** with `#ifdef DEBUG`
3. **Learn to read assembly** for low-level debugging
4. **Use `-fsanitize=address`** with GCC for additional memory checking
5. **Practice with small programs** before tackling complex ones

Remember: GDB is incredibly powerful once you learn its commands. Start with the basics (`run`, `break`, `print`, `bt`) and gradually add more advanced techniques to your debugging toolkit!
