
# 生成硬盘
disk:
	bochs/bin/bximage -hd -mode="flat" -size=60 -q bochs/hd60M.img

# 汇编mbr
mbr:
	nasm -I a/boot/include -o a/boot/mbr.bin a/boot/mbr.S

loader:
	nasm -I a/boot/include -o a/boot/loader.bin a/boot/loader.S

# 将mbr写入到硬盘0盘0道1扇区
bootsector:
	dd if=a/boot/mbr.bin of=bochs/hd60M.img bs=512 count=1 conv=notrunc

loadersector:
	dd if=a/boot/loader.bin of=bochs/hd60M.img bs=512 count=1 seek=2 conv=notrunc
clean:
	rm a/boot/mbr.bin
	rm a/boot/loader.bin
	rm bochs/hd60M.img
