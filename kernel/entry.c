// MIT License
/*
 * Memory Operation driver for Linux Android
 *
 * Original author:  Jiang-Night
 * Current maintainer: Poko
 *
*/

#include <linux/module.h>
#include <linux/fs.h>
#include <linux/miscdevice.h>
#include <linux/uaccess.h>
#include "comm.h"
#include "memory.h"
#include "process.h"

#define DEVICE_NAME "secrvg"

static int dispatch_open(struct inode *node, struct file *file) {
	return 0;
}

static int dispatch_close(struct inode *node, struct file *file) {
	return 0;
}

static long dispatch_ioctl(struct file *const file, unsigned int const cmd, unsigned long const arg)
{
	COPY_MEMORY cm;
	MODULE_BASE mb;
	char name[0x100] = {0};

	switch (cmd)
	{
	case OP_READ_MEM:
	{
		if (copy_from_user(&cm, (void __user *)arg, sizeof(cm)) != 0) {
			return -1;
		}
		if (readwrite_process_memory(cm.pid, cm.addr, cm.buffer, cm.size, false) == false) {
			return -1;
		}
		break;
	}
	case OP_WRITE_MEM:
	{
		if (copy_from_user(&cm, (void __user *)arg, sizeof(cm)) != 0) {
			return -1;
		}
		if (readwrite_process_memory(cm.pid, cm.addr, cm.buffer, cm.size, true) == false) {
			return -1;
		}
		break;
	}
	case OP_MODULE_BASE:
	{
		if (copy_from_user(&mb, (void __user *)arg, sizeof(mb)) != 0 || copy_from_user(name, (void __user *)mb.name, sizeof(name) - 1) != 0) {
			return -1;
		}
		mb.base = get_module_base(mb.pid, name);
		if (copy_to_user((void __user *)arg, &mb, sizeof(mb)) != 0) {
			return -1;
		}
		break;
	}
	default:
		break;
	}
	return 0;
}

static struct file_operations dispatch_functions = {
	.owner = THIS_MODULE,
	.open = dispatch_open,
	.release = dispatch_close,
	.unlocked_ioctl = dispatch_ioctl,
};

static struct miscdevice misc = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = DEVICE_NAME,
	.fops = &dispatch_functions,
};

int __init memkernel_entry(void)
{
	int ret;
	printk("[+] memkernel_entry");
	ret = misc_register(&misc);
	return ret;
}

void __exit memkernel_unload(void)
{
	printk("[+] memkernel_unload");
	misc_deregister(&misc);
}

module_init(memkernel_entry);
module_exit(memkernel_unload);

MODULE_DESCRIPTION("Linux Kernel.");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Linux");
