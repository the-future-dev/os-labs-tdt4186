#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Usage: schedset [SCHED ID]\n");
        exit(1);
    }
    int schedid = (*argv[1]) - '0';
    schedset(schedid);
    exit(0);
}
