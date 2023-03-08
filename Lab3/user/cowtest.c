#include "kernel/types.h"
#include "user.h"

int global_array[16777216] = {0};
int global_var = 0;

void testcase4()
{
    int pid;

    printf("\n----- Test case 4 -----\n");
    printf("[prnt] v1 --> ");
    print_free_frame_cnt();

    if ((pid = fork()) == 0)
    {
        // child
        sleep(50);
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
        printf("[chld] v4 --> ");
        print_free_frame_cnt();

        global_array[0] = 222;
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);

        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
        printf("[chld] v5 --> ");
        print_free_frame_cnt();

        global_array[2047] = 333;
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);

        printf("[chld] v6 --> ");
        print_free_frame_cnt();

        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
        print_free_frame_cnt();

        global_array[0] = 111;
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);

        printf("[prnt] v3 --> ");
        print_free_frame_cnt();
        printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
    }

    if (wait(0) != pid)
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v7 --> ");
    print_free_frame_cnt();
}

void testcase3()
{
    int pid;

    printf("\n----- Test case 3 -----\n");
    printf("[prnt] v1 --> ");
    print_free_frame_cnt();

    if ((pid = fork()) == 0)
    {
        // child
        sleep(50);
        printf("[chld] v4 --> ");
        print_free_frame_cnt();

        global_var = 100;
        printf("[chld] modified global_var, global_var=%d\n", global_var);

        printf("[chld] v5 --> ");
        print_free_frame_cnt();

        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
        print_free_frame_cnt();

        printf("[prnt] read global_var, global_var=%d\n", global_var);

        printf("[prnt] v3 --> ");
        print_free_frame_cnt();
    }

    if (wait(0) != pid)
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
    print_free_frame_cnt();
}

void testcase2()
{
    int pid;

    printf("\n----- Test case 2 -----\n");
    printf("[prnt] v1 --> ");
    print_free_frame_cnt();

    if ((pid = fork()) == 0)
    {
        // child
        sleep(50);
        printf("[chld] v3 --> ");
        print_free_frame_cnt();

        printf("[chld] read global_var, global_var=%d\n", global_var);

        printf("[chld] v4 --> ");
        print_free_frame_cnt();

        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
        print_free_frame_cnt();
    }

    if (wait(0) != pid)
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
    print_free_frame_cnt();
}

void testcase1()
{
    int pid;

    printf("\n----- Test case 1 -----\n");
    printf("[prnt] v1 --> ");
    print_free_frame_cnt();

    if ((pid = fork()) == 0)
    {
        // child
        sleep(50);
        printf("[chld] v2 --> ");
        print_free_frame_cnt();
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
        print_free_frame_cnt();
    }

    if (wait(0) != pid)
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
    print_free_frame_cnt();
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("Usage: cowtest test_id");
    }
    switch (atoi(argv[1]))
    {
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
        break;

    case 3:
        testcase3();
        break;

    case 4:
        testcase4();
        break;

    default:
        printf("Error: No test with index %s", argv[1]);
        return 1;
    }
    return 0;
}