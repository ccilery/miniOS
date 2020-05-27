;loader程序
;   1. GDT表, gdt_ptr, total_mem_bytes 等 0x300个字节的数据结构
;   2. 获取内存容量于total_mem_bytes处
;   3. 打印当前进度
;   4. 准备进入保护模式
;   5. 保护模式下的初始化
;----------------------------------------------------

%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR  ; 起始地址编译为 0x900, 线性地址也是物理地址

;;;;;;;;;;;;;;;;;;;;;;; 1. GDT表, gdt_ptr, total_mem_bytes 等 0x300个字节的数据结构 ;;;;;;;;;;;;;;;;;
; selector
SELECTOR_CODE equ 0x8
SELECTOR_DATA equ 0x10
SELECTOR_VIDEO equ 0x18

; GDT  64 * 8 = 512 = 0x200 字节
GDT_BASE:   dq 0x0 
GDT_CODE:   Descriptor STA_X, 0x0, 0xffffffff
GDT_STACK:  Descriptor STA_W, 0x0, 0xffffffff
GDT_VIDEO: 
    dw 0x0007, 0x8000
    db 0x0b, 0x92, 0xc0, 0x00   ; 基址 0xb8000

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1
times 60 dq 0  ; 预留60个段描述符空位


; total_mem_bytes用于保存内存容量,以字节为单位,此位置比较好记。
; 当前偏移loader.bin文件头0x200字节,loader.bin的加载地址是0x900,
; 故total_mem_bytes内存中的地址是0xb00.将来在内核中咱们会引用此地址
total_mem_bytes dd 0					 

;以下是定义gdt的指针，前2字节是gdt界限，后4字节是gdt起始地址
gdt_ptr  dw  GDT_LIMIT 
         dd  GDT_BASE

;人工对齐:total_mem_bytes4字节+gdt_ptr6字节+ards_buf244字节+ards_nr2,共256字节
msg db '2 loader'
ards_buf times 236 db 0
ards_nr dw 0		      ;用于记录ards结构体数量


loader_start:   ;当前偏移loader.bin文件头0x300字节

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 2. 获取内存容量于total_mem_bytes处 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------  int 15h eax = 0000E820h ,edx = 534D4150h ('SMAP') 获取内存布局  -------
   xor ebx, ebx		      ;第一次调用时，ebx值要为0
   mov edx, 0x534d4150	      ;edx只赋值一次，循环体中不会改变
   mov di, ards_buf	      ;ards结构缓冲区
.e820_mem_get_loop:	      ;循环获取每个ARDS内存范围描述结构
   mov eax, 0x0000e820	      ;执行int 0x15后,eax值变为0x534d4150,所以每次执行int前都要更新为子功能号。
   mov ecx, 20		      ;ARDS地址范围描述符结构大小是20字节
   int 0x15
   jc .e820_failed_so_try_e801   ;若cf位为1则有错误发生，尝试0xe801子功能
   add di, cx		      ;使di增加20字节指向缓冲区中新的ARDS结构位置
   inc word [ards_nr]	      ;记录ARDS数量
   cmp ebx, 0		      ;若ebx为0且cf不为1,这说明ards全部返回，当前已是最后一个
   jnz .e820_mem_get_loop

;在所有ards结构中，找出(base_add_low + length_low)的最大值，即内存的容量。
   mov cx, [ards_nr]	      ;遍历每一个ARDS结构体,循环次数是ARDS的数量
   mov ebx, ards_buf 
   xor edx, edx		      ;edx为最大的内存容量,在此先清0
.find_max_mem_area:	      ;无须判断type是否为1,最大的内存块一定是可被使用
   mov eax, [ebx]	      ;base_add_low
   add eax, [ebx+8]	      ;length_low
   add ebx, 20		      ;指向缓冲区中下一个ARDS结构
   cmp edx, eax		      ;冒泡排序，找出最大,edx寄存器始终是最大的内存容量
   jge .next_ards
   mov edx, eax		      ;edx为总内存大小
.next_ards:
   loop .find_max_mem_area
   jmp .mem_get_ok

;------  int 15h ax = E801h 获取内存大小,最大支持4G  ------
; 返回后, ax cx 值一样,以KB为单位,bx dx值一样,以64KB为单位
; 在ax和cx寄存器中为低16M,在bx和dx寄存器中为16MB到4G。
.e820_failed_so_try_e801:
   mov ax,0xe801
   int 0x15
   jc .e801_failed_so_try88   ;若当前e801方法失败,就尝试0x88方法

;1 先算出低15M的内存,ax和cx中是以KB为单位的内存数量,将其转换为以byte为单位
   mov cx,0x400	     ;cx和ax值一样,cx用做乘数
   mul cx 
   shl edx,16
   and eax,0x0000FFFF
   or edx,eax
   add edx, 0x100000 ;ax只是15MB,故要加1MB
   mov esi,edx	     ;先把低15MB的内存容量存入esi寄存器备份

;2 再将16MB以上的内存转换为byte为单位,寄存器bx和dx中是以64KB为单位的内存数量
   xor eax,eax
   mov ax,bx		
   mov ecx, 0x10000	;0x10000十进制为64KB
   mul ecx		;32位乘法,默认的被乘数是eax,积为64位,高32位存入edx,低32位存入eax.
   add esi,eax		;由于此方法只能测出4G以内的内存,故32位eax足够了,edx肯定为0,只加eax便可
   mov edx,esi		;edx为总内存大小
   jmp .mem_get_ok

