#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "timer.h"
#include "memory.h"
#include "thread.h"
#include "console.h"

void init_all()
{
    put_str("init_all\n");

    idt_init();     // 中断相关的初始化
    mem_init();     // 初始化内存管理系统
    thread_init();  // 线程初始化
    timer_init();   // 8253定时器的初始化, 初始化时钟中断信号的频率
    console_init(); // 终端初始化
}