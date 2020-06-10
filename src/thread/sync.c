#include "sync.h"
#include "interrupt.h"
#include "stdint.h"
#include "debug.h"
#include "thread.h"

// 初始化信号量
void sema_init(struct semaphore* psema, uint8_t value)
{
    psema->value = value;
    list_init(&psema->waiters);
}

// 初始化锁
void lock_init(struct lock* plock)
{
    plock->holder = NULL;
    plock->holder_repeat_nr = 0;
    sema_init(&plock->semaphore, 1);    // 二元信号量
}

// P操作
void sema_down(struct semaphore* psema)
{
    enum intr_status old_status = intr_disable();   // 保证原子操作
    while(psema->value == 0)
    {
        struct task_struct* cur = running_thread();
        ASSERT(!elem_find(&psema->waiters, &cur->general_tag));
        list_append(&psema->waiters, &cur->general_tag);
        thread_block(TASK_BLOCKED);
    }

    psema->value--;
    ASSERT(psema->value == 0);
    intr_set_status(old_status);
}

// V操作
void sema_up(struct semaphore* psema)
{
    enum intr_status old_status = intr_disable();
    ASSERT(psema->value == 0);
    if(!list_empty(&psema->waiters))    // 有线程阻塞于该信号量
    {
        struct task_struct* thread_blocked = elem2entry(struct task_struct, general_tag, list_pop(&psema->waiters));
        thread_unblock(thread_blocked);
    }
    psema->value++;
    ASSERT(psema->value == 1);
    intr_set_status(old_status);
}

// 获取锁
void lock_acquire(struct lock* plock)
{
    struct task_struct* cur = running_thread();
    if(plock->holder != cur)
    {
        sema_down(&plock->semaphore);
        plock->holder = cur;
        ASSERT(plock->holder_repeat_nr == 0);
        plock->holder_repeat_nr = 1;
    }
    else 
        plock->holder_repeat_nr++;
}

// 释放锁
void lock_release(struct lock* plock)
{
    ASSERT(plock->holder == running_thread());
    if(plock->holder_repeat_nr > 1)
    {
        plock->holder_repeat_nr--;
        return;
    }
    ASSERT(plock->holder_repeat_nr == 1);
    plock->holder = NULL;
    plock->holder_repeat_nr = 0;
    sema_up(&plock->semaphore);
}