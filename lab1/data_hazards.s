.data
array: .word 10, 20, 30, 40, 50
result: .word 0

.text
main:
    li t0, 5        # Load immediate value 5 into t0
    
    # === RAW (Read After Write) HAZARD EXAMPLE 1 ===
    # The following instructions create a RAW hazard
    add t1, t0, t0      # t1 = t0 + t0 = 5 + 5 = 10 (WB stage writes t1)
    add t2, t1, t0      # t2 = t1 + t0 (ID stage reads t1 before WB writes it)
    # Hazard: t2 tries to read t1 before t1 is written back
    # Solution: Forwarding from EX/MEM or MEM/WB pipeline registers
    
    # === RAW HAZARD EXAMPLE 2 (Load-Use Hazard) ===
    # This is the most critical type requiring stalls
    la t3, array        # Load address of array
    lw t4, 0(t3)        # Load word from memory (value available in WB stage)
    add t5, t4, t1      # Use t4 immediately (needs t4 in EX stage)
    # Hazard: add needs t4 in EX stage, but lw provides it in WB stage
    # Solution: Pipeline stall (bubble) required - forwarding can't help
    
    # === RAW HAZARD EXAMPLE 3 (Multiple Dependencies) ===
    li t6, 15           # t6 = 15
    add s0, t6, t2      # s0 = t6 + t2 (depends on t6)
    sub s1, s0, t6      # s1 = s0 - t6 (depends on s0 and t6)
    mul s2, s1, s0      # s2 = s1 * s0 (depends on s1 and s0)
    # Multiple cascading dependencies requiring forwarding
    
    # === RAW HAZARD EXAMPLE 4 (Branch with Dependency) ===
    li a0, 100          # a0 = 100
    addi a1, a0, 50     # a1 = a0 + 50 = 150
    beq a1, a0, skip    # Branch if a1 == a0 (depends on a1 from previous instr)
    # Hazard: branch needs a1 value before it's written back
    # May require stall if forwarding to branch unit isn't available
    
    add a2, a1, a0      # This executes if branch not taken
    
skip:
    # === LOAD-STORE HAZARD EXAMPLE ===
    la s3, result       # Load address of result
    sw t2, 0(s3)        # Store t2 to memory
    lw s4, 0(s3)        # Load from same memory location
    # Potential hazard if store hasn't completed when load executes
    
    # === EXAMPLE WITH NO HAZARDS (Good Pipeline Utilization) ===
    # Instructions that don't depend on each other
    li x10, 1           # Independent instruction
    li x11, 2           # Independent instruction  
    li x12, 3           # Independent instruction
    add x13, x10, x11   # Can execute in parallel with above
    add x14, x12, x10   # Uses different registers
    
    # === COMPLEX DEPENDENCY CHAIN ===
    # This creates a long dependency chain
    li t0, 1            # t0 = 1
    add t1, t0, t0      # t1 = 2  (depends on t0)
    add t2, t1, t0      # t2 = 3  (depends on t1)
    add t3, t2, t1      # t3 = 5  (depends on t2)
    add t4, t3, t2      # t4 = 8  (depends on t3)
    add t5, t4, t3      # t5 = 13 (depends on t4)
    # Each instruction depends on the result of the previous one
    
    # Exit program
    li a7, 10
    ecall