;-----------------  int 15h ah = 0x88 获取内存大小,只能获取64M之内  ----------
.e801_failed_so_try88: 
   ;int 15后，ax存入的是以kb为单位的内存容量
   mov  ah, 0x88
   int  0x15
   jc .error_hlt
   and eax,0x0000FFFF
      
   ;16位乘法，被乘数是ax,积为32位.积的高16位在dx中，积的低16位在ax中
   mov cx, 0x400     ;0x400等于1024,将ax中的内存容量换为以byte为单位
   mul cx
   shl edx, 16	     ;把dx移到高16位
   or edx, eax	     ;把积的低16位组合到edx,为32位的积
   add edx,0x100000  ;0x88子功能只会返回1MB以上的内存,故实际内存大小要加上1MB

.mem_get_ok:
   mov [total_mem_bytes], edx	 ;将内存换为byte单位后存入total_mem_bytes处。


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 3. 打印当前进度 ;;;;;;;;;;;;;;;;;;;;
   mov byte [gs:160], '2'
   mov byte [gs:162], ' '
   mov byte [gs:164], 'l'
   mov byte [gs:166], 'o'
   mov byte [gs:168], 'a'
   mov byte [gs:170], 'd'
   mov byte [gs:172], 'e'
   mov byte [gs:174], 'r'



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4. 准备进入保护模式;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  1. 使能A20地址线
;;  2. 初始化GDTR寄存器
;;  3. 打开保护模式开关
;---------------------------------------------------------------------------

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

mov byte [gs:178], 'P'   ; 进入保护模式

jmp SELECTOR_CODE:p_mode_start  ; 刷新流水线, 避免之前分支预测的影响
                                ; 更新CS段寄存器高速缓存

.error_hlt:		      ;出错则挂起
   hlt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 5. 保护模式下的初始化 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  1. 初始化段寄存器
;;  2. 建立页目录表和页表
;;  3. 更新GDT表, 将GDT表"放入"内核虚拟地址空间, 显存"放入"内核虚拟地址空间, 栈"放入"内核虚拟地址空间
;;  4. 打开页机制
;----------------------------------------------------------------------------------

[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax

    call setup_page     ; 建立页目录表和页表

    ; 将GDT表"放入"内核虚拟地址空间
    ; 显存"放入"内核虚拟地址空间
    ; 栈"放入"内核虚拟地址空间
    sgdt [gdt_ptr]
    mov ebx, [gdt_ptr + 2]
    or dword [ebx + 0x18 + 4], 0xc000000 ; 修改video段基址为线性地址
    add dword [gdt_ptr + 2], 0xc0000000
    add esp, 0xc0000000

    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax    ; 页目录表的物理地址

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax    ; PG开关打开

    lgdt [gdt_ptr]

    mov byte [gs:182], 'V'  ; 页机制打开
    
    jmp $

;------------------ 创建页目录及页表 -----------
;  1. 清空页目录表所在空间
;  2. 创建页目录项, 0号页目录项以及内核空间的页目录项 768~1023
;  3. 创建第一个页表的 256 个页表项, 映射到物理内存低地址的1M空间
;---------------------------------------------- 
setup_page:
; 清空页目录所占用的空间  
; 物理地址 0x100000~0x100fff, 因为还没有开启页机制, 也是线性地址
    mov ecx, 4096
    mov esi, 0
.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

; 创建页目录项, 页目录项中的是物理地址
; 内核虚拟地址空间: 0xc0000000~0xffffffff 所在的页目录项为 768~1023项
; 为了在多进程中共享内核的虚拟地址空间, 需要将内核虚拟地址空间的页表项都建立起来
; 
.create_pde:
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x1000     ; 第一个页表的物理地址
    mov ebx, eax
    or eax, PG_US_U | PG_RW_W | PG_P  ; pde
    mov [PAGE_DIR_TABLE_POS + 0x0], eax     ; 0号页目录项
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax   ; 768号页目录项 内核虚拟地址空间的第一个页目录
    
    sub eax, 0x1000     ; 页目录表的地址 + 数目
    mov [PAGE_DIR_TABLE_POS + 4092], eax    ; 最后一个页目录项, 指向页目录表, 用于通过虚拟地址访问到页目录表和页表

    ; 创建第一个页表的页表项, 只设置其中的256个, 对应1M的低位内存
    mov ecx, 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P   ; pte, 起始页的物理地址为0
.create_pte:
    mov [ebx + esi * 4], edx    ; ebx第一个页表的物理地址
    inc esi 
    add edx, 4096   ; 下一个物理页的地址
    loop .create_pte

    ; 创建内核虚拟地址空间的其他页目录项 769~1022
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000     ;第二个页表的物理地址
    or eax, PG_US_U | PG_RW_W | PG_P  ; pde
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254    ; 1022-769+1
    mov esi, 769
.create_kernel_pde:
    mov [ebx + esi * 4], eax
    inc esi
    add eax, 0x1000 ; 下一个页表的物理地址
    loop .create_kernel_pde
    ret


