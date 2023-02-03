GCC = gcc

BPF_PROGRAM  ?= bpf_program

KERNEL_SRC = usr/src/linux-source-5.15.0

INCLUDE_PATH += -I/$(KERNEL_SRC)/tools/testing/selftests/bpf


## 为了 bpf_load.c
BPFLOADER = /$(KERNEL_SRC)/samples/bpf/bpf_load.c

LOADINCLUDE += -I/$(KERNEL_SRC)/samples/bpf
LOADINCLUDE += -I/$(KERNEL_SRC)/tools/lib
LOADINCLUDE += -I/$(KERNEL_SRC)/tools/perf
LOADINCLUDE += -I/$(KERNEL_SRC)/tools/include

# LIBRARY_PATH += -L/lib/x86_64-linux-gnu/
LOADER_PROGRAM = util/uni_loader


.PHONY: clean

clean: 
	rm -rf *.o *.so $(BPF_PROGRAM) $(LOADER_PROGRAM)
#user space -lelf -lbpf not needed
bpf: $(BPF_PROGRAM.c)
	$(GCC) -O1 -target bpf -o ${BPF_PROGRAM:=.o} -c $(BPF_PROGRAM:=.c) $(INCLUDE_PATH)  
#kernel space
loader: $(LOADER_PROGRAM.c)
	$(GCC)  -o $(LOADER_PROGRAM) -lelf -lbpf $(LOADINCLUDE)  $(BPFLOADER) $(LOADER_PROGRAM:=.c) -v

test: loader bpf
	./$(LOADER_PROGRAM) $(BPF_PROGRAM:=.o)
.DEFAULT_GOAL:= loader

