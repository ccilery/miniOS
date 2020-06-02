#include "print.h"
#include "init.h"
#include "debug.h"
#include "string.h"
int main(void)
{
    put_str("I am kernel\n");
    init_all();
    // asm volatile("sti");    // 开启中断
    put_int(strlen("hello"));
    // ASSERT (2 == 3);
    while(1);
    return 0;
}
