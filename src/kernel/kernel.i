%line 1+1 kernel.S
[bits 32]






[extern put_str]
[extern idt_table]



%line 46+1 kernel.S


[section .data]
intr_str db "interrupt occur!", 0xa, 0

[global intr_entry_table]
intr_entry_table:

[section .text]
%line 54+0 kernel.S
intr0x00entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x00
 call [idt_table + 0x00 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x00entry

%line 55+1 kernel.S
[section .text]
%line 55+0 kernel.S
intr0x01entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x01
 call [idt_table + 0x01 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x01entry

%line 56+1 kernel.S
[section .text]
%line 56+0 kernel.S
intr0x02entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x02
 call [idt_table + 0x02 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x02entry

%line 57+1 kernel.S
[section .text]
%line 57+0 kernel.S
intr0x03entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x03
 call [idt_table + 0x03 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x03entry

%line 58+1 kernel.S
[section .text]
%line 58+0 kernel.S
intr0x04entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x04
 call [idt_table + 0x04 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x04entry

%line 59+1 kernel.S
[section .text]
%line 59+0 kernel.S
intr0x05entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x05
 call [idt_table + 0x05 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x05entry

%line 60+1 kernel.S
[section .text]
%line 60+0 kernel.S
intr0x06entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x06
 call [idt_table + 0x06 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x06entry

%line 61+1 kernel.S
[section .text]
%line 61+0 kernel.S
intr0x07entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x07
 call [idt_table + 0x07 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x07entry

%line 62+1 kernel.S
[section .text]
%line 62+0 kernel.S
intr0x08entry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x08
 call [idt_table + 0x08 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x08entry

%line 63+1 kernel.S
[section .text]
%line 63+0 kernel.S
intr0x09entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x09
 call [idt_table + 0x09 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x09entry

%line 64+1 kernel.S
[section .text]
%line 64+0 kernel.S
intr0x0aentry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x0a
 call [idt_table + 0x0a * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0aentry

%line 65+1 kernel.S
[section .text]
%line 65+0 kernel.S
intr0x0bentry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x0b
 call [idt_table + 0x0b * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0bentry

%line 66+1 kernel.S
[section .text]
%line 66+0 kernel.S
intr0x0centry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x0c
 call [idt_table + 0x0c * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0centry

%line 67+1 kernel.S
[section .text]
%line 67+0 kernel.S
intr0x0dentry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x0d
 call [idt_table + 0x0d * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0dentry

%line 68+1 kernel.S
[section .text]
%line 68+0 kernel.S
intr0x0eentry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x0e
 call [idt_table + 0x0e * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0eentry

%line 69+1 kernel.S
[section .text]
%line 69+0 kernel.S
intr0x0fentry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x0f
 call [idt_table + 0x0f * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0fentry

%line 70+1 kernel.S
[section .text]
%line 70+0 kernel.S
intr0x10entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x10
 call [idt_table + 0x10 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x10entry

%line 71+1 kernel.S
[section .text]
%line 71+0 kernel.S
intr0x11entry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x11
 call [idt_table + 0x11 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x11entry

%line 72+1 kernel.S
[section .text]
%line 72+0 kernel.S
intr0x12entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x12
 call [idt_table + 0x12 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x12entry

%line 73+1 kernel.S
[section .text]
%line 73+0 kernel.S
intr0x13entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x13
 call [idt_table + 0x13 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x13entry

%line 74+1 kernel.S
[section .text]
%line 74+0 kernel.S
intr0x14entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x14
 call [idt_table + 0x14 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x14entry

%line 75+1 kernel.S
[section .text]
%line 75+0 kernel.S
intr0x15entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x15
 call [idt_table + 0x15 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x15entry

%line 76+1 kernel.S
[section .text]
%line 76+0 kernel.S
intr0x16entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x16
 call [idt_table + 0x16 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x16entry

%line 77+1 kernel.S
[section .text]
%line 77+0 kernel.S
intr0x17entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x17
 call [idt_table + 0x17 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x17entry

%line 78+1 kernel.S
[section .text]
%line 78+0 kernel.S
intr0x18entry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x18
 call [idt_table + 0x18 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x18entry

%line 79+1 kernel.S
[section .text]
%line 79+0 kernel.S
intr0x19entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x19
 call [idt_table + 0x19 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x19entry

%line 80+1 kernel.S
[section .text]
%line 80+0 kernel.S
intr0x1aentry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x1a
 call [idt_table + 0x1a * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1aentry

%line 81+1 kernel.S
[section .text]
%line 81+0 kernel.S
intr0x1bentry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x1b
 call [idt_table + 0x1b * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1bentry

%line 82+1 kernel.S
[section .text]
%line 82+0 kernel.S
intr0x1centry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x1c
 call [idt_table + 0x1c * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1centry

%line 83+1 kernel.S
[section .text]
%line 83+0 kernel.S
intr0x1dentry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x1d
 call [idt_table + 0x1d * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1dentry

%line 84+1 kernel.S
[section .text]
%line 84+0 kernel.S
intr0x1eentry:
 nop


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x1e
 call [idt_table + 0x1e * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1eentry

%line 85+1 kernel.S
[section .text]
%line 85+0 kernel.S
intr0x1fentry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x1f
 call [idt_table + 0x1f * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1fentry

%line 86+1 kernel.S
[section .text]
%line 86+0 kernel.S
intr0x20entry:
 push 0


 push ds
 push es
 push fs
 push gs
 pushad

 push 0x20
 call [idt_table + 0x20 * 4]

 add esp, 4
 popad
 pop gs
 pop fs
 pop es
 pop ds

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x20entry

