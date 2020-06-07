SELECTOR_VIDEO equ 0x18 ; 0000000000011 000     视频段段选择子

[bits 32]
section .data
    put_int_buffer dq 0     ; 将32位无符号整数转换为16进制字符表示的缓冲区, 8个16进制字符

section .text

;--------------------------- put_str ---------------------------
;  功能描述: 把传入地址处的字符串打印到光标处, 传入的参数是字符串地址
;       将每个字符读取出来传入到put_char函数, 一直到 '\0' 为止
;----------------------------------------------------------------
global put_str
put_str:
    push ebx
    push ecx    ; 备份
    xor ecx, ecx
    mov ebx, [esp + 12]     ; 栈中的参数, 字符串的地址
.goon:
    mov cl, [ebx]           ; 读取字符
    cmp cl, 0               ; \0 字符
    jz .str_over
    push ecx                ; 为put_char传参
    call put_char
    add esp, 4              ; 清除参数
    inc ebx
    jmp .goon
.str_over:
    pop ecx
    pop ebx

    ret

;--------------------------- put_int -----------------------------------------------------
;   功能描述: 将小端字节序的数字变成对应的ascii后，倒置
;   输入：栈中参数为待打印的数字
;   输出：在屏幕上打印16进制数字,并不会打印前缀0x,如打印10进制15时，只会直接打印f，不会是0xf
;------------------------------------------------------------------------------------------
global put_int
put_int:
   pushad
   mov ebp, esp
   mov eax, [ebp+4*9]		       ; call的返回地址占4字节+pushad的8个4字节
   mov edx, eax
   mov edi, 7                          ; 指定在put_int_buffer中初始的偏移量
   mov ecx, 8			       ; 32位数字中,16进制数字的位数是8个
   mov ebx, put_int_buffer

;将32位数字按照16进制的形式从低位到高位逐个处理,共处理8个16进制数字
.16based_4bits:			       ; 每4位二进制是16进制数字的1位,遍历每一位16进制数字
   and edx, 0x0000000F		       ; 解析16进制数字的每一位。and与操作后,edx只有低4位有效
   cmp edx, 9			       ; 数字0～9和a~f需要分别处理成对应的字符
   jg .is_A2F 
   add edx, '0'			       ; ascii码是8位大小。add求和操作后,edx低8位有效。
   jmp .store
.is_A2F:
   sub edx, 10			       ; A~F 减去10 所得到的差,再加上字符A的ascii码,便是A~F对应的ascii码
   add edx, 'A'

;将每一位数字转换成对应的字符后,按照类似“大端”的顺序存储到缓冲区put_int_buffer
;高位字符放在低地址,低位字符要放在高地址,这样和大端字节序类似,只不过咱们这里是字符序.
.store:
; 此时dl中应该是数字对应的字符的ascii码
   mov [ebx+edi], dl		       
   dec edi
   shr eax, 4
   mov edx, eax 
   loop .16based_4bits

;现在put_int_buffer中已全是字符,打印之前,
;把高位连续的字符去掉,比如把字符000123变成123
.ready_to_print:
   inc edi			       ; 此时edi退减为-1(0xffffffff),加1使其为0
.skip_prefix_0:  
   cmp edi,8			       ; 若已经比较第9个字符了，表示待打印的字符串为全0 
   je .full0 
;找出连续的0字符, edi做为非0的最高位字符的偏移
.go_on_skip:   
   mov cl, [put_int_buffer+edi]
   inc edi
   cmp cl, '0' 
   je .skip_prefix_0		       ; 继续判断下一位字符是否为字符0(不是数字0)
   dec edi			       ;edi在上面的inc操作中指向了下一个字符,若当前字符不为'0',要恢复edi指向当前字符		       
   jmp .put_each_num

.full0:
   mov cl,'0'			       ; 输入的数字为全0时，则只打印0
.put_each_num:
   push ecx			       ; 此时cl中为可打印的字符
   call put_char
   add esp, 4
   inc edi			       ; 使edi指向下一个字符
   mov cl, [put_int_buffer+edi]	       ; 获取下一个字符到cl寄存器
   cmp edi,8
   jl .put_each_num
   popad
   ret

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

.put_other:     ; 可显示字符
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

; 供默认的中断处理函数使用, 将异常信息显示在左上方
global set_cursor
set_cursor:
   pushad
   mov bx, [esp+36]
;;;;;;; 1 先设置高8位 ;;;;;;;;
   mov dx, 0x03d4			  ;索引寄存器
   mov al, 0x0e				  ;用于提供光标位置的高8位
   out dx, al
   mov dx, 0x03d5			  ;通过读写数据端口0x3d5来获得或设置光标位置 
   mov al, bh
   out dx, al

;;;;;;; 2 再设置低8位 ;;;;;;;;;
   mov dx, 0x03d4
   mov al, 0x0f
   out dx, al
   mov dx, 0x03d5 
   mov al, bl
   out dx, al
   popad
   ret