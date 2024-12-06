<a href="#ru">Ru guide</a>
<a id="en"></a>
# MemKernel
MemKernel is a Kernel Driver for Android.
Originally created by [Jiang-Night](https://github.com/Jiang-Night/Kernel_driver_hack), modified & fixed according to my personal need.
This driver Reads, Writes physical memory of target process (effectively bypassing anticheats).

## Integration
2 ways you can integrate this driver to your kernel source (for compilation) using setup script:
* __Y__ : To build the source as part of the kernel. (statically build within kernel).
```
curl -LSs "https://raw.githubusercontent.com/Poko-Apps/MemKernel/main/kernel/setup.sh" | bash -s Y
```
* __M__ : To build lkm (loadable kernel module). after adding this driver and building the kernel again, the lkm might be shipped within kernel (remember it).
```
curl -LSs "https://raw.githubusercontent.com/Poko-Apps/MemKernel/main/kernel/setup.sh" | bash -s M
```

**TIP** : By default the setup script generates random name for the driver (/dev/*randomname*), this is to bypass existency check done via [*access(2)*](https://man7.org/linux/man-pages/man2/access.2.html) syscall. but you can override this behaviour by providing 2nd argument to the setup script like this:

```curl -LSs "https://raw.githubusercontent.com/Poko-Apps/MemKernel/main/kernel/setup.sh" | bash -s M myname```

## Compilation
Totally depends on the kernel source you're building (gki & non-gki). I leave this part upto you.

## How It Works
On a higher level:

This driver code (be it lkm or inbuilt within kernel) creates a [character](https://linux-kernel-labs.github.io/refs/heads/master/labs/device_drivers.html) device driver in dev folder (/dev/drivername). A userspace app with root permission can talk to this driver (file) via [*ioctl(2)*](https://man7.org/linux/man-pages/man2/ioctl.2.html) syscall. the kernel part (driver) reads or writes the target memory behalf on userspace app and forward read data to userspace app to use.

<a id="ru"></a>
<a href="#en">En guide</a>

# MemKernel
MemKernel is a Kernel Driver for Android.
Изначально создан [Jiang-Night](https://github.com/Jiang-Night/Kernel_driver_hack).
Этот драйвер читает и записывает физическую память целевого процесса (эффективно обходя античиты).

## Интеграция
Существует два способа интегрировать этот драйвер в исходный код ядра (для компиляции) с использованием скрипта установки:
* __Y__ : Для сборки исходного кода как части ядра. (статическая сборка внутри ядра).
```
curl -LSs "https://raw.githubusercontent.com/Poko-Apps/MemKernel/main/kernel/setup.sh" | bash -s Y
```
* __M__ : Для сборки lkm (загружаемого модуля ядра). После добавления этого драйвера и повторной сборки ядра, lkm может быть поставлен вместе с ядром (не забудьте об этом).
```
curl -LSs "https://raw.githubusercontent.com/Poko-Apps/MemKernel/main/kernel/setup.sh" | bash -s M
```

**СОВЕТ** : По умолчанию скрипт установки генерирует случайное имя для драйвера (/dev/*randomname*), это позволяет обойти проверку существования, выполняемую через системный вызов [*access(2)*](https://man7.org/linux/man-pages/man2/access.2.html). Однако вы можете переопределить это поведение, предоставив второй аргумент скрипту установки следующим образом:

```curl -LSs "https://raw.githubusercontent.com/Poko-Apps/MemKernel/main/kernel/setup.sh" | bash -s M myname```

## Компиляция
Полностью зависит от исходного кода ядра, которое вы собираете (gki & non-gki). Эту часть я оставляю на ваше усмотрение.

## Как это работает
На высоком уровне:

Этот драйвер (будь то lkm или встроенный в ядро) создает драйвер [символьного устройства](https://linux-kernel-labs.github.io/refs/heads/master/labs/device_drivers.html) в папке dev (/dev/drivername). Приложение пользовательского пространства с правами root может взаимодействовать с этим драйвером (файлом) через системный вызов [*ioctl(2)*](https://man7.org/linux/man-pages/man2/ioctl.2.html). Ядерная часть (драйвер) читает или записывает целевую память от имени приложения пользовательского пространства и передает прочитанные данные приложению пользовательского пространства для использования.
