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

// PCB的大小为1个物理页, 1MB低地址空间中空闲区域为 0x500~0x9fc00
// 为了使内核主线程的PCB正好使用1个物理页, 使用 0x9e000~0x9efff 作为内核主线程的PCB, 0x9f000~0x9fc00空闲
// 设置栈指针为0x9f000, 即PCB高地址+1
// 使用4页来保存bitmap, 0x9a000~0x9e000, 1页管理128MB内存

#define PG_SIZE 4096
#define MEM_BITMAP_BASE 0xc009a000      // 位图的起始地址, 共4页的位图, 管理512MB内存  内核内存池, 用户内存池, 内核虚拟内存池
#define K_HEAD_START 0xc0100000         // 内核空间的堆区起始地址, 越过低1MB的地址空间

#define PDE_IDX(la)     ((la >> 22) & 0x3ff)   
#define PTE_IDX(la)     ((la >> 12) & 0x3ff)

// 物理内存地址池
struct pool
{
    struct bitmap pool_bitmap;  // 内存池的管理, 管理内存的结构
    uint32_t phy_addr_start;    // 内存池的起始物理地址, 管理的内存
    uint32_t pool_size;         // 内存池的大小, bytes
};

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