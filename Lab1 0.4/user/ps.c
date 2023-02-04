#include "kernel/types.h"
#include "user/user.h"

struct proc_info{
  int pid;
  char name[16];
  int status;
};

int main (void){
  //syscall: procinfos
    procinfos();
    exit(0);
}