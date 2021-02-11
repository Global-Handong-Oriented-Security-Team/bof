// AFTER => bof10.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#define BUF_SIZE 8

// ASLR ON
// STACK-PROTECTOR OFF
// STACK-EXECUTION OFF

void vuln(void) {
    char buf[BUF_SIZE] = {'\0'};
    memset(buf, 0, sizeof(buf));
    printf("printf() address : %p\n", printf);

    if (setreuid(UID_BOF13, UID_BOF13)) {
        perror("setuid");
        exit(1);
    }
    if (setregid(UID_BOF13, UID_BOF13)) {
        perror("setgid");
        exit(1);
    }
    unsigned short mistake = -128;
    fgets(buf, mistake, stdin);
    printf("Hello %s\n", buf);
}

int main(void) {
    vuln();
    return 0;
}
