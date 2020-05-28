;------------------ loader 和 kernel
LOADER_BASE_ADDR equ 0x900      ; loader程序加载到0x900处
LOADER_START_SECTOR equ 0x2     ; loader程序从磁盘的第2号扇区开始  LBS逻辑扇区
LOADER_STACK_TOP equ LOADER_BASE_ADDR
PAGE_DIR_TABLE_POS equ 0x100000     ; page directory table 的物理地址
KERNEL_START_SECTOR equ 0x9
KERNEL_BIN_BASE_ADDR equ 0x70000    ; 内核文件所在的物理地址
KERNEL_ENTRY_POINT equ 0xc0001500
PT_NULL equ 0
; 段描述符中的type字段
STA_X	equ	0x8	    ;Executable segment
STA_E	equ	0x4	    ;Expand down (non-executable segments)
STA_C	equ	0x4	    ;Conforming code segment (executable only)
STA_W	equ	0x2	    ;Writeable (non-executable segments)
STA_R	equ	0x2	    ;Readable (executable segments)
STA_A	equ	0x1	    ;Accessed

; 段描述符的宏定义
; (type, base, limit) base 32位, limit 32位
%macro Descriptor 3     
dw  ((%3 >> 12) & 0xffff), ((%2) & 0xffff)
db  ((%2 >> 16) & 0xff), (0x90 | %1) 
db  (0xC0 | ((%3 >> 28) & 0xf)), ((%2 >> 24) & 0xff)
%endmacro

;-------------------- 页表相关属性 -----------
; PDE和PTE的低3位
PG_P equ 1b
PG_RW_R equ 00b
PG_RW_W equ 10b
PG_US_S equ 000b
PG_US_U equ 100b