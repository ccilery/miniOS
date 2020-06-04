#ifndef __KERNEL_MEMORY_H
#define __KERNEL_MEMORY_H
#include "bitmap.h"
#include "stdint.h"

// 内存池标记
enum pool_flags
{
    PF_KERNEL = 1,  // 从内核内存池中分配
    PF_USER = 2     // 从用户内存池中分配
};

// page directory entry 和 page table entry 的低3位
#define PG_P_1      1
#define PG_P_0      0
#define PG_RW_R     0
#define PG_RW_W     2
#define PG_US_S     0
#define PG_US_U     4



// 虚拟地址池
struct virtual_addr
{
    struct bitmap vaddr_bitmap;  // 虚拟地址池的bitmap, 每个进程内部的虚拟地址是唯一的
    uint32_t vaddr_start;        // 虚拟地址起始地址
};

extern struct pool kernel_pool, user_pool;  // 供外部文件使用
void mem_init(void);
void* get_kernel_pages(uint32_t pg_cnt);

#endif // __KERNEL_MEMORY_H