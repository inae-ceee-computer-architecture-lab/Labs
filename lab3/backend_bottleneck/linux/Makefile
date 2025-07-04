#
#
#
# Copyright (C) 2014 Intel Corporation
#
# This software and the related documents are Intel copyrighted materials, and your use of them
# is governed by the express license under which they were provided to you ("License"). Unless
# the License provides otherwise, you may not use, modify, copy, publish, distribute, disclose
# or transmit this software or the related documents without Intel's prior written permission.
#
# This software and the related documents are provided as is, with no express or implied
# warranties, other than those that are expressly stated in the License.
#

#
# To compile with the GNU* C/C++ compiler, creating an execution file with the
# extension ".gcc" for binary instrumentation, issue:
#
#   > make
#
# To compile with the Intel(R) C++ Compiler for Linux*, creating an execution
# file with the extension ".icc":
#
#   Source <path_to_compiler_bin>/compilervars.sh or iccvars.csh;
#
#   > make icc
#
# To compile with the Intel(R) C++ Compiler for Linux* with Intel(R) MKL library
# creating an executionfile with the extension ".mkl":
#
#   Source <path_to_compiler_bin>/compilervars.sh or iccvars.csh;
#
#   > make mkl
#
# To compile with the Intel(R) C++ Compiler for Linux to cross compile for the
# Intel(R) Xeon Phi(TM) coprocessor, creating an execution file with the
# extension ".mic":
#
#   Source <path_to_compiler_bin>/compilervars.sh intel64
#
#   > make mic
#
# To compile them all, use the source line from the Intel MIC architecture
# option above, then type:
#
#   > make all

SHELL = /bin/sh

PARAMODEL = -DUSE_THR	# Default parallelism using pthreads/Win threads
#PARAMODEL = -DUSE_OMP -fopenmp	# Use OpenMP for multithreading

GCC     = gcc
ICC     = icc
CFLAGS  = -g -O3 -fno-asm
OPTFLAGS = -xSSE3 
# OPTFLAGS = -xHost -fno-alias
# add -DALIGNED to the multiply.c and matrix.c
LDFLAGS = -lpthread -lm

GCFLAGS = $(CFLAGS) $(PARAMODEL)
ICFLAGS = $(CFLAGS) $(PARAMODEL)-DICC -debug inline-debug-info #-vec-report3 -qopt-report -qopt-report-phase=vec
MKFLAGS = $(CFLAGS) -DUSE_MKL   -DICC -mkl -debug inline-debug-info


GCC_EXE = matrix.gcc
ICC_EXE = matrix.icc
MKL_EXE = matrix.mkl


srcdir = ../src

gcc: $(GCC_EXE)
icc: $(ICC_EXE)
mkl: $(MKL_EXE)
all: $(GCC_EXE) $(ICC_EXE) $(MKL_EXE)


OBJS = util.o thrmodel.o multiply.o matrix.o 


matrix.gcc: $(srcdir)/matrix.c $(srcdir)/multiply.c $(srcdir)/multiply.h $(srcdir)/util.c $(srcdir)/thrmodel.c
	$(GCC) $(GCFLAGS) -c $(srcdir)/util.c -D_LINUX
	$(GCC) $(GCFLAGS) -c $(srcdir)/thrmodel.c -D_LINUX
	$(GCC) $(GCFLAGS) -c $(srcdir)/multiply.c -D_LINUX
	$(GCC) $(GCFLAGS) -c $(srcdir)/matrix.c -D_LINUX
	$(GCC) $(GCFLAGS) -g $(OBJS) -o ../matrix $(LDFLAGS)


matrix.icc: $(srcdir)/matrix.c $(srcdir)/multiply.c $(srcdir)/multiply.h $(srcdir)/util.c $(srcdir)/thrmodel.c
	$(ICC) $(ICFLAGS) -c $(srcdir)/util.c -D_LINUX
	$(ICC) $(ICFLAGS) -c $(srcdir)/thrmodel.c -D_LINUX
	$(ICC) $(ICFLAGS) $(OPTFLAGS) -c $(srcdir)/multiply.c -D_LINUX
	$(ICC) $(ICFLAGS) $(OPTFLAGS) -c $(srcdir)/matrix.c -D_LINUX
	$(ICC) $(ICFLAGS) $(OBJS) -o ../matrix $(LDFLAGS)


matrix.mkl:     $(srcdir)/matrix.c $(srcdir)/multiply.c $(srcdir)/multiply.h $(srcdir)/util.c $(srcdir)/thrmodel.c
	$(ICC) $(MKFLAGS) -c $(srcdir)/util.c -D_LINUX
	$(ICC) $(MKFLAGS) -c $(srcdir)/thrmodel.c -D_LINUX
	$(ICC) $(MKFLAGS) $(OPTFLAGS) -c $(srcdir)/multiply.c -D_LINUX
	$(ICC) $(MKFLAGS) $(OPTFLAGS) -c $(srcdir)/matrix.c -D_LINUX
	$(ICC) $(MKFLAGS) $(OBJS) -o ../matrix $(LDFLAGS)

clean:
	@rm -rf $(OBJS) $(GCC_EXE) $(ICC_EXE) $(MKL_EXE)

# * Other names and brands may be claimed as the property of others.
