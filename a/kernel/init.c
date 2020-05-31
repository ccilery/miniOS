#include "init.h"
#include "print.h"
#include "interrupt.h"

void init_all()
{
    put_str("init_all\n");

    idt_init();     // 中断相关的初始化
}