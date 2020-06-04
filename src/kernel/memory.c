#include "memory.h"
#include "stdint.h"
#include "print.h"
#include "string.h"
#include "debug.h"




struct pool kernel_pool, user_pool;     // 内核内存池 用户内存池
struct virtual_addr kernel_vaddr;        // 给内核分配虚拟地址


// all_mem: 可用物理内存大小, loader.S中通过BIOS中断进行了检测, 存放在0xb00处
static void mem_pool_init(uint32_t all_mem)
{
    put_str("    mem_pool_init start\n");

    // 页目录表 + 第0号页目录表项对应的页表 + 内核地址空间的页表(768~1023号页目录表项对应的页表, 
    // 768号和0号页目录表项对应的页表相同, 1023号页目录表项指向页目录表) 的大小  1 + 1 + 254
    uint32_t page_table_size = 256 * PG_SIZE; 
    
    // 已经使用的内存不再进行管理
    uint32_t used_mem = page_table_size + 0x100000;     // 0x100000为低端1MB内存
    uint32_t free_mem = all_mem - used_mem;
    uint32_t all_free_pages = free_mem / PG_SIZE;   // 不足1页的丢弃

    // 内核物理地址空间 和 用户物理地址空间 的 pages
    uint32_t kernel_free_pages = all_free_pages / 2;
    uint32_t user_free_pages = all_free_pages - kernel_free_pages;

    // 内核物理地址空间 和 用户物理地址空间 位图的长度, 余数不作处理, 会丢弃 (1-7) * 2 页
    uint32_t kbm_length = kernel_free_pages / 8;
    uint32_t ubm_length = user_free_pages / 8;

    // 内核物理地址空间 和 用户物理地址空间 的起始物理地址
    uint32_t kp_start = used_mem;
    uint32_t up_start = kp_start + kernel_free_pages * PG_SIZE;

    // 初始化 内核 和 用户 内存池数据结构
    kernel_pool.phy_addr_start = kp_start;
    user_pool.phy_addr_start = up_start;

    kernel_pool.pool_size = kernel_free_pages * PG_SIZE;
    user_pool.pool_size = user_free_pages * PG_SIZE;

    kernel_pool.pool_bitmap.bitmap_bytes_len = kbm_length;
    user_pool.pool_bitmap.bitmap_bytes_len = ubm_length;


    kernel_pool.pool_bitmap.bits = (uint8_t*)MEM_BITMAP_BASE;
    user_pool.pool_bitmap.bits = (uint8_t*)(MEM_BITMAP_BASE + kbm_length);

    // 输出内存池信息
    put_str("    kernel_pool_bitmap_start: ");
    put_int((uint32_t)kernel_pool.pool_bitmap.bits);
    put_str("  kernel_pool_phy_addr_start: ");
    put_int((uint32_t)kernel_pool.phy_addr_start);
    put_char('\n');

    put_str("    user_pool_bitmap_start: ");
    put_int((uint32_t)user_pool.pool_bitmap.bits);
    put_str("  user_pool_phy_addr_start: ");
    put_int((uint32_t)user_pool.phy_addr_start);
    put_char('\n');

    // 内存池 bitmap 清零
    bitmap_init(&kernel_pool.pool_bitmap);
    bitmap_init(&user_pool.pool_bitmap);


    // 初始化内核虚拟地址内存池
    kernel_vaddr.vaddr_bitmap.bitmap_bytes_len = kbm_length;
    kernel_vaddr.vaddr_bitmap.bits = (uint8_t*)(MEM_BITMAP_BASE + kbm_length + ubm_length);
    kernel_vaddr.vaddr_start = K_HEAD_START;        // 内核虚拟内存池的起始地址为内核堆的起始地址
    bitmap_init(&kernel_vaddr.vaddr_bitmap);
    put_str("    mem_pool_init done\n");
}

// 在pf物理内存池中 **连续分配** pg_cnt个物理页, 返回虚拟地址
static void* vaddr_get(enum pool_flags pf, uint32_t pg_cnt)
{
    int vaddr_start = 0, bit_idx_start = -1;
    uint32_t cnt = 0;
    if(pf == PF_KERNEL)
    {
        bit_idx_start = bitmap_scan(&kernel_pool.pool_bitmap, pg_cnt);
        // ASSERT(bit_idx_start != -1);
        if(bit_idx_start == -1)
            return NULL;
        while(cnt < pg_cnt)     // 修改标识为已分配
            bitmap_set(&kernel_pool.pool_bitmap, bit_idx_start + cnt++, 1);
        vaddr_start = kernel_vaddr.vaddr_start + bit_idx_start * PG_SIZE;
    }
    else
    {
        /* code */
    }
    return (void*)vaddr_start;
}

