#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc <= 1)
    {
        printf("Usage: vatopa virtual_address [pid]");
        exit(1);
    }
    
    int addr = atoi(argv[1]);
    int pid = -1;
    if (argc >= 3)
    {
        pid = atoi(argv[2]);
    }
    int va = va2pa(addr, pid);
    printf("0x%x\n", va);
    
    exit(0);
}

/*
vatopa 0
vatopa 21903211938 0
vatopa
*/