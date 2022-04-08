#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "timer.h"
#include "memory.h"

// 负责所有模块的初始化
void init_all() {
    put_str("init_all\n");
    idt_init(); // 初始化中断
    timer_init(); //初始化PIT
    mem_init(); // 内存管理系统初始化
}