#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "timer.h"
#include "memory.h"
#include "thread.h"
#include "console.h"
#include "keyboard.h"
#include "tss.h"
#include "syscall-init.h"
#include "ide.h"
#include "fs.h"

// 负责所有模块的初始化
void init_all() {
    put_str("init_all\n");
    idt_init(); // 初始化中断
    mem_init(); // 内存管理系统初始化
    thread_init(); // 初始化线程相关结构
    timer_init(); //初始化PIT
    console_init(); //控制台初始化
    keyboard_init();  // 键盘初始化
    tss_init(); // tss初始化
    syscall_init(); // 初始化系统调用
	intr_enable();
    ide_init();	     // 初始化硬盘
    filesys_init();  // 初始化文件系统
}