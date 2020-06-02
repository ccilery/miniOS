#ifndef __KERNEL_INTERRUPT_H
#define __KERNEL_INTERRUPT_H

//-------------------------------- 中断初始化 ----------------------
#define IDT_DESC_CNT 0x21   // 目前支持的总中断数  33

// 中断控制器 8259A的端口
#define PIC_M_CTRL 0x20     // 主片的控制端口
#define PIC_M_DATA 0x21     // 主片的数据端口
#define PIC_S_CTRL 0xa0     // 从片的控制端口
#define PIC_S_DATA 0xa1     // 从片的数据端口

typedef void* intr_handler;     // 中断处理程序的入口地
void idt_init(void);

//------------------------------- 中断状态的一些操作 -----------------
#define EFLAGS_IF 0x00000200    // eflags寄存器中的IF为1, 开中断
#define GET_EFLAGS(EFLAGS_VAR) asm volatile("pushfl; popl %0" : "=g"(EFLAGS_VAR))  // 获取eflags寄存器内容到C程序中的变量

// 中断状态
enum intr_status
{
    INTR_OFF,
    INTR_ON
};
enum intr_status intr_get_status(void); // 获取当前中断状态
enum intr_status intr_set_status(enum intr_status status); // 设置中断状态并返回之前的中断状态
enum intr_status intr_enable(void); // 开中断并返回之前的中断状态
enum intr_status intr_disable(void); // 关中断并返回之前的中断状态


#endif // __KERNEL_INTERRUPT_H