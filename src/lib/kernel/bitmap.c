#include "bitmap.h"
#include "string.h"
#include "debug.h"
#include "stdint.h"
#include "stdbool.h"
#include "print.h"

// 将位图初始化全部bit为0
void bitmap_init(struct bitmap* btmp)
{
    memset(btmp->bits, 0, btmp->bitmap_bytes_len);
}

// 判断bit_idx位是否为1, 若为1, 则返回true, 否则返回0
bool bitmap_scan_test(struct bitmap* btmp, uint32_t bit_idx)
{
    uint32_t byte_idx = bit_idx / 8;
    uint32_t bit_odd = bit_idx % 8;
    return (btmp->bits[byte_idx] & (BITMAP_MASK << bit_odd)); 
}

// 在位图中连续申请cnt个bit, 成功则返回起始bit的下标, 失败返回-1
int bitmap_scan(struct bitmap* btmp, uint32_t cnt)
{
    // 1. 逐字节比较, 找到第一个包含0的byte
    uint32_t byte_idx = 0;
    while(0xff == btmp->bits[byte_idx] && byte_idx < btmp->bitmap_bytes_len)
        byte_idx++;
    if(byte_idx == btmp->bitmap_bytes_len)
        return -1;

    // 2. 逐位比较, 在包含0的byte中找到为0的bit
    uint32_t bit_idx = 0;
    while(btmp->bits[byte_idx] & (BITMAP_MASK << bit_idx))
        bit_idx++;
    
    int bit_idx_start = byte_idx * 8 + bit_idx;    // 第一个空闲bit在bitmap中的下标
    if(cnt == 1)
        return bit_idx_start;

    // 3. 寻找连续的cnt个0
    uint32_t bit_left = btmp->bitmap_bytes_len * 8 - bit_idx_start - 1;
    uint32_t bit_next = bit_idx_start + 1;
    uint32_t count = 1;
    bit_idx_start = -1;
    
    while(bit_left--) 
    {
        if(!bitmap_scan_test(btmp, bit_next))
            count++;
        else 
            count = 0;
        if(count == cnt)
        {
            bit_idx_start = bit_next - cnt + 1;
            break;
        }
        bit_next++;
    }
    return bit_idx_start;
}

// 将bit_idx对应的bit设置为value
void bitmap_set(struct bitmap* btmp, uint32_t bit_idx, int8_t value)
{
    ASSERT((value == 0) || (value == 1));

    uint32_t byte_idx = bit_idx / 8;
    uint32_t bit_odd = bit_idx % 8;
    if(value == 1)
        btmp->bits[byte_idx] |= (BITMAP_MASK << bit_odd);
    else // value == 0
        btmp->bits[byte_idx] &= ~(BITMAP_MASK << bit_odd);
}