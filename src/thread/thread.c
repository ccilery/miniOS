#include "thread.h"
#include "memory.h"
#include "string.h"
#include "list.h"
#include "interrupt.h"
#include "debug.h"
#include "print.h"


struct task_struct* main_thread;    // 主线程的PCB
struct list thread_ready_list;     // 任务就绪队列
struct list thread_all_list;       // 所有任务队列
static struct list_elem* thread_tag;    // 保存队列中的节点，用于 list_elem 转换为 task_struct

extern void switch_to(struct task_struct* cur, struct task_struct* next);

// 获取当前线程的PCB地址, esp指向PCB中的0特权级栈顶
struct task_struct* running_thread()
{
    uint32_t esp;
    asm volatile("movl %%esp, %0" : "=g"(esp));
    return (struct task_struct*)(esp & 0xfffff000);
}

static void kernel_create(thread_func function, void* func_arg)
{
    intr_enable();      // 时钟中断处理函数调用任务调度器调度任务, 进入中断时, 处理器会关中断
    function(func_arg);
}

static void thread_create(struct task_struct* thread, thread_func function, void* func_arg)
{
    // 留出 intr_stack的空间
    
    thread->self_kstack -= sizeof(struct intr_stack);
    // put_int((uint32_t)thread->self_kstack);
    // 留出 thread_stack的空间
    thread->self_kstack -= sizeof(struct thread_stack);
    // 初始化 thread_stack的空间
    struct thread_stack* tstack = (struct thread_stack*)thread->self_kstack;
    // put_int((uint32_t)*thread->self_kstack);
    tstack->eip = kernel_create;
    tstack->function = function;
    tstack->func_arg = func_arg;
    tstack->ebp = tstack->ebx = tstack->edi = tstack->esi = 0;  // 在分配物理页时已将整个页面初始化为0
}

static void init_thread(struct task_struct* thread, char* name, int prio)
{
    memset(thread, 0, sizeof(*thread));
    strcpy(thread->name, name);
    if(thread == main_thread)       // 主线程
        thread->status = TASK_RUNNING;
    else 
        thread->status = TASK_READY;
    thread->priority = prio;
    thread->ticks = prio;
    thread->elapsed_ticks = 0;
    thread->self_kstack = (uint32_t*)((uint32_t)thread + PG_SIZE);  // pcb的栈顶
    thread->pgdir = NULL;
    thread->stack_magic = STACK_MAGIC;
}

// 创建线程, 并返回pcb
struct task_struct* thread_start(char* name, int prio, thread_func function, void* func_arg)
{
    // pcb供内核调度器使用, 属于内核管理的数据结构, 从内核内存池中分配1页
    struct task_struct* thread = (struct task_struct*)get_kernel_pages(1);  
    init_thread(thread, name, prio);
    thread_create(thread, function, func_arg);

    // 加入到队列
    ASSERT(!elem_find(&thread_ready_list, &thread->general_tag));
    list_append(&thread_ready_list, &thread->general_tag);

    ASSERT(!elem_find(&thread_all_list, &thread->all_list_tag));
    list_append(&thread_all_list, &thread->all_list_tag);

    // asm volatile("movl %0, %%esp;" // thread_stack栈顶
    //              "popl %%ebp;"
    //              "popl %%ebx;"
    //              "popl %%edi;"
    //              "popl %%esi;"
    //              "ret"          // eip
    //              : :"g"(thread->self_kstack) : "memory");
    return thread;
}

// 将kernel中的main函数完善为主线程
static void make_main_thread(void)
{
    main_thread = running_thread(); // pcb地址, 0x9e000~0x9f000, 不需要另分配一页
    init_thread(main_thread, "main", 10);

    //main线程是当前线程, 不在 thread_ready_list 中
    ASSERT(!elem_find(&thread_all_list, &main_thread->all_list_tag));
    list_append(&thread_all_list, &main_thread->all_list_tag);
}

// 任务调度: 时间片用完/阻塞
void schedule() {
    ASSERT(intr_get_status() == INTR_OFF);

    struct task_struct* cur_thread = running_thread();
    if (cur_thread->status == TASK_RUNNING) {
        // 时间片用完，重新加到就绪队列
        ASSERT(!elem_find(&thread_ready_list, &cur_thread->general_tag));
        list_append(&thread_ready_list, &cur_thread->general_tag);
        cur_thread->ticks = cur_thread->priority;
        cur_thread->status = TASK_READY;
    }
    
    // 当前没有实现idle线程，所以要保证必须有可调度的线程存在
    ASSERT(!list_empty(&thread_ready_list));

    thread_tag = NULL;
    thread_tag = list_pop(&thread_ready_list);
    struct task_struct* next = elem2entry(struct task_struct, general_tag, thread_tag);
    next->status = TASK_RUNNING;
    
    switch_to(cur_thread, next);
}

/**
 * 阻塞当前线程.
 */ 
void thread_block(enum task_status status) {
    ASSERT(status == TASK_BLOCKED || status == TASK_HANGING || status == TASK_WAITING);

    enum intr_status old_status = intr_disable();

    struct task_struct* cur = running_thread();
    cur->status = status;
    schedule();

    // 等到当前线程再次被调度时才能执行下面的语句
    // 调度的其它线程无非两种情况:
    // 1. 如果第一次执行，那么在kernel_thread方法中第一件事就是开中断
    // 2. 如果不是第一次执行，那么通过中断返回的方式继续执行，而iret执行也会再次开中断
    intr_set_status(old_status);
}

void thread_unblock(struct task_struct* pthread) {
    enum intr_status old_status = intr_disable();

    ASSERT(pthread->status == TASK_BLOCKED || pthread->status == TASK_HANGING || pthread->status == TASK_WAITING);

    if (pthread->status != TASK_READY) {
        ASSERT(!elem_find(&thread_ready_list, &pthread->general_tag));
        list_push(&thread_ready_list, &pthread->general_tag);
        pthread->status = TASK_READY;
    }

    intr_set_status(old_status);
}

void thread_init()
{
    put_str("thread_init start\n");
    list_init(&thread_ready_list);          // 传的是指针的地址!!!
    list_init(&thread_all_list);

    make_main_thread();

    put_str("thread_init done\n");
}