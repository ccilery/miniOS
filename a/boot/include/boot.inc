;------------------ loader 和 kernel
LOADER_BASE_ADDR equ 0x900      ; loader程序加载到0x900处
LOADER_START_SECTOR equ 0x2     ; loader程序从磁盘的第2号扇区开始  LBS逻辑扇区