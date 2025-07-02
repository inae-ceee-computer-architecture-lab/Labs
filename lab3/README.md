# Lab 3: Computer Architecture Tools – Part II

This lab focuses on identifying performance bottlenecks using two tools: `perf` and Intel® VTune™ Profiler. You will compile backend and frontend bottleneck binaries and then analyze them to understand where CPU time is being spent.

- **Backend Bottleneck**: Occurs when the CPU is ready to execute instructions but is stalled waiting for data, typically due to memory latency or limited bandwidth.
- **Frontend Bottleneck**: Happens when the CPU cannot fetch or decode instructions fast enough, often caused by instruction cache misses or branch mispredictions.

---

## Task 0: Collecting the Program Binaries

### 0.1 Backend Bottleneck Binary (Matrix Multiplication)

1. Navigate to the backend bottleneck source directory:
   ```
   cd lab3/backend_bottleneck/linux
   ```

2. Build the binary:
   ```
   make
   ```

3. Return to the parent directory:
   ```
   cd ..
   ```

- This generates a binary named `matrix` which will be used for performance analysis with `perf` and VTune.

---

### 0.2 Frontend Bottleneck Binary

1. Navigate to the frontend bottleneck source directory:
   ```
   cd lab3/frontend_bottleneck/
   ```

2. Build the binary:
   ```
   make
   ```

- This generates a binary named `FE_bottleneck` which will also be used for performance analysis.

---

## Task 1: Using `perf` Tool

### 1.1 List Available Performance Events

To view the full list of events supported by your system:

```
perf list
```

---

### 1.2 Run `perf stat` on a Compiled Binary

To measure performance statistics:

```
perf stat -e <event_list> ./binary
```

- Replace `<event_list>` with specific hardware/software events (or omit to use default).
- Replace `./binary` with `./matrix` or `./FE_bottleneck` depending on what you're analyzing.

Part A: To check number of cycles and instructions 

```
perf stat -e instructions,cycles ./binary
```

Part B: To check cache related events

```
perf stat -e L1-dcache-loads,L1-dcache-stores,L1-icache-loads,L1-icache-load-misses,LLC-loads,LLC-load-misses,LLC-stores,LLC-store-misses ./binary
```

Part C: To check branch related events

```
perf stat -e branch-loads,branch-load-misses,branch-instructions,branch-misses ./binary
```

Part D: To check operating system (OS) related events

```
perf stat -e context-switches,page-faults ./binary
```
---

## Task 2: Using Intel® VTune™ Profiler

1. Launch Intel® VTune™ Profiler.

2. Select the binary (`matrix` or `FE_bottleneck`) as the target application.

3. Choose an analysis type (e.g., **Performance snapshots**, **Hotspots**, **Microarchitecture Exploration**, etc.).

4. Run the analysis.

5. Explore the results to identify CPU, memory, or frontend/backend pipeline bottlenecks.


---

## Directory Structure

```
lab3/
├── backend_bottleneck/
│   └── linux/
│       ├── Makefile
│       ├── matrix (generated after build)
│       └── ...
├── frontend_bottleneck/
│   ├── Makefile
│   ├── FE_bottleneck (generated after build)
│   └── ...
└── README.md
```

---

## Summary

By the end of this lab, you will:

- Use `perf` to capture basic performance metrics.
- Use Intel® VTune™ to perform in-depth profiling and identify bottlenecks.

