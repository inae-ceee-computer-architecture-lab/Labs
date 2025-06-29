# RISC-V Assembly Examples of Data Hazards
# This code demonstrates four types of data hazards
# Compatible with RIPES simulator

.data
value1: .word 10
value2: .word 20
value3: .word 30

.text
.globl _start
_start:
    # Load initial values
    lw t0, value1
    lw t1, value2
    lw t2, value3
    
    # ==============================================
    # 1. RAW (Read After Write) Hazard
    # Also known as True Dependence - Most critical
    # ==============================================
    
    # RAW Hazard Example:
    add s0, t1, t2      # s0 = t1 + t2 (writes to s0)
    sub s1, s0, t1      # s1 = s0 - t1 (reads s0 - RAW hazard!)
    
    # Without forwarding, CPU needs to stall because
    # s0 from first instruction isn't ready yet
    mul s2, s0, s1      # Another RAW hazard (reads s0 and s1)
    
    # ==============================================
    # 2. WAR (Write After Read) Hazard  
    # Also known as Anti-dependence
    # ==============================================
    
    # WAR Hazard Example:
    add s3, t0, t1      # Reads t0 and t1
    add t0, t2, s0      # Writes to t0 (WAR hazard with t0!)
    
    # In out-of-order execution, if second instruction
    # completes before first, it overwrites t0
    sub s4, t1, s3      # Reads t1
    mul t1, s4, s3      # Writes to t1 (WAR hazard with t1!)
    
    # ==============================================
    # 3. WAW (Write After Write) Hazard
    # Also known as Output dependence  
    # ==============================================
    
    # WAW Hazard Example:
    add s5, t0, t1      # Writes to s5
    sub s5, t2, s0      # Also writes to s5 (WAW hazard!)
    
    # Final value of s5 must be from second instruction
    mul s6, t0, t1      # Writes to s6
    add s6, t2, s1      # Also writes to s6 (WAW hazard!)
    
    # ==============================================
    # 4. RAR (Read After Read) - NOT a true hazard
    # Also known as Input dependence - SAFE
    # ==============================================
    
    # RAR "Hazard" Example:
    add s7, t0, t1      # Reads t0 and t1
    sub s8, t0, t2      # Also reads t0 (RAR - but safe!)
    mul s9, t1, s2      # Also reads t1 (RAR - but safe!)
    
    # RAR is not a true hazard because:
    # - Reading doesn't change register value
    # - Multiple reads can happen simultaneously
    # - No data corruption occurs
    and s10, t0, t1     # More reads of t0 and t1
    or s11, t0, t1      # Even more reads - still safe!
    
    # ==============================================
    # Pipeline Stall Example - Dependency Chain
    # ==============================================
    
    # This creates maximum stalls in simple pipeline
    lw a0, value1       # Load from memory (slow)
    add a1, a0, a0      # RAW hazard - waits for a0
    sub a2, a1, a0      # RAW hazard - waits for a1  
    mul a3, a2, a1      # RAW hazard - waits for a2
    div a4, a3, a2      # RAW hazard - waits for a3
    
    # Each instruction depends on previous one
    # Creates longest possible dependency chain
    
    # Exit program
    li a7, 10           # Exit system call
    ecall
