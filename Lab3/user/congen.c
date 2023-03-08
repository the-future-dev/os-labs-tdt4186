// Concurrent execution test that generates output for being filtered

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define N 5

void print(const char *s)
{
    write(1, s, strlen(s));
}

void forktest(void)
{
    int n, pid;

    print("fork test\n");

    for (n = 0; n < N; n++)
    {
        pid = fork();
        if (pid < 0)
            break;
        if (pid == 0)
            break;
    }

    for (unsigned long long i = 0; i < 1000; i++)
    {
        if (pid == 0)
        {
            printf("CHILD %d: %d\n", n, i);
        }
        else
        {
            printf("PARENT: %d\n", i);
        }
    }

    print("fork test OK\n");
}

int main(void)
{
    forktest();
    exit(0);
}
