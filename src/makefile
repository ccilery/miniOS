# clean:
# 	rm build/*
# 	rm bochs/hd60M.img
# boot:
# 	bochs/bin/bximage -hd -mode="flat" -size=60 -q bochs/hd60M.img
# 	nasm -I a/boot/include/ -o build/mbr.bin a/boot/mbr.S 
# 	nasm -I a/boot/include/ -o build/loader.bin a/boot/loader.S
# 	nasm -f elf32 -o build/print.o a/lib/kernel/print.S
# 	nasm -f elf32 -o build/kernel.o a/kernel/kernel.S
# 	gcc -fno-stack-protector -I a/lib/kernel/ -I a/lib/ -I a/kernel/ -c -fno-builtin a/kernel/interrupt.c -o build/interrupt.o -m32
# 	gcc -fno-stack-protector -I a/lib/kernel/ -I a/lib/ -I a/kernel/ -I a/device -c -fno-builtin a/kernel/init.c -o build/init.o -m32
# 	gcc -fno-stack-protector -I a/lib/kernel/ -I a/lib/ -I a/kernel/ -c -fno-builtin a/kernel/main.c -o build/main.o -m32
# 	gcc -fno-stack-protector -I a/lib/kernel/ -I a/lib/ -I a/kernel/ -I a/device -c -fno-builtin a/device/timer.c -o build/timer.o -m32
# 	ld -Ttext 0xc0001500 -e main -o build/kernel.bin build/main.o build/init.o build/interrupt.o build/print.o build/kernel.o build/timer.o -melf_i386 
# 	dd if=build/mbr.bin of=bochs/hd60M.img bs=512 count=1 conv=notrunc  # mbr
# 	dd if=build/loader.bin of=bochs/hd60M.img bs=512 count=4 seek=2 conv=notrunc  # loader
# 	dd if=build/kernel.bin of=bochs/hd60M.img bs=512 count=200 seek=9 conv=notrunc  # kernel

BUILD_DIR = build
ENTRY_POINT = 0xc0001500	# 内核程序的入口
AS = nasm
CC = gcc
LD = ld
LIB = -I lib -I lib/kernel -I lib/user -I kernel -I device -I thread
ASFLAGS = -f elf32
CFLAGS = -Wall $(LIB) -c -fno-stack-protector -W -Wstrict-prototypes -Wmissing-prototypes -fno-builtin -m32
LDFLAGS = -Ttext $(ENTRY_POINT) -e main -Map $(BUILD_DIR)/kernel.map -melf_i386
OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/thread.o $(BUILD_DIR)/string.o $(BUILD_DIR)/debug.o $(BUILD_DIR)/interrupt.o \
      $(BUILD_DIR)/timer.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/print.o $(BUILD_DIR)/bitmap.o $(BUILD_DIR)/memory.o
     

##############   c代码编译     ###############
$(BUILD_DIR)/main.o: kernel/main.c 
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/init.o: kernel/init.c 
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/interrupt.o: kernel/interrupt.c
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/timer.o: device/timer.c 
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/debug.o: kernel/debug.c 
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/string.o: lib/string.c 
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/memory.o: kernel/memory.c 
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/bitmap.o: lib/kernel/bitmap.c 
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR)/thread.o: thread/thread.c 
	$(CC) $(CFLAGS) $< -o $@

##############    汇编代码编译    ###############
$(BUILD_DIR)/kernel.o: kernel/kernel.S
	$(AS) $(ASFLAGS) $< -o $@
$(BUILD_DIR)/print.o: lib/kernel/print.S
	$(AS) $(ASFLAGS) $< -o $@
bootloader:
	nasm -I boot/include/ -o build/mbr.bin boot/mbr.S 
	nasm -I boot/include/ -o build/loader.bin boot/loader.S

##############    链接所有目标文件    #############
$(BUILD_DIR)/kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

.PHONY : mk_dir hd clean all bootloader

mk_dir:
	if [[ ! -d $(BUILD_DIR) ]];then mkdir $(BUILD_DIR);fi

hd:
	../bochs/bin/bximage -hd -mode="flat" -size=60 -q ../bochs/hd60M.img
	dd if=build/mbr.bin of=../bochs/hd60M.img bs=512 count=1 conv=notrunc  			 # mbr
	dd if=build/loader.bin of=../bochs/hd60M.img bs=512 count=4 seek=2 conv=notrunc  # loader
	dd if=$(BUILD_DIR)/kernel.bin \
           of=../bochs/hd60M.img \
           bs=512 count=200 seek=9 conv=notrunc									     # kernel

clean:
	if [ -f "../bochs/hd60M.img" ];then rm -f ../bochs/hd60M.img; fi
	cd $(BUILD_DIR) && rm -f ./*

build: $(BUILD_DIR)/kernel.bin

all: mk_dir bootloader build hd