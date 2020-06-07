#include "timer.h"
#include "io.h"
#include "print.h"
#include "thread.h"
#include "debug.h"
#include "interrupt.h"

#define IRQ0_FREQUENCY	   100                                 // 时钟中断频率, HZ
#define INPUT_FREQUENCY	   1193180                           // 时钟脉冲信号的频率, HZ
#define COUNTER0_VALUE	   INPUT_FREQUENCY / IRQ0_FREQUENCY  // 计数初值
#define CONTRER0_PORT	   0x40                              // 8253中0号计数器的端口
#define COUNTER0_NO	   0                                     // 控制命令字的6-7位
#define COUNTER_MODE	   2                                 // 计数模式, 控制命令字的1-3位
#define READ_WRITE_LATCH   3                                 // 控制命令字的4-5位
#define PIT_CONTROL_PORT   0x43                              // 8253控制端口

uint32_t ticks;     // 内核自中断开启以来总共的嘀嗒数(时钟中断数)

// 时钟中断频率的设置, 高频 --> 低频
static void frequency_set(uint8_t counter_port, \
                          uint8_t counter_no, \
                          uint8_t rwl, \
                          uint8_t counter_mode, \
                          uint16_t counter_value
                        )
{
    // 1. 向8253控制端口写入控制字  00_11_010_0
    outb(PIT_CONTROL_PORT, (uint8_t)(counter_no << 6 | rwl << 4 | counter_mode << 1));

    // 2. 在计数器端口写入计数初值
    
    outb(counter_port, (uint8_t)counter_value);  // 先写入counter_value的低8位  
    outb(counter_port, (uint8_t)counter_value >> 8);  // 再写入counter_value的高8位 
}


static void intr_timer_handler(void)
{
    struct task_struct* cur_thread = running_thread();  // 当前运行线程的PCB
    ASSERT(cur_thread->stack_magic == STACK_MAGIC);     // 检查PCB中内核栈是否溢出

    cur_thread->elapsed_ticks++;
    ticks++;
    if(cur_thread->ticks == 0)
        schedule();     // 调度其他任务
    else 
        cur_thread->ticks--;    // 当前线程的时间片-1
}


// 初始化8253计时器, 及设置时钟中断的频率 通过计时器来协调CPU的高速时钟频率和外设的低速时钟频率
// 将高频的脉冲信号转化为低频的时钟中断信号
void timer_init()
{
    put_str("timer_init start\n");
    frequency_set(CONTRER0_PORT, COUNTER0_NO, READ_WRITE_LATCH, COUNTER_MODE, COUNTER0_VALUE);
    register_handler(0x20, intr_timer_handler);
    put_str("timer_init done\n");
}

