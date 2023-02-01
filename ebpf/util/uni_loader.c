#include "bpf_load.h"
#include<stdio.h>
#include<string.h>
#include<errno.h>

int
main(int argc, char **argv){
    int result = 0;
    if(argc!=2){ printf("argument error! need 1 bpf program to load!\n");}
    if((result=load_bpf_file(argv[1]))!=0){
        printf("The Kernel didn't load the bpf program! %d(%s)\n",result,strerror(errno));
        return -1;
    }

    read_trace_pipe();
    return 0;
}