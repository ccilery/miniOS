#include "print.h"
#include "init.h"
#include "debug.h"

int main(void)
{
    put_str("I am kernel\n");
    init_all();
    // asm volatile("sti");    // 开启中断

    ASSERT (2 == 3);
    while(1);
    return 0;
}
