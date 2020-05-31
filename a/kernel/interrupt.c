#include "stdint.h"
#include "print.h"
#include "interrupt.h"
#include "global.h"
#include "io.h"

/*
 *  
 */

#define IDT_DESC_CNT 0x21   // 目前支持的总中断数  33

#define PIC_M_CTRL 0x20     // 主片的控制端口
#define PIC_M_DATA 0x21     // 主片的数据端口
#define PIC_S_CTRL 0xa0     // 从片的控制端口
#define PIC_S_DATA 0xa1     // 从片的数据端口

/*中断门描述符结构体, 低地址->高地址*/
struct gate_desc    // 8byte
{
    uint16_t func_offset_low_word;  // 中断处理例程在目标代码段中的偏移量(低16位)
    uint16_t selector;              // 中断处理例程所在目标代码段的段选择子
    uint8_t dcount;                 // 固定值 0
    uint8_t attribute;              // 中断门描述符的属性
    uint16_t func_offset_high_word; // 中断处理例程在目标代码段中的偏移量(高16位)
};

static struct gate_desc idt[IDT_DESC_CNT];      // 中断描述符表，中断门描述符的数组
extern intr_handler intr_entry_table[IDT_DESC_CNT];     // kernel.S中定义, 中断处理例程地址的数组

/*创建中断门描述符*/
// intr_handler: 中断处理例程的入口地址
static void make_idt_desc(struct gate_desc *p_gdesc, uint8_t attr, intr_handler function)
{
    p_gdesc->func_offset_low_word = (uint32_t)function & 0xffff;    // 低16位
    p_gdesc->selector = SELECTOR_K_CODE;    // 内核代码段选择子
    p_gdesc->dcount = 0;
    p_gdesc->attribute = attr;
    p_gdesc->func_offset_high_word = ((uint32_t)function & 0xffff0000) >> 16;
}

/*初始化中断描述符表, 创建每一个中断门描述符*/
static void idt_desc_init()
{
    int i;
    for(i = 0; i < IDT_DESC_CNT; i++)
        make_idt_desc(&idt[i], IDT_DESC_ATTR_DPL0, intr_entry_table[i]);
    put_str("    idt_desc_init done\n");
}

/*初始化8259A*/
void pci_init()
{
    // ICW字 初始化命令字
    outb(PIC_M_CTRL, 0x11);     // ICW1 
    outb(PIC_M_DATA, 0x20);     // ICW2
    outb(PIC_M_DATA, 0x04);     // ICW3
    outb(PIC_M_DATA, 0x01);     // ICW4

    outb(PIC_S_CTRL, 0x11);     // ICW1 
    outb(PIC_S_DATA, 0x28);     // ICW2
    outb(PIC_S_DATA, 0x02);     // ICW3
    outb(PIC_S_DATA, 0x01);     // ICW4

    // OCW字 操作命令字
    outb(PIC_M_DATA, 0xfe);
    outb(PIC_S_DATA, 0xff);

    put_str("    pic_init done\n");
}

/*中断相关的初始化操作*/
void idt_init()
{
    put_str("idt_init start\n");

    idt_desc_init();        // 初始化中断描述符表
    pci_init();             // 初始化中断控制器 8259A

    /*加载idt到idtr寄存器*/
    uint64_t idt_operand = (sizeof(idt) - 1) | ((int64_t)(uint32_t)idt << 16);
    asm volatile ("lidt %0": : "m"(idt_operand));   // 取64bit中的低48bit
    put_str("idt_init done\n");
}