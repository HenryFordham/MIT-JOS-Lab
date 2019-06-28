# MIT-JOS-Lab
目录

1  主要阅读汇编语言资料。

2 使用GDB命令跟踪BIOS做了哪些事情

2.1 先做好准备工作

2.1.1 下载好练习JOS系统

2.1.2 下载好QEMU模拟器并编译（如已经编译过可以忽略此步）

2.2 用GDB跟踪BIOS

3  读懂BOOT启动时的相关代码

3.1 分析 boot/boot.S的代码

3.2 分析boot/main.c的代码

3.2.1 Main.C做的主要工作

4  熟悉C语言中指针的操作

4.1 Pointer.c代码的演绎

 4.2 Pointer.c代码的解读

5  测试BootLoader载入Kernel的过程 

6  链接VS装载（Link VS Load Address）

7 加载Kernel时重新进行映射的测试

8  探究控制台的输出格式

8.1  kern/printf.c， lib/printfmt.c 和 kern/console.c之间的关联性

8.2  输出满屏后如何清屏操作

8.3 解释格式化输出的一些指令和变量

8.4  格式化输出的例子

8.4.1 关于Hello World 的例子

8.4.2 关于参数数量小于格式化要输出的占位数的例子

8.5 参数的调用与入栈出栈的顺序

8.6 补充缺少的八进制代码段

8.7  让八进制格式化输出能够支持正负号

8.8  重载“%n”模式

8.8.1 参考C99标准中的%n

8.8.2 复现printf函数中的%n

8.8.3 测试%n是否正确

8.9  修改 printfmt.c 中的模式输出

1  主要阅读汇编语言资料。

Exercise 1. Familiarize yourself with the assembly language materials available on the 6.828 reference page. You don't have to read them now, but you'll almost certainly want to refer to some of this material when reading and writing x86 assembly. 

2 使用GDB命令跟踪BIOS做了哪些事情

Exercise 2. Use GDB's si (Step Instruction) command to trace into the ROM BIOS for a few more instructions, and try to guess what it might be doing. You might want to look at Phil Storrs I/O Ports Description, as well as other materials on the 6.828 reference materials page. No need to figure out all the details - just the general idea of what the BIOS is doing first.

2.1 先做好准备工作

2.1.1 下载好练习JOS系统

git clone -b lab1 http://ipads.se.sjtu.edu.cn:1312/lab/jos-2019-spring.git
cd jos-2019-spring
2.1.2 下载好QEMU模拟器并编译（如已经编译过可以忽略此步）

# 下载qemu模拟器，这个下载有点慢可以科学上网之后会加快速度
sudo git clone git://git.qemu.org/qemu.git
# 准备编译环境
sudo yum install gzlib-devel glib2-devel pixman-devel gcc
# 准备编译
cd $HOME/qemu
sudo ./configure
# 这时可能会如下的错误
# Disabling libtool due to broken toolchain support
# ERROR: zlib check failed
#       Make sure to have the zlib libs and headers installed.
# 那么就需要执行下列命令
sudo yum install zlib*
这个时候在安装zlib安装包的时候又报错，以下是Yum安装时提示保护多库版本的报错：

错误： Multilib version problems found. This often means that the root
      cause is something else and multilib version checking is just
      pointing out that there is a problem. Eg.:

        1. You have an upgrade for zlib which is missing some
           dependency that another package requires. Yum is trying to
           solve this by installing an older version of zlib of the
           different architecture. If you exclude the bad architecture
           yum will tell you what the root cause is (which package
           requires what). You can try redoing the upgrade with
           --exclude zlib.otherarch ... this should give you an error
           message showing the root cause of the problem.

        2. You have multiple architectures of zlib installed, but
           yum can only see an upgrade for one of those architectures.
           If you don't want/need both architectures anymore then you
           can remove the one with the missing update and everything
           will work.

        3. You have duplicate versions of zlib installed already.
           You can use "yum check" to get yum show these errors.

      ...you can also use --setopt=protected_multilib=false to remove
      this checking, however this is almost never the correct thing to
      do as something else is very likely to go wrong (often causing
      much more problems).

      保护多库版本：zlib-1.2.7-15.el7.x86_64 != zlib-1.2.7-13.el7.i686
那么这时候执行如下命令：

yum install --setopt=protected_multilib=false zlib
之后再去重复安装：

sudo yum install zlib*
 在执行configure成功之前可能出多个诸如此类的缺失安装包的错误，届时按提示安装即可

sudo make
sudo make install
此时QEMU就已经编译安装好，进入我们的JOS目录进行模拟开机，并用GDB跟踪：

2.2 用GDB跟踪BIOS

这时候打开两个终端，都到JOS目录下：

第一个输入：

sudo make qemu-gdb

# gdb -n -x .gdbinit
# GNU gdb (GDB) Red Hat Enterprise Linux 7.6.1-114.el7
# Copyright (C) 2013 Free Software Foundation, Inc.
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
# and "show warranty" for details.
# This GDB was configured as "x86_64-redhat-linux-gnu".
# For bug reporting instructions, please see:
# <http://www.gnu.org/software/gdb/bugs/>.
# + target remote localhost:25000
# The target architecture is assumed to be i8086
# [f000:fff0]    0xffff0:	ljmp   $0x3630,$0xf000e05b
# 0x0000fff0 in ?? ()
# + symbol-file obj/kern/kernel
# warning: A handler for the OS ABI "GNU/Linux" is not built into this 
# configuration
# of GDB.  Attempting to continue with the default i8086 settings.
另一个输入：

sudo make gdb
# ***
# *** Now run 'make gdb'.
# ***
# qemu-system-i386 -drive file=obj/kern/kernel.img,index=0,media=disk,format=raw -
# serial mon:stdio -gdb tcp::25000 -D qemu.log  -S
# VNC server running on 127.0.0.1:5900
 之后输入si （set instructions指令），分步查看调用步骤：

(gdb) si
# [f000:e05b]    0xfe05b:	cmpw   $0x8,%cs:(%esi)
# [f000:e062]    0xfe062:	jne    0xd241d0e2
# [f000:e066]    0xfe066:	xor    %edx,%edx
# [f000:e068]    0xfe068:	mov    %edx,%ss
# [f000:e06a]    0xfe06a:	mov    $0x7000,%sp
# [f000:e070]    0xfe070:	mov    $0x1a9d,%dx
# [f000:e076]    0xfe076:	jmp    0x5576cf5c
# [f000:cf5a]    0xfcf5a:	cli    
# [f000:cf5b]    0xfcf5b:	cld   
# [f000:cf5c]    0xfcf5c:	mov    %ax,%cx
# [f000:cf5f]    0xfcf5f:	mov    $0x8f,%ax
# [f000:cf65]    0xfcf65:	out    %al,$0x70
# [f000:cf67]    0xfcf67:	in     $0x71,%al
# [f000:cf69]    0xfcf69:	in     $0x92,%al
# [f000:cf6b]    0xfcf6b:	or     $0x2,%al
# [f000:cf6d]    0xfcf6d:	out    %al,$0x92
# [f000:cf6f]    0xfcf6f:	mov    %cx,%ax
# [f000:cf72]    0xfcf72:	lidtl  %cs:(%esi)
# [f000:cf78]    0xfcf78:	lgdtl  %cs:(%esi)
# [f000:cf7e]    0xfcf7e:	mov    %cr0,%ecx
# [f000:cf81]    0xfcf81:	and    $0xffff,%cx
# [f000:cf88]    0xfcf88:	or     $0x1,%cx
# [f000:cf8c]    0xfcf8c:	mov    %ecx,%cr0
# [f000:cf8f]    0xfcf8f:	ljmpw  $0xf,$0xcf97
代码详细解释：

