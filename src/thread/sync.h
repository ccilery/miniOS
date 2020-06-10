#ifndef __THREAD_SYNC_H
#define __THREAD_SYNC_H

#include "stdint.h"
#include "list.h"
#include "thread.h"

// 信号量, 初值以及阻塞在该信号量上的线程
struct semaphore
{
    uint8_t value;
    struct list waiters;    // 阻塞在该信号量上的线程
};

// 锁
struct lock
{
    struct task_struct* holder;     // 锁的持有者
    struct semaphore semaphore;     // 用2元信号量实现锁
    uint32_t holder_repeat_nr;      // 锁的持有者重复申请锁的次数
};


// 初始化信号量
void sema_init(struct semaphore* psema, uint8_t value);
// 初始化锁
void lock_init(struct lock* plock);
// P操作
void sema_down(struct semaphore* psema);
// V操作
void sema_up(struct semaphore* psema);
// 获取锁
void lock_acquire(struct lock* plock);
// 释放锁
void lock_release(struct lock* plock);

#endif // __THREAD_SYNC_H