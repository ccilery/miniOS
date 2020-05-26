%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR
jmp loader_start

; GDT
GDT_BASE: dq 0x0 
GDT_CODE: Descriptor STA_X, 0x0, 0xffffffff
GDT_STACK: Descriptor STA_W, 0x0, 0xfffffff
GDT_VIDEO: 
    dw 0x0007, 0x8000
    db 0x0b, 0x92, 0xc0, 0x00   ; 基址 0xb8000

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1
times 60 dq 0  ; 预留60个段描述符空位

; selector
SELECTOR_CODE equ 0x8
SELECTOR_DATA equ 0x10
SELECTOR_VIDEO equ 0x18

; 48bit
gdt_ptr:
        dw GDT_LIMIT
        dd GDT_BASE

msg db '2 loader in real.'

loader_start:
;------------------------------------------------------------
;INT 0x10    功能号:0x13    功能描述:打印字符串
;------------------------------------------------------------
;输入:
;AH 子功能号=13H
;BH = 页码
;BL = 属性(若AL=00H或01H)
;CX＝字符串长度
;(DH、DL)＝坐标(行、列)
;ES:BP＝字符串地址 
;AL＝显示输出方式
;   0——字符串中只含显示字符，其显示属性在BL中。显示后，光标位置不变
;   1——字符串中只含显示字符，其显示属性在BL中。显示后，光标位置改变
;   2——字符串中含显示字符和显示属性。显示后，光标位置不变
;   3——字符串中含显示字符和显示属性。显示后，光标位置改变
;无返回值
   mov	 sp, LOADER_BASE_ADDR
   mov	 bp, msg           ; ES:BP = 字符串地址
   mov	 cx, 17			 ; CX = 字符串长度
   mov	 ax, 0x1301		 ; AH = 13,  AL = 01h
   mov	 bx, 0x001f		 ; 页号为0(BH = 0) 蓝底粉红字(BL = 1fh)
   mov	 dx, 0x1800		 ;
   int	 0x10                    ; 10h 号中断


;;;;;;;;;;;;;;;;;;;;;;准备进入保护模式;;;;;;;;;;;;;
;;  1. 使能A20地址线
;;  2. 初始化GDTR寄存器
;;  3. 打开保护模式开关
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 1.使能A20地址线
in al, 0x92
or al, 0x02
out 0x92, al

;; 2. 初始化GDTR寄存器
lgdt [gdt_ptr]  ; 48bit

;; 3. 设置cr0的0位置为1
mov eax, cr0    ; 实模式下指令扩展
or eax, 0x1
mov cr0, eax

jmp SELECTOR_CODE:p_mode_start  ; 刷新流水线, 避免之前分支预测的影响
                                ; 更新CS段寄存器高速缓存

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    mov byte [gs:160], 'P'
    

    jmp $
