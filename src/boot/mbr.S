;主引导程序 
;   1. 初始化段寄存器
;   2. 调用BIOS中断清屏
;   3. 直接向显存写入数据, 打印当前进度
;   4. 载入 loader 程序, 并跳转过去
;------------------------------------------------------------

%include "boot.inc"
SECTION MBR vstart=0x7c00   ; 起始地址编译为 0x7c00, 线性地址也是物理地址

;;;;;;;;;;;;;;;;;;;;;;;;; 1. 初始化段寄存器 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      
    mov ax,cs           ; 用cs寄存器初始化其他段寄存器, BIOS最后跳转指令 jmp 0:7c00, 因此cs=0 
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00       ; 栈指针, 指向栈顶, 向低地址走 0~0x7c00为栈空间
    mov ax, 0xb800      ; 显存 0xb8000~0xbffff的段基址
    mov gs, ax          

;;;;;;;;;;;;;;;;;;;;;;; 2. 清屏 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 清屏 利用0x06号功能，上卷全部行，则可清屏。 
; -----------------------------------------------------------
;INT 0x10   功能号:0x06	   功能描述:上卷窗口
;------------------------------------------------------
;输入：
;AH 功能号= 0x06
;AL = 上卷的行数(如果为0,表示全部)
;BH = 上卷行属性
;(CL,CH) = 窗口左上角的(X,Y)位置
;(DL,DH) = 窗口右下角的(X,Y)位置
;无返回值：
    mov     ax, 0x600       ; ah 0x06
    mov     bx, 0x700
    mov     cx, 0           ; 左上角: (0, 0)
    mov     dx, 0x184f	   ; 右下角: (80,25),
                ; VGA文本模式中,一行只能容纳80个字符,共25行。
                ; 下标从0开始,所以0x18=24,0x4f=79
    int     0x10            ; int 0x10 BIOS中断


;;;;;;;;;;;;;;;;;;;;;;;;; 3. 直接向显存写入数据, 打印当前进度 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov byte [gs:0x00], '1'     ; 字符
    ; mov byte [gs:0x01], 0xA4    ; 字符属性, 前景色+背景色

    mov byte [gs:0x02], ' '
    ; mov byte [gs:0x03], 0xA4

    mov byte [gs:0x04], 'M'
    ; mov byte [gs:0x05], 0xA4

    mov byte [gs:0x06], 'B'
    ; mov byte [gs:0x07], 0xA4

    mov byte [gs:0x08], 'R'
    ; mov byte [gs:0x09], 0xA4


;;;;;;;;;;;;;;;;;;;;;;;;; 4. 从磁盘读取 loader 程序, 并跳转 ;;;;;;;;;;;;;;;;
    mov eax, LOADER_START_SECTOR  ; 2 lsa模式 
    mov bx, LOADER_BASE_ADDR      ; 0x900
    mov cx, 4   ; 读取的扇区数目
    call rd_disk_m_16

    jmp LOADER_BASE_ADDR + 0x300    ; loader程序的前0x300字节为GDT表等数据

;-----------------------------------------
; 功能: 16位实模式下读取硬盘n个扇区
;   eax: 从该扇区开始读
;   bx: 读取到内存的位置
;   cx: 读取扇区的数目
rd_disk_m_16:
;-----------------------------------------
    mov esi, eax    ; 备份eax
    mov di, cx      ; 备份cx

; 第一步: 设置要读取的扇区数
    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi    ; 恢复eax

;第2步: 将LBA地址存入0x1f3-0x1f6
    ; LBA地址的0-7位写入端口0x1f3
    mov dx, 0x1f3
    out dx, al

    ; LBA地址的8-15位写入端口0x1f4
    mov dx, 0x1f4
    mov cl, 8       ; cx的数据已经用完，扇区数
    shr eax, cl     ; 右移8位
    out dx, al

    ; LBA地址的16-23位写入端口0x1f5
    mov dx, 0x1f5
    shr eax, cl
    out dx, al

    shr eax, cl
    and al, 0x0f    ; 只保留低4位, 原来eax的24-27位
    or al, 0xe0     ; 设置高4位 1110, lba模式
    mov dx, 0x1f6
    out dx, al

; 第3步: 向0x1f7端口写入读命令
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

; 第4步: 检测硬盘状态, 读0x1f7端口
  .not_ready:
    nop             ; 什么都不做, 增加延迟, 等待硬盘状态改变
    in al, dx
    and al, 0x88    ; 第4位为1表示硬盘控制器准备好数据传送, 第7位为1表示硬盘忙
                    ; 10001000
    cmp al, 0x08
    jnz .not_ready      ; 条件跳转

; 第5步: 从0x1f0端口读数据
    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
    mov dx, 0x1f0
  .go_on_read:
    in ax, dx
    mov [bx], ax    ; 内存位置 0:bx
    add bx, 2
    loop .go_on_read
    ret

    times 510-($-$$) db 0
    db 0x55, 0xaa