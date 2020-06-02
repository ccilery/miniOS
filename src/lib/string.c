#include "string.h"
#include "global.h"
#include "debug.h"

// 将dst_起始的size个字节, 每个字节初始化为value
void memset(void* dst_, uint8_t value, uint32_t size)
{
    ASSERT(dst_ != NULL);
    uint8_t* dst = (uint8_t*)dst_;
    while(size--)
        *dst++ = value;
}

// 将src起始的size个字节拷贝到dst_起始
void memcpy(void* dst_, const void* src_, uint32_t size)
{
    ASSERT(dst_ != NULL && src_ != NULL);
    uint8_t* dst = (uint8_t*)dst_;
    const uint8_t* src = (const uint8_t*)src_;
    while(size--)
        *dst++ = *src++;
}

// 连续比较地址a_ 和 地址b_ 开始的size个字节, 若相等则返回0, a_ > b_, 则返回1, 否则返回-1
int memcmp(const void* a_, const void* b_, uint32_t size)
{
    ASSERT(a_ != NULL && b_ != NULL);
    char *a = (char*)a_;
    char *b = (char*)b_;
    while(size--)
    {
        if(*a != *b)
            return *a > *b ? 1 : -1;
        a++;
        b++;
    }
    return 0;
}

// 将src_字符串拷贝到dst_
char* strcpy(char* dst_, const char* src_)
{
    ASSERT(dst_ != NULL && src_ != NULL);
    char *r = dst_;
    while(*src_ != '\0')
        *dst_++ = *src_++;
    *dst_ = '\0';
    return r;
}
// str字符串的长度
uint32_t strlen(const char* str)
{
    ASSERT(str != NULL);
    uint32_t c = 0;
    while(*str++ != '\0')
        ++c;
    return c;
}

int8_t strcmp(const char* a_, const char* b_)
{
    ASSERT(a_ != NULL && b_ != NULL);
    while(*a_ != '\0' && *b_ != '\0')
    {
        if(*a_ != *b_)
            return *a_ > *b_ ? 1 : -1;
        a_++;
        b_++;
    }
    // *a == '\0' || *b == '\0'
    return (*a_ == *b_) ? 0 : ((*a_ == '\0') ? -1 : 1); 
}
// 从左到右第一次出现ch的地址
char* strchr(const char* str, const uint8_t ch)
{
    ASSERT(str != NULL);
    while(*str != '\0' && *str != ch)
        ++str;
    return *str == '\0' ? NULL : (char*)str;
}

// 从右向左第一次出现ch的地址
char* strrchr(const char* str, const uint8_t ch)
{
    ASSERT(str != NULL);
    const char *r = NULL;
    while(*str != '\0')
    {
        if(*str == ch)
            r = str;
        str++;
    }
    return (char*)r;
}
char* strcat(char* dst_, const char* src_)
{
    char* r = dst_;
    while(*dst_ != '\0')    // 找到dst_的末尾
        dst_++;
    while(*src_ != '\0')
        *dst_++ = *src_++;
    return r;
}
// str中ch出现的次数
uint32_t strchrs(const char* str, uint8_t ch)
{
    uint32_t c = 0;
    while(*str != '\0')
    {
        if(*str == ch)
            c++;
        str++;
    }
    return c;
}