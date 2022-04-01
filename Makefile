HDSRC=/home/tuhb/bochs/hd60M.img
BUILD_DIR = ./build
AS = nasm
LIB = -I boot/include/
MBR = $(BUILD_DIR)/mbr.bin
LOADER = $(BUILD_DIR)/loader.bin

$(MBR) : boot/mbr.S
	$(AS) $(LIB) -o $@ $^

$(LOADER)/loader.bin : boot/loader.S
	$(AS) $(LIB) -o $@ $^


.PHONY : mk_dir hd1 hd2 hd3 clean all

hd1:$(MBR)
	dd if=$(MBR) of=$(HDSRC) bs=512 count=1 conv=notrunc

hd2:$(LOADER)
	dd if=$(LOADER) of=$(HDSRC) bs=512 count=1 seek=2 conv=notrunc

mk_dir:
	@if [ ! -d $(BUILD_DIR) ];then mkdir $(BUILD_DIR);fi

build : $(BUILD_DIR)/mbr.bin $(BUILD_DIR)/loader.bin

install : hd1 hd2

all : mk_dir build
