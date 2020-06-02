#ifndef __LIB_STRING_H
#define __LIB_STRING_H

#include "stdint.h"

// 将从dst_起始的size个字节, 每个字节初始化为value
void memset(void* dst_, uint8_t value, uint32_t size);
// 将从src_起始的size个字节, 拷贝到dst_起始处
void memcpy(void* dst_, const void* src, uint32_t size);
// 比较a_ 和 b_ 起始的size个字节的数据
int memcmp(const void* a_, const void* b_, uint32_t size);

char* strcpy(char* dst_, const char* src_);
uint32_t strlen(const char* str);
int8_t strcmp(const char* a_, const char* b_);
char* strchr(const char* str, const uint8_t ch);

char* strrchr(const char* str, const uint8_t ch);
char* strcat(char* dst_, const char* src_);
uint32_t strchrs(const char* str, uint8_t ch);

#endif // __LIB_STRING_H