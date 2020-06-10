#ifndef __THREAD_THREAD_H
#define __THREAD_THREAD_H

#include "stdint.h"
#include "list.h"

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

// 中断栈, 中断处理程序保护上下文现场, 压入到此结构
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
    uint32_t* self_kstack;      // 线程的0级特权栈（内核栈）
    enum task_status status;
    char name[16];
    
    uint8_t priority;           // 优先级用线程被调度时需要执行的时钟中断数表示, 任务被换下时, 用priority赋值给ticks
    uint8_t ticks;              // 任务被调度到CPU上要执行的时钟中断数, 每1次时钟中断则减1,减为0则换下
    uint32_t elapsed_ticks;     // 此任务自第一次被CPU调度, 共执行的时钟中断数

    // tag加入到内核维护的任务队列, 内核中的任务队列用宏处理tag得到PCB的地址
    struct list_elem general_tag;       // 加入到 就绪队列或其他等待队列中
    struct list_elem all_list_tag;      // 加入到所有任务的队列

    uint32_t* pgdir;            // 进程页表的虚拟地址, 线程没有页表, 为NULL
    uint32_t stack_magic;       // 因为线程的0特权级栈在pcb中, stack_magic用来分割 
};

#define STACK_MAGIC 0x12345678

// 获取当前运行线程的PCB地址
struct task_struct* running_thread(void);   
struct task_struct* thread_start(char* name, int prio, thread_func function, void* func_arg);
// 任务调度
void schedule(void);
void thread_init(void);

void thread_block(enum task_status stat);
void thread_unblock(struct task_struct* pthread);
#endif // __THREAD_THREAD_H