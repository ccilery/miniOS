#ifndef __KERNEL_INTERRUPT_H
#define __KERNEL_INTERRUPT_H

typedef void* intr_handler;     // 中断处理程序的入口地址

void idt_init();
#endif // __KERNEL_INTERRUPT_H