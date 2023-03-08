// Create a zombie process that
// must be reparented at exit.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[])
{
    struct user_proc *procs = ps(0, 64);

    for (int i = 0; i < 64; i++)
    {
        if (procs[i].state == UNUSED)
            break;
        printf("%s (%d): %d\n", procs[i].name, procs[i].pid, procs[i].state);
    }
    exit(0);
}
