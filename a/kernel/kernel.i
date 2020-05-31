%line 1+1 kernel.S
[bits 32]






[extern put_str]

[section .data]
intr_str db "interrupt occur!", 0xa, 0





%line 36+1 kernel.S

[global intr_entry_table]
intr_entry_table:
[section .text]
%line 39+0 kernel.S
intr0x00 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x00 entry

%line 40+1 kernel.S
[section .text]
%line 40+0 kernel.S
intr0x01 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x01 entry

%line 41+1 kernel.S
[section .text]
%line 41+0 kernel.S
intr0x02 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x02 entry

%line 42+1 kernel.S
[section .text]
%line 42+0 kernel.S
intr0x03 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x03 entry

%line 43+1 kernel.S
[section .text]
%line 43+0 kernel.S
intr0x04 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x04 entry

%line 44+1 kernel.S
[section .text]
%line 44+0 kernel.S
intr0x05 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x05 entry

%line 45+1 kernel.S
[section .text]
%line 45+0 kernel.S
intr0x06 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x06 entry

%line 46+1 kernel.S
[section .text]
%line 46+0 kernel.S
intr0x07 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x07 entry

%line 47+1 kernel.S
[section .text]
%line 47+0 kernel.S
intr0x08 entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x08 entry

%line 48+1 kernel.S
[section .text]
%line 48+0 kernel.S
intr0x09 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x09 entry

%line 49+1 kernel.S
[section .text]
%line 49+0 kernel.S
intr0x0a entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0a entry

%line 50+1 kernel.S
[section .text]
%line 50+0 kernel.S
intr0x0b entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0b entry

%line 51+1 kernel.S
[section .text]
%line 51+0 kernel.S
intr0x0c entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0c entry

%line 52+1 kernel.S
[section .text]
%line 52+0 kernel.S
intr0x0d entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0d entry

%line 53+1 kernel.S
[section .text]
%line 53+0 kernel.S
intr0x0e entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0e entry

%line 54+1 kernel.S
[section .text]
%line 54+0 kernel.S
intr0x0f entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x0f entry

%line 55+1 kernel.S
[section .text]
%line 55+0 kernel.S
intr0x10 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x10 entry

%line 56+1 kernel.S
[section .text]
%line 56+0 kernel.S
intr0x11 entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x11 entry

%line 57+1 kernel.S
[section .text]
%line 57+0 kernel.S
intr0x12 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x12 entry

%line 58+1 kernel.S
[section .text]
%line 58+0 kernel.S
intr0x13 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x13 entry

%line 59+1 kernel.S
[section .text]
%line 59+0 kernel.S
intr0x14 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x14 entry

%line 60+1 kernel.S
[section .text]
%line 60+0 kernel.S
intr0x15 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x15 entry

%line 61+1 kernel.S
[section .text]
%line 61+0 kernel.S
intr0x16 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x16 entry

%line 62+1 kernel.S
[section .text]
%line 62+0 kernel.S
intr0x17 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x17 entry

%line 63+1 kernel.S
[section .text]
%line 63+0 kernel.S
intr0x18 entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x18 entry

%line 64+1 kernel.S
[section .text]
%line 64+0 kernel.S
intr0x19 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x19 entry

%line 65+1 kernel.S
[section .text]
%line 65+0 kernel.S
intr0x1a entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1a entry

%line 66+1 kernel.S
[section .text]
%line 66+0 kernel.S
intr0x1b entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1b entry

%line 67+1 kernel.S
[section .text]
%line 67+0 kernel.S
intr0x1c entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1c entry

%line 68+1 kernel.S
[section .text]
%line 68+0 kernel.S
intr0x1d entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1d entry

%line 69+1 kernel.S
[section .text]
%line 69+0 kernel.S
intr0x1e entry:
 nop
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1e entry

%line 70+1 kernel.S
[section .text]
%line 70+0 kernel.S
intr0x1f entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x1f entry

%line 71+1 kernel.S
[section .text]
%line 71+0 kernel.S
intr0x20 entry:
 push 0
 push intr_str
 call put_str
 add esp, 4

 mov al, 0x20
 out 0xa0, al
 out 0x20, al

 add esp, 4
 iret

[section .data]
 dd intr0x20 entry

