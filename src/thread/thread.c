#include "thread.h"
#include "memory.h"
#include "string.h"

static void kernel_create(thread_func function, void* func_arg)
{
    function(func_arg);
}

static void thread_create(struct task_struct* thread, thread_func function, void* func_arg)
{
    // 留出 intr_stack的空间
    thread->self_kstack -= sizeof(struct intr_stack);
    // 留出 thread_stack的空间
    thread->self_kstack -= sizeof(struct thread_stack);
    // 初始化 thread_stack的空间
    struct thread_stack* tstack = (struct thread_stack*)thread->self_kstack;
    tstack->eip = kernel_create;
    tstack->function = function;
    tstack->func_arg = func_arg;
    tstack->ebp = tstack->ebx = tstack->edi = tstack->esi = 0;  // 在分配物理页时已将整个页面初始化为0
}

static void init_thread(struct task_struct* thread, char* name, int prio)
{
    strcpy(thread->name, name);
    thread->priority = prio;
    thread->self_kstack = (uint32_t*)((uint32_t)thread + PG_SIZE);  // pcb的栈顶
    thread->status = TASK_RUNNING;
    thread->stack_magic = 0x12345678;
}

// 创建线程, 并返回pcb
struct task_struct* thread_start(char* name, int prio, thread_func function, void* func_arg)
{
    // pcb供内核调度器使用, 属于内核管理的数据结构, 从内核内存池中分配1页
    struct task_struct* thread = (struct task_struct*)get_kernel_pages(1);  
    init_thread(thread, name, prio);
    thread_create(thread, function, func_arg);

    asm volatile("movl %0, %%esp;" // thread_stack栈顶
                 "popl %%ebp;"
                 "popl %%ebx;"
                 "popl %%edi;"
                 "popl %%esi;"
                 "ret"          // eip
                 : :"g"(thread->self_kstack) : "memory");
    return thread;
}