
# 生成硬盘
disk:
	bochs/bin/bximage -hd -mode="flat" -size=60 -q bochs/hd60M.img

# 汇编mbr
mbr:
	nasm -I a/boot/include/ -o a/boot/mbr.bin a/boot/mbr.S

loader:
	nasm -I a/boot/include/ -o a/boot/loader.bin a/boot/loader.S

# 将mbr写入到硬盘0盘0道1扇区
bootsector:
	dd if=a/boot/mbr.bin of=bochs/hd60M.img bs=512 count=1 conv=notrunc

loadersector:
	dd if=a/boot/loader.bin of=bochs/hd60M.img bs=512 count=4 seek=2 conv=notrunc
clean:
	rm build/*
	rm bochs/hd60M.img
boot:
	bochs/bin/bximage -hd -mode="flat" -size=60 -q bochs/hd60M.img
	nasm -I a/boot/include/ -o build/mbr.bin a/boot/mbr.S 
	nasm -I a/boot/include/ -o build/loader.bin a/boot/loader.S
	nasm -f elf32 -o build/print.o a/lib/kernel/print.S
	nasm -f elf32 -o build/kernel.o a/kernel/kernel.S
	gcc -fno-stack-protector -I a/lib/kernel/ -I a/lib/ -I a/kernel/ -c -fno-builtin a/kernel/interrupt.c -o build/interrupt.o -m32
	gcc -fno-stack-protector -I a/lib/kernel/ -I a/lib/ -I a/kernel/ -c -fno-builtin a/kernel/init.c -o build/init.o -m32
	gcc -fno-stack-protector -I a/lib/kernel/ -I a/lib/ -I a/kernel/ -c -fno-builtin a/kernel/main.c -o build/main.o -m32
	ld -Ttext 0xc0001500 -e main -o build/kernel.bin build/main.o build/init.o build/interrupt.o build/print.o build/kernel.o -melf_i386 
#	bochs/bin/bximage -hd -mode="flat" -size=60 -q bochs/hd60M.img
	dd if=build/mbr.bin of=bochs/hd60M.img bs=512 count=1 conv=notrunc  # mbr
	dd if=build/loader.bin of=bochs/hd60M.img bs=512 count=4 seek=2 conv=notrunc  # loader
	dd if=build/kernel.bin of=bochs/hd60M.img bs=512 count=200 seek=9 conv=notrunc  # kernel
