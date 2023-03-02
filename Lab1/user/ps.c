#include "kernel/types.h"
#include "user/user.h"

int main (void){
    struct proc_info p[64];
  int n = procinfos(p);

  for (int i = 0; i<n; i++){
    printf("%s (%d): %d\n", p[i].name, p[i].pid, p[i].status);
  }
    
    exit(0);
}