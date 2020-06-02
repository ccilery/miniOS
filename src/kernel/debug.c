#include "debug.h"
#include "print.h"
#include "interrupt.h"

void panic_spin(char* filename, int line, const char* func, const char* condition)
{

    enum intr_status old = intr_disable(); // 关中断
    put_str("\n\n!!!! error !!!!\n");
    put_str("filename: "); put_str(filename); put_char('\n');
    put_str("line: "); put_int(line); put_char('\n');
    put_str("function: "); put_str(func); put_char('\n');
    put_str("condition: "); put_str(condition); put_char('\n');
    while(1);
}