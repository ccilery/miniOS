#ifndef __THREAD_THREAD_H
#define __THREAD_THREAD_H

#include "stdint.h"

typedef void (*thread_func)(void*);     // 函数指针类型

// 线程/进程状态
enum task_status
{
    TASK_RUNNING,
    TASK_READY,
    TASK_BLOCKED,
    TASK_WAITING,
    TASK_HANGING,
    TASK_DIED
};

// 中断栈
struct intr_stack
{
    // kernel.S
    uint32_t vec_no;        // 低地址, 栈顶, 中断向量号
    uint32_t edi;
    uint32_t esi;
    uint32_t ebp;
    uint32_t esp_dummy;
    uint32_t ebx;
    uint32_t edx;
    uint32_t ecx;
    uint32_t eax;
    uint32_t gs;
    uint32_t fs;
    uint32_t es;
    uint32_t ds;

    // 中断发生时, 低特权级级的栈切换为高特权级的栈, 高特权级的栈自动保存
    uint32_t error_code;
    void (*eip)(void);      // ??
    uint32_t cs;
    uint32_t eflags;
    void* esp;          // 低特权级栈的栈指针
    uint32_t ss;        // 高地址
};


// 线程栈
//  1. 存储线程首次执行时调用的函数及函数的参数
//  2. 任务切换时, 保存新任务的返回地址
struct thread_stack
{
    // 被调用者保存寄存器
    uint32_t ebp;
    uint32_t ebx;
    uint32_t edi;
    uint32_t esi;

    //线程第一次执行时, eip指向带调用函数 kernel_thread, 其他时候, eip指向switch_to的返回地址
    void (*eip)(thread_func, void*);
    void (*unused_retaddr);     // 虚假的函数返回地址
    thread_func function;
    void* func_arg;
};

// pcb
struct task_struct
{
    uint32_t* self_kstack;
    enum task_status status;
    uint8_t priority;
    char name[16];
    uint32_t stack_magic;   // 因为线程的0特权级栈在pcb中, stack_magic用来分割 kstack 和 线程信息
};


struct task_struct* thread_start(char* name, int prio, thread_func function, void* func_arg);
#endif // __THREAD_THREAD_H