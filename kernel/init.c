#include "init.h"
#include "print.h"
#include "interrupt.h"

// 负责所有模块的初始化
void init_all() {
    put_str("init_all\n");
    idt_init(); // 初始化中断
}