#ifndef __LIB_KERNEL_LIST_H
#define __LIB_KERNEL_LIST_H

#include "stdbool.h"
#include "stdint.h"

// 结构体成员在结构体中的偏移量 = 结构体成员的地址 - 结构体的地址   // 令结构体地址为0
#define offset(struct_type, member) (uint32_t)(&((struct_type*)0)->member)
// 将结构体中某个成员的地址转换为结构体的地址 = 结构体成员的地址 - 结构体成员的偏移量
#define elem2entry(struct_type, member, elem_ptr) \
                    (struct_type*)((uint32_t)elem_ptr - offset(struct_type, member))

// 链表节点
struct list_elem
{
    struct list_elem* prev;
    struct list_elem* next;
};

// 双向链表
struct list
{
    struct list_elem head;
    struct list_elem tail;
};

typedef bool (*function)(struct list_elem*, int arg);

void list_init(struct list* list);

bool list_empty(struct list* plist);

// 将elem插入到before之前
void list_insert_before(struct list_elem* before, struct list_elem* elem);

// 在链表头部插入elem
void list_push(struct list* plist, struct list_elem* elem);

// 在链表尾部插入elem
void list_append(struct list* plist, struct list_elem* elem);

// 从链表中移除elem供上层使用
void list_remove(struct list_elem* elem);

// 将链表中的第一个元素移除并返回
struct list_elem* list_pop(struct list* plist);

bool elem_find(struct list* plist, struct list_elem* elem);

struct list_elem* list_traversal(struct list* plist, function func, int arg);

uint32_t list_len(struct list* plist);



#endif // __LIB_KERNEL_LIST_H