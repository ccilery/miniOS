[bits 32]
section .text
global switch_to
switch_to:      ; 两个参数, 第一个参数是当前线程PCB, 第二个是下一个调度的线程PCB
    push esi
    push edi
    push ebx
    push ebp
    mov eax, [esp + 20]     ; 获取第一个参数当前线程的PCB地址  栈中的内容  ebp ebx edi esi 返回地址 第一个参数 第二个参数...
    mov [eax], esp          ; 将当前栈的栈顶保存到PCB的kstack


    ;;;;;;;;;;;;;;; 恢复下一个线程的寄存器环境
    mov eax, [esp + 24]     ; 第二个参数, 下一个线程的PCB地址
    mov esp, [eax]          ; 下一个线程的栈顶
    pop ebp
    pop ebx
    pop edi
    pop esi
    ret     ; 如果是第一次执行线程中的函数, 此时栈指针指向函数入口, 
            ; 如果已经执行过线程中的函数, 此时根据上一次对该线程环境的保存, esi上面的是schedule中调用switch_to的返回地址
