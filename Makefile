HDSRC=/home/tuhb/bochs/hd60M.img
AS = nasm
LD = ld
CC = gcc
BUILD_DIR = ./build
ENTRY_POINT = 0xc0001500
MBR = $(BUILD_DIR)/mbr.bin
LOADER = $(BUILD_DIR)/loader.bin
KERNEL = $(BUILD_DIR)/kernel.bin

LIB = -I boot/include/ -I lib/ -I lib/kernel/ -I lib/user/ -I kernel/ -I device/ -I thread/ -I userprog/

CFLAGS = -Wall $(LIB) -c -fno-builtin -fno-stack-protector -W -Wstrict-prototypes -Wmissing-prototypes

LDFLAGS = -Ttext $(ENTRY_POINT) -e main 

ASFLAGS = -f elf

OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/interrupt.o \
      $(BUILD_DIR)/timer.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/print.o \
      $(BUILD_DIR)/debug.o $(BUILD_DIR)/memory.o $(BUILD_DIR)/bitmap.o \
      $(BUILD_DIR)/string.o $(BUILD_DIR)/thread.o $(BUILD_DIR)/list.o \
      $(BUILD_DIR)/switch.o $(BUILD_DIR)/console.o $(BUILD_DIR)/sync.o \
      $(BUILD_DIR)/keyboard.o $(BUILD_DIR)/ioqueue.o $(BUILD_DIR)/tss.o \
      $(BUILD_DIR)/process.o $(BUILD_DIR)/syscall.o $(BUILD_DIR)/syscall-init.o \
	  $(BUILD_DIR)/stdio.o

##### c代码编译  ##########
$(BUILD_DIR)/main.o: kernel/main.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/init.o: kernel/init.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/interrupt.o: kernel/interrupt.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/timer.o: device/timer.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/debug.o: kernel/debug.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/string.o: lib/string.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/bitmap.o: lib/kernel/bitmap.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/memory.o: kernel/memory.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/thread.o: thread/thread.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/list.o: lib/kernel/list.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/sync.o: thread/sync.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/console.o: device/console.c
	$(CC) $(CFLAGS) $^ -o $@
	
$(BUILD_DIR)/keyboard.o: device/keyboard.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/ioqueue.o: device/ioqueue.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/tss.o: userprog/tss.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/process.o: userprog/process.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/syscall.o: lib/user/syscall.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/syscall-init.o: userprog/syscall-init.c
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)/stdio.o: lib/stdio.c
	$(CC) $(CFLAGS) $^ -o $@
##### 汇编代码编译 ######
$(MBR) : boot/mbr.S
	$(AS) $(LIB) -o $@ $^

$(LOADER) : boot/loader.S
	$(AS) $(LIB) -o $@ $^

$(BUILD_DIR)/kernel.o: kernel/kernel.S
	$(AS) $(ASFLAGS) -o $@ $^

$(BUILD_DIR)/print.o: lib/kernel/print.S
	$(AS) $(ASFLAGS) -o $@ $^

$(BUILD_DIR)/switch.o: thread/switch.S
	$(AS) $(ASFLAGS) -o $@ $^

##### 链接所有目标文件 #########
$(BUILD_DIR)/kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

.PHONY : mk_dir hd1 hd2 hd3 clean all

hd1:
	dd if=$(MBR) of=$(HDSRC) bs=512 count=1 conv=notrunc

hd2:
	dd if=$(LOADER) of=$(HDSRC) bs=512 count=4 seek=2 conv=notrunc

hd3:
	dd if=$(KERNEL) of=$(HDSRC) bs=512 count=200 seek=9 conv=notrunc

mk_dir:
	@if [ ! -d $(BUILD_DIR) ];then mkdir $(BUILD_DIR);fi

build : $(MBR) $(LOADER) $(KERNEL)

install : hd1 hd2 hd3

clean:
	@rm -rf $(BUILD_DIR)

all : mk_dir build
