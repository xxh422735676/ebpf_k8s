#!/usr/bin/python
from bcc import BPF

prog = """
#include <uapi/linux/limits.h> // for  NAME_MAX

struct event_data_t {
    u32 pid;
    char fname[NAME_MAX];  // max of filename
    char dfd[5];
    u32 size;
};

BPF_PERF_OUTPUT(open_events);

// 1. 原来的函数 trace_syscall_open 被 TRACEPOINT_PROBE 所替代
TRACEPOINT_PROBE(syscalls,sys_enter_execve){  
    u32 pid = bpf_get_current_pid_tgid() >> 32;
    struct event_data_t evt = {};

    evt.pid = pid; evt.size = NAME_MAX;
    bpf_probe_read(&evt.fname, sizeof(evt.fname), (void *)args->filename);
    bpf_probe_read(&evt.dfd,sizeof(evt.dfd),(void *)args->argv);

    open_events.perf_submit((struct pt_regs *)args, &evt, sizeof(evt));
    return 0;
}
"""

b = BPF(text=prog)

# 2. 不需要在显示调用注册，该行被删除
# b.attach_kprobe(event=b.get_syscall_fnname("open"), fn_name="trace_syscall_open")

# process event
def print_event(cpu, data, size):
  event = b["open_events"].event(data)
  print("Rcv Event %d, %s dfd = %s"%(event.pid, event.fname,event.dfd[0]))

# loop with callback to print_event
b["open_events"].open_perf_buffer(print_event)
while True:
    try:
        b.perf_buffer_poll()
    except KeyboardInterrupt:
        exit()