1、第一条指令为 

[f000:fff0]    0xffff0:	ljmp   $0x3630,$0xf000e05b
CS（CodeSegment）和IP（Instruction Pointer）寄存器一起用于确定下一条指令的地址。计算公式： physical address = 16 * segment + offset.
PC开始运行时，CS = 0x3630，IP = 0xf000e05b，第一条指令做了jmp操作，跳到物理地址为16 * segment + offset的位置。
2、Cli和Cld

[f000:cf5a]    0xfcf5a:	cli    
[f000:cf5b]    0xfcf5b:	cld 
......
[f000:cf72]    0xfcf72:	lidtl  %cs:(%esi)
[f000:cf78]    0xfcf78:	lgdtl  %cs:(%esi)
CLI：Clear Interupt，禁止中断发生。STL：Set Interupt，允许中断发生。CLI和STI是用来屏蔽中断和恢复中断用的，如设置栈基址SS和偏移地址SP时，需要CLI，因为如果这两条指令被分开了，那么很有可能SS被修改了，但由于中断，而代码跳去其它地方执行了，SP还没来得及修改，就有可能出错。
CLD: Clear Director。STD：Set Director。在字行块传送时使用的，它们决定了块传送的方向。CLD使得传送方向从低地址到高地址，而STD则相反。
LIDT: 加载中断描述符。LGDT：加载全局描述符。
(gdb) si
[f000:e05b]    0xfe05b:	cmpw   $0x8,%cs:(%esi)
0x0000e05b in ?? ()
(gdb) si
[f000:e062]    0xfe062:	jne    0xd241d0e2
0x0000e062 in ?? ()
(gdb) b *0xfcf5a
Breakpoint 1 at 0xfcf5a
(gdb) c
Continuing.
Program received signal SIGTRAP, Trace/breakpoint trap.
[f000:cf5a]    0xfcf5a:	cli    
0x0000cf5a in ?? ()
3  读懂BOOT启动时的相关代码

3.1 分析 boot/boot.S的代码

#include <inc/mmu.h>

# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

.set PROT_MODE_CSEG, 0x8         # kernel code segment selector
.set PROT_MODE_DSEG, 0x10        # kernel data segment selector
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
  cld                         # String operations increment

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
  movw    %ax,%ds             # -> Data Segment
  movw    %ax,%es             # -> Extra Segment
  movw    %ax,%ss             # -> Stack Segment

  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.1

  movb    $0xd1,%al               # 0xd1 -> port 0x64
  outb    %al,$0x64

seta20.2:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.2

  movb    $0xdf,%al               # 0xdf -> port 0x60
  outb    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
  movl    %eax, %cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
  movw    %ax, %ds                # -> DS: Data Segment
  movw    %ax, %es                # -> ES: Extra Segment
  movw    %ax, %fs                # -> FS
  movw    %ax, %gs                # -> GS
  movw    %ax, %ss                # -> SS: Stack Segment
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
  call bootmain

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin

# Bootstrap GDT
.p2align 2                                # force 4 byte alignment
gdt:
  SEG_NULL				# null seg
  SEG(STA_X|STA_R, 0x0, 0xffffffff)	# code seg
  SEG(STA_W, 0x0, 0xffffffff)	        # data seg

gdtdesc:
  .word   0x17                            # sizeof(gdt) - 1
  .long   gdt                             # address gdt
seta20.1和seta20.2两段代码实现打开A20门的功能，其中seta20.1是向键盘控制器的0x64端口发送0x61命令，这个命令的意思是要向键盘控制器的 P2 写入数据；seta20.2是向键盘控制器的 P2 端口写数据了。写数据的方法是把数据通过键盘控制器的 0x60 端口写进去。写入的数据是 0xdf，因为 A20 gate 就包含在键盘控制器的 P2 端口中，随着 0xdf 的写入，A20 gate 就被打开了。
test对两个参数(目标，源)执行AND逻辑操作，并根据结果设置标志寄存器，结果本身不会保存。
GDT是全局描述符表，GDTR是全局描述符表寄存器。想要在“保护模式”下对内存进行寻址就先要有 GDT，GDT表里每一项叫做“段描述符”，用来记录每个内存分段的一些属性信息，每个段描述符占8字节。CPU使用GDTR寄存器来保存我们GDT在内存中的位置和GDT的长度。lgdt gdtdesc将源操作数的值（存储在gdtdesc地址中）加载到全局描述符表寄存器中。
一个操作系统在计算机启动后到底应该做些什么：（摘自参考文献1《【学习xv6】从实模式到保护模式》）
计算机开机，运行环境为 1MB 寻址限制带“卷绕”机制
打开 A20 gate 让计算机突破 1MB 寻址限制
在内存中建立 GDT 全局描述符表，并将建立好的 GDT 表的位置和大小告诉 CPU
设置控制寄存器，进入保护模式
按照保护模式的内存寻址方式继续执行
3.2 分析boot/main.c的代码

#include <inc/x86.h>
#include <inc/elf.h>

/**********************************************************************
 * This a dirt simple boot loader, whose sole job is to boot
 * an ELF kernel image from the first IDE hard disk.
 *
 * DISK LAYOUT
 *  * This program(boot.S and main.c) is the bootloader.  It should
 *    be stored in the first sector of the disk.
 *
 *  * The 2nd sector onward holds the kernel image.
 *
 *  * The kernel image must be in ELF format.
 *
 * BOOT UP STEPS
 *  * when the CPU boots it loads the BIOS into memory and executes it
 *
 *  * the BIOS intializes devices, sets of the interrupt routines, and
 *    reads the first sector of the boot device(e.g., hard-drive)
 *    into memory and jumps to it.
 *
 *  * Assuming this boot loader is stored in the first sector of the
 *    hard-drive, this code takes over...
 *
 *  * control starts in boot.S -- which sets up protected mode,
 *    and a stack so C code then run, then calls bootmain()
 *
 *  * bootmain() in this file takes over, reads in the kernel and jumps to it.
 **********************************************************************/

#define SECTSIZE	512
#define ELFHDR		((struct Elf *) 0x10000) // scratch space

void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();

bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
		/* do nothing */;
}

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;

	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
	}
}

void
waitdisk(void)
{
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
		/* do nothing */;
}

