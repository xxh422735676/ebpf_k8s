# eBPF project illustration

## BMC

BMC(BPF memcahced cahce), using eBPF program bypassing Linux TCP network stack to accelerate in-memory database(etcd/memcahced) Receive/Send rate.

## dataCollection

This section contains eBPF files to obtain data inside kernel space from linux network subsystem and cgroup subsystem.  Outputting these data in appropriate format and store in specific location.

## network

This section contains eBPF files to process network packets inside Linux kernel space and invoke dataCollection program if necessary.

This section contains shell scripts to initialize libbpf,bcc,bpftools module in kernel and provide user space support, like sending data to remote host.