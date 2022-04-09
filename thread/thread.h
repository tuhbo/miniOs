#ifndef __THREAD_THREAD_H
#define __THREAD_THREAD_H
#include "stdint.h"

// 自定义通用函类型
typedef void thread_func(void *);

// 进程或线程的状态
enum task_status {
    TASK_RUNNING,
    TASK_READY,
    TASK_BLOCKED,
    TASK_WAITING,
    TASK_HANGING,
    TASK_DIED
};

// 中断栈
// 此结构用于中断发生时保护(进程或线程)的上下文环境

struct intr_stack {
    uint32_t vec_no;
    uint32_t edi;
    uint32_t esi;
    uint32_t ebp;
    uint32_t esp_dummy;
    uint32_t ebx;
    uint32_t edx;
    uint32_t ecx;
    uint32_t eax;
    uint32_t gs;
    uint32_t fs;
    uint32_t es;
    uint32_t ds;

    // cpu从低特权及进入高特权级时压入
    uint32_t err_code;
    void (*eip) (void);
    uint32_t cs;
    uint32_t eflags;
    void *esp;
    uint32_t ss;
};

// 线程栈
// 线程自己的栈，用于存储线程中待执行的函数
// 用在switch_to时保存线程环境

struct thread_stack {
    uint32_t ebp;
    uint32_t ebx;
    uint32_t edi;
    uint32_t esi;

    // 线程第一次执行时，eip指向kernel_thread，其他时候指向switch_to的返回地址
    void (*eip)(thread_func *func, void *func_arg);

    // 以下参数仅供第一次调度上cpu时使用
    // 占位符
    void (*unused_retaddr);
    thread_func *function;
    void *func_arg;
};

struct task_struct {
    uint32_t *self_kstack;
    enum task_status status;
    uint8_t priority;
    char name[16];
    uint32_t stack_magic; // 魔数，标记栈的边界
};

void thread_create(struct task_struct *pthread, thread_func function, void *func_arg);
void init_thread(struct task_struct *pthread, char *name, int prio);
struct task_struct *thread_start(char *name, int prio, thread_func function, void *func_arg);

#endif // !__THREAD_THREAD_H
