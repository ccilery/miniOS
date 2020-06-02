#ifndef __KERNEL_INTERRUPT_H
#define __KERNEL_INTERRUPT_H

#define IDT_DESC_CNT 0x21   // 目前支持的总中断数  33

#define PIC_M_CTRL 0x20     // 主片的控制端口
#define PIC_M_DATA 0x21     // 主片的数据端口
#define PIC_S_CTRL 0xa0     // 从片的控制端口
#define PIC_S_DATA 0xa1     // 从片的数据端口

typedef void* intr_handler;     // 中断处理程序的入口地址

void idt_init();
#endif // __KERNEL_INTERRUPT_H