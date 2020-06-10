#ifndef __LIB_KERNEL_PRINT_H
#define __LIB_KERNEL_PRINT_H

#include "stdint.h"
void put_str(const char*);
void put_char(uint8_t);
void put_int(uint32_t);
void set_cursor(uint32_t cursor_pos);
#endif // __LIB_KERNEL_PRINT_H