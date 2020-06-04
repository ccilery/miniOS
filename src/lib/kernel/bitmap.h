#ifndef __LIB_KERNEL_BITMAP_H
#define __LIB_KERNEL_BITMAP_H
#include "stdint.h"
#include "stdbool.h"

#define BITMAP_MASK 1

struct bitmap
{
    uint32_t bitmap_bytes_len;   // 字节为单位的长度
    uint8_t* bits;  // 字节型指针
};

// 将位图初始化全部bit为0
void bitmap_init(struct bitmap* btmp);

// 判断bit_idx位是否为1, 若为1, 则返回true, 否则返回0
bool bitmap_scan_test(struct bitmap* btmp, uint32_t bit_idx);

// 在位图中连续申请cnt个bit, 成功则返回起始bit的下标, 失败返回-1
int bitmap_scan(struct bitmap* btmp, uint32_t cnt);

// 将bit_idx对应的bit设置为value
void bitmap_set(struct bitmap* btmp, uint32_t bit_idx, int8_t value);


#endif // __LIB_KERNEL_BITMAP_H