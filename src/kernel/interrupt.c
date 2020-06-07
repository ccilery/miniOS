#include "stdint.h"
#include "print.h"
#include "interrupt.h"
#include "global.h"
#include "io.h"

extern void set_cursor(int pos);

/*中断门描述符结构体, 低地址->高地址*/
struct gate_desc    // 8byte
{
    uint16_t func_offset_low_word;  // 中断处理例程在目标代码段中的偏移量(低16位)
    uint16_t selector;              // 中断处理例程所在目标代码段的段选择子
    uint8_t dcount;                 // 固定值 0
    uint8_t attribute;              // 中断门描述符的属性
    uint16_t func_offset_high_word; // 中断处理例程在目标代码段中的偏移量(高16位)
};

char* intr_name[IDT_DESC_CNT];                          // 异常的名字
static struct gate_desc idt[IDT_DESC_CNT];              // 中断描述符表，中断门描述符的数组
extern intr_handler intr_entry_table[IDT_DESC_CNT];     // kernel.S中定义, 中断处理例程入口的数组
intr_handler idt_table[IDT_DESC_CNT];                   // 中断处理程序地址的数组, intr_entry_table[i] ---> idt_table[i]

/*创建中断门描述符*/
// function: 中断处理例程的入口地址
static void make_idt_desc(struct gate_desc *p_gdesc, uint8_t attr, intr_handler function)
{
    p_gdesc->func_offset_low_word = (uint32_t)function & 0xffff;    // 低16位
    p_gdesc->selector = SELECTOR_K_CODE;    // 内核代码段选择子
    p_gdesc->dcount = 0;
    p_gdesc->attribute = attr;
    p_gdesc->func_offset_high_word = ((uint32_t)function & 0xffff0000) >> 16;
}

/*初始化中断描述符表, 创建每一个中断门描述符*/
static void idt_desc_init(void)
{
    int i;
    for(i = 0; i < IDT_DESC_CNT; i++)
        make_idt_desc(&idt[i], IDT_DESC_ATTR_DPL0, intr_entry_table[i]);
    put_str("    idt_desc_init done\n");
}

// 默认的中断处理程序, vec_nr 中断向量号
static void general_intr_handler(uint16_t vec_nr)
{
    if(vec_nr == 0x27 || vec_nr == 0x2f)    // 伪中断, 不处理
        return;

    //重置光标位于左上角, 并清空4行
    set_cursor(0);
    int cursor_pos = 0;
    while(cursor_pos < 320)
    {
        put_char(' ');
        cursor_pos++;
    }
    set_cursor(0);

    put_str("!!!!!!!!!!!! exception message begin !!!!!!!!!!!!!!!!\n");
    set_cursor(88);  // 第2行的第8个字符开始打印
    put_str(intr_name[vec_nr]);
    if(vec_nr == 14)    // pagefault
    {
        uint32_t page_fault_vaddr = 0;
        asm volatile("movl %%cr2, %0" : "=r"(page_fault_vaddr)); // cr2存放page fault的地址
        put_str("\npage fault addr is ");
        put_int(page_fault_vaddr);
    } 
    put_str("\n!!!!!! exception message end !!!!!!!!!!!!!!!!!!!!!!!!!\n");

    while(1);
}

 // 异常名初始化, 注册默认的中断处理程序
static void exception_init(void)
{
    int i;
    for(i = 0; i < IDT_DESC_CNT; i++)
    {
        idt_table[i] = general_intr_handler;    // 注册中断处理程序
        intr_name[i] = "unknown";
    }
    intr_name[0] = "#DE Divide Error";
    intr_name[1] = "#DB Debug Exception";
    intr_name[2] = "NMI Interrupt";
    intr_name[3] = "#BP Breakpoint Exception";
    intr_name[4] = "#OF Overflow Exception";
    intr_name[5] = "#BR BOUND Range Exceeded Exception";
    intr_name[6] = "#UD Invalid Opcode Exception";
    intr_name[7] = "#NM Device Not Available Exception";
    intr_name[8] = "#DF Double Fault Exception";
    intr_name[9] = "Coprocessor Segment Overrun";
    intr_name[10] = "#TS Invalid TSS Exception";
    intr_name[11] = "#NP Segment Not Present";
    intr_name[12] = "#SS Stack Fault Exception";
    intr_name[13] = "#GP General Protection Exception";
    intr_name[14] = "#PF Page-Fault Exception";
    // intr_name[15] 第15项是intel保留项，未使用
    intr_name[16] = "#MF x87 FPU Floating-Point Error";
    intr_name[17] = "#AC Alignment Check Exception";
    intr_name[18] = "#MC Machine-Check Exception";
    intr_name[19] = "#XF SIMD Floating-Point Exception";
}

// vec_nr号中断安装中断处理程序
void register_handler(uint8_t vec_nr, intr_handler function)
{
    idt_table[vec_nr] = function;
}

/*初始化8259A*/
static void pci_init(void)
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
void idt_init(void)
{
    put_str("idt_init start\n");

    idt_desc_init();        // 初始化中断描述符表  中断处理程序的入口
    exception_init();       // 异常名初始化, 注册默认的中断处理程序
    pci_init();             // 初始化中断控制器 8259A

    /*加载idt到idtr寄存器*/
    uint64_t idt_operand = (sizeof(idt) - 1) | ((int64_t)(uint32_t)idt << 16);
    asm volatile ("lidt %0": : "m"(idt_operand));   // 取64bit中的低48bit
    put_str("idt_init done\n");
}
/*
外部中断发生后, 外设向中断控制器发送中断信号, 中断控制器经过中断仲裁, 将优先级高的中断信号处理为中断向量号发送给CPU, 
如果CPU没有屏蔽中断, CPU根据中断描述符表寄存器找到中断描述符表的地址, 从中断描述符表找到对应的中断向量, 然后找到中断处理程序的入口,
中断处理程序的入口处会调用注册的中断处理程序, 处理完, 中断返回.
*/

//-------------------------------------- 中断状态的一些操作函数 --------------------------

// 开中断并返回开中断前的状态
enum intr_status intr_enable(void)
{
    enum intr_status old_status;
    old_status = intr_get_status();
    if(old_status == INTR_OFF)
        asm volatile("sti");    // 开中断
    return old_status;
}

// 关中断并返回关中断前的状态
enum intr_status intr_disable(void)
{
    enum intr_status old_status;
    old_status = intr_get_status();
    if(old_status == INTR_ON)
        asm volatile("cli");    // 关中断
    return old_status;
}

// 设置中断状态, 并返回之前的状态
enum intr_status intr_set_status(enum intr_status status)
{
    return status == INTR_ON ? intr_enable() : intr_disable();
}

// 获取当前中断状态
enum intr_status intr_get_status(void)
{
    uint32_t eflags = 0;
    GET_EFLAGS(eflags);
    return (eflags & EFLAGS_IF) == 0 ? INTR_OFF : INTR_ON;
}