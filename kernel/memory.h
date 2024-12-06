#ifndef MEMKERNEL_MEM_H
#define MEMKERNEL_MEM_H

#include <linux/kernel.h>
#include <linux/sched.h>

#define MAX_MEMOP_SIZE 4096 * 2

bool readwrite_process_memory(pid_t pid, uintptr_t addr, void *buffer, size_t size, bool iswrite);

#endif