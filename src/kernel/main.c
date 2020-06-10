#include "print.h"
#include "init.h"
#include "debug.h"
#include "string.h"
#include "memory.h"
#include "thread.h"
#include "interrupt.h"
#include "console.h"

void k_thread_a(void* arg);
void k_thread_b(void* arg);


int main(void)
{
    put_str("I am kernel\n");
    init_all();

    thread_start("k_thread_a", 10, k_thread_a, "argA ");
    thread_start("k_thread_b", 8, k_thread_b, "argB ");
    thread_start("k_thread_c", 8, k_thread_b, "argC ");
    thread_start("k_thread_d", 10, k_thread_b, "argD ");

    thread_start("k_thread_a1", 10, k_thread_a, "argA1 ");
    thread_start("k_thread_b1", 8, k_thread_b, "argB1 ");
    thread_start("k_thread_c1", 8, k_thread_b, "argC1 ");
    thread_start("k_thread_d1", 10, k_thread_b, "argD1 ");
    
    intr_enable();
    while(1)
    {
        intr_disable();
        put_str("main ");
        intr_enable();

        // // intr_disable();
        // console_put_str("main ");
        // // intr_enable();

    }
    return 0;
}

void k_thread_a(void* arg)
{
    char* p = (char*)arg;
    while(1)
    {
        // intr_disable();
        // console_put_str(p);
        // intr_enable();

        // intr_disable();
        // put_str(p);
        // intr_enable();
    }
}

void k_thread_b(void* arg)
{
    char* p = (char*)arg;
    while(1)
    {
        // intr_disable();
        // console_put_str(p);
        // intr_enable();

        intr_disable();
        put_str(p);
        intr_enable();
    }
}
