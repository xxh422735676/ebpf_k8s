#include<stdio.h>
#include<string.h>
#include<stdlib.h>


char* exec(const char* cmd) {
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return "ERROR";
    char buffer[128];
    char* result = "";
    while(!feof(pipe)) {
        if(fgets(buffer, 128, pipe) != NULL)
        strcat(result,buffer);
    }
    pclose(pipe);
    return result;
}


int main(){
    printf("%s\n",exec("ls -l"));
    return 0;
}