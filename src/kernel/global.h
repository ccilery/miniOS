#ifndef __KERNEL_GLOBAL_H
#define __KERNEL_GLOBAL_H

/*----------------------------------- 段选择子 ----------------------------------*/
// 段选择子中的RPL
#define RPL0 0
#define RPL1 1
#define RPL2 2
#define RPL3 3

// 段选择子中的TI位
#define TI_GDT 0
#define TI_LDT 1

// 内核空间段选择子 16bit
#define SELECTOR_K_CODE (1 << 3) + (TI_GDT << 2) + RPL0     // 代码段选择子, 0000000000001_0_00
#define SELECTOR_K_DATA (2 << 3) + (TI_GDT << 2) + RPL0     // 数据段选择子, 0000000000010_0_00
#define SELECTOR_K_STACK SELECTOR_K_DATA
#define SELECTOR_K_GS   (3 << 3) + (TI_GDT << 2) + RPL0     // 显示段选择子, 0000000000011_0_00


/*----------------------------------- 中断门描述符 ----------------------------------*/

#define IDT_DESC_P 1        // P字段, 段是否在内存
#define IDT_DESC_DPL0 0     // DPL字段
#define IDT_DESC_DPL3 3
#define IDT_DESC_32_TYPE 0xE    // type字段 1110

// 中断门描述符的属性
#define IDT_DESC_ATTR_DPL0 \
        ((IDT_DESC_P << 7) + (IDT_DESC_DPL0 << 5) + IDT_DESC_32_TYPE)  // S为为0,系统段  10001110

#define IDT_DESC_ATTR_DPL3 \
        ((IDT_DESC_P << 7) + (IDT_DESC_DPL3 << 5) + IDT_DESC_32_TYPE)  // 11101110
#endif // __KERNEL_GLOBAL_H