// 虚拟地址对应的pte指针
static uint32_t* pte_ptr(uint32_t vaddr)
{
    uint32_t page_vaddr = 0xffc00000 + (PDE_IDX(vaddr) << 12);  // vaddr所在页表的虚拟地址
    return (uint32_t*)(page_vaddr + PTE_IDX(vaddr)  * 4);
}

// 虚拟地址对应的pde指针
static uint32_t* pde_ptr(uint32_t vaddr)
{
    // 页目录表的虚拟地址: 0xfffff000   1111111111_1111111111_000000000000 页目录表的最后一项指向自身
    return (uint32_t*)(0xfffff000 + PDE_IDX(vaddr) * 4);
}

// 在m_pool所指向的物理内存池中分配1个物理页, 成功返回物理页的物理地址, 失败返回NULL
static void* palloc(struct pool* m_pool)
{
    int bit_idx = bitmap_scan(&m_pool->pool_bitmap, 1);
    if(bit_idx == -1)
        return NULL;
    bitmap_set(&m_pool->pool_bitmap, bit_idx, 1);
    return (uint32_t*)(m_pool->phy_addr_start + bit_idx * PG_SIZE);
}

// 在页表中添加一项, 虚拟地址和分配的物理页的物理地址的映射
static void page_table_add(void* _vaddr, void* _page_phyaddr)
{
    uint32_t vaddr = (uint32_t)_vaddr, page_phyaddr = (uint32_t)_page_phyaddr;
    uint32_t* pde = pde_ptr(vaddr);      // 虚拟地址对应的页目录表项的虚拟地址, 里面存放的是页表的物理地址
    uint32_t* pte = pte_ptr(vaddr);      // 虚拟地址对应的页表项的虚拟地址, 里面存放的是分配的物理页的物理地址

    // 判断页表是否存在, 即页目录表项中的P位是否为1
    if(*pde & 0x1)  // 页表存在
    {
        ASSERT(!(*pte & 0x1));  // 断言pte还没被设置
        *pte = page_phyaddr | PG_P_1 | PG_RW_W | PG_US_U;
    }
    else    // 页表不存在
    {
        // 先创建页表, 填写pde
        uint32_t page_table_phyaddr = (uint32_t)palloc(&kernel_pool);
        *pde = page_table_phyaddr | PG_P_1 | PG_RW_W | PG_US_U;
        // 初始化页表
        memset((void*)((uint32_t)pte & 0xfffff000), 0, PG_SIZE);
        ASSERT(!(*pte & 0x1)); 
        *pte = page_phyaddr | PG_P_1 | PG_RW_W | PG_US_U;
    }
}

// 在pf内存池中分配pg_cnt个页, 并返回虚拟地址
static void* malloc_page(enum pool_flags pf, uint32_t pg_cnt)
{
    ASSERT(pg_cnt > 0 && pg_cnt < 3850);
    // malloc page 的3个动作
    // 1. 在虚拟内存池申请虚拟页  vaddr_get
    // 2. 在物理内存池申请物理页  palloc
    // 3. 建立映射 page_table_add

    void* v_start = vaddr_get(pf, pg_cnt);
    // ASSERT(v_start != NULL);
    if(v_start == NULL)
        return NULL;
    
    uint32_t vaddr = (uint32_t)v_start, cnt = pg_cnt;
    struct pool* mem_pool = (pf == PF_KERNEL ? &kernel_pool : &user_pool);

    while(cnt--)
    {
        void* paddr = palloc(mem_pool);
        if(paddr == NULL)
        {
            // TODO  回收内存
            return NULL;
        }
        page_table_add((void*)vaddr, paddr);

        vaddr += PG_SIZE;
    }
    return v_start;
}

// 从内核内存池中分配1页内存, 成功返回其虚拟地址, 失败返回NULL
void* get_kernel_pages(uint32_t pg_cnt)
{
    void* res = malloc_page(PF_KERNEL, pg_cnt);
    // ASSERT(res != NULL);
    if(res == NULL)
        return res;
    memset(res, 0, PG_SIZE * pg_cnt);
    return res;
}

void mem_init()
{
    put_str("mem_init start\n");
    uint32_t mem_bytes_total = *(uint32_t*)(0xb00);
    mem_pool_init(mem_bytes_total);
    put_str("mem_init done\n");
}