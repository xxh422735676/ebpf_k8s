#include<stdio.h>
#include<string.h>
#include<stdlib.h>


void exec(const char* cmd) {
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return ;
    char buffer[128];
    char* result = "";
    while(!feof(pipe)) {
        if(fgets(buffer, 128, pipe) != NULL)
        fprintf(stdout,"%s",buffer);
    }
    pclose(pipe);
}


int main(){
    exec("ls -l");
    return 0;
}