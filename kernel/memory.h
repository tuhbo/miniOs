#ifndef __KERNEL_MEMORY_H
#define __KERNEL_MEMORY_H
#include "stdint.h"
#include "bitmap.h"

enum pool_flags {
    PF_KERNEL = 1,
    PF_USER = 2
};

#define PG_P_1  1 //页表项或页目录项存在属性位
#define PG_P_0  0
#define PG_RW_R 0
#define PG_RW_W 2
#define PG_US_S 0
#define PG_US_U 4


struct virtual_addr {
    struct bitmap vaddr_bitmap; //虚拟地址用到的位图结构
    uint32_t vaddr_start;   // 虚拟地址起始地址
};

struct pool {
    struct bitmap pool_bitmap;
    uint32_t phy_addr_start; //管理的物理内存的起始地址
    uint32_t pool_size; // 内存池的容量
};

struct pool kernel_pool, user_pool;
struct virtual_addr kernel_vaddr; // 内核虚拟地址池


void mem_init(void);
void *get_kernel_pages(uint32_t pg_cnt);
void *malloc_page(enum pool_flags pf, uint32_t pg_cnt);
void malloc_init(void);
uint32_t *pte_ptr(uint32_t vaddr);
uint32_t *pde_ptr(uint32_t vaddr);

#endif // !__KERNEL_MEMPRY_H