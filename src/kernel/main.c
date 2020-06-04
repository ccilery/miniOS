#include "print.h"
#include "init.h"
#include "debug.h"
#include "string.h"
#include "memory.h"

int main(void)
{
    put_str("I am kernel\n");
    init_all();
    // asm volatile("sti");    // 开启中断
    // put_int(strlen("hello"));
    // ASSERT (2 == 3);
    void* addr = get_kernel_pages(3);
    put_str("\nget kernel_page start vaddr is ");
    put_int((uint32_t)addr);
    while(1);
    return 0;
}
