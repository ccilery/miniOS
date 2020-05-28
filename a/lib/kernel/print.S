SELECTOR_VIDEO equ 0x18 ; 0000000000011 000     视频段段选择子

[bits 32]
section .text
;--------------------------- put_char ---------------------------
;  功能描述: 把栈中的1个字符写入光标所在处
;----------------------------------------------------------------
global put_char ; 全局符号, 导出到外部文件可以使用
put_char:
    pushad  ; 备份所有32位寄存器 8个, 压入栈中的顺序: eax->ecx->edx->ebx->esp->ebp->esi->edi
    ; 为保险, 每次打印都重新设置视频段的段选择子
    mov ax, SELECTOR_VIDEO  ; 不能把立即数直接为段寄存器赋值
    mov gs, ax


    ;----------------- 获取光标位置, 光标是下一个打印字符的位置 ----------------
    ; 高8位
    mov dx, 0x3d4   ; address reg
    mov al, 0x0e    ; 索引
    out dx, al      ; 将索引写入到地址寄存器
    mov dx, 0x3d5   ; data reg
    in al, dx       ; 读出高8位
    mov ah, al      ; 高8位
    ; 低8位
    mov dx, 0x3d4   ; address reg
    mov al, 0x0f    ; 索引
    out dx, al      ; 将索引写入到地址寄存器
    mov dx, 0x3d5   ; data reg
    in al, dx       ; 读出低8位

    mov bx, ax
    mov ecx, [esp + 36]     ; 从栈中获取待打印的字符, 栈中压入 字符 + 返回地址 + 8个32位寄存器

    cmp cl, 0xd             ; 字符是回车
    jz .is_carriage_return
    cmp cl, 0xa             ; 字符是换行
    jz .is_line_feed

    cmp cl, 0x8             ; 字符是退格
    jz .is_backspace
    jmp .put_other          ; 其他字符
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------ 对字符的处理 ------------------------
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.is_backspace:  ; 光标前移一个位置, 将该位置的字符用空格覆盖  光标位置 bx
    dec bx
    shl bx, 1   ; 左移1位, 相当于*2, 显存的偏移量 = 光标位置 * 2
    mov byte [gs:bx], 0x20   ; 字符
    inc bx      
    mov byte [gs:bx], 0x07   ; 字符属性, 黑底白字
    shr bx, 1   ; 从显存偏移量恢复为光标位置
    jmp .set_cursor     ; 去向光标坐标寄存器更新光标坐标
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.put_other:
    shl bx, 1
    mov [gs:bx], cl     ; 字符
    inc bx
    mov byte [gs:bx], 0x07   ; 字符属性
    shr bx, 1
    inc bx              ; 下一个光标位置
    cmp bx, 2000        ; 一个屏幕2000个字符, 超出相当于在最后一行行尾换行处理, 滚屏
    jl .set_cursor

.is_line_feed:
.is_carriage_return:
    xor dx, dx
    mov ax, bx
    mov si, 80
    div si
    sub bx, dx          ;  处理回车, 光标移动到行首

.is_carriage_return_end:
    add bx, 80
    cmp bx, 2000
.is_line_feed_end:      ; 换行则需要将光标+80
    jl .set_cursor

.roll_screen:   ; 滚屏, 1-24行移动到0-23行, 第24行填充为空格
    cld
    mov ecx, 960    ; 2000-80=1920个字符, 1920*2=3840个字节, 3840/4 = 960次搬运
    mov esi, 0xc00b80a0 ; 第1行行首
    mov edi, 0xc00b8000 ; 第0行行首
    rep movsd

    ;;;;;;;;;; 最后一行填充为空白 ;;;;;;;;;;;;;;;;;;
    mov ebx, 3840
    mov ecx, 80
.cls:
    mov word [gs:ebx], 0x0720   ; 黑底白字的空格
    add ebx, 2
    loop .cls
    mov bx, 1920   ; 光标值为最后一行行首

.set_cursor:    ; 更新光标坐标寄存器
    mov dx, 0x03d4
    mov al, 0x0e
    out dx, al
    mov dx, 0x03d5
    mov al, bh
    out dx, al

    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al
    mov dx, 0x03d5
    mov al, bl
    out dx, al

.put_char_done:
    popad       ; 对应函数开头的 pushad
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end put_char ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
