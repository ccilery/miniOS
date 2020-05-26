;------------------ loader 和 kernel
LOADER_BASE_ADDR equ 0x900      ; loader程序加载到0x900处
LOADER_START_SECTOR equ 0x2     ; loader程序从磁盘的第2号扇区开始  LBS逻辑扇区

; 段描述符中的type字段
STA_X	equ	0x8	    ;Executable segment
STA_E	equ	0x4	    ;Expand down (non-executable segments)
STA_C	equ	0x4	    ;Conforming code segment (executable only)
STA_W	equ	0x2	    ;Writeable (non-executable segments)
STA_R	equ	0x2	    ;Readable (executable segments)
STA_A	equ	0x1	    ;Accessed


; 段描述符的宏定义
; %macro Descriptor_NULL 0
; dw 0x0, 0x0
; db 0x0, 0x0, 0x0, 0x0

; (type, base, limit) base 32位, limit 32位
%macro Descriptor 3     
dw  ((%3 >> 12) & 0xffff), ((%2) & 0xffff)
db  ((%2 >> 16) & 0xff), (0x90 | %1) 
db  (0xC0 | ((%3 >> 28) & 0xf)), ((%2 >> 24) & 0xff)
%endmacro