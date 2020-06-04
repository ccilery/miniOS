#include "print.h"
#include "init.h"
#include "debug.h"
#include "string.h"
#include "memory.h"
#include "thread.h"

void k_thread_a(void* arg);



int main(void)
{
    put_str("I am kernel\n");
    init_all();
    // asm volatile("sti");    // 开启中断
    // put_int(strlen("hello"));
    // ASSERT (2 == 3);
    // void* addr = get_kernel_pages(3);
    // put_str("\nget kernel_page start vaddr is ");
    // put_int((uint32_t)addr);

    thread_start("k_thread_a", 31, k_thread_a, "argA ");

    while(1);
    return 0;
}

void k_thread_a(void* arg)
{
    const char* p = (const char*)arg;
    while(1)
        put_str(p);
}