void
readsect(void *dst, uint32_t offset)
{
	// wait for disk to be ready
	waitdisk();

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
其实经过上述解释，这里看Main的C代码已经不是特别困难了，结合英文注释就可以看得懂，下面再来结合Main的汇编语言再来深度理解一下Main所做的事情。

3.2.1 Main.C做的主要工作

其中，先来分析，ReadSect这个函数的主要工作流程：

这个函数主要做了三件事情：等待磁盘（waitdisk）、输出扇区数目及地址信息到端口（out）、读取扇区数据（insl）。

// waitdisk:
 7c6a:   55                      push   %ebp
 7c6b:   ba f7 01 00 00          mov    $0x1f7,%edx
 7c70:   89 e5                   mov    %esp,%ebp
 7c72:   ec                      in     (%dx),%al
 7c73:   83 e0 c0                and    $0xffffffc0,%eax
 7c76:   3c 40                   cmp    $0x40,%al
 7c78:   75 f8                   jne    7c72 <waitdisk+0x8>
// out:
 7c7c:   55                      push   %ebp
 7c7d:   89 e5                   mov    %esp,%ebp
 7c7f:   57                      push   %edi
 7c80:   8b 4d 0c                mov    0xc(%ebp),%ecx
 7c83:   e8 e2 ff ff ff          call   7c6a <waitdisk>
 7c88:   ba f2 01 00 00          mov    $0x1f2,%edx
 7c8d:   b0 01                   mov    $0x1,%al
 7c8f:   ee                      out    %al,(%dx)
 7c90:   ba f3 01 00 00          mov    $0x1f3,%edx
 7c95:   88 c8                   mov    %cl,%al
 7c97:   ee                      out    %al,(%dx)
 7c98:   89 c8                   mov    %ecx,%eax
 7c9a:   ba f4 01 00 00          mov    $0x1f4,%edx
 7c9f:   c1 e8 08                shr    $0x8,%eax
 7ca2:   ee                      out    %al,(%dx)
 7ca3:   89 c8                   mov    %ecx,%eax
 7ca5:   ba f5 01 00 00          mov    $0x1f5,%edx
 7caa:   c1 e8 10                shr    $0x10,%eax
 7cad:   ee                      out    %al,(%dx)
 7cae:   89 c8                   mov    %ecx,%eax
 7cb0:   ba f6 01 00 00          mov    $0x1f6,%edx
 7cb5:   c1 e8 18                shr    $0x18,%eax
 7cb8:   83 c8 e0                or     $0xffffffe0,%eax
 7cbb:   ee                      out    %al,(%dx)
 7cbc:   ba f7 01 00 00          mov    $0x1f7,%edx
 7cc1:   b0 20                   mov    $0x20,%al
 7cc3:   ee                      out    %al,(%dx)
 7cc4:   e8 a1 ff ff ff          call   7c6a <waitdisk>
 // insl:
 7cc9:   8b 7d 08                mov    0x8(%ebp),%edi
 7ccc:   b9 80 00 00 00          mov    $0x80,%ecx
 7cd1:   ba f0 01 00 00          mov    $0x1f0,%edx
 7cd6:   fc                      cld    
 7cd7:   f2 6d                   repnz insl (%dx),%es:(%edi)
 7cd9:   5f                      pop    %edi
 7cda:   5d                      pop    %ebp
 7cdb:   c3                      ret    
等待磁盘。waitdisk的函数实现如下所示。它其实就做一件事情：不断地读端口0x1fc的bit_7和bit_6的值，直到bit_7=0和bit_6=1.结合参考文献1可知，端口1F7在被读的时候是作为状态寄存器使用，其中bit_7=0表示控制器空闲，bit_6=1表示驱动器就绪。因此，waitdisk在控制器空闲和驱动器就绪同时成立时才会结束等待。`
输出数据到端口。根据参考文献1的介绍，IDE定义了8个寄存器来操作硬盘。PC 体系结构将第一个硬盘控制器映射到端口 1F0-1F7 处，而第二个硬盘控制器则被映射到端口 170-177 处。out函数主要是是把扇区计数、扇区LBA地址等信息输出到端口1F2-1F6，然后将0x20命令写到1F7，表示要进行读扇区的操作。
读取扇区数据。主要用到insl函数，其实现是一个内联汇编语句。这个stackflow网站解释了insl函数的作用：“That function will read cnt dwords from the input port specified by port into the supplied output array addr.”。关于内联汇编的介绍见Brennan's Guide to Inline Assembly和GCC内联汇编基础。insl函数实质上就是从0x1F0端口连续读128个dword（即512个字节，也就是一个扇区的字节数）到目的地址。其中，0x1F0是数据寄存器，读写硬盘数据都必须通过这个寄存器。
4  熟悉C语言中指针的操作

4.1 Pointer.c代码的演绎

本题目的主要是为了熟悉指针在C语言的操作规律，为了让原代码更好理解可以把代码加一点东西输出，如下：

#include <stdio.h>
#include <stdlib.h>

void f(void)
{
    int a[4];
    int *b = malloc(16);
    int *c;
    int i;
    printf("1: a = %p, b = %p, c = %p\n", &a, &b, &c);
    c = a;
    for (i = 0; i < 4; i++)
	    a[i] = 100 + i;
    c[0] = 200;
    printf("2: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n",
	   a[0], a[1], a[2], a[3]);
    c[1] = 300;
    *(c + 2) = 301;
    3[c] = 302;
    printf("3: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n",
	   a[0], a[1], a[2], a[3]);

    printf("3.1: a = %d, a+1 = %d,a+2 = %d,a+3 = %d, b = %d, c = %d, c+1=%d\n", a,a+1,a+2,a+3, b, c, c+1);
    c = c + 1;
    printf("3.2: a = %d, a+1 = %d,a+2 = %d,a+3 = %d, b = %d, c = %d, c+1=%d\n", a,a+1,a+2,a+3, b, c, c+1);
    *c = 400;
    printf("4: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n",
	   a[0], a[1], a[2], a[3]);
    printf("4.1: a = %d, a+1 = %d,a+2 = %d,a+3 = %d, b = %d, c = %d, c+1=%d\n", a,a+1,a+2,a+3, b, c, c+1);
    c = (int *) ((char *) c + 1);
    printf("4.2: a = %d, a+1 = %d,a+2 = %d,a+3 = %d, b = %d, c = %d, c+1=%d\n", a,a+1,a+2,a+3, b, c, c+1);
    *c = 500;
    printf("5: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n",
	   a[0], a[1], a[2], a[3]);

    b = (int *) a + 1;
    c = (int *) ((char *) a + 1);
    printf("6: a = %p, b = %p, c = %p\n", a, b, c);
}

int main(int ac, char **av){
    f();
    return 0;
}
如上述代码输出的内容如下（机器不同，指针地址可能不同，不要纠结于此）：

1: a = 0x7ffeee515570, b = 0x7ffeee515568, c = 0x7ffeee515560
2: a[0] = 200, a[1] = 101, a[2] = 102, a[3] = 103
3: a[0] = 200, a[1] = 300, a[2] = 301, a[3] = 302
3.1: a = -296659600, a+1 = -296659596,a+2 = -296659592,a+3 = -296659588, b = 1464861216, c = -296659600, c+1=-296659596
3.2: a = -296659600, a+1 = -296659596,a+2 = -296659592,a+3 = -296659588, b = 1464861216, c = -296659596, c+1=-296659592
4: a[0] = 200, a[1] = 400, a[2] = 301, a[3] = 302
4.1: a = -296659600, a+1 = -296659596,a+2 = -296659592,a+3 = -296659588, b = 1464861216, c = -296659596, c+1=-296659592
4.2: a = -296659600, a+1 = -296659596,a+2 = -296659592,a+3 = -296659588, b = 1464861216, c = -296659595, c+1=-296659591
5: a[0] = 200, a[1] = 128144, a[2] = 256, a[3] = 302
6: a = 0x7ffeee515570, b = 0x7ffeee515574, c = 0x7ffeee515571
 4.2 Pointer.c代码的解读

下面就来对上述代码深度解读，其实也是复习C语言指针的一个过程：

#include <stdio.h>
#include <stdlib.h>

void f(void)
{
    int a[4];
    int *b = malloc(16);
    int *c;
    int I;
    // a是一个int类型的数组，那么在代码中要理解的是如下三个概念：
    // 1. a是指a指针指向内存所代表的地址
    // 2. &a是指a指针的内存地址
    // 3. *a是指a指针指向内存代表的地址中的内容
    // 因此，在下面一行代码执行结果出现的是a，b，c三个指针所在的内存地址，并不是他们指向的地址
    // 于是内存地址按照 &a>&b>&c 分配，并且三个地址连续
    printf("1: a = %p, b = %p, c = %p\n", &a, &b, &c);
    // 下面把c的指针的内存地址指向a
    // 那么也就意味着c+1变成了a[1]的地址，c+2变成了a[2]的地址，等等
    c = a;
    for (i = 0; i < 4; i++)
	    a[i] = 100 + I;
    // c[0]为200，那么也就意味着c的指针指向内存代表的地址中的内容为200，也就意味着a[0]=200
    c[0] = 200;
    printf("2: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n",
	   a[0], a[1], a[2], a[3]);
    // 下面主要是替换指针指向内存代表的地址中的内容，较为简单的三种形式
    // 按照如下模版都是一个意思：
    //c[1]=*(c+1)=1[c]
    c[1] = 300;
    *(c + 2) = 301;
    3[c] = 302;
    printf("3: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n",
	   a[0], a[1], a[2], a[3]);
    // 这里如果不清楚指针地址是如何变换的，那么打印一下指针地址就知道了
    // 从输出就可以看出，a和c指针指向内存代表的地址是相同的
    printf("3.1: a = %d, a+1 = %d,a+2 = %d,a+3 = %d, b = %d, c = %d, c+1=%d\n", a,a+1,a+2,a+3, b, c, c+1);
    // 这时，将c指针向后挪动一个位置，这里的一个位置代表的是四个bit（32位）
    // 也就是说c指针指向内存的地址变成了原来c+1指针指向内存的地址
    // c+1指针指向内存的地址变成了原来c+2指针指向内存的地址，等等
    // 这时，变化的仅仅是c指针吗？并不是，之前的c=a依然作数
    // 也就是说现在的c指针指向的内存地址变化了，那么以前的关系也要发生变化
    // 原来c指针指向的内存地址也是a指针指向的内存地址
    // 现在c指针指向了原来c+1的内存地址，原来c+1指向的是a+1的内存地址
    // 那么意味着，c指针现在指针也指向a+1的内存地址
    c = c + 1;
    // 所以可以输出一下内存地址看一下，可以看出现在c的指向内存地址和a+1的内存地址是完全一致的
    // 而在+1之前，c的指向内存地址和a的内存地址是完全一致的
    printf("3.2: a = %d, a+1 = %d,a+2 = %d,a+3 = %d, b = %d, c = %d, c+1=%d\n", a,a+1,a+2,a+3, b, c, c+1);
    *c = 400;
    // 这里把c的指向内存地址的内容换成了400，那么意味着，同一地址的a+1的内容也发生了改变
    printf("4: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n",
	   a[0], a[1], a[2], a[3]);
    // 这里输出一下各个部分的指向内存地址
    printf("4.1: a = %d, a+1 = %d,a+2 = %d,a+3 = %d, b = %d, c = %d, c+1=%d\n", a,a+1,a+2,a+3, b, c, c+1);
    // 这里继续变化c的指向内存的地址，和上次不一样的是，上次顺延了4个bit（一个int的长度）
    // 现在是1个bit（一个char的长度）
    c = (int *) ((char *) c + 1);
    printf("4.2: a = %d, a+1 = %d,a+2 = %d,a+3 = %d, b = %d, c = %d, c+1=%d\n", a,a+1,a+2,a+3, b, c, c+1);
    // 为了更便于理解，在这里呢，我分析的更加具体一些：
    // 现在a[2]的值为301
    // 用八个bit表示就是：0000 0000 0000 0000 0000 0001 0010 1101
    // 现在a[1]的值为400
    // 用八个bit表示就是：0000 0000 0000 0000 0000 0001 1101 0000
    // 我先写a[2] 再写a[1] 的原因是因为a[2]地址大，a[1]地址小，大的在上方比较符合规律
    // 现在要替换一个数500
    // 用八个bit表示就是：0000 0000 0000 0000 0000 0001 1111 0100
    // 开始替换的位置是a[1]的地址上顺延1个bit，那么替换后，可以知道
    // 现在a[2]的值为256
    // 用八个bit表示就是：0000 0000 0000 0000 0000 0001 0000 0000
    // 现在a[1]的值为128144
    // 用八个bit表示就是：0000 0000 0000 0001 1111 0100 1001 0000
    *c = 500;
    printf("5: a[0] = %d, a[1] = %d, a[2] = %d, a[3] = %d\n",
	   a[0], a[1], a[2], a[3]);
    // 理解到上面，下面的不必解释了
    b = (int *) a + 1;
    c = (int *) ((char *) a + 1);
    printf("6: a = %p, b = %p, c = %p\n", a, b, c);
}

int main(int ac, char **av){
    f();
    return 0;
}
5  测试BootLoader载入Kernel的过程 

下面过程重复一下上述步骤进行GDB分部调试，不过，在调试之前我注意到了$PATH/boot/Makefrag 这个文件里面的内容：

$(OBJDIR)/boot/%.o: boot/%.c
        @echo + cc -Os $<
        @mkdir -p $(@D)
        $(V)$(CC) -nostdinc $(KERN_CFLAGS) -Os -c -o $@ $<

$(OBJDIR)/boot/%.o: boot/%.S
        @echo + as $<
        @mkdir -p $(@D)
        $(V)$(CC) -nostdinc $(KERN_CFLAGS) -c -o $@ $<

$(OBJDIR)/boot/main.o: boot/main.c
        @echo + cc -Os $<
        $(V)$(CC) -nostdinc $(KERN_CFLAGS) -Os -c -o $(OBJDIR)/boot/main.o boot/main.c

$(OBJDIR)/boot/boot: $(BOOT_OBJS)
        @echo + ld boot/boot
        $(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $@.out $^
        $(V)$(OBJDUMP) -S $@.out >$@.asm
        $(V)$(OBJCOPY) -S -O binary -j .text $@.out $@
        $(V)perl boot/sign.pl $(OBJDIR)/boot/boot
有上述的命令可以看出先运行了boot.S，再调用了main.c，BIOS之后切换到Boot Loader内核，且，所有指令的开始地址是从0x7c00开始的，所以先来在0x7c00插入一个断点进行测试：

进入GDB调试过程： 

(gdb) b *0x7c00
Breakpoint 1 at 0x7c00
(gdb) c
Continuing.
[   0:7c00] => 0x7c00:	cli    

Breakpoint 1, 0x00007c00 in ?? ()
(gdb) x/8x 0x100000
0x100000:	0x00000000	0x00000000	0x00000000	0x00000000
0x100010:	0x00000000	0x00000000	0x00000000	0x00000000
(gdb) b *0x10000c
Breakpoint 2 at 0x10000c
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0x10000c:	movw   $0x1234,0x472

Breakpoint 2, 0x0010000c in ?? ()
(gdb) x/8x 0x100000
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x0000b812	0x220f0011	0xc0200fd8
(gdb) x/8i 0x100000
   0x100000:	add    0x1bad(%eax),%dh
   0x100006:	add    %al,(%eax)
   0x100008:	decb   0x52(%edi)
   0x10000b:	in     $0x66,%al
   0x10000d:	movl   $0xb81234,0x472
   0x100017:	add    %dl,(%ecx)
   0x100019:	add    %cl,(%edi)
   0x10001b:	and    %al,%bl
在这里首先要明确几个地址的概念：

0x7c00，the BIOS loads the boot sector at address 0x7c00，这是BIOS加载BOOT扇区的初始地址。

0x100000，这是Kernel最终被装载的地址。

于是，内核由boot loader负责载入，初始当BIOS切换到boot loader时，它还没有开始相应的装载工作，所以在这个时候所有的8个word全都是0。而当boot loader进入内核运行时，这个时候内核已经装载完毕，所以从0x1000000开始就是内核ELF文件的文件内容了。（ELF HEADER）

6  链接VS装载（Link VS Load Address）

Exercise 6. Trace through the first few instructions of the boot loader again and identify the first instruction that would "break" or otherwise do the wrong thing if you were to get the boot loader's link address wrong. Then change the link address in boot/Makefrag to something wrong, run make clean, recompile the lab with make, and trace into the boot loader again to see what happens. Don't forget to change the link address back and make clean afterwards!

这个题目的要求把$PATH/boot/Makefrag中第28行-Ttext参数从0x7c00改成0x7c20，即实际的Boot Loader装载位置比链接位置靠后，我们重新编译看一下效果。首先执行make clean，重新make：

[root@VM_0_8_centos jos-2019-spring]# make gdb
gdb -n -x .gdbinit
GNU gdb (GDB) Red Hat Enterprise Linux 7.6.1-114.el7
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
+ target remote localhost:25000
The target architecture is assumed to be i8086
[f000:fff0]    0xffff0:	ljmp   $0x3630,$0xf000e05b
0x0000fff0 in ?? ()
+ symbol-file obj/kern/kernel
warning: A handler for the OS ABI "GNU/Linux" is not built into this configuration
of GDB.  Attempting to continue with the default i8086 settings.

(gdb) c
Continuing.
^C
Program received signal SIGINT, Interrupt.
The target architecture is assumed to be i386
=> 0x7fb7ea4:	mov    0x18(%esp),%eax
0x07fb7ea4 in ?? ()
(gdb) c
Continuing.
^C
Program received signal SIGINT, Interrupt.
=> 0xe9d0c:	rep movsb %ds:(%esi),%es:(%edi)
0x000e9d0c in ?? ()
(gdb) si
=> 0xe9d0c:	rep movsb %ds:(%esi),%es:(%edi)
0x000e9d0c in ?? ()
(gdb) si
=> 0xe9d0c:	rep movsb %ds:(%esi),%es:(%edi)
0x000e9d0c in ?? ()
(gdb) si
=> 0xe9d0c:	rep movsb %ds:(%esi),%es:(%edi)
0x000e9d0c in ?? ()
(gdb) si
=> 0xe9d0c:	rep movsb %ds:(%esi),%es:(%edi)
0x000e9d0c in ?? ()
可以发现程序卡在了这个0x9d0c的指令无法往下进行。于是，指令无法继续进行以跳入内核。

如下是没有改动内核装载地址的效果，在0x7c2d地址的时候，Boot Loader跳入内核：

(gdb) b *0x7c2d
Breakpoint 1 at 0x7c2d
(gdb) c
Continuing.
[   0:7c2d] => 0x7c2d:	ljmp   $0xb866,$0x87c32

Breakpoint 1, 0x00007c2d in ?? ()
(gdb) si
The target architecture is assumed to be i386
=> 0x7c32:	mov    $0x10,%ax
0x00007c32 in ?? ()
(gdb) c
Continuing.
^C
Program received signal SIGINT, Interrupt.
=> 0xf0100405 <kbd_proc_data+261>:	mov    $0xffffffff,%eax
kbd_proc_data () at kern/console.c:324
324			return -1;
改动成了0X7C20之后，Boot Loader无法跳入内核：

(gdb) b *0x7c2d
Breakpoint 1 at 0x7c2d
(gdb) c
Continuing.
[   0:7c2d] => 0x7c2d:	ljmp   $0xb866,$0x87c52

Breakpoint 1, 0x00007c2d in ?? ()
(gdb) si
[f000:e05b]    0xfe05b:	cmpw   $0x8,%cs:(%esi)
0x0000e05b in ?? ()
(gdb) c
Continuing.
[   0:7c2d] => 0x7c2d:	ljmp   $0xb866,$0x87c52

Breakpoint 1, 0x00007c2d in ?? ()
(gdb) si
[f000:e05b]    0xfe05b:	cmpw   $0x8,%cs:(%esi)
0x0000e05b in ?? ()
(gdb) c
Continuing.
[   0:7c2d] => 0x7c2d:	ljmp   $0xb866,$0x87c52

Breakpoint 1, 0x00007c2d in ?? ()
(gdb) si
[f000:e05b]    0xfe05b:	cmpw   $0x8,%cs:(%esi)
0x0000e05b in ?? ()
(gdb) c
Continuing.
[   0:7c2d] => 0x7c2d:	ljmp   $0xb866,$0x87c52

Breakpoint 1, 0x00007c2d in ?? ()
7 加载Kernel时重新进行映射的测试

Exercise 7. Use QEMU and GDB to trace into the JOS kernel and find where the new virtual-to-physical mapping takes effect. Then examine the Global Descriptor Table (GDT) that the code uses to achieve this effect, and make sure you understand what's going on. 

What is the first instruction after the new mapping is established that would fail to work properly if the old mapping were still in place? Comment out or otherwise intentionally break the segmentation setup code in kern/entry.S, trace into it, and see if you were right.

下面这是kern/entry.S的代码片段：

/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>

# Shift Right Logical 
#define SRL(val, shamt)		(((val) >> (shamt)) & ~(-1 << (32 - (shamt))))


###################################################################
# The kernel (this code) is linked at address ~(KERNBASE + 1 Meg), 
# but the bootloader loads it at address ~1 Meg.
#	
# RELOC(x) maps a symbol x from its link address to its actual
# location in physical memory (its load address).	 
###################################################################

#define	RELOC(x) ((x) - KERNBASE)

#define MULTIBOOT_HEADER_MAGIC (0x1BADB002)
#define MULTIBOOT_HEADER_FLAGS (0)
#define CHECKSUM (-(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS))

###################################################################
# entry point
###################################################################

.text

# The Multiboot header
.align 4
.long MULTIBOOT_HEADER_MAGIC
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

# '_start' specifies the ELF entry point.  Since we haven't set up
# virtual memory when the bootloader enters this code, we need the
# bootloader to jump to the *physical* address of the entry point.
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot

	# We haven't set up virtual memory yet, so we're running from
	# the physical address the boot loader loaded the kernel at: 1MB
	# (plus a few bytes).  However, the C code is linked to run at
	# KERNBASE+1MB.  Hence, we set up a trivial page directory that
	# translates virtual addresses [KERNBASE, KERNBASE+4MB) to
	# physical addresses [0, 4MB).  This 4MB region will be
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
	movl	%eax, %cr3
	# Turn on paging.
	movl	%cr0, %eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
	movl	%eax, %cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
	jmp	*%eax
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer

	# Set the stack pointer
	movl	$(bootstacktop),%esp

	# now to C code
	call	i386_init

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin


.data
###################################################################
# boot stack
###################################################################
	.p2align	PGSHIFT		# force page alignment
	.globl		bootstack
bootstack:
	.space		KSTKSIZE
	.globl		bootstacktop   
bootstacktop:
下面这个是obj/kern/kernel.asm文件，可以看得出来这个asm文件和上面长的很像。

事实证明他就是一个东西，asm文件更详细。从asm里面可以看到每一条指令的具体地址，由此可以去找到设置位置。

比如说从下面的代码可以看出：boot loader在初始化的时候自己定义了GDT（Global Descirptor Table），代替了原来的GDT，这个GDT移动到物理内存 [0,4MB)，放在了cr3中。

Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl          _start
_start = RELOC(entry)

.globl entry
entry:
        movw    $0x1234,0x472                   # warm boot
f0100000:       02 b0 ad 1b 00 00       add    0x1bad(%eax),%dh
f0100006:       00 00                   add    %al,(%eax)
f0100008:       fe 4f 52                decb   0x52(%edi)
f010000b:       e4                      .byte 0xe4

f010000c <entry>:
f010000c:       66 c7 05 72 04 00 00    movw   $0x1234,0x472
f0100013:       34 12
        # sufficient until we set up our real page table in mem_init
        # in lab 2.

        # Load the physical address of entry_pgdir into cr3.  entry_pgdir
        # is defined in entrypgdir.c.
        movl    $(RELOC(entry_pgdir)), %eax
f0100015:       b8 00 00 11 00          mov    $0x110000,%eax
        movl    %eax, %cr3
f010001a:       0f 22 d8                mov    %eax,%cr3
        # Turn on paging.
        movl    %cr0, %eax
f010001d:       0f 20 c0                mov    %cr0,%eax
        orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:       0d 01 00 01 80          or     $0x80010001,%eax
        movl    %eax, %cr0
f0100025:       0f 22 c0                mov    %eax,%cr0

        # Now paging is enabled, but we're still running at a low EIP
        # (why is this okay?).  Jump up above KERNBASE before entering
        # C code.
        mov     $relocated, %eax
f0100028:       b8 2f 00 10 f0          mov    $0xf010002f,%eax
        jmp     *%eax
f010002d:       ff e0                   jmp    *%eax

f010002f <relocated>:
relocated:

        # Clear the frame pointer register (EBP)
        # so that once we get into debugging C code,
        # stack backtraces will be terminated properly.
        movl    $0x0,%ebp                       # nuke frame pointer
f010002f:       bd 00 00 00 00          mov    $0x0,%ebp
我们把Entry.S 中载入cr3中的两句代码屏蔽掉，即下面两句：

orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
movl	%eax, %cr0
重新make clean ，make，进入gdb，在f0100025处设置断点，之后继续运行，查看结果：

f0100025:       0f 22 c0                mov    %eax,%cr0
可以发现程序无法继续进行，卡在了某一句：

(gdb) b *0xf0100025
Breakpoint 1 at 0xf0100025: file kern/entry.S, line 68.
(gdb) c
Continuing.
^C
Program received signal SIGINT, Interrupt.
The target architecture is assumed to be i386
=> 0xf015c52b:	add    %al,(%eax)
0xf015c52b in ?? ()
(gdb) c
Continuing.
^C
Program received signal SIGINT, Interrupt.
=> 0xf028f15f:	add    %al,(%eax)
去掉断点后，继续运行，可以发现程序正常运行：

(gdb) b *0xf0100025
Breakpoint 1 at 0xf0100025: file kern/entry.S, line 62.
(gdb) c
Continuing.
^C
Program received signal SIGINT, Interrupt.
The target architecture is assumed to be i386
=> 0x7c74:	in     (%dx),%al
0x00007c74 in ?? ()
(gdb) c
Continuing.
^C
Program received signal SIGINT, Interrupt.
=> 0x7c7c:	pop    %ebp
8  探究控制台的输出格式

We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment. Remember the octal number should begin with '0'.

首先，完成这个之前要知道下面的几个问题：

8.1  kern/printf.c， lib/printfmt.c 和 kern/console.c之间的关联性

Explain the interface between printf.c and console.c. Specifically, what function does console.cexport? How is this function used by printf.c?

kern/console.c 主要提供一些与硬件直接进行交互的接口以便其他程序进行输入输出的调用。

其中，与kern/printf.c进行交互的主要是putch函数：

static void putch(int ch, int *cnt)
{
        cputchar(ch);
        (*cnt)++;
}
该函数将一个字符输出到显示器。

下面的代码是 console.c 中的一段代码。

static void cga_putc(int c)
{
        // if no attribute given, then use black on white
        if (!(c & ~0xFF))
                c |= 0x0700;

        switch (c & 0xff) {
        case '\b':
                if (crt_pos > 0) {
                        crt_pos--;
                        crt_buf[crt_pos] = (c & ~0xff) | ' ';
                }
                break;
        case '\n':
                crt_pos += CRT_COLS;
                /* fallthru */
        case '\r':
                crt_pos -= (crt_pos % CRT_COLS);
                break;
        case '\t':
                cons_putc(' ');
                cons_putc(' ');
                cons_putc(' ');
                cons_putc(' ');
                cons_putc(' ');
                break;
        default:
                crt_buf[crt_pos++] = c;         /* write the character */
                break;
        }

        // What is the purpose of this?
        if (crt_pos >= CRT_SIZE) {
                int i;

                memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
                for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
                        crt_buf[i] = 0x0700 | ' ';
                crt_pos -= CRT_COLS;
        }

        /* move that little blinky thing */
        outb(addr_6845, 14);
        outb(addr_6845 + 1, crt_pos >> 8);
        outb(addr_6845, 15);
        outb(addr_6845 + 1, crt_pos);
}

8.2 输出满屏后如何清屏操作

Explain the following from console.c:

console.c这段代码有个特别要注意一个地方：

if (crt_pos >= CRT_SIZE) {
                int i;
                memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
                for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
                        crt_buf[i] = 0x0700 | ' ';
                crt_pos -= CRT_COLS;
        }
上面打印检测满屏（满屏都是输出了），那么则将最后一行空出来，最上面一行被抛弃，同时让光标置为最后一行的行首。

8.3 解释格式化输出的一些指令和变量

For the following questions you might wish to consult the notes for Lecture 2. These notes cover GCC's calling convention on the x86.

Trace the execution of the following code step-by-step:

In the call to cprintf(), to what does fmt point? To what does ap point?
List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.
这里要求跟踪下面的一段代码，并查看 cons_putc, va_arg, and vcprintf 指令，fmt和ap分别怎么变化。

int x = 1, y = 3, z = 4;
cprintf("x %d, y %x, z %d\n", x, y, z);
下面贴一段kern/printf.c 中的 cprintf函数：

int cprintf(const char *fmt, ...)
{
        va_list ap;
        int cnt;

        va_start(ap, fmt);
        cnt = vcprintf(fmt, ap);
        va_end(ap);

        return cnt;
}
再贴一段 kern/console.c中的 cons_putc函数：

// output a character to the console
static void cons_putc(int c)
{
        serial_putc(c);
        lpt_putc(c);
        cga_putc(c);
}
从上述代码可以看出，cprintf（）中，fmt指向的是格式的字符串，在上例中即：

"x %d, y %x, z %d\n"
而，ap指的是上述不定参数表中的第一个参数地址，在上例中为x。

其次，va_arg的作用是将ap每次指向的地址往后移动需要的类型个字节：

例如：

precision = va_arg(ap, int);
ap类型应该是要往后输出一个int，然后往后移动一个int字节大小的长度。



8.4  格式化输出的例子

8.4.1 关于Hello World 的例子

Run the following code.

检测下列代码输出结果是什么，首先要考虑怎么让他输出到我们的界面中。

unsigned int i = 0x00646c72;
cprintf("H%x Wo%s", 57616, &i);
下面粘贴的一段 kern/monitor.c 的一段 monitor 函数：

void monitor(struct Trapframe *tf){
        char *buf;

        cprintf("Welcome to the JOS kernel monitor!\n");
        cprintf("Type 'help' for a list of commands.\n");


        while (1) {
                buf = readline("K> ");
                if (buf != NULL)
                        if (runcmd(buf, tf) < 0)
                                break;
}
 可以发现，在 $PATH 中运行 make qemu 的时候：

可以发现输出了 ：

Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
并且一直输出 “K>” 并交互式让用户输入命令。

所以将下列代码插入到 kern/monitor.c 就可以方便看到结果：

unsigned int i = 0x00646c72;
cprintf("H%x Wo%s", 57616, &i);
[root@VM_0_8_centos jos-2019-spring]# make qemu
sed "s/localhost:1234/localhost:25000/" < .gdbinit.tmpl > .gdbinit
qemu-system-i386 -drive file=obj/kern/kernel.img,index=0,media=disk,format=raw -serial mon:stdio -gdb tcp::25000 -D qemu.log 
VNC server running on 127.0.0.1:5900
6828 decimal is XXX octal!
pading space in the right to number 22: ------22.
chnum1: 0 chnum2: 0
chnum1: 0
show me the sign: %+d, %+d
entering test_backtrace 5
entering test_backtrace 4
entering test_backtrace 3
entering test_backtrace 2
entering test_backtrace 1
entering test_backtrace 0
Backtrace success
leaving test_backtrace 0
leaving test_backtrace 1
leaving test_backtrace 2
leaving test_backtrace 3
leaving test_backtrace 4
leaving test_backtrace 5
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
He110 WorldK
可以看出 输出的是什么内容，因为57616的16进制表示的就是e11，unsigned int 0x00646c72在little endian的机器上用char表示出来就是 { 0x72 0x6c 0x64 0x00} ={ 'r', 'l', 'd' '\0'}

如果要在big endian机器上想要打出同样的结果，i的值必须是 0x726c6400，而e110的打印处不用更改。

8.4.2 关于参数数量小于格式化要输出的占位数的例子

In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?

    cprintf("x=%d y=%d", 3);
再把这段代码输出到monitor.c

[root@VM_0_8_centos jos-2019-spring]# make qemu
sed "s/localhost:1234/localhost:25000/" < .gdbinit.tmpl > .gdbinit
qemu-system-i386 -drive file=obj/kern/kernel.img,index=0,media=disk,format=raw -serial mon:stdio -gdb tcp::25000 -D qemu.log 
VNC server running on 127.0.0.1:5900
6828 decimal is XXX octal!
pading space in the right to number 22: ------22.
chnum1: 0 chnum2: 0
chnum1: 0
show me the sign: %+d, %+d
entering test_backtrace 5
entering test_backtrace 4
entering test_backtrace 3
entering test_backtrace 2
entering test_backtrace 1
entering test_backtrace 0
Backtrace success
leaving test_backtrace 0
leaving test_backtrace 1
leaving test_backtrace 2
leaving test_backtrace 3
leaving test_backtrace 4
leaving test_backtrace 5
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
He110 World
x=3 y=-267321700
可以根据vprintfmt的机制，每次打印的变量都是根据va_arg从ap指针不断的往后取得的，如果给的参数数量不足以实际打印的数量，那么最后ap就跳到了一个未知的内存区域。

8.5 参数的调用与入栈出栈的顺序

Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments?

下面是$PATH/inc/stdarg.h中的代码：

/*      $NetBSD: stdarg.h,v 1.12 1995/12/25 23:15:31 mycroft Exp $      */

#ifndef JOS_INC_STDARG_H
#define JOS_INC_STDARG_H

typedef __builtin_va_list va_list;

#define va_start(ap, last) __builtin_va_start(ap, last)

#define va_arg(ap, type) __builtin_va_arg(ap, type)

#define va_end(ap) __builtin_va_end(ap)

#endif  /* !JOS_INC_STDARG_H */
可以看出，va_arg不停以地址往后增长去除下一个参数的变量地址。这等价于编译器从右到左的顺序入栈，因为后压栈的参数在内存低的位置，所以如果从左到右取出各个变量，那么编译器就是从右到左的顺序入栈的。

如果编译器改变了压栈的顺序，那么为了仍让能够正确取出所有的参数，那么需要修改va_start, va_arg，将其改编取参顺序。



8.6 补充缺少的八进制代码段

We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment. Remember the octal number should begin with '0'.

在lib/printfmt.c中加入如下代码：

                case 'o':
                        num = getuint(&ap, lflag);
                        base = 8;
                        goto number;
                        break;
8.7  让八进制格式化输出能够支持正负号

You need also to add support for the "+" flag, which forces to precede the result with a plus or minus sign (+ or -) even for positive numbers.

在lib/printfmt.c中加入如下代码：


                case 'o':
                        num = getint(&ap, lflag);
                        base = 8;

                        if ((long long) num > 0) {
                                putch('+', putdat);
                                num = +(long long) num;
                        }

                        if ((long long) num < 0) {
                                putch('-', putdat);
                                num = -(long long) num;
                        }
                        goto number;
                        break;
替换 kern/monitor.c 中的部分代码，并重新make clean && make：

void monitor(struct Trapframe *tf)
{
        char *buf;

        cprintf("Welcome to the JOS kernel monitor!\n");
        cprintf("Type 'help' for a list of commands.\n");

        int j=0;
        cprintf("测试八进制数+41：%o\n",+41);
        cprintf("测试八进制数-41：%o\n",-41);
        while (1) {
                buf = readline("K> ");
                if (buf != NULL)
                        if (runcmd(buf, tf) < 0)
                                break;
        }
}
在make qemu中终端可以看到如下内容，证明改写正确： 

测试八进制数+41：+51
测试八进制数-41：-51
8.8 重载“%n”模式

Exercise 10. Enhance the cprintf function to allow it print with the %n specifier, you can consult the %n specifier specification of the C99 printf function for your reference by typing "man 3 printf" on the console. In this lab, we will use the char * type argument instead of the C99 int * argument, that is, "the number of characters written so far is stored into the signed char type integer indicated by the char * pointer argument. No argument is converted." You must deal with some special cases properly, because we are in kernel, such as when the argument is a NULL pointer, or when the char integer pointed by the argument has been overflowed. Find and fill in this code fragment.

8.8.1 参考C99标准中的%n

%n在C99标准中就是输出字符串个字符个数，参数的格式应该是一个char * 类型，举例来说：

#include <cstdio>
int main(){
    char* a;
    a=(char *)malloc(sizeof(char));
    int t;
    scanf("%s%n",a,&t);
    printf("%s-->You have just entered %d character(s).\n",a,t);
}
# 输入：123121
# 输出：123121-->You have just entered 6 character(s).
8.8.2 复现printf函数中的%n

将 lib/printfmt.c 中的部分代码进行替换：

                    case 'n': {
                            
                                  const char *null_error = 
                                    "\nerror! writing through NULL pointer!
                                     (%n argument)\n";
                                  const char *overflow_error = 
                                    "\nwarning! The value %n argument 
                                    pointed to has been overflowed!\n";                                  
                                  
                                  char* pos = va_arg(ap,char*);
                                  if (pos == NULL)
                                        printfmt(putch, putdat, 
                                            "错误内容：%s", null_error);
                                  else if ((*(unsigned int *)putdat)>254)
                                        printfmt(putch, putdat, 
                                            "错误内容：%s", overflow_error);
                                  else
                                        *pos = *(char *)putdat;
                                  break;
                          }
提示：

1）这里会一直用到num，putch，putdat这三个变量，num应该是提取出来的数字，putch应该是提取出的字符，putdat应该是提取的字符串长度吧。

2）题目中说不能再用 收入的参数的类型不是int，而是char，则意味着，8.8.1中例子的t要变为char，则代码中的相应部分也应该改动。

8.8.3 测试%n是否正确

替换 kern/monitor.c 中的部分代码，并重新make clean && make：

void monitor(struct Trapframe *tf){
        char *buf;

        cprintf("Welcome to the JOS kernel monitor!\n");
        cprintf("Type 'help' for a list of commands.\n");

        int j=0;
        char b;
        cprintf("%s%n\n","i'm Henry Fordham",&b);
        cprintf("上面那句话一共%d个字符\n",b);
        while (1) {
                buf = readline("K> ");
                if (buf != NULL)
                        if (runcmd(buf, tf) < 0)
                                break;
        }
}
在make qemu中终端可以看到如下内容，证明改写正确： 

i'm Henry Fordham
上面那句话一共17个字符
8.9  修改 printfmt.c 中的模式输出

Modify the function printnum() in lib/printfmt.c to support "%-"when printing numbers. With the directives starting with "%-", the printed number should be left adjusted. (i.e., paddings are on the right side.) For example, the following function call: 

cprintf("test:[%-5d]", 3)
, should give a result as 

"test:[3    ]"
(4 spaces after '3'). Before modifying printnum(), make sure you know what happened in function vprintffmt().

在 lib/printfmt.c 的printnum()函数中替换如下内容：

static void printnum(void (*putch)(int, void*), void *putdat,
         unsigned long long num, unsigned base, int width, int padc){
        // if cprintf'parameter includes pattern of the form "%-", padding
        // space on the right side if neccesary.
        // you can add helper function if needed.
        // your code here:
        if (padc == '-') {
                int i = 0;
                int num_of_digit = 0;
                int temp = num;
                while(temp > 0) {
                        num_of_digit += 1;
                        temp /= base;
                }
                printnum(putch, putdat, num, base, num_of_digit, ' ');
                for (i = 0; i < width - num_of_digit; i++)
                        putch(' ', putdat);
                return;
        }
        ......
}
同样，从monitor.c输出内容即可得到正确的答案。

9  栈

Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?

在 kern/entry.S 中可以看到如下代码片段：

relocated:

        # Clear the frame pointer register (EBP)
        # so that once we get into debugging C code,
        # stack backtraces will be terminated properly.
        movl    $0x0,%ebp                       # nuke frame pointer

        # Set the stack pointer
        movl    $(bootstacktop),%esp

        # now to C code
        call    i386_init

        # Should never get here, but in case we do, just spin.
spin:   jmp     spin
可以看出这个代码片设置了 ebp寄存器为0，esp寄存器为“栈底（TOP）”，也就是栈的最高地址，栈的增长是向低地址增长的，所以最高位置就是“栈底（TOP）”。简单来说，esp是真实的指针，ebp是用来在c程序中进行测试使用的，如果发生错误，则用ebp可以检测错误。

To become familiar with the C calling conventions on the x86, find the address of the test_backtrace function in obj/kern/kernel.asm, set a breakpoint there, and examine what happens each time it gets called after the kernel starts. How many 32-bit words does each recursive nesting level of test_backtrace push on the stack, and what are those words?

Note that, for this exercise to work properly, you should be using the patched version of QEMU available on the tools page. Otherwise, you'll have to manually translate all breakpoint and memory addresses to linear addresses.



test_backtrace(int x)
{
f0100040:       55                      push   %ebp
f0100041:       89 e5                   mov    %esp,%ebp
f0100043:       53                      push   %ebx
f0100044:       83 ec 14                sub    $0x14,%esp
f0100047:       8b 5d 08                mov    0x8(%ebp),%ebx
        cprintf("entering test_backtrace %d\n", x);
f010004a:       89 5c 24 04             mov    %ebx,0x4(%esp)
f010004e:       c7 04 24 c0 1c 10 f0    movl   $0xf0101cc0,(%esp)
f0100055:       e8 b3 0a 00 00          call   f0100b0d <cprintf>
        if (x > 0)
f010005a:       85 db                   test   %ebx,%ebx
f010005c:       7e 0d                   jle    f010006b <test_backtrace+0x2b>
                test_backtrace(x-1);
f010005e:       8d 43 ff                lea    -0x1(%ebx),%eax
f0100061:       89 04 24                mov    %eax,(%esp)
f0100064:       e8 d7 ff ff ff          call   f0100040 <test_backtrace>
f0100069:       eb 1c                   jmp    f0100087 <test_backtrace+0x47>
        else
                mon_backtrace(0, 0, 0);
f010006b:       c7 44 24 08 00 00 00    movl   $0x0,0x8(%esp)
f0100072:       00 
f0100073:       c7 44 24 04 00 00 00    movl   $0x0,0x4(%esp)
f010007a:       00 
f010007b:       c7 04 24 00 00 00 00    movl   $0x0,(%esp)
f0100082:       e8 36 08 00 00          call   f01008bd <mon_backtrace>
        cprintf("leaving test_backtrace %d\n", x);
f0100087:       89 5c 24 04             mov    %ebx,0x4(%esp)
f010008b:       c7 04 24 dc 1c 10 f0    movl   $0xf0101cdc,(%esp)
f0100092:       e8 76 0a 00 00          call   f0100b0d <cprintf>
}
一共四类栈空间被使用：

%ebp（占用4b）  ：入口处ebp保存了使用的栈空间

%ebx（占用4b）  ：保存了函数使用到的ebx通用寄存器

%esp（占用20b）：栈底指针esp减少0X14，存放caller函数

%eip （占用4b）   ：call命令的时候，会将eip压栈

一共32byte空间压入栈

Implement the backtrace function as specified above. Use the same format as in the example, since otherwise the grading script will be confused. When you think you have it working right, run make grade to see if its output conforms to what our grading script expects, and fix it if it doesn't. After you have handed in your Lab 1 code, you are welcome to change the output format of the backtrace function any way you like.

%esp（占用20b）：说明有五个参数。

int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
        uint32_t *ebp = (unsigned int *)read_ebp();
        for (;ebp != NULL;) {
                cprintf("eip %8x  ebp %8x  args %08x %08x %08x %08x %08x\n",
                        ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
                ebp = (unsigned int *)(*ebp);
        }
        //overflow_me();
        cprintf("Backtrace success\n");

        return 0;
}
重新编译运行可以看到如下结果： 

entering test_backtrace 5
entering test_backtrace 4
entering test_backtrace 3
entering test_backtrace 2
entering test_backtrace 1
entering test_backtrace 0
eip f0100087  ebp f010fdf8  args 00000000 00000000 00000000 0000001a f0100b04
eip f0100069  ebp f010fe18  args 00000000 00000001 f010fe58 0000001a f0100b04
eip f0100069  ebp f010fe38  args 00000001 00000002 f010fe78 0000001a f0100b04
eip f0100069  ebp f010fe58  args 00000002 00000003 f010fe98 0000001a f0100b04
eip f0100069  ebp f010fe78  args 00000003 00000004 00000000 0000001b 00000000
eip f0100069  ebp f010fe98  args 00000004 00000005 00000000 f010fede f010ffdf
eip f01001e3  ebp f010feb8  args 00000005 00000400 fffffc00 f010ffde 00000000
eip f010003e  ebp f010fff8  args 00111021 00000000 00000000 00000000 00000000
Backtrace success
leaving test_backtrace 0
leaving test_backtrace 1
leaving test_backtrace 2
leaving test_backtrace 3
leaving test_backtrace 4
leaving test_backtrace 5
