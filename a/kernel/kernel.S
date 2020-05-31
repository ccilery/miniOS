[bits 32]
; 单行宏
; 中断发生时，会压入错误码
%define ERROR_CODE nop  
; 中断发生时，不会压入错误码, 压入一个32位的数，使得压入错误码的中断和不压入错误码的中断 的栈结构中栈顶指针相同
%define ZERO push 0

extern put_str ; 声明外部函数

section .data
intr_str db "interrupt occur!", 0xa, 0  ; 回车, '\0'



; 第一个参数为 中断向量号
; 第二个参数为 占位操作, 使得对会压入错误码的中断和不会压入错误码的中断具有统一的处理
%macro VECTOR 2
section .text
intr%1entry:   ; 中断处理程序的入口地址
    %2  ; 进入中断处理程序前, 处理器会自动进行压栈操作 (ss, esp, eflags, cs, eip) 以及 error code
    push intr_str       ; put_str的参数
    call put_str
    add esp, 4          ; 主调函数处理参数

    mov al, 0x20        ; EOI, 中断结束标记
    out 0xa0, al        ; 向从片写入 OCW2
    out 0x20, al        ; 向主片写入 OCW2

    add esp, 4          ; 跳过错误码或占位符
    iret

section .data
    dd intr%1entry ; 存储中断处理程序的入口地址

%endmacro

global intr_entry_table     ; 全局符号
intr_entry_table:
                ; 所有的宏展开后, 所有的.data会合并成一个segment, 在内存地址连续
VECTOR 0x00,ZERO
VECTOR 0x01,ZERO
VECTOR 0x02,ZERO
VECTOR 0x03,ZERO 
VECTOR 0x04,ZERO
VECTOR 0x05,ZERO
VECTOR 0x06,ZERO
VECTOR 0x07,ZERO 
VECTOR 0x08,ERROR_CODE
VECTOR 0x09,ZERO
VECTOR 0x0a,ERROR_CODE
VECTOR 0x0b,ERROR_CODE 
VECTOR 0x0c,ZERO
VECTOR 0x0d,ERROR_CODE
VECTOR 0x0e,ERROR_CODE
VECTOR 0x0f,ZERO 
VECTOR 0x10,ZERO
VECTOR 0x11,ERROR_CODE
VECTOR 0x12,ZERO
VECTOR 0x13,ZERO 
VECTOR 0x14,ZERO
VECTOR 0x15,ZERO
VECTOR 0x16,ZERO
VECTOR 0x17,ZERO 
VECTOR 0x18,ERROR_CODE
VECTOR 0x19,ZERO
VECTOR 0x1a,ERROR_CODE
VECTOR 0x1b,ERROR_CODE 
VECTOR 0x1c,ZERO
VECTOR 0x1d,ERROR_CODE
VECTOR 0x1e,ERROR_CODE
VECTOR 0x1f,ZERO 
VECTOR 0x20,ZERO
