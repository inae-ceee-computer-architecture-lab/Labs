# Lab 4: Computer Architecture Simulators 

This lab focuses on simulators and the Intel Pin tool. We explore how the ChampSim simulator works, generate traces using the Intel® Pin tool, and then use those traces with ChampSim to analyze and evaluate performance.


---


### Task 0: Check and Set Up Dependencies  (OPTIONAL)

1. Set up the required environment variables to ensure the Intel Pin tool runs correctly: 
   ```
   export LD_LIBRARY_PATH=/intel64/lib:/opt/intel/oneapi/tcm/1.3/lib:/opt/intel/oneapi/umf/0.10/lib:/opt/intel/oneapi/tbb/2022.1/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/pti/0.12/lib:/opt/intel/oneapi/mpi/2021.15/opt/mpi/libfabric/lib:/opt/intel/oneapi/mpi/2021.15/lib:/opt/intel/oneapi/mkl/2025.1/lib:/opt/intel/oneapi/ippcp/2025.1/lib/:/opt/intel/oneapi/ipp/2022.1/lib:/opt/intel/oneapi/dnnl/2025.1/lib:/opt/intel/oneapi/debugger/2025.1/opt/debugger/lib:/opt/intel/oneapi/dal/2025.5/lib:/opt/intel/oneapi/compiler/2025.1/opt/compiler/lib:/opt/intel/oneapi/compiler/2025.1/lib:/opt/intel/oneapi/ccl/2021.15/lib/

   ```
---

## Task 1: generate trace file using `Intel Pin tool` 

### How to use Intel Pin tool

### Tracer Options

The tracer has three configurable options:

- `-o`  
  - Specifies the output file for your trace.  

  - **Default**: `default_trace.champsim`


- `-s <number>`  
  - Specifies the number of instructions to **skip** in the program before tracing begins.  

  - **Default**: `0`


- `-t <number>`  
  - Specifies the number of instructions to **trace**, after the `-s` instructions have been skipped.  

  - **Default**: `1,000,000`

### Example

To trace **200,000 instructions** of the program `ls`, **after skipping the first 100,000 instructions**, use the following command:

```bash
pin -t obj/champsim_tracer.so -o traces/ls_trace.champsim -s 100000 -t 200000 -- ls
```
---
### Steps to generate trace

0. Unzip the pin folder present on your desktop
```
cd ~/Desktop

tar -xzvf <pin.tar.xz>
```
(optional) Download the pin folder from this [link](https://drive.google.com/drive/folders/1HCgv6H3RlohP919jtxzfrnKTu4pbo7ij?usp=drive_link) 

1. Copy the `obj-intel-64` folder from `Labs/lab4/Pin_tool`. 
```
cd ~

cp -r Desktop/Labs/lab4/Pin_tool/obj-intel64/ Desktop/
```
2. Navigate to the Pin tool directory
```
cd ~/Desktop/pin-3.22-98547-g7a303a835-gcc-linux/
```
3. Generate trace 
```
./pin -t ../obj-intel64/champsim_tracer.so -o ../Labs/lab4/ChampSim/traces/test.champsim -s 1000 -t 1000000 -- ../Labs/lab4/Pin_tool/test 
```

This will generate the trace file for the program named test

4. navigate to trace file 
```
cd ~/Desktop/Labs/lab4/ChampSim/traces/
```
5. Compress trace file
```
xz test.champsim
```



## Task 2 ChampSim
Navigate to ChampSim home folder
```
cd ../
```
### Compile

ChampSim takes eighteen parameters: 

`Branch predictor, L1I prefertcher L1D prefetcher, L2C prefetcher, LLC prefetcher, ITLB prefetcher, DTLB prefetcher, STLB prefetcher,BTB replacement policy, L1I replacement policy, L1D replacement policy, L2C replacement policy, LLC replacement policy, ITLB replacement policy, DTLBreplacement policy, STLB replacement policy, the number of cores and tail name`. 

For example, `./build_champsim.sh bimodal no no no no no no no lru lru lru lru lru lru lru lru 1 no` builds a single-core processor with bimodal branch predictor, no L1/L2/LLC data prefetchers,no ITLB/DTLB/STLB prefetchers and the baseline LRU replacement policy for the L1/L2/LLC and ITLB/DTLB/STLB.
```
$ ./build_champsim.sh bimodal no no no no no no no lru lru lru lru lru lru lru lru 1 no
```
```
$ ./build_champsim.sh ./build_champsim.sh ${branch_pred} ${l1i_pref} ${l1d_pref}
    ${l2c_pref} ${llc_pref} ${itlb_pref} ${dtlb_pref} ${stlb_pref} ${btb_repl}
    ${l1i_repl} ${l1d_repl} ${l2c_repl} ${llc_repl} ${itlb_repl} ${dtlb_repl}
    ${stlb_repl} ${num_core} ${tail_name}
```
### Run simulation

Execute `ChampSim binary` with proper input arguments.


```
./bin/{Binary} -warmup_instructions {N_WARM} -simulation_instructions {N_SIM} -traces {TRACE} > {OUTPUT}


${BINARY}: ChampSim binary compiled by "build_champsim.sh" (bimodal-no-no-lru-1core)
${N_WARM}: number of instructions for warmup (25 million)
${N_SIM}:  number of instructinos for detailed simulation (25 million)
${TRACE}: trace name with its localtion
${OUTPUT}: output file
```
## Additional Resources

- [ChampSim](https://github.com/ChampSim)
- [Intel Pin tool](https://www.intel.com/content/www/us/en/developer/articles/tool/pin-a-dynamic-binary-instrumentation-tool.html)
- [SPEC Benchmarks](https://www.spec.org/products/)
