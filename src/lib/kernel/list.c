#include "list.h"
#include "stdint.h"
#include "interrupt.h"
#include "stdbool.h"

void list_init(struct list* list)
{
    list->head.prev = NULL;
    list->head.next = &list->tail;
    list->tail.prev = &list->head;
    list->tail.next = NULL;
}

bool list_empty(struct list* plist)
{
    return plist->head.next == &plist->tail;
}

// 将elem插入到before之前
void list_insert_before(struct list_elem* before, struct list_elem* elem)
{
    enum intr_status old_status = intr_disable();

    elem->next = before;
    elem->prev = before->prev;
    before->prev->next = elem;
    before->prev = elem;

    intr_set_status(old_status);
}

// 在链表头部插入elem
void list_push(struct list* plist, struct list_elem* elem)
{
    list_insert_before(plist->head.next, elem);
}

// 在链表尾部插入elem
void list_append(struct list* plist, struct list_elem* elem)
{
    list_insert_before(&plist->tail, elem);
}

// 从链表中移除elem供上层使用
void list_remove(struct list_elem* elem)
{
    enum intr_status old_status = intr_disable();

    elem->prev->next = elem->next;      
    elem->next->prev = elem->prev;

    intr_set_status(old_status);
}

// 将链表中的第一个元素移除并返回
struct list_elem* list_pop(struct list* plist)
{
    // enum intr_status old_status = intr_disable();       // 是否需要？

    struct list_elem* node = plist->head.next;
    list_remove(node);

    // intr_set_status(old_status);
    return node;
}

bool elem_find(struct list* plist, struct list_elem* elem)
{
    struct list_elem* p = plist->head.next;
    while(p != &plist->tail)
    {
        if(p == elem)
            return true;
        p = p->next;
    }
    return false;
}

struct list_elem* list_traversal(struct list* plist, function func, int arg)
{
    struct list_elem* p = plist->head.next;
    while(p != &plist->tail)
    {
        if(func(p, arg))
            return p;
        p = p->next;
    }
    return NULL;
}

uint32_t list_len(struct list* plist)
{
    uint32_t len = 0;
    struct list_elem* p = plist->head.next;
    while(p != &plist->tail)
    {
        len++;
        p = p->next;
    }
    return len;
}