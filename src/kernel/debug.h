#ifndef __KERNEL_DEBUG_H
#define __KERNEL_DEBUG_H

void panic_spin(char* filename, int line, const char* func, const char* condition);

// 参数个数可变的宏
// __VA_ARGS__ 是预处理器所支持的专用标识符, 表示所有与省略号相对应的参数
// __FILE__, __LINE__, __func__ 都是预处理器支持的专用标识符
// ...表示宏的参数可变
#define PANIC(...)  panic_spin(__FILE__, __LINE__, __func__, __VA_ARGS__)

// 条件编译, 在gcc中指定预定义的宏 -DNDEBUG
// #CONDITION 将表达式转化为字符串常量
#ifdef NDEBUG
    #define ASSERT(CONDITION) ((void)0)
#else
    #define ASSERT(CONDITION) \
        if(CONDITION) {} \
        else { \
        PANIC(#CONDITION); \
        }
#endif // NODEBUG


#endif // __KERNEL_DEBUG_H