
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 60 1e 10 f0 	movl   $0xf0101e60,(%esp)
f0100055:	e8 cf 0c 00 00       	call   f0100d29 <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 e3 08 00 00       	call   f010096a <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 7c 1e 10 f0 	movl   $0xf0101e7c,(%esp)
f0100092:	e8 92 0c 00 00       	call   f0100d29 <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	57                   	push   %edi
f01000a1:	56                   	push   %esi
f01000a2:	53                   	push   %ebx
f01000a3:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
	extern char edata[], end[];
   	// Lab1 only
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f01000a9:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f01000ad:	c6 45 e6 00          	movb   $0x0,-0x1a(%ebp)
f01000b1:	66 c7 85 e6 fe ff ff 	movw   $0x0,-0x11a(%ebp)
f01000b8:	00 00 
f01000ba:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f01000c0:	bb fe 00 00 00       	mov    $0xfe,%ebx
f01000c5:	89 d9                	mov    %ebx,%ecx
f01000c7:	c1 e9 02             	shr    $0x2,%ecx
f01000ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01000cf:	f3 ab                	rep stos %eax,%es:(%edi)
f01000d1:	f6 c3 02             	test   $0x2,%bl
f01000d4:	74 08                	je     f01000de <i386_init+0x41>
f01000d6:	66 c7 07 00 00       	movw   $0x0,(%edi)
f01000db:	83 c7 02             	add    $0x2,%edi
f01000de:	83 e3 01             	and    $0x1,%ebx
f01000e1:	85 db                	test   %ebx,%ebx
f01000e3:	74 03                	je     f01000e8 <i386_init+0x4b>
f01000e5:	c6 07 00             	movb   $0x0,(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000e8:	b8 40 39 11 f0       	mov    $0xf0113940,%eax
f01000ed:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f01000f2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000fd:	00 
f01000fe:	c7 04 24 00 33 11 f0 	movl   $0xf0113300,(%esp)
f0100105:	e8 ad 18 00 00       	call   f01019b7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010a:	e8 60 05 00 00       	call   f010066f <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f010010f:	8d 45 e6             	lea    -0x1a(%ebp),%eax
f0100112:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100116:	8d 75 e7             	lea    -0x19(%ebp),%esi
f0100119:	89 74 24 08          	mov    %esi,0x8(%esp)
f010011d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100124:	00 
f0100125:	c7 04 24 10 1f 10 f0 	movl   $0xf0101f10,(%esp)
f010012c:	e8 f8 0b 00 00       	call   f0100d29 <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f0100131:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
f0100138:	00 
f0100139:	c7 04 24 30 1f 10 f0 	movl   $0xf0101f30,(%esp)
f0100140:	e8 e4 0b 00 00       	call   f0100d29 <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f0100145:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f0100149:	89 44 24 08          	mov    %eax,0x8(%esp)
f010014d:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0100151:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100155:	c7 04 24 97 1e 10 f0 	movl   $0xf0101e97,(%esp)
f010015c:	e8 c8 0b 00 00       	call   f0100d29 <cprintf>
	cprintf("%n", NULL);
f0100161:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100168:	00 
f0100169:	c7 04 24 b0 1e 10 f0 	movl   $0xf0101eb0,(%esp)
f0100170:	e8 b4 0b 00 00       	call   f0100d29 <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100175:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f010017c:	00 
f010017d:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f0100184:	00 
f0100185:	8d 9d e6 fe ff ff    	lea    -0x11a(%ebp),%ebx
f010018b:	89 1c 24             	mov    %ebx,(%esp)
f010018e:	e8 24 18 00 00       	call   f01019b7 <memset>
	cprintf("%s%n", ntest, &chnum1); 
f0100193:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100197:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010019b:	c7 04 24 ae 1e 10 f0 	movl   $0xf0101eae,(%esp)
f01001a2:	e8 82 0b 00 00       	call   f0100d29 <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f01001a7:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f01001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01001af:	c7 04 24 b3 1e 10 f0 	movl   $0xf0101eb3,(%esp)
f01001b6:	e8 6e 0b 00 00       	call   f0100d29 <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f01001bb:	c7 44 24 08 00 fc ff 	movl   $0xfffffc00,0x8(%esp)
f01001c2:	ff 
f01001c3:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f01001ca:	00 
f01001cb:	c7 04 24 bf 1e 10 f0 	movl   $0xf0101ebf,(%esp)
f01001d2:	e8 52 0b 00 00       	call   f0100d29 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01001d7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01001de:	e8 5d fe ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01001e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01001ea:	e8 7b 09 00 00       	call   f0100b6a <monitor>
f01001ef:	eb f2                	jmp    f01001e3 <i386_init+0x146>

f01001f1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01001f1:	55                   	push   %ebp
f01001f2:	89 e5                	mov    %esp,%ebp
f01001f4:	56                   	push   %esi
f01001f5:	53                   	push   %ebx
f01001f6:	83 ec 10             	sub    $0x10,%esp
f01001f9:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01001fc:	83 3d 44 39 11 f0 00 	cmpl   $0x0,0xf0113944
f0100203:	75 3d                	jne    f0100242 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100205:	89 35 44 39 11 f0    	mov    %esi,0xf0113944

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010020b:	fa                   	cli    
f010020c:	fc                   	cld    

	va_start(ap, fmt);
f010020d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100210:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100213:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100217:	8b 45 08             	mov    0x8(%ebp),%eax
f010021a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010021e:	c7 04 24 db 1e 10 f0 	movl   $0xf0101edb,(%esp)
f0100225:	e8 ff 0a 00 00       	call   f0100d29 <cprintf>
	vcprintf(fmt, ap);
f010022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010022e:	89 34 24             	mov    %esi,(%esp)
f0100231:	e8 c0 0a 00 00       	call   f0100cf6 <vcprintf>
	cprintf("\n");
f0100236:	c7 04 24 69 1f 10 f0 	movl   $0xf0101f69,(%esp)
f010023d:	e8 e7 0a 00 00       	call   f0100d29 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100242:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100249:	e8 1c 09 00 00       	call   f0100b6a <monitor>
f010024e:	eb f2                	jmp    f0100242 <_panic+0x51>

f0100250 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100250:	55                   	push   %ebp
f0100251:	89 e5                	mov    %esp,%ebp
f0100253:	53                   	push   %ebx
f0100254:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100257:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010025a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010025d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100261:	8b 45 08             	mov    0x8(%ebp),%eax
f0100264:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100268:	c7 04 24 f3 1e 10 f0 	movl   $0xf0101ef3,(%esp)
f010026f:	e8 b5 0a 00 00       	call   f0100d29 <cprintf>
	vcprintf(fmt, ap);
f0100274:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100278:	8b 45 10             	mov    0x10(%ebp),%eax
f010027b:	89 04 24             	mov    %eax,(%esp)
f010027e:	e8 73 0a 00 00       	call   f0100cf6 <vcprintf>
	cprintf("\n");
f0100283:	c7 04 24 69 1f 10 f0 	movl   $0xf0101f69,(%esp)
f010028a:	e8 9a 0a 00 00       	call   f0100d29 <cprintf>
	va_end(ap);
}
f010028f:	83 c4 14             	add    $0x14,%esp
f0100292:	5b                   	pop    %ebx
f0100293:	5d                   	pop    %ebp
f0100294:	c3                   	ret    
f0100295:	66 90                	xchg   %ax,%ax
f0100297:	66 90                	xchg   %ax,%ax
f0100299:	66 90                	xchg   %ax,%ax
f010029b:	66 90                	xchg   %ax,%ax
f010029d:	66 90                	xchg   %ax,%ax
f010029f:	90                   	nop

f01002a0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002a0:	55                   	push   %ebp
f01002a1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002a8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002a9:	a8 01                	test   $0x1,%al
f01002ab:	74 08                	je     f01002b5 <serial_proc_data+0x15>
f01002ad:	b2 f8                	mov    $0xf8,%dl
f01002af:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002b0:	0f b6 c0             	movzbl %al,%eax
f01002b3:	eb 05                	jmp    f01002ba <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002ba:	5d                   	pop    %ebp
f01002bb:	c3                   	ret    

f01002bc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 04             	sub    $0x4,%esp
f01002c3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002c5:	eb 2a                	jmp    f01002f1 <cons_intr+0x35>
		if (c == 0)
f01002c7:	85 d2                	test   %edx,%edx
f01002c9:	74 26                	je     f01002f1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002cb:	a1 24 35 11 f0       	mov    0xf0113524,%eax
f01002d0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002d3:	89 0d 24 35 11 f0    	mov    %ecx,0xf0113524
f01002d9:	88 90 20 33 11 f0    	mov    %dl,-0xfeecce0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002df:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01002e5:	75 0a                	jne    f01002f1 <cons_intr+0x35>
			cons.wpos = 0;
f01002e7:	c7 05 24 35 11 f0 00 	movl   $0x0,0xf0113524
f01002ee:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002f1:	ff d3                	call   *%ebx
f01002f3:	89 c2                	mov    %eax,%edx
f01002f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f8:	75 cd                	jne    f01002c7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002fa:	83 c4 04             	add    $0x4,%esp
f01002fd:	5b                   	pop    %ebx
f01002fe:	5d                   	pop    %ebp
f01002ff:	c3                   	ret    

f0100300 <kbd_proc_data>:
f0100300:	ba 64 00 00 00       	mov    $0x64,%edx
f0100305:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100306:	a8 01                	test   $0x1,%al
f0100308:	0f 84 f7 00 00 00    	je     f0100405 <kbd_proc_data+0x105>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010030e:	a8 20                	test   $0x20,%al
f0100310:	0f 85 f5 00 00 00    	jne    f010040b <kbd_proc_data+0x10b>
f0100316:	b2 60                	mov    $0x60,%dl
f0100318:	ec                   	in     (%dx),%al
f0100319:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010031b:	3c e0                	cmp    $0xe0,%al
f010031d:	75 0d                	jne    f010032c <kbd_proc_data+0x2c>
		// E0 escape character
		shift |= E0ESC;
f010031f:	83 0d 00 33 11 f0 40 	orl    $0x40,0xf0113300
		return 0;
f0100326:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010032b:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010032c:	55                   	push   %ebp
f010032d:	89 e5                	mov    %esp,%ebp
f010032f:	53                   	push   %ebx
f0100330:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100333:	84 c0                	test   %al,%al
f0100335:	79 37                	jns    f010036e <kbd_proc_data+0x6e>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100337:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f010033d:	89 cb                	mov    %ecx,%ebx
f010033f:	83 e3 40             	and    $0x40,%ebx
f0100342:	83 e0 7f             	and    $0x7f,%eax
f0100345:	85 db                	test   %ebx,%ebx
f0100347:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010034a:	0f b6 d2             	movzbl %dl,%edx
f010034d:	0f b6 82 c0 20 10 f0 	movzbl -0xfefdf40(%edx),%eax
f0100354:	83 c8 40             	or     $0x40,%eax
f0100357:	0f b6 c0             	movzbl %al,%eax
f010035a:	f7 d0                	not    %eax
f010035c:	21 c1                	and    %eax,%ecx
f010035e:	89 0d 00 33 11 f0    	mov    %ecx,0xf0113300
		return 0;
f0100364:	b8 00 00 00 00       	mov    $0x0,%eax
f0100369:	e9 a3 00 00 00       	jmp    f0100411 <kbd_proc_data+0x111>
	} else if (shift & E0ESC) {
f010036e:	8b 0d 00 33 11 f0    	mov    0xf0113300,%ecx
f0100374:	f6 c1 40             	test   $0x40,%cl
f0100377:	74 0e                	je     f0100387 <kbd_proc_data+0x87>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100379:	83 c8 80             	or     $0xffffff80,%eax
f010037c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010037e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100381:	89 0d 00 33 11 f0    	mov    %ecx,0xf0113300
	}

	shift |= shiftcode[data];
f0100387:	0f b6 d2             	movzbl %dl,%edx
f010038a:	0f b6 82 c0 20 10 f0 	movzbl -0xfefdf40(%edx),%eax
f0100391:	0b 05 00 33 11 f0    	or     0xf0113300,%eax
	shift ^= togglecode[data];
f0100397:	0f b6 8a c0 1f 10 f0 	movzbl -0xfefe040(%edx),%ecx
f010039e:	31 c8                	xor    %ecx,%eax
f01003a0:	a3 00 33 11 f0       	mov    %eax,0xf0113300

	c = charcode[shift & (CTL | SHIFT)][data];
f01003a5:	89 c1                	mov    %eax,%ecx
f01003a7:	83 e1 03             	and    $0x3,%ecx
f01003aa:	8b 0c 8d a0 1f 10 f0 	mov    -0xfefe060(,%ecx,4),%ecx
f01003b1:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003b5:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003b8:	a8 08                	test   $0x8,%al
f01003ba:	74 1b                	je     f01003d7 <kbd_proc_data+0xd7>
		if ('a' <= c && c <= 'z')
f01003bc:	89 da                	mov    %ebx,%edx
f01003be:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003c1:	83 f9 19             	cmp    $0x19,%ecx
f01003c4:	77 05                	ja     f01003cb <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f01003c6:	83 eb 20             	sub    $0x20,%ebx
f01003c9:	eb 0c                	jmp    f01003d7 <kbd_proc_data+0xd7>
		else if ('A' <= c && c <= 'Z')
f01003cb:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ce:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003d1:	83 fa 19             	cmp    $0x19,%edx
f01003d4:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003d7:	f7 d0                	not    %eax
f01003d9:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003db:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003dd:	f6 c2 06             	test   $0x6,%dl
f01003e0:	75 2f                	jne    f0100411 <kbd_proc_data+0x111>
f01003e2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003e8:	75 27                	jne    f0100411 <kbd_proc_data+0x111>
		cprintf("Rebooting!\n");
f01003ea:	c7 04 24 5f 1f 10 f0 	movl   $0xf0101f5f,(%esp)
f01003f1:	e8 33 09 00 00       	call   f0100d29 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003fb:	b8 03 00 00 00       	mov    $0x3,%eax
f0100400:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100401:	89 d8                	mov    %ebx,%eax
f0100403:	eb 0c                	jmp    f0100411 <kbd_proc_data+0x111>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100405:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010040a:	c3                   	ret    
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010040b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100410:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100411:	83 c4 14             	add    $0x14,%esp
f0100414:	5b                   	pop    %ebx
f0100415:	5d                   	pop    %ebp
f0100416:	c3                   	ret    

f0100417 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100417:	55                   	push   %ebp
f0100418:	89 e5                	mov    %esp,%ebp
f010041a:	57                   	push   %edi
f010041b:	56                   	push   %esi
f010041c:	53                   	push   %ebx
f010041d:	83 ec 1c             	sub    $0x1c,%esp
f0100420:	89 c7                	mov    %eax,%edi
f0100422:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100427:	be fd 03 00 00       	mov    $0x3fd,%esi
f010042c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100431:	eb 06                	jmp    f0100439 <cons_putc+0x22>
f0100433:	89 ca                	mov    %ecx,%edx
f0100435:	ec                   	in     (%dx),%al
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	89 f2                	mov    %esi,%edx
f010043b:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010043c:	a8 20                	test   $0x20,%al
f010043e:	75 05                	jne    f0100445 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100440:	83 eb 01             	sub    $0x1,%ebx
f0100443:	75 ee                	jne    f0100433 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100445:	89 f8                	mov    %edi,%eax
f0100447:	0f b6 c0             	movzbl %al,%eax
f010044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100452:	ee                   	out    %al,(%dx)
f0100453:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100458:	be 79 03 00 00       	mov    $0x379,%esi
f010045d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100462:	eb 06                	jmp    f010046a <cons_putc+0x53>
f0100464:	89 ca                	mov    %ecx,%edx
f0100466:	ec                   	in     (%dx),%al
f0100467:	ec                   	in     (%dx),%al
f0100468:	ec                   	in     (%dx),%al
f0100469:	ec                   	in     (%dx),%al
f010046a:	89 f2                	mov    %esi,%edx
f010046c:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010046d:	84 c0                	test   %al,%al
f010046f:	78 05                	js     f0100476 <cons_putc+0x5f>
f0100471:	83 eb 01             	sub    $0x1,%ebx
f0100474:	75 ee                	jne    f0100464 <cons_putc+0x4d>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100476:	ba 78 03 00 00       	mov    $0x378,%edx
f010047b:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010047f:	ee                   	out    %al,(%dx)
f0100480:	b2 7a                	mov    $0x7a,%dl
f0100482:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100487:	ee                   	out    %al,(%dx)
f0100488:	b8 08 00 00 00       	mov    $0x8,%eax
f010048d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010048e:	89 fa                	mov    %edi,%edx
f0100490:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100496:	89 f8                	mov    %edi,%eax
f0100498:	80 cc 07             	or     $0x7,%ah
f010049b:	85 d2                	test   %edx,%edx
f010049d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004a0:	89 f8                	mov    %edi,%eax
f01004a2:	0f b6 c0             	movzbl %al,%eax
f01004a5:	83 f8 09             	cmp    $0x9,%eax
f01004a8:	74 78                	je     f0100522 <cons_putc+0x10b>
f01004aa:	83 f8 09             	cmp    $0x9,%eax
f01004ad:	7f 0a                	jg     f01004b9 <cons_putc+0xa2>
f01004af:	83 f8 08             	cmp    $0x8,%eax
f01004b2:	74 18                	je     f01004cc <cons_putc+0xb5>
f01004b4:	e9 9d 00 00 00       	jmp    f0100556 <cons_putc+0x13f>
f01004b9:	83 f8 0a             	cmp    $0xa,%eax
f01004bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004c0:	74 3a                	je     f01004fc <cons_putc+0xe5>
f01004c2:	83 f8 0d             	cmp    $0xd,%eax
f01004c5:	74 3d                	je     f0100504 <cons_putc+0xed>
f01004c7:	e9 8a 00 00 00       	jmp    f0100556 <cons_putc+0x13f>
	case '\b':
		if (crt_pos > 0) {
f01004cc:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f01004d3:	66 85 c0             	test   %ax,%ax
f01004d6:	0f 84 e5 00 00 00    	je     f01005c1 <cons_putc+0x1aa>
			crt_pos--;
f01004dc:	83 e8 01             	sub    $0x1,%eax
f01004df:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e5:	0f b7 c0             	movzwl %ax,%eax
f01004e8:	66 81 e7 00 ff       	and    $0xff00,%di
f01004ed:	83 cf 20             	or     $0x20,%edi
f01004f0:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f01004f6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004fa:	eb 78                	jmp    f0100574 <cons_putc+0x15d>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004fc:	66 83 05 28 35 11 f0 	addw   $0x50,0xf0113528
f0100503:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100504:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f010050b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100511:	c1 e8 16             	shr    $0x16,%eax
f0100514:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100517:	c1 e0 04             	shl    $0x4,%eax
f010051a:	66 a3 28 35 11 f0    	mov    %ax,0xf0113528
f0100520:	eb 52                	jmp    f0100574 <cons_putc+0x15d>
		break;
	case '\t':
		cons_putc(' ');
f0100522:	b8 20 00 00 00       	mov    $0x20,%eax
f0100527:	e8 eb fe ff ff       	call   f0100417 <cons_putc>
		cons_putc(' ');
f010052c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100531:	e8 e1 fe ff ff       	call   f0100417 <cons_putc>
		cons_putc(' ');
f0100536:	b8 20 00 00 00       	mov    $0x20,%eax
f010053b:	e8 d7 fe ff ff       	call   f0100417 <cons_putc>
		cons_putc(' ');
f0100540:	b8 20 00 00 00       	mov    $0x20,%eax
f0100545:	e8 cd fe ff ff       	call   f0100417 <cons_putc>
		cons_putc(' ');
f010054a:	b8 20 00 00 00       	mov    $0x20,%eax
f010054f:	e8 c3 fe ff ff       	call   f0100417 <cons_putc>
f0100554:	eb 1e                	jmp    f0100574 <cons_putc+0x15d>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100556:	0f b7 05 28 35 11 f0 	movzwl 0xf0113528,%eax
f010055d:	8d 50 01             	lea    0x1(%eax),%edx
f0100560:	66 89 15 28 35 11 f0 	mov    %dx,0xf0113528
f0100567:	0f b7 c0             	movzwl %ax,%eax
f010056a:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
f0100570:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100574:	66 81 3d 28 35 11 f0 	cmpw   $0x7cf,0xf0113528
f010057b:	cf 07 
f010057d:	76 42                	jbe    f01005c1 <cons_putc+0x1aa>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010057f:	a1 2c 35 11 f0       	mov    0xf011352c,%eax
f0100584:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010058b:	00 
f010058c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100592:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100596:	89 04 24             	mov    %eax,(%esp)
f0100599:	e8 66 14 00 00       	call   f0101a04 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010059e:	8b 15 2c 35 11 f0    	mov    0xf011352c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005a9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005af:	83 c0 01             	add    $0x1,%eax
f01005b2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005b7:	75 f0                	jne    f01005a9 <cons_putc+0x192>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005b9:	66 83 2d 28 35 11 f0 	subw   $0x50,0xf0113528
f01005c0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005c1:	8b 0d 30 35 11 f0    	mov    0xf0113530,%ecx
f01005c7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005cc:	89 ca                	mov    %ecx,%edx
f01005ce:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005cf:	0f b7 1d 28 35 11 f0 	movzwl 0xf0113528,%ebx
f01005d6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005d9:	89 d8                	mov    %ebx,%eax
f01005db:	66 c1 e8 08          	shr    $0x8,%ax
f01005df:	89 f2                	mov    %esi,%edx
f01005e1:	ee                   	out    %al,(%dx)
f01005e2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005e7:	89 ca                	mov    %ecx,%edx
f01005e9:	ee                   	out    %al,(%dx)
f01005ea:	89 d8                	mov    %ebx,%eax
f01005ec:	89 f2                	mov    %esi,%edx
f01005ee:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005ef:	83 c4 1c             	add    $0x1c,%esp
f01005f2:	5b                   	pop    %ebx
f01005f3:	5e                   	pop    %esi
f01005f4:	5f                   	pop    %edi
f01005f5:	5d                   	pop    %ebp
f01005f6:	c3                   	ret    

f01005f7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005f7:	80 3d 34 35 11 f0 00 	cmpb   $0x0,0xf0113534
f01005fe:	74 11                	je     f0100611 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100606:	b8 a0 02 10 f0       	mov    $0xf01002a0,%eax
f010060b:	e8 ac fc ff ff       	call   f01002bc <cons_intr>
}
f0100610:	c9                   	leave  
f0100611:	f3 c3                	repz ret 

f0100613 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100613:	55                   	push   %ebp
f0100614:	89 e5                	mov    %esp,%ebp
f0100616:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100619:	b8 00 03 10 f0       	mov    $0xf0100300,%eax
f010061e:	e8 99 fc ff ff       	call   f01002bc <cons_intr>
}
f0100623:	c9                   	leave  
f0100624:	c3                   	ret    

f0100625 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010062b:	e8 c7 ff ff ff       	call   f01005f7 <serial_intr>
	kbd_intr();
f0100630:	e8 de ff ff ff       	call   f0100613 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100635:	a1 20 35 11 f0       	mov    0xf0113520,%eax
f010063a:	3b 05 24 35 11 f0    	cmp    0xf0113524,%eax
f0100640:	74 26                	je     f0100668 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100642:	8d 50 01             	lea    0x1(%eax),%edx
f0100645:	89 15 20 35 11 f0    	mov    %edx,0xf0113520
f010064b:	0f b6 88 20 33 11 f0 	movzbl -0xfeecce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100652:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100654:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010065a:	75 11                	jne    f010066d <cons_getc+0x48>
			cons.rpos = 0;
f010065c:	c7 05 20 35 11 f0 00 	movl   $0x0,0xf0113520
f0100663:	00 00 00 
f0100666:	eb 05                	jmp    f010066d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100668:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010066d:	c9                   	leave  
f010066e:	c3                   	ret    

f010066f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010066f:	55                   	push   %ebp
f0100670:	89 e5                	mov    %esp,%ebp
f0100672:	57                   	push   %edi
f0100673:	56                   	push   %esi
f0100674:	53                   	push   %ebx
f0100675:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100678:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010067f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100686:	5a a5 
	if (*cp != 0xA55A) {
f0100688:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010068f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100693:	74 11                	je     f01006a6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100695:	c7 05 30 35 11 f0 b4 	movl   $0x3b4,0xf0113530
f010069c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006a4:	eb 16                	jmp    f01006bc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006a6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006ad:	c7 05 30 35 11 f0 d4 	movl   $0x3d4,0xf0113530
f01006b4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006bc:	8b 0d 30 35 11 f0    	mov    0xf0113530,%ecx
f01006c2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c7:	89 ca                	mov    %ecx,%edx
f01006c9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ca:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006cd:	89 da                	mov    %ebx,%edx
f01006cf:	ec                   	in     (%dx),%al
f01006d0:	0f b6 f0             	movzbl %al,%esi
f01006d3:	c1 e6 08             	shl    $0x8,%esi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006db:	89 ca                	mov    %ecx,%edx
f01006dd:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006de:	89 da                	mov    %ebx,%edx
f01006e0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006e1:	89 3d 2c 35 11 f0    	mov    %edi,0xf011352c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006e7:	0f b6 d8             	movzbl %al,%ebx
f01006ea:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006ec:	66 89 35 28 35 11 f0 	mov    %si,0xf0113528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fd:	89 f2                	mov    %esi,%edx
f01006ff:	ee                   	out    %al,(%dx)
f0100700:	b2 fb                	mov    $0xfb,%dl
f0100702:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100707:	ee                   	out    %al,(%dx)
f0100708:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010070d:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100712:	89 da                	mov    %ebx,%edx
f0100714:	ee                   	out    %al,(%dx)
f0100715:	b2 f9                	mov    $0xf9,%dl
f0100717:	b8 00 00 00 00       	mov    $0x0,%eax
f010071c:	ee                   	out    %al,(%dx)
f010071d:	b2 fb                	mov    $0xfb,%dl
f010071f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100724:	ee                   	out    %al,(%dx)
f0100725:	b2 fc                	mov    $0xfc,%dl
f0100727:	b8 00 00 00 00       	mov    $0x0,%eax
f010072c:	ee                   	out    %al,(%dx)
f010072d:	b2 f9                	mov    $0xf9,%dl
f010072f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100734:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100735:	b2 fd                	mov    $0xfd,%dl
f0100737:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100738:	3c ff                	cmp    $0xff,%al
f010073a:	0f 95 c1             	setne  %cl
f010073d:	88 0d 34 35 11 f0    	mov    %cl,0xf0113534
f0100743:	89 f2                	mov    %esi,%edx
f0100745:	ec                   	in     (%dx),%al
f0100746:	89 da                	mov    %ebx,%edx
f0100748:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100749:	84 c9                	test   %cl,%cl
f010074b:	75 0c                	jne    f0100759 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f010074d:	c7 04 24 6b 1f 10 f0 	movl   $0xf0101f6b,(%esp)
f0100754:	e8 d0 05 00 00       	call   f0100d29 <cprintf>
}
f0100759:	83 c4 1c             	add    $0x1c,%esp
f010075c:	5b                   	pop    %ebx
f010075d:	5e                   	pop    %esi
f010075e:	5f                   	pop    %edi
f010075f:	5d                   	pop    %ebp
f0100760:	c3                   	ret    

f0100761 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100761:	55                   	push   %ebp
f0100762:	89 e5                	mov    %esp,%ebp
f0100764:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100767:	8b 45 08             	mov    0x8(%ebp),%eax
f010076a:	e8 a8 fc ff ff       	call   f0100417 <cons_putc>
}
f010076f:	c9                   	leave  
f0100770:	c3                   	ret    

f0100771 <getchar>:

int
getchar(void)
{
f0100771:	55                   	push   %ebp
f0100772:	89 e5                	mov    %esp,%ebp
f0100774:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100777:	e8 a9 fe ff ff       	call   f0100625 <cons_getc>
f010077c:	85 c0                	test   %eax,%eax
f010077e:	74 f7                	je     f0100777 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100780:	c9                   	leave  
f0100781:	c3                   	ret    

f0100782 <iscons>:

int
iscons(int fdnum)
{
f0100782:	55                   	push   %ebp
f0100783:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100785:	b8 01 00 00 00       	mov    $0x1,%eax
f010078a:	5d                   	pop    %ebp
f010078b:	c3                   	ret    
f010078c:	66 90                	xchg   %ax,%ax
f010078e:	66 90                	xchg   %ax,%ax

f0100790 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100790:	55                   	push   %ebp
f0100791:	89 e5                	mov    %esp,%ebp
f0100793:	56                   	push   %esi
f0100794:	53                   	push   %ebx
f0100795:	83 ec 10             	sub    $0x10,%esp
f0100798:	bb a4 24 10 f0       	mov    $0xf01024a4,%ebx
f010079d:	be d4 24 10 f0       	mov    $0xf01024d4,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007a2:	8b 03                	mov    (%ebx),%eax
f01007a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007a8:	8b 43 fc             	mov    -0x4(%ebx),%eax
f01007ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007af:	c7 04 24 c0 21 10 f0 	movl   $0xf01021c0,(%esp)
f01007b6:	e8 6e 05 00 00       	call   f0100d29 <cprintf>
f01007bb:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01007be:	39 f3                	cmp    %esi,%ebx
f01007c0:	75 e0                	jne    f01007a2 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01007c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c7:	83 c4 10             	add    $0x10,%esp
f01007ca:	5b                   	pop    %ebx
f01007cb:	5e                   	pop    %esi
f01007cc:	5d                   	pop    %ebp
f01007cd:	c3                   	ret    

f01007ce <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007ce:	55                   	push   %ebp
f01007cf:	89 e5                	mov    %esp,%ebp
f01007d1:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d4:	c7 04 24 c9 21 10 f0 	movl   $0xf01021c9,(%esp)
f01007db:	e8 49 05 00 00       	call   f0100d29 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e0:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007e7:	00 
f01007e8:	c7 04 24 50 23 10 f0 	movl   $0xf0102350,(%esp)
f01007ef:	e8 35 05 00 00       	call   f0100d29 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f4:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007fb:	00 
f01007fc:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100803:	f0 
f0100804:	c7 04 24 78 23 10 f0 	movl   $0xf0102378,(%esp)
f010080b:	e8 19 05 00 00       	call   f0100d29 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100810:	c7 44 24 08 47 1e 10 	movl   $0x101e47,0x8(%esp)
f0100817:	00 
f0100818:	c7 44 24 04 47 1e 10 	movl   $0xf0101e47,0x4(%esp)
f010081f:	f0 
f0100820:	c7 04 24 9c 23 10 f0 	movl   $0xf010239c,(%esp)
f0100827:	e8 fd 04 00 00       	call   f0100d29 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082c:	c7 44 24 08 00 33 11 	movl   $0x113300,0x8(%esp)
f0100833:	00 
f0100834:	c7 44 24 04 00 33 11 	movl   $0xf0113300,0x4(%esp)
f010083b:	f0 
f010083c:	c7 04 24 c0 23 10 f0 	movl   $0xf01023c0,(%esp)
f0100843:	e8 e1 04 00 00       	call   f0100d29 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100848:	c7 44 24 08 40 39 11 	movl   $0x113940,0x8(%esp)
f010084f:	00 
f0100850:	c7 44 24 04 40 39 11 	movl   $0xf0113940,0x4(%esp)
f0100857:	f0 
f0100858:	c7 04 24 e4 23 10 f0 	movl   $0xf01023e4,(%esp)
f010085f:	e8 c5 04 00 00       	call   f0100d29 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100864:	b8 3f 3d 11 f0       	mov    $0xf0113d3f,%eax
f0100869:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010086e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100873:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100879:	85 c0                	test   %eax,%eax
f010087b:	0f 48 c2             	cmovs  %edx,%eax
f010087e:	c1 f8 0a             	sar    $0xa,%eax
f0100881:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100885:	c7 04 24 08 24 10 f0 	movl   $0xf0102408,(%esp)
f010088c:	e8 98 04 00 00       	call   f0100d29 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100891:	b8 00 00 00 00       	mov    $0x0,%eax
f0100896:	c9                   	leave  
f0100897:	c3                   	ret    

f0100898 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f0100898:	55                   	push   %ebp
f0100899:	89 e5                	mov    %esp,%ebp
f010089b:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f010089e:	c7 04 24 e2 21 10 f0 	movl   $0xf01021e2,(%esp)
f01008a5:	e8 7f 04 00 00       	call   f0100d29 <cprintf>
}
f01008aa:	c9                   	leave  
f01008ab:	c3                   	ret    

f01008ac <mon_time>:
	str[ret_byte_2] = 'h';
	str[ret_byte_3] = '\0';
	cprintf("%s%n\n", str, pret_addr+3);
}
int mon_time(int argc, char **argv, struct Trapframe *tf)
{
f01008ac:	55                   	push   %ebp
f01008ad:	89 e5                	mov    %esp,%ebp
f01008af:	57                   	push   %edi
f01008b0:	56                   	push   %esi
f01008b1:	53                   	push   %ebx
f01008b2:	83 ec 2c             	sub    $0x2c,%esp
	if (argc != 2)
f01008b5:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01008b9:	0f 85 8e 00 00 00    	jne    f010094d <mon_time+0xa1>
f01008bf:	be a0 24 10 f0       	mov    $0xf01024a0,%esi
f01008c4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01008c9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i;
	struct Command command;
	/* search */
    
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(commands[i].name, argv[1]) == 0) {
f01008cc:	8b 47 04             	mov    0x4(%edi),%eax
f01008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d3:	8b 06                	mov    (%esi),%eax
f01008d5:	89 04 24             	mov    %eax,(%esp)
f01008d8:	e8 3f 10 00 00       	call   f010191c <strcmp>
f01008dd:	85 c0                	test   %eax,%eax
f01008df:	74 0d                	je     f01008ee <mon_time+0x42>
	uint64_t before, after;
	int i;
	struct Command command;
	/* search */
    
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008e1:	83 c3 01             	add    $0x1,%ebx
f01008e4:	83 c6 0c             	add    $0xc,%esi
f01008e7:	83 fb 04             	cmp    $0x4,%ebx
f01008ea:	75 e0                	jne    f01008cc <mon_time+0x20>
f01008ec:	eb 66                	jmp    f0100954 <mon_time+0xa8>
f01008ee:	89 c7                	mov    %eax,%edi
		if (strcmp(commands[i].name, argv[1]) == 0) {
				break;
		}
	}

	if (i == ARRAY_SIZE(commands))
f01008f0:	83 fb 04             	cmp    $0x4,%ebx
f01008f3:	74 66                	je     f010095b <mon_time+0xaf>

static inline uint64_t
read_tsc(void)
{
	uint64_t tsc;
	asm volatile("rdtsc" : "=A" (tsc));
f01008f5:	0f 31                	rdtsc  
f01008f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01008fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		return -1;
	
	/* run */
	before = read_tsc();
	(commands[i].func)(1, argv+1, tf);
f01008fd:	8d 34 1b             	lea    (%ebx,%ebx,1),%esi
f0100900:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0100903:	8b 55 10             	mov    0x10(%ebp),%edx
f0100906:	89 54 24 08          	mov    %edx,0x8(%esp)
f010090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010090d:	8d 51 04             	lea    0x4(%ecx),%edx
f0100910:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100914:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010091b:	ff 14 85 a8 24 10 f0 	call   *-0xfefdb58(,%eax,4)
f0100922:	0f 31                	rdtsc  
	after = read_tsc();
	cprintf("%s cycles: %d\n", commands[i].name, after - before);
f0100924:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100927:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
f010092a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010092e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100932:	01 f3                	add    %esi,%ebx
f0100934:	8b 04 9d a0 24 10 f0 	mov    -0xfefdb60(,%ebx,4),%eax
f010093b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093f:	c7 04 24 f4 21 10 f0 	movl   $0xf01021f4,(%esp)
f0100946:	e8 de 03 00 00       	call   f0100d29 <cprintf>
	return 0;
f010094b:	eb 13                	jmp    f0100960 <mon_time+0xb4>
	cprintf("%s%n\n", str, pret_addr+3);
}
int mon_time(int argc, char **argv, struct Trapframe *tf)
{
	if (argc != 2)
		return -1;
f010094d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100952:	eb 0c                	jmp    f0100960 <mon_time+0xb4>
				break;
		}
	}

	if (i == ARRAY_SIZE(commands))
		return -1;
f0100954:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100959:	eb 05                	jmp    f0100960 <mon_time+0xb4>
f010095b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
	before = read_tsc();
	(commands[i].func)(1, argv+1, tf);
	after = read_tsc();
	cprintf("%s cycles: %d\n", commands[i].name, after - before);
	return 0;
}
f0100960:	89 f8                	mov    %edi,%eax
f0100962:	83 c4 2c             	add    $0x2c,%esp
f0100965:	5b                   	pop    %ebx
f0100966:	5e                   	pop    %esi
f0100967:	5f                   	pop    %edi
f0100968:	5d                   	pop    %ebp
f0100969:	c3                   	ret    

f010096a <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{	
f010096a:	55                   	push   %ebp
f010096b:	89 e5                	mov    %esp,%ebp
f010096d:	56                   	push   %esi
f010096e:	53                   	push   %ebx
f010096f:	83 ec 40             	sub    $0x40,%esp
	uint32_t *ebp = (unsigned int *)read_ebp();
f0100972:	89 eb                	mov    %ebp,%ebx
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f0100974:	c7 04 24 03 22 10 f0 	movl   $0xf0102203,(%esp)
f010097b:	e8 a9 03 00 00       	call   f0100d29 <cprintf>
	for (;ebp != NULL;) {
		cprintf("  eip %08x ebp %08x args %08x %08x %08x %08x %08x", 
			ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		debuginfo_eip(ebp[1], &info);
f0100980:	8d 75 e0             	lea    -0x20(%ebp),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{	
	uint32_t *ebp = (unsigned int *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	for (;ebp != NULL;) {
f0100983:	eb 7d                	jmp    f0100a02 <mon_backtrace+0x98>
		cprintf("  eip %08x ebp %08x args %08x %08x %08x %08x %08x", 
f0100985:	8b 43 18             	mov    0x18(%ebx),%eax
f0100988:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010098c:	8b 43 14             	mov    0x14(%ebx),%eax
f010098f:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100993:	8b 43 10             	mov    0x10(%ebx),%eax
f0100996:	89 44 24 14          	mov    %eax,0x14(%esp)
f010099a:	8b 43 0c             	mov    0xc(%ebx),%eax
f010099d:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009a1:	8b 43 08             	mov    0x8(%ebx),%eax
f01009a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01009ac:	8b 43 04             	mov    0x4(%ebx),%eax
f01009af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b3:	c7 04 24 34 24 10 f0 	movl   $0xf0102434,(%esp)
f01009ba:	e8 6a 03 00 00       	call   f0100d29 <cprintf>
			ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		debuginfo_eip(ebp[1], &info);
f01009bf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009c3:	8b 43 04             	mov    0x4(%ebx),%eax
f01009c6:	89 04 24             	mov    %eax,(%esp)
f01009c9:	e8 53 04 00 00       	call   f0100e21 <debuginfo_eip>
    cprintf("\n     %s:%d %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ebp[1] - info.eip_fn_addr);
f01009ce:	8b 43 04             	mov    0x4(%ebx),%eax
f01009d1:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01009d4:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01009db:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009df:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01009e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f4:	c7 04 24 15 22 10 f0 	movl   $0xf0102215,(%esp)
f01009fb:	e8 29 03 00 00       	call   f0100d29 <cprintf>
		ebp = (unsigned int *)(*ebp);
f0100a00:	8b 1b                	mov    (%ebx),%ebx
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{	
	uint32_t *ebp = (unsigned int *)read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	for (;ebp != NULL;) {
f0100a02:	85 db                	test   %ebx,%ebx
f0100a04:	0f 85 7b ff ff ff    	jne    f0100985 <mon_backtrace+0x1b>
		debuginfo_eip(ebp[1], &info);
    cprintf("\n     %s:%d %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ebp[1] - info.eip_fn_addr);
		ebp = (unsigned int *)(*ebp);
	}
	//overflow_me();
    	cprintf("Backtrace success\n");
f0100a0a:	c7 04 24 2a 22 10 f0 	movl   $0xf010222a,(%esp)
f0100a11:	e8 13 03 00 00       	call   f0100d29 <cprintf>
        cprintf("Overflow success\n");	
f0100a16:	c7 04 24 e2 21 10 f0 	movl   $0xf01021e2,(%esp)
f0100a1d:	e8 07 03 00 00       	call   f0100d29 <cprintf>
	return 0;
}
f0100a22:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a27:	83 c4 40             	add    $0x40,%esp
f0100a2a:	5b                   	pop    %ebx
f0100a2b:	5e                   	pop    %esi
f0100a2c:	5d                   	pop    %ebp
f0100a2d:	c3                   	ret    

f0100a2e <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f0100a2e:	55                   	push   %ebp
f0100a2f:	89 e5                	mov    %esp,%ebp
f0100a31:	57                   	push   %edi
f0100a32:	56                   	push   %esi
f0100a33:	53                   	push   %ebx
f0100a34:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
    char str[256] = {};
f0100a3a:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f0100a40:	b9 40 00 00 00       	mov    $0x40,%ecx
f0100a45:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a4a:	f3 ab                	rep stos %eax,%es:(%edi)
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f0100a4c:	8d 75 04             	lea    0x4(%ebp),%esi
    char *pret_addr;
    pret_addr = (char*)read_pretaddr(); // get eip pointer
	int i = 0;
	for (;i < 256; i++) {
		str[i] = 'h';
		if (i%2)
f0100a4f:	a8 01                	test   $0x1,%al
f0100a51:	75 0a                	jne    f0100a5d <start_overflow+0x2f>
    int nstr = 0;
    char *pret_addr;
    pret_addr = (char*)read_pretaddr(); // get eip pointer
	int i = 0;
	for (;i < 256; i++) {
		str[i] = 'h';
f0100a53:	c6 84 05 e8 fe ff ff 	movb   $0x68,-0x118(%ebp,%eax,1)
f0100a5a:	68 
f0100a5b:	eb 08                	jmp    f0100a65 <start_overflow+0x37>
		if (i%2)
			str[i] = 'a';
f0100a5d:	c6 84 05 e8 fe ff ff 	movb   $0x61,-0x118(%ebp,%eax,1)
f0100a64:	61 
    char str[256] = {};
    int nstr = 0;
    char *pret_addr;
    pret_addr = (char*)read_pretaddr(); // get eip pointer
	int i = 0;
	for (;i < 256; i++) {
f0100a65:	83 c0 01             	add    $0x1,%eax
f0100a68:	3d 00 01 00 00       	cmp    $0x100,%eax
f0100a6d:	75 e0                	jne    f0100a4f <start_overflow+0x21>
		if (i%2)
			str[i] = 'a';
	}
	void (*do_overflow_t)();
	do_overflow_t = do_overflow;
	uint32_t ret_addr = (uint32_t)do_overflow_t+3; // ignore stack asm code
f0100a6f:	bf 9b 08 10 f0       	mov    $0xf010089b,%edi
	
	uint32_t ret_byte_0 = ret_addr & 0xff;
f0100a74:	89 f8                	mov    %edi,%eax
f0100a76:	0f b6 c0             	movzbl %al,%eax
f0100a79:	89 c2                	mov    %eax,%edx
	uint32_t ret_byte_1 = (ret_addr >> 8) & 0xff;
f0100a7b:	89 f8                	mov    %edi,%eax
f0100a7d:	0f b6 c4             	movzbl %ah,%eax
f0100a80:	89 85 e4 fe ff ff    	mov    %eax,-0x11c(%ebp)
	uint32_t ret_byte_2 = (ret_addr >> 16) & 0xff;
f0100a86:	89 f9                	mov    %edi,%ecx
f0100a88:	c1 e9 10             	shr    $0x10,%ecx
f0100a8b:	0f b6 c9             	movzbl %cl,%ecx
f0100a8e:	89 8d e0 fe ff ff    	mov    %ecx,-0x120(%ebp)
	uint32_t ret_byte_3 = (ret_addr >> 24) & 0xff;
	str[ret_byte_0] = '\0';
f0100a94:	89 95 dc fe ff ff    	mov    %edx,-0x124(%ebp)
f0100a9a:	c6 84 15 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edx,1)
f0100aa1:	00 
	cprintf("%s%n\n", str, pret_addr);
f0100aa2:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100aa6:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
f0100aac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ab0:	c7 04 24 3d 22 10 f0 	movl   $0xf010223d,(%esp)
f0100ab7:	e8 6d 02 00 00       	call   f0100d29 <cprintf>
	str[ret_byte_0] = 'h';
f0100abc:	8b 85 dc fe ff ff    	mov    -0x124(%ebp),%eax
f0100ac2:	c6 84 05 e8 fe ff ff 	movb   $0x68,-0x118(%ebp,%eax,1)
f0100ac9:	68 
	str[ret_byte_1] = '\0';
f0100aca:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f0100ad0:	c6 84 05 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%eax,1)
f0100ad7:	00 
	cprintf("%s%n\n", str, pret_addr+1);
f0100ad8:	8d 46 01             	lea    0x1(%esi),%eax
f0100adb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100adf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ae3:	c7 04 24 3d 22 10 f0 	movl   $0xf010223d,(%esp)
f0100aea:	e8 3a 02 00 00       	call   f0100d29 <cprintf>
	str[ret_byte_1] = 'h';
f0100aef:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
f0100af5:	c6 84 05 e8 fe ff ff 	movb   $0x68,-0x118(%ebp,%eax,1)
f0100afc:	68 
	str[ret_byte_2] = '\0';
f0100afd:	8b 8d e0 fe ff ff    	mov    -0x120(%ebp),%ecx
f0100b03:	c6 84 0d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%ecx,1)
f0100b0a:	00 
	cprintf("%s%n\n", str, pret_addr+2);
f0100b0b:	8d 46 02             	lea    0x2(%esi),%eax
f0100b0e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b16:	c7 04 24 3d 22 10 f0 	movl   $0xf010223d,(%esp)
f0100b1d:	e8 07 02 00 00       	call   f0100d29 <cprintf>
	str[ret_byte_2] = 'h';
f0100b22:	8b 8d e0 fe ff ff    	mov    -0x120(%ebp),%ecx
f0100b28:	c6 84 0d e8 fe ff ff 	movb   $0x68,-0x118(%ebp,%ecx,1)
f0100b2f:	68 
	uint32_t ret_addr = (uint32_t)do_overflow_t+3; // ignore stack asm code
	
	uint32_t ret_byte_0 = ret_addr & 0xff;
	uint32_t ret_byte_1 = (ret_addr >> 8) & 0xff;
	uint32_t ret_byte_2 = (ret_addr >> 16) & 0xff;
	uint32_t ret_byte_3 = (ret_addr >> 24) & 0xff;
f0100b30:	c1 ef 18             	shr    $0x18,%edi
	cprintf("%s%n\n", str, pret_addr+1);
	str[ret_byte_1] = 'h';
	str[ret_byte_2] = '\0';
	cprintf("%s%n\n", str, pret_addr+2);
	str[ret_byte_2] = 'h';
	str[ret_byte_3] = '\0';
f0100b33:	c6 84 3d e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%edi,1)
f0100b3a:	00 
	cprintf("%s%n\n", str, pret_addr+3);
f0100b3b:	83 c6 03             	add    $0x3,%esi
f0100b3e:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100b42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b46:	c7 04 24 3d 22 10 f0 	movl   $0xf010223d,(%esp)
f0100b4d:	e8 d7 01 00 00       	call   f0100d29 <cprintf>
}
f0100b52:	81 c4 2c 01 00 00    	add    $0x12c,%esp
f0100b58:	5b                   	pop    %ebx
f0100b59:	5e                   	pop    %esi
f0100b5a:	5f                   	pop    %edi
f0100b5b:	5d                   	pop    %ebp
f0100b5c:	c3                   	ret    

f0100b5d <overflow_me>:
	cprintf("%s cycles: %d\n", commands[i].name, after - before);
	return 0;
}
void
overflow_me(void)
{
f0100b5d:	55                   	push   %ebp
f0100b5e:	89 e5                	mov    %esp,%ebp
f0100b60:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f0100b63:	e8 c6 fe ff ff       	call   f0100a2e <start_overflow>
}
f0100b68:	c9                   	leave  
f0100b69:	c3                   	ret    

f0100b6a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b6a:	55                   	push   %ebp
f0100b6b:	89 e5                	mov    %esp,%ebp
f0100b6d:	57                   	push   %edi
f0100b6e:	56                   	push   %esi
f0100b6f:	53                   	push   %ebx
f0100b70:	83 ec 5c             	sub    $0x5c,%esp
	
	unsigned int i = 0x00646c72;
    	cprintf("H%x Wo%s\n", 57616, &i);
	cprintf("x=%d y=%d\n", 3);
	int j=0;*/
	cprintf("测试八进制数+1024：%o\n",+1024);
f0100b73:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0100b7a:	00 
f0100b7b:	c7 04 24 43 22 10 f0 	movl   $0xf0102243,(%esp)
f0100b82:	e8 a2 01 00 00       	call   f0100d29 <cprintf>
	cprintf("测试八进制数-1024：%o\n",-1024);
f0100b87:	c7 44 24 04 00 fc ff 	movl   $0xfffffc00,0x4(%esp)
f0100b8e:	ff 
f0100b8f:	c7 04 24 61 22 10 f0 	movl   $0xf0102261,(%esp)
f0100b96:	e8 8e 01 00 00       	call   f0100d29 <cprintf>

	cprintf("测试八进制数+1024：%d\n",+1024);
f0100b9b:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0100ba2:	00 
f0100ba3:	c7 04 24 7f 22 10 f0 	movl   $0xf010227f,(%esp)
f0100baa:	e8 7a 01 00 00       	call   f0100d29 <cprintf>
        cprintf("测试八进制数-1024：%d\n",-1024);
f0100baf:	c7 44 24 04 00 fc ff 	movl   $0xfffffc00,0x4(%esp)
f0100bb6:	ff 
f0100bb7:	c7 04 24 9d 22 10 f0 	movl   $0xf010229d,(%esp)
f0100bbe:	e8 66 01 00 00       	call   f0100d29 <cprintf>
        /*char b;
	cprintf("%s%n\n","i'm Henry Fordham",&b);
	cprintf("上面那句话一共%d个字符\n",b);
	cprintf("test:[%-5d]\n", 3);*/
	while (1) {
		buf = readline("K> ");
f0100bc3:	c7 04 24 bb 22 10 f0 	movl   $0xf01022bb,(%esp)
f0100bca:	e8 91 0b 00 00       	call   f0101760 <readline>
f0100bcf:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100bd1:	85 c0                	test   %eax,%eax
f0100bd3:	74 ee                	je     f0100bc3 <monitor+0x59>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100bd5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100bdc:	be 00 00 00 00       	mov    $0x0,%esi
f0100be1:	eb 0a                	jmp    f0100bed <monitor+0x83>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100be3:	c6 03 00             	movb   $0x0,(%ebx)
f0100be6:	89 f7                	mov    %esi,%edi
f0100be8:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100beb:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100bed:	0f b6 03             	movzbl (%ebx),%eax
f0100bf0:	84 c0                	test   %al,%al
f0100bf2:	74 63                	je     f0100c57 <monitor+0xed>
f0100bf4:	0f be c0             	movsbl %al,%eax
f0100bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bfb:	c7 04 24 bf 22 10 f0 	movl   $0xf01022bf,(%esp)
f0100c02:	e8 73 0d 00 00       	call   f010197a <strchr>
f0100c07:	85 c0                	test   %eax,%eax
f0100c09:	75 d8                	jne    f0100be3 <monitor+0x79>
			*buf++ = 0;
		if (*buf == 0)
f0100c0b:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100c0e:	74 47                	je     f0100c57 <monitor+0xed>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100c10:	83 fe 0f             	cmp    $0xf,%esi
f0100c13:	75 16                	jne    f0100c2b <monitor+0xc1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100c15:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100c1c:	00 
f0100c1d:	c7 04 24 c4 22 10 f0 	movl   $0xf01022c4,(%esp)
f0100c24:	e8 00 01 00 00       	call   f0100d29 <cprintf>
f0100c29:	eb 98                	jmp    f0100bc3 <monitor+0x59>
			return 0;
		}
		argv[argc++] = buf;
f0100c2b:	8d 7e 01             	lea    0x1(%esi),%edi
f0100c2e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100c32:	eb 03                	jmp    f0100c37 <monitor+0xcd>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100c34:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c37:	0f b6 03             	movzbl (%ebx),%eax
f0100c3a:	84 c0                	test   %al,%al
f0100c3c:	74 ad                	je     f0100beb <monitor+0x81>
f0100c3e:	0f be c0             	movsbl %al,%eax
f0100c41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c45:	c7 04 24 bf 22 10 f0 	movl   $0xf01022bf,(%esp)
f0100c4c:	e8 29 0d 00 00       	call   f010197a <strchr>
f0100c51:	85 c0                	test   %eax,%eax
f0100c53:	74 df                	je     f0100c34 <monitor+0xca>
f0100c55:	eb 94                	jmp    f0100beb <monitor+0x81>
			buf++;
	}
	argv[argc] = 0;
f0100c57:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100c5e:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100c5f:	85 f6                	test   %esi,%esi
f0100c61:	0f 84 5c ff ff ff    	je     f0100bc3 <monitor+0x59>
f0100c67:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c6c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c6f:	8b 04 85 a0 24 10 f0 	mov    -0xfefdb60(,%eax,4),%eax
f0100c76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c7d:	89 04 24             	mov    %eax,(%esp)
f0100c80:	e8 97 0c 00 00       	call   f010191c <strcmp>
f0100c85:	85 c0                	test   %eax,%eax
f0100c87:	75 24                	jne    f0100cad <monitor+0x143>
			return commands[i].func(argc, argv, tf);
f0100c89:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c8c:	8b 55 08             	mov    0x8(%ebp),%edx
f0100c8f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100c93:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100c96:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100c9a:	89 34 24             	mov    %esi,(%esp)
f0100c9d:	ff 14 85 a8 24 10 f0 	call   *-0xfefdb58(,%eax,4)
	cprintf("上面那句话一共%d个字符\n",b);
	cprintf("test:[%-5d]\n", 3);*/
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ca4:	85 c0                	test   %eax,%eax
f0100ca6:	78 25                	js     f0100ccd <monitor+0x163>
f0100ca8:	e9 16 ff ff ff       	jmp    f0100bc3 <monitor+0x59>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100cad:	83 c3 01             	add    $0x1,%ebx
f0100cb0:	83 fb 04             	cmp    $0x4,%ebx
f0100cb3:	75 b7                	jne    f0100c6c <monitor+0x102>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100cb5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cbc:	c7 04 24 e1 22 10 f0 	movl   $0xf01022e1,(%esp)
f0100cc3:	e8 61 00 00 00       	call   f0100d29 <cprintf>
f0100cc8:	e9 f6 fe ff ff       	jmp    f0100bc3 <monitor+0x59>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ccd:	83 c4 5c             	add    $0x5c,%esp
f0100cd0:	5b                   	pop    %ebx
f0100cd1:	5e                   	pop    %esi
f0100cd2:	5f                   	pop    %edi
f0100cd3:	5d                   	pop    %ebp
f0100cd4:	c3                   	ret    
f0100cd5:	66 90                	xchg   %ax,%ax
f0100cd7:	90                   	nop

f0100cd8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100cd8:	55                   	push   %ebp
f0100cd9:	89 e5                	mov    %esp,%ebp
f0100cdb:	53                   	push   %ebx
f0100cdc:	83 ec 14             	sub    $0x14,%esp
f0100cdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0100ce2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ce5:	89 04 24             	mov    %eax,(%esp)
f0100ce8:	e8 74 fa ff ff       	call   f0100761 <cputchar>
	(*cnt)++;
f0100ced:	83 03 01             	addl   $0x1,(%ebx)
}
f0100cf0:	83 c4 14             	add    $0x14,%esp
f0100cf3:	5b                   	pop    %ebx
f0100cf4:	5d                   	pop    %ebp
f0100cf5:	c3                   	ret    

f0100cf6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100cf6:	55                   	push   %ebp
f0100cf7:	89 e5                	mov    %esp,%ebp
f0100cf9:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100cfc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100d03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d06:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d0a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d0d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100d14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d18:	c7 04 24 d8 0c 10 f0 	movl   $0xf0100cd8,(%esp)
f0100d1f:	e8 17 05 00 00       	call   f010123b <vprintfmt>
	return cnt;
}
f0100d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d27:	c9                   	leave  
f0100d28:	c3                   	ret    

f0100d29 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100d29:	55                   	push   %ebp
f0100d2a:	89 e5                	mov    %esp,%ebp
f0100d2c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100d2f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100d32:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d36:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d39:	89 04 24             	mov    %eax,(%esp)
f0100d3c:	e8 b5 ff ff ff       	call   f0100cf6 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100d41:	c9                   	leave  
f0100d42:	c3                   	ret    
f0100d43:	90                   	nop

f0100d44 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100d44:	55                   	push   %ebp
f0100d45:	89 e5                	mov    %esp,%ebp
f0100d47:	57                   	push   %edi
f0100d48:	56                   	push   %esi
f0100d49:	53                   	push   %ebx
f0100d4a:	83 ec 10             	sub    $0x10,%esp
f0100d4d:	89 c6                	mov    %eax,%esi
f0100d4f:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100d52:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100d55:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100d58:	8b 1a                	mov    (%edx),%ebx
f0100d5a:	8b 01                	mov    (%ecx),%eax
f0100d5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100d5f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100d66:	eb 77                	jmp    f0100ddf <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0100d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100d6b:	01 d8                	add    %ebx,%eax
f0100d6d:	b9 02 00 00 00       	mov    $0x2,%ecx
f0100d72:	99                   	cltd   
f0100d73:	f7 f9                	idiv   %ecx
f0100d75:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100d77:	eb 01                	jmp    f0100d7a <stab_binsearch+0x36>
			m--;
f0100d79:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100d7a:	39 d9                	cmp    %ebx,%ecx
f0100d7c:	7c 1d                	jl     f0100d9b <stab_binsearch+0x57>
f0100d7e:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100d81:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100d86:	39 fa                	cmp    %edi,%edx
f0100d88:	75 ef                	jne    f0100d79 <stab_binsearch+0x35>
f0100d8a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100d8d:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100d90:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0100d94:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100d97:	73 18                	jae    f0100db1 <stab_binsearch+0x6d>
f0100d99:	eb 05                	jmp    f0100da0 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100d9b:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0100d9e:	eb 3f                	jmp    f0100ddf <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100da0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100da3:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100da5:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100da8:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100daf:	eb 2e                	jmp    f0100ddf <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100db1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100db4:	73 15                	jae    f0100dcb <stab_binsearch+0x87>
			*region_right = m - 1;
f0100db6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100db9:	48                   	dec    %eax
f0100dba:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100dbd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100dc0:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100dc2:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100dc9:	eb 14                	jmp    f0100ddf <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100dcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100dce:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100dd1:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0100dd3:	ff 45 0c             	incl   0xc(%ebp)
f0100dd6:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100dd8:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100ddf:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100de2:	7e 84                	jle    f0100d68 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100de4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100de8:	75 0d                	jne    f0100df7 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0100dea:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100ded:	8b 00                	mov    (%eax),%eax
f0100def:	48                   	dec    %eax
f0100df0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100df3:	89 07                	mov    %eax,(%edi)
f0100df5:	eb 22                	jmp    f0100e19 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100df7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dfa:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100dfc:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100dff:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100e01:	eb 01                	jmp    f0100e04 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100e03:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100e04:	39 c1                	cmp    %eax,%ecx
f0100e06:	7d 0c                	jge    f0100e14 <stab_binsearch+0xd0>
f0100e08:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0100e0b:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100e10:	39 fa                	cmp    %edi,%edx
f0100e12:	75 ef                	jne    f0100e03 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100e14:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0100e17:	89 07                	mov    %eax,(%edi)
	}
}
f0100e19:	83 c4 10             	add    $0x10,%esp
f0100e1c:	5b                   	pop    %ebx
f0100e1d:	5e                   	pop    %esi
f0100e1e:	5f                   	pop    %edi
f0100e1f:	5d                   	pop    %ebp
f0100e20:	c3                   	ret    

f0100e21 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100e21:	55                   	push   %ebp
f0100e22:	89 e5                	mov    %esp,%ebp
f0100e24:	57                   	push   %edi
f0100e25:	56                   	push   %esi
f0100e26:	53                   	push   %ebx
f0100e27:	83 ec 3c             	sub    $0x3c,%esp
f0100e2a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100e30:	c7 03 d0 24 10 f0    	movl   $0xf01024d0,(%ebx)
	info->eip_line = 0;
f0100e36:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100e3d:	c7 43 08 d0 24 10 f0 	movl   $0xf01024d0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100e44:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100e4b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100e4e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100e55:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100e5b:	76 12                	jbe    f0100e6f <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100e5d:	b8 37 80 10 f0       	mov    $0xf0108037,%eax
f0100e62:	3d 25 66 10 f0       	cmp    $0xf0106625,%eax
f0100e67:	0f 86 cd 01 00 00    	jbe    f010103a <debuginfo_eip+0x219>
f0100e6d:	eb 1c                	jmp    f0100e8b <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100e6f:	c7 44 24 08 da 24 10 	movl   $0xf01024da,0x8(%esp)
f0100e76:	f0 
f0100e77:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100e7e:	00 
f0100e7f:	c7 04 24 e7 24 10 f0 	movl   $0xf01024e7,(%esp)
f0100e86:	e8 66 f3 ff ff       	call   f01001f1 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100e8b:	80 3d 36 80 10 f0 00 	cmpb   $0x0,0xf0108036
f0100e92:	0f 85 a9 01 00 00    	jne    f0101041 <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100e98:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100e9f:	b8 24 66 10 f0       	mov    $0xf0106624,%eax
f0100ea4:	2d 84 27 10 f0       	sub    $0xf0102784,%eax
f0100ea9:	c1 f8 02             	sar    $0x2,%eax
f0100eac:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100eb2:	83 e8 01             	sub    $0x1,%eax
f0100eb5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100eb8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ebc:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100ec3:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100ec6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100ec9:	b8 84 27 10 f0       	mov    $0xf0102784,%eax
f0100ece:	e8 71 fe ff ff       	call   f0100d44 <stab_binsearch>
	if (lfile == 0)
f0100ed3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ed6:	85 c0                	test   %eax,%eax
f0100ed8:	0f 84 6a 01 00 00    	je     f0101048 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ede:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ee1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ee4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ee7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100eeb:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100ef2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ef5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ef8:	b8 84 27 10 f0       	mov    $0xf0102784,%eax
f0100efd:	e8 42 fe ff ff       	call   f0100d44 <stab_binsearch>

	if (lfun <= rfun) {
f0100f02:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f05:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f08:	39 d0                	cmp    %edx,%eax
f0100f0a:	7f 3d                	jg     f0100f49 <debuginfo_eip+0x128>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100f0c:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100f0f:	8d b9 84 27 10 f0    	lea    -0xfefd87c(%ecx),%edi
f0100f15:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100f18:	8b 89 84 27 10 f0    	mov    -0xfefd87c(%ecx),%ecx
f0100f1e:	bf 37 80 10 f0       	mov    $0xf0108037,%edi
f0100f23:	81 ef 25 66 10 f0    	sub    $0xf0106625,%edi
f0100f29:	39 f9                	cmp    %edi,%ecx
f0100f2b:	73 09                	jae    f0100f36 <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100f2d:	81 c1 25 66 10 f0    	add    $0xf0106625,%ecx
f0100f33:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100f36:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100f39:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100f3c:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100f3f:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100f41:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100f44:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100f47:	eb 0f                	jmp    f0100f58 <debuginfo_eip+0x137>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100f49:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f4f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100f52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f55:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100f58:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100f5f:	00 
f0100f60:	8b 43 08             	mov    0x8(%ebx),%eax
f0100f63:	89 04 24             	mov    %eax,(%esp)
f0100f66:	e8 30 0a 00 00       	call   f010199b <strfind>
f0100f6b:	2b 43 08             	sub    0x8(%ebx),%eax
f0100f6e:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100f71:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f75:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100f7c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100f7f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100f82:	b8 84 27 10 f0       	mov    $0xf0102784,%eax
f0100f87:	e8 b8 fd ff ff       	call   f0100d44 <stab_binsearch>
	if (lline <= rline) {
f0100f8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f8f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100f92:	0f 8f b7 00 00 00    	jg     f010104f <debuginfo_eip+0x22e>
		info->eip_line = stabs[lline].n_desc;
f0100f98:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100f9b:	0f b7 80 8a 27 10 f0 	movzwl -0xfefd876(%eax),%eax
f0100fa2:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100fa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fa8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100fab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100fae:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100fb1:	81 c2 84 27 10 f0    	add    $0xf0102784,%edx
f0100fb7:	eb 06                	jmp    f0100fbf <debuginfo_eip+0x19e>
f0100fb9:	83 e8 01             	sub    $0x1,%eax
f0100fbc:	83 ea 0c             	sub    $0xc,%edx
f0100fbf:	89 c6                	mov    %eax,%esi
f0100fc1:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100fc4:	7f 33                	jg     f0100ff9 <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0100fc6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100fca:	80 f9 84             	cmp    $0x84,%cl
f0100fcd:	74 0b                	je     f0100fda <debuginfo_eip+0x1b9>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100fcf:	80 f9 64             	cmp    $0x64,%cl
f0100fd2:	75 e5                	jne    f0100fb9 <debuginfo_eip+0x198>
f0100fd4:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100fd8:	74 df                	je     f0100fb9 <debuginfo_eip+0x198>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100fda:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100fdd:	8b 86 84 27 10 f0    	mov    -0xfefd87c(%esi),%eax
f0100fe3:	ba 37 80 10 f0       	mov    $0xf0108037,%edx
f0100fe8:	81 ea 25 66 10 f0    	sub    $0xf0106625,%edx
f0100fee:	39 d0                	cmp    %edx,%eax
f0100ff0:	73 07                	jae    f0100ff9 <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100ff2:	05 25 66 10 f0       	add    $0xf0106625,%eax
f0100ff7:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ff9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ffc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100fff:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101004:	39 ca                	cmp    %ecx,%edx
f0101006:	7d 53                	jge    f010105b <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
f0101008:	8d 42 01             	lea    0x1(%edx),%eax
f010100b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010100e:	89 c2                	mov    %eax,%edx
f0101010:	6b c0 0c             	imul   $0xc,%eax,%eax
f0101013:	05 84 27 10 f0       	add    $0xf0102784,%eax
f0101018:	89 ce                	mov    %ecx,%esi
f010101a:	eb 04                	jmp    f0101020 <debuginfo_eip+0x1ff>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010101c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101020:	39 d6                	cmp    %edx,%esi
f0101022:	7e 32                	jle    f0101056 <debuginfo_eip+0x235>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101024:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0101028:	83 c2 01             	add    $0x1,%edx
f010102b:	83 c0 0c             	add    $0xc,%eax
f010102e:	80 f9 a0             	cmp    $0xa0,%cl
f0101031:	74 e9                	je     f010101c <debuginfo_eip+0x1fb>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101033:	b8 00 00 00 00       	mov    $0x0,%eax
f0101038:	eb 21                	jmp    f010105b <debuginfo_eip+0x23a>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010103a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010103f:	eb 1a                	jmp    f010105b <debuginfo_eip+0x23a>
f0101041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101046:	eb 13                	jmp    f010105b <debuginfo_eip+0x23a>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0101048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010104d:	eb 0c                	jmp    f010105b <debuginfo_eip+0x23a>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	}
	else {
		return -1;
f010104f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101054:	eb 05                	jmp    f010105b <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101056:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010105b:	83 c4 3c             	add    $0x3c,%esp
f010105e:	5b                   	pop    %ebx
f010105f:	5e                   	pop    %esi
f0101060:	5f                   	pop    %edi
f0101061:	5d                   	pop    %ebp
f0101062:	c3                   	ret    
f0101063:	66 90                	xchg   %ax,%ax
f0101065:	66 90                	xchg   %ax,%ax
f0101067:	66 90                	xchg   %ax,%ax
f0101069:	66 90                	xchg   %ax,%ax
f010106b:	66 90                	xchg   %ax,%ax
f010106d:	66 90                	xchg   %ax,%ax
f010106f:	90                   	nop

f0101070 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101070:	55                   	push   %ebp
f0101071:	89 e5                	mov    %esp,%ebp
f0101073:	57                   	push   %edi
f0101074:	56                   	push   %esi
f0101075:	53                   	push   %ebx
f0101076:	83 ec 3c             	sub    $0x3c,%esp
f0101079:	89 c7                	mov    %eax,%edi
f010107b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010107e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101081:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101084:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101087:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010108a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010108d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0101090:	8b 75 18             	mov    0x18(%ebp),%esi
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-') {
f0101093:	83 fe 2d             	cmp    $0x2d,%esi
f0101096:	75 67                	jne    f01010ff <printnum+0x8f>
		int i = 0;
		int num_of_digit = 0;
		int temp = num;
f0101098:	8b 45 dc             	mov    -0x24(%ebp),%eax
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	if (padc == '-') {
		int i = 0;
		int num_of_digit = 0;
f010109b:	66 be 00 00          	mov    $0x0,%si
		int temp = num;
		while(temp > 0) {
f010109f:	eb 0a                	jmp    f01010ab <printnum+0x3b>
			num_of_digit += 1;
f01010a1:	83 c6 01             	add    $0x1,%esi
			temp /= base;
f01010a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01010a9:	f7 f1                	div    %ecx
	// your code here:
	if (padc == '-') {
		int i = 0;
		int num_of_digit = 0;
		int temp = num;
		while(temp > 0) {
f01010ab:	85 c0                	test   %eax,%eax
f01010ad:	7f f2                	jg     f01010a1 <printnum+0x31>
			num_of_digit += 1;
			temp /= base;
		}
		printnum(putch, putdat, num, base, num_of_digit, ' ');
f01010af:	c7 44 24 10 20 00 00 	movl   $0x20,0x10(%esp)
f01010b6:	00 
f01010b7:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01010ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01010be:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01010c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010c5:	89 14 24             	mov    %edx,(%esp)
f01010c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01010cb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01010cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01010d2:	89 f8                	mov    %edi,%eax
f01010d4:	e8 97 ff ff ff       	call   f0101070 <printnum>
		for (i = 0; i < width - num_of_digit; i++)
f01010d9:	be 00 00 00 00       	mov    $0x0,%esi
f01010de:	2b 5d d0             	sub    -0x30(%ebp),%ebx
f01010e1:	eb 13                	jmp    f01010f6 <printnum+0x86>
			putch(' ', putdat);
f01010e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01010f1:	ff d7                	call   *%edi
		while(temp > 0) {
			num_of_digit += 1;
			temp /= base;
		}
		printnum(putch, putdat, num, base, num_of_digit, ' ');
		for (i = 0; i < width - num_of_digit; i++)
f01010f3:	83 c6 01             	add    $0x1,%esi
f01010f6:	39 de                	cmp    %ebx,%esi
f01010f8:	7c e9                	jl     f01010e3 <printnum+0x73>
f01010fa:	e9 b5 00 00 00       	jmp    f01011b4 <printnum+0x144>
			putch(' ', putdat);
		return;
	}	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01010ff:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101102:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101109:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010110d:	77 05                	ja     f0101114 <printnum+0xa4>
f010110f:	39 4d dc             	cmp    %ecx,-0x24(%ebp)
f0101112:	72 5e                	jb     f0101172 <printnum+0x102>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101114:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101118:	83 eb 01             	sub    $0x1,%ebx
f010111b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010111f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101123:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0101127:	8b 74 24 0c          	mov    0xc(%esp),%esi
f010112b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010112e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101131:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101135:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101139:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010113c:	89 04 24             	mov    %eax,(%esp)
f010113f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101142:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101146:	e8 75 0a 00 00       	call   f0101bc0 <__udivdi3>
f010114b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010114f:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101153:	89 04 24             	mov    %eax,(%esp)
f0101156:	89 54 24 04          	mov    %edx,0x4(%esp)
f010115a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010115d:	89 f8                	mov    %edi,%eax
f010115f:	e8 0c ff ff ff       	call   f0101070 <printnum>
f0101164:	eb 13                	jmp    f0101179 <printnum+0x109>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101166:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101169:	89 44 24 04          	mov    %eax,0x4(%esp)
f010116d:	89 34 24             	mov    %esi,(%esp)
f0101170:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101172:	83 eb 01             	sub    $0x1,%ebx
f0101175:	85 db                	test   %ebx,%ebx
f0101177:	7f ed                	jg     f0101166 <printnum+0xf6>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010117c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101180:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101184:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101187:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010118a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010118e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101192:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101195:	89 04 24             	mov    %eax,(%esp)
f0101198:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010119b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010119f:	e8 4c 0b 00 00       	call   f0101cf0 <__umoddi3>
f01011a4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011a8:	0f be 80 f5 24 10 f0 	movsbl -0xfefdb0b(%eax),%eax
f01011af:	89 04 24             	mov    %eax,(%esp)
f01011b2:	ff d7                	call   *%edi
}
f01011b4:	83 c4 3c             	add    $0x3c,%esp
f01011b7:	5b                   	pop    %ebx
f01011b8:	5e                   	pop    %esi
f01011b9:	5f                   	pop    %edi
f01011ba:	5d                   	pop    %ebp
f01011bb:	c3                   	ret    

f01011bc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01011bc:	55                   	push   %ebp
f01011bd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01011bf:	83 fa 01             	cmp    $0x1,%edx
f01011c2:	7e 0e                	jle    f01011d2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01011c4:	8b 10                	mov    (%eax),%edx
f01011c6:	8d 4a 08             	lea    0x8(%edx),%ecx
f01011c9:	89 08                	mov    %ecx,(%eax)
f01011cb:	8b 02                	mov    (%edx),%eax
f01011cd:	8b 52 04             	mov    0x4(%edx),%edx
f01011d0:	eb 22                	jmp    f01011f4 <getuint+0x38>
	else if (lflag)
f01011d2:	85 d2                	test   %edx,%edx
f01011d4:	74 10                	je     f01011e6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01011d6:	8b 10                	mov    (%eax),%edx
f01011d8:	8d 4a 04             	lea    0x4(%edx),%ecx
f01011db:	89 08                	mov    %ecx,(%eax)
f01011dd:	8b 02                	mov    (%edx),%eax
f01011df:	ba 00 00 00 00       	mov    $0x0,%edx
f01011e4:	eb 0e                	jmp    f01011f4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01011e6:	8b 10                	mov    (%eax),%edx
f01011e8:	8d 4a 04             	lea    0x4(%edx),%ecx
f01011eb:	89 08                	mov    %ecx,(%eax)
f01011ed:	8b 02                	mov    (%edx),%eax
f01011ef:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01011f4:	5d                   	pop    %ebp
f01011f5:	c3                   	ret    

f01011f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01011f6:	55                   	push   %ebp
f01011f7:	89 e5                	mov    %esp,%ebp
f01011f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01011fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101200:	8b 10                	mov    (%eax),%edx
f0101202:	3b 50 04             	cmp    0x4(%eax),%edx
f0101205:	73 0a                	jae    f0101211 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101207:	8d 4a 01             	lea    0x1(%edx),%ecx
f010120a:	89 08                	mov    %ecx,(%eax)
f010120c:	8b 45 08             	mov    0x8(%ebp),%eax
f010120f:	88 02                	mov    %al,(%edx)
}
f0101211:	5d                   	pop    %ebp
f0101212:	c3                   	ret    

f0101213 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101213:	55                   	push   %ebp
f0101214:	89 e5                	mov    %esp,%ebp
f0101216:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0101219:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010121c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101220:	8b 45 10             	mov    0x10(%ebp),%eax
f0101223:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101227:	8b 45 0c             	mov    0xc(%ebp),%eax
f010122a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010122e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101231:	89 04 24             	mov    %eax,(%esp)
f0101234:	e8 02 00 00 00       	call   f010123b <vprintfmt>
	va_end(ap);
}
f0101239:	c9                   	leave  
f010123a:	c3                   	ret    

f010123b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010123b:	55                   	push   %ebp
f010123c:	89 e5                	mov    %esp,%ebp
f010123e:	57                   	push   %edi
f010123f:	56                   	push   %esi
f0101240:	53                   	push   %ebx
f0101241:	83 ec 4c             	sub    $0x4c,%esp
f0101244:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101247:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010124a:	eb 14                	jmp    f0101260 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010124c:	85 c0                	test   %eax,%eax
f010124e:	0f 84 84 04 00 00    	je     f01016d8 <vprintfmt+0x49d>
				return;
			putch(ch, putdat);
f0101254:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101258:	89 04 24             	mov    %eax,(%esp)
f010125b:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010125e:	89 f3                	mov    %esi,%ebx
f0101260:	8d 73 01             	lea    0x1(%ebx),%esi
f0101263:	0f b6 03             	movzbl (%ebx),%eax
f0101266:	83 f8 25             	cmp    $0x25,%eax
f0101269:	75 e1                	jne    f010124c <vprintfmt+0x11>
f010126b:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010126f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101276:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010127d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0101284:	ba 00 00 00 00       	mov    $0x0,%edx
f0101289:	eb 24                	jmp    f01012af <vprintfmt+0x74>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010128b:	89 de                	mov    %ebx,%esi
		case '+':
			padc = '+';
f010128d:	c6 45 dc 2b          	movb   $0x2b,-0x24(%ebp)
			altflag = 1;
f0101291:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0101298:	eb 15                	jmp    f01012af <vprintfmt+0x74>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010129a:	89 de                	mov    %ebx,%esi
			padc = '+';
			altflag = 1;
                        goto reswitch;
		// flag to pad on the right
		case '-':
			padc = '-';
f010129c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f01012a0:	eb 0d                	jmp    f01012af <vprintfmt+0x74>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01012a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01012a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01012a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012af:	8d 5e 01             	lea    0x1(%esi),%ebx
f01012b2:	0f b6 06             	movzbl (%esi),%eax
f01012b5:	0f b6 c8             	movzbl %al,%ecx
f01012b8:	83 e8 23             	sub    $0x23,%eax
f01012bb:	3c 55                	cmp    $0x55,%al
f01012bd:	0f 87 f5 03 00 00    	ja     f01016b8 <vprintfmt+0x47d>
f01012c3:	0f b6 c0             	movzbl %al,%eax
f01012c6:	ff 24 85 00 26 10 f0 	jmp    *-0xfefda00(,%eax,4)
f01012cd:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01012cf:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
			goto reswitch;
f01012d3:	eb da                	jmp    f01012af <vprintfmt+0x74>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012d5:	89 de                	mov    %ebx,%esi
f01012d7:	b8 00 00 00 00       	mov    $0x0,%eax
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01012dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01012df:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f01012e3:	0f be 0e             	movsbl (%esi),%ecx
				if (ch < '0' || ch > '9')
f01012e6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01012e9:	83 fb 09             	cmp    $0x9,%ebx
f01012ec:	77 36                	ja     f0101324 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01012ee:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01012f1:	eb e9                	jmp    f01012dc <vprintfmt+0xa1>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01012f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f6:	8d 48 04             	lea    0x4(%eax),%ecx
f01012f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01012fc:	8b 00                	mov    (%eax),%eax
f01012fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101301:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101303:	eb 22                	jmp    f0101327 <vprintfmt+0xec>
f0101305:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101308:	85 c0                	test   %eax,%eax
f010130a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010130f:	0f 49 c8             	cmovns %eax,%ecx
f0101312:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101315:	89 de                	mov    %ebx,%esi
f0101317:	eb 96                	jmp    f01012af <vprintfmt+0x74>
f0101319:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010131b:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
			goto reswitch;
f0101322:	eb 8b                	jmp    f01012af <vprintfmt+0x74>
f0101324:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0101327:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010132b:	79 82                	jns    f01012af <vprintfmt+0x74>
f010132d:	e9 70 ff ff ff       	jmp    f01012a2 <vprintfmt+0x67>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101332:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101335:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101337:	e9 73 ff ff ff       	jmp    f01012af <vprintfmt+0x74>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010133c:	8b 45 14             	mov    0x14(%ebp),%eax
f010133f:	8d 50 04             	lea    0x4(%eax),%edx
f0101342:	89 55 14             	mov    %edx,0x14(%ebp)
f0101345:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101349:	8b 00                	mov    (%eax),%eax
f010134b:	89 04 24             	mov    %eax,(%esp)
f010134e:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101351:	e9 0a ff ff ff       	jmp    f0101260 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101356:	8b 45 14             	mov    0x14(%ebp),%eax
f0101359:	8d 50 04             	lea    0x4(%eax),%edx
f010135c:	89 55 14             	mov    %edx,0x14(%ebp)
f010135f:	8b 00                	mov    (%eax),%eax
f0101361:	99                   	cltd   
f0101362:	31 d0                	xor    %edx,%eax
f0101364:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101366:	83 f8 06             	cmp    $0x6,%eax
f0101369:	7f 0b                	jg     f0101376 <vprintfmt+0x13b>
f010136b:	8b 14 85 58 27 10 f0 	mov    -0xfefd8a8(,%eax,4),%edx
f0101372:	85 d2                	test   %edx,%edx
f0101374:	75 20                	jne    f0101396 <vprintfmt+0x15b>
				printfmt(putch, putdat, "error %d", err);
f0101376:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010137a:	c7 44 24 08 0d 25 10 	movl   $0xf010250d,0x8(%esp)
f0101381:	f0 
f0101382:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101386:	8b 45 08             	mov    0x8(%ebp),%eax
f0101389:	89 04 24             	mov    %eax,(%esp)
f010138c:	e8 82 fe ff ff       	call   f0101213 <printfmt>
f0101391:	e9 ca fe ff ff       	jmp    f0101260 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0101396:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010139a:	c7 44 24 08 16 25 10 	movl   $0xf0102516,0x8(%esp)
f01013a1:	f0 
f01013a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01013a9:	89 04 24             	mov    %eax,(%esp)
f01013ac:	e8 62 fe ff ff       	call   f0101213 <printfmt>
f01013b1:	e9 aa fe ff ff       	jmp    f0101260 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01013b6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01013b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013bc:	89 45 c8             	mov    %eax,-0x38(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01013bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c2:	8d 50 04             	lea    0x4(%eax),%edx
f01013c5:	89 55 14             	mov    %edx,0x14(%ebp)
f01013c8:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01013ca:	85 f6                	test   %esi,%esi
f01013cc:	b8 06 25 10 f0       	mov    $0xf0102506,%eax
f01013d1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f01013d4:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f01013d8:	0f 84 97 00 00 00    	je     f0101475 <vprintfmt+0x23a>
f01013de:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f01013e2:	0f 8e 9b 00 00 00    	jle    f0101483 <vprintfmt+0x248>
				for (width -= strnlen(p, precision); width > 0; width--)
f01013e8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01013ec:	89 34 24             	mov    %esi,(%esp)
f01013ef:	e8 54 04 00 00       	call   f0101848 <strnlen>
f01013f4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01013f7:	29 c1                	sub    %eax,%ecx
f01013f9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
					putch(padc, putdat);
f01013fc:	0f be 45 dc          	movsbl -0x24(%ebp),%eax
f0101400:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101403:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0101406:	8b 75 08             	mov    0x8(%ebp),%esi
f0101409:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010140c:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010140e:	eb 0f                	jmp    f010141f <vprintfmt+0x1e4>
					putch(padc, putdat);
f0101410:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101414:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101417:	89 04 24             	mov    %eax,(%esp)
f010141a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010141c:	83 eb 01             	sub    $0x1,%ebx
f010141f:	85 db                	test   %ebx,%ebx
f0101421:	7f ed                	jg     f0101410 <vprintfmt+0x1d5>
f0101423:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101426:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101429:	85 c9                	test   %ecx,%ecx
f010142b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101430:	0f 49 c1             	cmovns %ecx,%eax
f0101433:	29 c1                	sub    %eax,%ecx
f0101435:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101438:	89 cf                	mov    %ecx,%edi
f010143a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010143d:	eb 50                	jmp    f010148f <vprintfmt+0x254>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010143f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101443:	74 1e                	je     f0101463 <vprintfmt+0x228>
f0101445:	0f be d2             	movsbl %dl,%edx
f0101448:	83 ea 20             	sub    $0x20,%edx
f010144b:	83 fa 5e             	cmp    $0x5e,%edx
f010144e:	76 13                	jbe    f0101463 <vprintfmt+0x228>
					putch('?', putdat);
f0101450:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101453:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101457:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010145e:	ff 55 08             	call   *0x8(%ebp)
f0101461:	eb 0d                	jmp    f0101470 <vprintfmt+0x235>
				else
					putch(ch, putdat);
f0101463:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101466:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010146a:	89 04 24             	mov    %eax,(%esp)
f010146d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101470:	83 ef 01             	sub    $0x1,%edi
f0101473:	eb 1a                	jmp    f010148f <vprintfmt+0x254>
f0101475:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101478:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010147b:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010147e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101481:	eb 0c                	jmp    f010148f <vprintfmt+0x254>
f0101483:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101486:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101489:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010148c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010148f:	83 c6 01             	add    $0x1,%esi
f0101492:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0101496:	0f be c2             	movsbl %dl,%eax
f0101499:	85 c0                	test   %eax,%eax
f010149b:	74 27                	je     f01014c4 <vprintfmt+0x289>
f010149d:	85 db                	test   %ebx,%ebx
f010149f:	78 9e                	js     f010143f <vprintfmt+0x204>
f01014a1:	83 eb 01             	sub    $0x1,%ebx
f01014a4:	79 99                	jns    f010143f <vprintfmt+0x204>
f01014a6:	89 f8                	mov    %edi,%eax
f01014a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01014ab:	8b 75 08             	mov    0x8(%ebp),%esi
f01014ae:	89 c3                	mov    %eax,%ebx
f01014b0:	eb 1a                	jmp    f01014cc <vprintfmt+0x291>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01014b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01014bd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01014bf:	83 eb 01             	sub    $0x1,%ebx
f01014c2:	eb 08                	jmp    f01014cc <vprintfmt+0x291>
f01014c4:	89 fb                	mov    %edi,%ebx
f01014c6:	8b 75 08             	mov    0x8(%ebp),%esi
f01014c9:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01014cc:	85 db                	test   %ebx,%ebx
f01014ce:	7f e2                	jg     f01014b2 <vprintfmt+0x277>
f01014d0:	89 75 08             	mov    %esi,0x8(%ebp)
f01014d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01014d6:	e9 85 fd ff ff       	jmp    f0101260 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01014db:	83 fa 01             	cmp    $0x1,%edx
f01014de:	7e 16                	jle    f01014f6 <vprintfmt+0x2bb>
		return va_arg(*ap, long long);
f01014e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01014e3:	8d 50 08             	lea    0x8(%eax),%edx
f01014e6:	89 55 14             	mov    %edx,0x14(%ebp)
f01014e9:	8b 50 04             	mov    0x4(%eax),%edx
f01014ec:	8b 00                	mov    (%eax),%eax
f01014ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01014f1:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01014f4:	eb 32                	jmp    f0101528 <vprintfmt+0x2ed>
	else if (lflag)
f01014f6:	85 d2                	test   %edx,%edx
f01014f8:	74 18                	je     f0101512 <vprintfmt+0x2d7>
		return va_arg(*ap, long);
f01014fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01014fd:	8d 50 04             	lea    0x4(%eax),%edx
f0101500:	89 55 14             	mov    %edx,0x14(%ebp)
f0101503:	8b 30                	mov    (%eax),%esi
f0101505:	89 75 c8             	mov    %esi,-0x38(%ebp)
f0101508:	89 f0                	mov    %esi,%eax
f010150a:	c1 f8 1f             	sar    $0x1f,%eax
f010150d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101510:	eb 16                	jmp    f0101528 <vprintfmt+0x2ed>
	else
		return va_arg(*ap, int);
f0101512:	8b 45 14             	mov    0x14(%ebp),%eax
f0101515:	8d 50 04             	lea    0x4(%eax),%edx
f0101518:	89 55 14             	mov    %edx,0x14(%ebp)
f010151b:	8b 30                	mov    (%eax),%esi
f010151d:	89 75 c8             	mov    %esi,-0x38(%ebp)
f0101520:	89 f0                	mov    %esi,%eax
f0101522:	c1 f8 1f             	sar    $0x1f,%eax
f0101525:	89 45 cc             	mov    %eax,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101528:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010152b:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010152e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101531:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
f0101534:	85 d2                	test   %edx,%edx
f0101536:	79 2b                	jns    f0101563 <vprintfmt+0x328>
				putch('-', putdat);
f0101538:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010153c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101543:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101546:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101549:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010154c:	f7 d8                	neg    %eax
f010154e:	83 d2 00             	adc    $0x0,%edx
f0101551:	f7 da                	neg    %edx
f0101553:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101556:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			}
			else if (altflag){
				putch('+', putdat);
			}	
			base = 10;
f0101559:	b8 0a 00 00 00       	mov    $0xa,%eax
f010155e:	e9 ab 00 00 00       	jmp    f010160e <vprintfmt+0x3d3>
f0101563:	b8 0a 00 00 00       	mov    $0xa,%eax
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			else if (altflag){
f0101568:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010156c:	0f 84 9c 00 00 00    	je     f010160e <vprintfmt+0x3d3>
				putch('+', putdat);
f0101572:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101576:	c7 04 24 2b 00 00 00 	movl   $0x2b,(%esp)
f010157d:	ff 55 08             	call   *0x8(%ebp)
			}	
			base = 10;
f0101580:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101585:	e9 84 00 00 00       	jmp    f010160e <vprintfmt+0x3d3>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010158a:	8d 45 14             	lea    0x14(%ebp),%eax
f010158d:	e8 2a fc ff ff       	call   f01011bc <getuint>
f0101592:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101595:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			base = 10;
f0101598:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010159d:	eb 6f                	jmp    f010160e <vprintfmt+0x3d3>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010159f:	8d 45 14             	lea    0x14(%ebp),%eax
f01015a2:	e8 15 fc ff ff       	call   f01011bc <getuint>
f01015a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01015aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			base = 8;
			putch('0', putdat);
f01015ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015b1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01015b8:	ff 55 08             	call   *0x8(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
			base = 8;
f01015bb:	b8 08 00 00 00       	mov    $0x8,%eax
			putch('0', putdat);
			goto number;
f01015c0:	eb 4c                	jmp    f010160e <vprintfmt+0x3d3>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01015c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01015cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01015d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01015db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01015de:	8b 45 14             	mov    0x14(%ebp),%eax
f01015e1:	8d 50 04             	lea    0x4(%eax),%edx
f01015e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01015e7:	8b 00                	mov    (%eax),%eax
f01015e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01015ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01015f1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01015f4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01015f9:	eb 13                	jmp    f010160e <vprintfmt+0x3d3>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01015fb:	8d 45 14             	lea    0x14(%ebp),%eax
f01015fe:	e8 b9 fb ff ff       	call   f01011bc <getuint>
f0101603:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101606:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			base = 16;
f0101609:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010160e:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0101612:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101616:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101619:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010161d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101621:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101624:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101627:	89 04 24             	mov    %eax,(%esp)
f010162a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010162e:	89 fa                	mov    %edi,%edx
f0101630:	8b 45 08             	mov    0x8(%ebp),%eax
f0101633:	e8 38 fa ff ff       	call   f0101070 <printnum>
			break;
f0101638:	e9 23 fc ff ff       	jmp    f0101260 <vprintfmt+0x25>

				  const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
				  const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

				  // Your code here
				  char* pos = va_arg(ap,char*);
f010163d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101640:	8d 50 04             	lea    0x4(%eax),%edx
f0101643:	89 55 14             	mov    %edx,0x14(%ebp)
f0101646:	8b 30                	mov    (%eax),%esi
				  if (pos == NULL)
f0101648:	85 f6                	test   %esi,%esi
f010164a:	75 24                	jne    f0101670 <vprintfmt+0x435>
				  	printfmt(putch, putdat, "%s", null_error);
f010164c:	c7 44 24 0c 84 25 10 	movl   $0xf0102584,0xc(%esp)
f0101653:	f0 
f0101654:	c7 44 24 08 16 25 10 	movl   $0xf0102516,0x8(%esp)
f010165b:	f0 
f010165c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101660:	8b 45 08             	mov    0x8(%ebp),%eax
f0101663:	89 04 24             	mov    %eax,(%esp)
f0101666:	e8 a8 fb ff ff       	call   f0101213 <printfmt>
f010166b:	e9 f0 fb ff ff       	jmp    f0101260 <vprintfmt+0x25>
				  else if ((*(unsigned int *)putdat)>254){
f0101670:	81 3f fe 00 00 00    	cmpl   $0xfe,(%edi)
f0101676:	76 27                	jbe    f010169f <vprintfmt+0x464>
					printfmt(putch, putdat, "%s", overflow_error);
f0101678:	c7 44 24 0c bc 25 10 	movl   $0xf01025bc,0xc(%esp)
f010167f:	f0 
f0101680:	c7 44 24 08 16 25 10 	movl   $0xf0102516,0x8(%esp)
f0101687:	f0 
f0101688:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010168c:	8b 45 08             	mov    0x8(%ebp),%eax
f010168f:	89 04 24             	mov    %eax,(%esp)
f0101692:	e8 7c fb ff ff       	call   f0101213 <printfmt>
				  	*pos =-1;
f0101697:	c6 06 ff             	movb   $0xff,(%esi)
f010169a:	e9 c1 fb ff ff       	jmp    f0101260 <vprintfmt+0x25>
				  }
				  else
				  	*pos = *(char *)putdat;
f010169f:	0f b6 07             	movzbl (%edi),%eax
f01016a2:	88 06                	mov    %al,(%esi)
f01016a4:	e9 b7 fb ff ff       	jmp    f0101260 <vprintfmt+0x25>
				  break;
			  }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01016a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016ad:	89 0c 24             	mov    %ecx,(%esp)
f01016b0:	ff 55 08             	call   *0x8(%ebp)
			break;
f01016b3:	e9 a8 fb ff ff       	jmp    f0101260 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01016b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016bc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01016c3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01016c6:	89 f3                	mov    %esi,%ebx
f01016c8:	eb 03                	jmp    f01016cd <vprintfmt+0x492>
f01016ca:	83 eb 01             	sub    $0x1,%ebx
f01016cd:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01016d1:	75 f7                	jne    f01016ca <vprintfmt+0x48f>
f01016d3:	e9 88 fb ff ff       	jmp    f0101260 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f01016d8:	83 c4 4c             	add    $0x4c,%esp
f01016db:	5b                   	pop    %ebx
f01016dc:	5e                   	pop    %esi
f01016dd:	5f                   	pop    %edi
f01016de:	5d                   	pop    %ebp
f01016df:	c3                   	ret    

f01016e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01016e0:	55                   	push   %ebp
f01016e1:	89 e5                	mov    %esp,%ebp
f01016e3:	83 ec 28             	sub    $0x28,%esp
f01016e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01016e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01016ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01016ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01016f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01016f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01016fd:	85 c0                	test   %eax,%eax
f01016ff:	74 30                	je     f0101731 <vsnprintf+0x51>
f0101701:	85 d2                	test   %edx,%edx
f0101703:	7e 2c                	jle    f0101731 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101705:	8b 45 14             	mov    0x14(%ebp),%eax
f0101708:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010170c:	8b 45 10             	mov    0x10(%ebp),%eax
f010170f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101713:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101716:	89 44 24 04          	mov    %eax,0x4(%esp)
f010171a:	c7 04 24 f6 11 10 f0 	movl   $0xf01011f6,(%esp)
f0101721:	e8 15 fb ff ff       	call   f010123b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101726:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101729:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010172c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010172f:	eb 05                	jmp    f0101736 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101731:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101736:	c9                   	leave  
f0101737:	c3                   	ret    

f0101738 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101738:	55                   	push   %ebp
f0101739:	89 e5                	mov    %esp,%ebp
f010173b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010173e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101741:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101745:	8b 45 10             	mov    0x10(%ebp),%eax
f0101748:	89 44 24 08          	mov    %eax,0x8(%esp)
f010174c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010174f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101753:	8b 45 08             	mov    0x8(%ebp),%eax
f0101756:	89 04 24             	mov    %eax,(%esp)
f0101759:	e8 82 ff ff ff       	call   f01016e0 <vsnprintf>
	va_end(ap);

	return rc;
}
f010175e:	c9                   	leave  
f010175f:	c3                   	ret    

f0101760 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101760:	55                   	push   %ebp
f0101761:	89 e5                	mov    %esp,%ebp
f0101763:	57                   	push   %edi
f0101764:	56                   	push   %esi
f0101765:	53                   	push   %ebx
f0101766:	83 ec 1c             	sub    $0x1c,%esp
f0101769:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010176c:	85 c0                	test   %eax,%eax
f010176e:	74 10                	je     f0101780 <readline+0x20>
		cprintf("%s", prompt);
f0101770:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101774:	c7 04 24 16 25 10 f0 	movl   $0xf0102516,(%esp)
f010177b:	e8 a9 f5 ff ff       	call   f0100d29 <cprintf>

	i = 0;
	echoing = iscons(0);
f0101780:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101787:	e8 f6 ef ff ff       	call   f0100782 <iscons>
f010178c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010178e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101793:	e8 d9 ef ff ff       	call   f0100771 <getchar>
f0101798:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010179a:	85 c0                	test   %eax,%eax
f010179c:	79 17                	jns    f01017b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010179e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017a2:	c7 04 24 74 27 10 f0 	movl   $0xf0102774,(%esp)
f01017a9:	e8 7b f5 ff ff       	call   f0100d29 <cprintf>
			return NULL;
f01017ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01017b3:	eb 6d                	jmp    f0101822 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01017b5:	83 f8 7f             	cmp    $0x7f,%eax
f01017b8:	74 05                	je     f01017bf <readline+0x5f>
f01017ba:	83 f8 08             	cmp    $0x8,%eax
f01017bd:	75 19                	jne    f01017d8 <readline+0x78>
f01017bf:	85 f6                	test   %esi,%esi
f01017c1:	7e 15                	jle    f01017d8 <readline+0x78>
			if (echoing)
f01017c3:	85 ff                	test   %edi,%edi
f01017c5:	74 0c                	je     f01017d3 <readline+0x73>
				cputchar('\b');
f01017c7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01017ce:	e8 8e ef ff ff       	call   f0100761 <cputchar>
			i--;
f01017d3:	83 ee 01             	sub    $0x1,%esi
f01017d6:	eb bb                	jmp    f0101793 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01017d8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01017de:	7f 1c                	jg     f01017fc <readline+0x9c>
f01017e0:	83 fb 1f             	cmp    $0x1f,%ebx
f01017e3:	7e 17                	jle    f01017fc <readline+0x9c>
			if (echoing)
f01017e5:	85 ff                	test   %edi,%edi
f01017e7:	74 08                	je     f01017f1 <readline+0x91>
				cputchar(c);
f01017e9:	89 1c 24             	mov    %ebx,(%esp)
f01017ec:	e8 70 ef ff ff       	call   f0100761 <cputchar>
			buf[i++] = c;
f01017f1:	88 9e 40 35 11 f0    	mov    %bl,-0xfeecac0(%esi)
f01017f7:	8d 76 01             	lea    0x1(%esi),%esi
f01017fa:	eb 97                	jmp    f0101793 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01017fc:	83 fb 0d             	cmp    $0xd,%ebx
f01017ff:	74 05                	je     f0101806 <readline+0xa6>
f0101801:	83 fb 0a             	cmp    $0xa,%ebx
f0101804:	75 8d                	jne    f0101793 <readline+0x33>
			if (echoing)
f0101806:	85 ff                	test   %edi,%edi
f0101808:	74 0c                	je     f0101816 <readline+0xb6>
				cputchar('\n');
f010180a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101811:	e8 4b ef ff ff       	call   f0100761 <cputchar>
			buf[i] = 0;
f0101816:	c6 86 40 35 11 f0 00 	movb   $0x0,-0xfeecac0(%esi)
			return buf;
f010181d:	b8 40 35 11 f0       	mov    $0xf0113540,%eax
		}
	}
}
f0101822:	83 c4 1c             	add    $0x1c,%esp
f0101825:	5b                   	pop    %ebx
f0101826:	5e                   	pop    %esi
f0101827:	5f                   	pop    %edi
f0101828:	5d                   	pop    %ebp
f0101829:	c3                   	ret    
f010182a:	66 90                	xchg   %ax,%ax
f010182c:	66 90                	xchg   %ax,%ax
f010182e:	66 90                	xchg   %ax,%ax

f0101830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101830:	55                   	push   %ebp
f0101831:	89 e5                	mov    %esp,%ebp
f0101833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101836:	b8 00 00 00 00       	mov    $0x0,%eax
f010183b:	eb 03                	jmp    f0101840 <strlen+0x10>
		n++;
f010183d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101844:	75 f7                	jne    f010183d <strlen+0xd>
		n++;
	return n;
}
f0101846:	5d                   	pop    %ebp
f0101847:	c3                   	ret    

f0101848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101848:	55                   	push   %ebp
f0101849:	89 e5                	mov    %esp,%ebp
f010184b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010184e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101851:	b8 00 00 00 00       	mov    $0x0,%eax
f0101856:	eb 03                	jmp    f010185b <strnlen+0x13>
		n++;
f0101858:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010185b:	39 d0                	cmp    %edx,%eax
f010185d:	74 06                	je     f0101865 <strnlen+0x1d>
f010185f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101863:	75 f3                	jne    f0101858 <strnlen+0x10>
		n++;
	return n;
}
f0101865:	5d                   	pop    %ebp
f0101866:	c3                   	ret    

f0101867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101867:	55                   	push   %ebp
f0101868:	89 e5                	mov    %esp,%ebp
f010186a:	53                   	push   %ebx
f010186b:	8b 45 08             	mov    0x8(%ebp),%eax
f010186e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101871:	89 c2                	mov    %eax,%edx
f0101873:	83 c2 01             	add    $0x1,%edx
f0101876:	83 c1 01             	add    $0x1,%ecx
f0101879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010187d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101880:	84 db                	test   %bl,%bl
f0101882:	75 ef                	jne    f0101873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101884:	5b                   	pop    %ebx
f0101885:	5d                   	pop    %ebp
f0101886:	c3                   	ret    

f0101887 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101887:	55                   	push   %ebp
f0101888:	89 e5                	mov    %esp,%ebp
f010188a:	53                   	push   %ebx
f010188b:	83 ec 08             	sub    $0x8,%esp
f010188e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101891:	89 1c 24             	mov    %ebx,(%esp)
f0101894:	e8 97 ff ff ff       	call   f0101830 <strlen>
	strcpy(dst + len, src);
f0101899:	8b 55 0c             	mov    0xc(%ebp),%edx
f010189c:	89 54 24 04          	mov    %edx,0x4(%esp)
f01018a0:	01 d8                	add    %ebx,%eax
f01018a2:	89 04 24             	mov    %eax,(%esp)
f01018a5:	e8 bd ff ff ff       	call   f0101867 <strcpy>
	return dst;
}
f01018aa:	89 d8                	mov    %ebx,%eax
f01018ac:	83 c4 08             	add    $0x8,%esp
f01018af:	5b                   	pop    %ebx
f01018b0:	5d                   	pop    %ebp
f01018b1:	c3                   	ret    

f01018b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01018b2:	55                   	push   %ebp
f01018b3:	89 e5                	mov    %esp,%ebp
f01018b5:	56                   	push   %esi
f01018b6:	53                   	push   %ebx
f01018b7:	8b 75 08             	mov    0x8(%ebp),%esi
f01018ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01018bd:	89 f3                	mov    %esi,%ebx
f01018bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01018c2:	89 f2                	mov    %esi,%edx
f01018c4:	eb 0f                	jmp    f01018d5 <strncpy+0x23>
		*dst++ = *src;
f01018c6:	83 c2 01             	add    $0x1,%edx
f01018c9:	0f b6 01             	movzbl (%ecx),%eax
f01018cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01018cf:	80 39 01             	cmpb   $0x1,(%ecx)
f01018d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01018d5:	39 da                	cmp    %ebx,%edx
f01018d7:	75 ed                	jne    f01018c6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01018d9:	89 f0                	mov    %esi,%eax
f01018db:	5b                   	pop    %ebx
f01018dc:	5e                   	pop    %esi
f01018dd:	5d                   	pop    %ebp
f01018de:	c3                   	ret    

f01018df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01018df:	55                   	push   %ebp
f01018e0:	89 e5                	mov    %esp,%ebp
f01018e2:	56                   	push   %esi
f01018e3:	53                   	push   %ebx
f01018e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01018e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01018ed:	89 f0                	mov    %esi,%eax
f01018ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01018f3:	85 c9                	test   %ecx,%ecx
f01018f5:	75 0b                	jne    f0101902 <strlcpy+0x23>
f01018f7:	eb 1d                	jmp    f0101916 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01018f9:	83 c0 01             	add    $0x1,%eax
f01018fc:	83 c2 01             	add    $0x1,%edx
f01018ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101902:	39 d8                	cmp    %ebx,%eax
f0101904:	74 0b                	je     f0101911 <strlcpy+0x32>
f0101906:	0f b6 0a             	movzbl (%edx),%ecx
f0101909:	84 c9                	test   %cl,%cl
f010190b:	75 ec                	jne    f01018f9 <strlcpy+0x1a>
f010190d:	89 c2                	mov    %eax,%edx
f010190f:	eb 02                	jmp    f0101913 <strlcpy+0x34>
f0101911:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0101913:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101916:	29 f0                	sub    %esi,%eax
}
f0101918:	5b                   	pop    %ebx
f0101919:	5e                   	pop    %esi
f010191a:	5d                   	pop    %ebp
f010191b:	c3                   	ret    

f010191c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010191c:	55                   	push   %ebp
f010191d:	89 e5                	mov    %esp,%ebp
f010191f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101922:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101925:	eb 06                	jmp    f010192d <strcmp+0x11>
		p++, q++;
f0101927:	83 c1 01             	add    $0x1,%ecx
f010192a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010192d:	0f b6 01             	movzbl (%ecx),%eax
f0101930:	84 c0                	test   %al,%al
f0101932:	74 04                	je     f0101938 <strcmp+0x1c>
f0101934:	3a 02                	cmp    (%edx),%al
f0101936:	74 ef                	je     f0101927 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101938:	0f b6 c0             	movzbl %al,%eax
f010193b:	0f b6 12             	movzbl (%edx),%edx
f010193e:	29 d0                	sub    %edx,%eax
}
f0101940:	5d                   	pop    %ebp
f0101941:	c3                   	ret    

f0101942 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101942:	55                   	push   %ebp
f0101943:	89 e5                	mov    %esp,%ebp
f0101945:	53                   	push   %ebx
f0101946:	8b 45 08             	mov    0x8(%ebp),%eax
f0101949:	8b 55 0c             	mov    0xc(%ebp),%edx
f010194c:	89 c3                	mov    %eax,%ebx
f010194e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101951:	eb 06                	jmp    f0101959 <strncmp+0x17>
		n--, p++, q++;
f0101953:	83 c0 01             	add    $0x1,%eax
f0101956:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101959:	39 d8                	cmp    %ebx,%eax
f010195b:	74 15                	je     f0101972 <strncmp+0x30>
f010195d:	0f b6 08             	movzbl (%eax),%ecx
f0101960:	84 c9                	test   %cl,%cl
f0101962:	74 04                	je     f0101968 <strncmp+0x26>
f0101964:	3a 0a                	cmp    (%edx),%cl
f0101966:	74 eb                	je     f0101953 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101968:	0f b6 00             	movzbl (%eax),%eax
f010196b:	0f b6 12             	movzbl (%edx),%edx
f010196e:	29 d0                	sub    %edx,%eax
f0101970:	eb 05                	jmp    f0101977 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101972:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101977:	5b                   	pop    %ebx
f0101978:	5d                   	pop    %ebp
f0101979:	c3                   	ret    

f010197a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010197a:	55                   	push   %ebp
f010197b:	89 e5                	mov    %esp,%ebp
f010197d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101980:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101984:	eb 07                	jmp    f010198d <strchr+0x13>
		if (*s == c)
f0101986:	38 ca                	cmp    %cl,%dl
f0101988:	74 0f                	je     f0101999 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010198a:	83 c0 01             	add    $0x1,%eax
f010198d:	0f b6 10             	movzbl (%eax),%edx
f0101990:	84 d2                	test   %dl,%dl
f0101992:	75 f2                	jne    f0101986 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101994:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101999:	5d                   	pop    %ebp
f010199a:	c3                   	ret    

f010199b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010199b:	55                   	push   %ebp
f010199c:	89 e5                	mov    %esp,%ebp
f010199e:	8b 45 08             	mov    0x8(%ebp),%eax
f01019a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01019a5:	eb 07                	jmp    f01019ae <strfind+0x13>
		if (*s == c)
f01019a7:	38 ca                	cmp    %cl,%dl
f01019a9:	74 0a                	je     f01019b5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01019ab:	83 c0 01             	add    $0x1,%eax
f01019ae:	0f b6 10             	movzbl (%eax),%edx
f01019b1:	84 d2                	test   %dl,%dl
f01019b3:	75 f2                	jne    f01019a7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01019b5:	5d                   	pop    %ebp
f01019b6:	c3                   	ret    

f01019b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01019b7:	55                   	push   %ebp
f01019b8:	89 e5                	mov    %esp,%ebp
f01019ba:	57                   	push   %edi
f01019bb:	56                   	push   %esi
f01019bc:	53                   	push   %ebx
f01019bd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01019c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01019c3:	85 c9                	test   %ecx,%ecx
f01019c5:	74 36                	je     f01019fd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01019c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01019cd:	75 28                	jne    f01019f7 <memset+0x40>
f01019cf:	f6 c1 03             	test   $0x3,%cl
f01019d2:	75 23                	jne    f01019f7 <memset+0x40>
		c &= 0xFF;
f01019d4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01019d8:	89 d3                	mov    %edx,%ebx
f01019da:	c1 e3 08             	shl    $0x8,%ebx
f01019dd:	89 d6                	mov    %edx,%esi
f01019df:	c1 e6 18             	shl    $0x18,%esi
f01019e2:	89 d0                	mov    %edx,%eax
f01019e4:	c1 e0 10             	shl    $0x10,%eax
f01019e7:	09 f0                	or     %esi,%eax
f01019e9:	09 c2                	or     %eax,%edx
f01019eb:	89 d0                	mov    %edx,%eax
f01019ed:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01019ef:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01019f2:	fc                   	cld    
f01019f3:	f3 ab                	rep stos %eax,%es:(%edi)
f01019f5:	eb 06                	jmp    f01019fd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01019f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019fa:	fc                   	cld    
f01019fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01019fd:	89 f8                	mov    %edi,%eax
f01019ff:	5b                   	pop    %ebx
f0101a00:	5e                   	pop    %esi
f0101a01:	5f                   	pop    %edi
f0101a02:	5d                   	pop    %ebp
f0101a03:	c3                   	ret    

f0101a04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101a04:	55                   	push   %ebp
f0101a05:	89 e5                	mov    %esp,%ebp
f0101a07:	57                   	push   %edi
f0101a08:	56                   	push   %esi
f0101a09:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a0c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101a12:	39 c6                	cmp    %eax,%esi
f0101a14:	73 35                	jae    f0101a4b <memmove+0x47>
f0101a16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101a19:	39 d0                	cmp    %edx,%eax
f0101a1b:	73 2e                	jae    f0101a4b <memmove+0x47>
		s += n;
		d += n;
f0101a1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0101a20:	89 d6                	mov    %edx,%esi
f0101a22:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101a24:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101a2a:	75 13                	jne    f0101a3f <memmove+0x3b>
f0101a2c:	f6 c1 03             	test   $0x3,%cl
f0101a2f:	75 0e                	jne    f0101a3f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101a31:	83 ef 04             	sub    $0x4,%edi
f0101a34:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101a37:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0101a3a:	fd                   	std    
f0101a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101a3d:	eb 09                	jmp    f0101a48 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101a3f:	83 ef 01             	sub    $0x1,%edi
f0101a42:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101a45:	fd                   	std    
f0101a46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101a48:	fc                   	cld    
f0101a49:	eb 1d                	jmp    f0101a68 <memmove+0x64>
f0101a4b:	89 f2                	mov    %esi,%edx
f0101a4d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101a4f:	f6 c2 03             	test   $0x3,%dl
f0101a52:	75 0f                	jne    f0101a63 <memmove+0x5f>
f0101a54:	f6 c1 03             	test   $0x3,%cl
f0101a57:	75 0a                	jne    f0101a63 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101a59:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101a5c:	89 c7                	mov    %eax,%edi
f0101a5e:	fc                   	cld    
f0101a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101a61:	eb 05                	jmp    f0101a68 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101a63:	89 c7                	mov    %eax,%edi
f0101a65:	fc                   	cld    
f0101a66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101a68:	5e                   	pop    %esi
f0101a69:	5f                   	pop    %edi
f0101a6a:	5d                   	pop    %ebp
f0101a6b:	c3                   	ret    

f0101a6c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101a6c:	55                   	push   %ebp
f0101a6d:	89 e5                	mov    %esp,%ebp
f0101a6f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101a72:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a75:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a79:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a80:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a83:	89 04 24             	mov    %eax,(%esp)
f0101a86:	e8 79 ff ff ff       	call   f0101a04 <memmove>
}
f0101a8b:	c9                   	leave  
f0101a8c:	c3                   	ret    

f0101a8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101a8d:	55                   	push   %ebp
f0101a8e:	89 e5                	mov    %esp,%ebp
f0101a90:	56                   	push   %esi
f0101a91:	53                   	push   %ebx
f0101a92:	8b 55 08             	mov    0x8(%ebp),%edx
f0101a95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101a98:	89 d6                	mov    %edx,%esi
f0101a9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101a9d:	eb 1a                	jmp    f0101ab9 <memcmp+0x2c>
		if (*s1 != *s2)
f0101a9f:	0f b6 02             	movzbl (%edx),%eax
f0101aa2:	0f b6 19             	movzbl (%ecx),%ebx
f0101aa5:	38 d8                	cmp    %bl,%al
f0101aa7:	74 0a                	je     f0101ab3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101aa9:	0f b6 c0             	movzbl %al,%eax
f0101aac:	0f b6 db             	movzbl %bl,%ebx
f0101aaf:	29 d8                	sub    %ebx,%eax
f0101ab1:	eb 0f                	jmp    f0101ac2 <memcmp+0x35>
		s1++, s2++;
f0101ab3:	83 c2 01             	add    $0x1,%edx
f0101ab6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101ab9:	39 f2                	cmp    %esi,%edx
f0101abb:	75 e2                	jne    f0101a9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101ac2:	5b                   	pop    %ebx
f0101ac3:	5e                   	pop    %esi
f0101ac4:	5d                   	pop    %ebp
f0101ac5:	c3                   	ret    

f0101ac6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101ac6:	55                   	push   %ebp
f0101ac7:	89 e5                	mov    %esp,%ebp
f0101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
f0101acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101acf:	89 c2                	mov    %eax,%edx
f0101ad1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101ad4:	eb 07                	jmp    f0101add <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101ad6:	38 08                	cmp    %cl,(%eax)
f0101ad8:	74 07                	je     f0101ae1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101ada:	83 c0 01             	add    $0x1,%eax
f0101add:	39 d0                	cmp    %edx,%eax
f0101adf:	72 f5                	jb     f0101ad6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101ae1:	5d                   	pop    %ebp
f0101ae2:	c3                   	ret    

f0101ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101ae3:	55                   	push   %ebp
f0101ae4:	89 e5                	mov    %esp,%ebp
f0101ae6:	57                   	push   %edi
f0101ae7:	56                   	push   %esi
f0101ae8:	53                   	push   %ebx
f0101ae9:	8b 55 08             	mov    0x8(%ebp),%edx
f0101aec:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101aef:	eb 03                	jmp    f0101af4 <strtol+0x11>
		s++;
f0101af1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101af4:	0f b6 0a             	movzbl (%edx),%ecx
f0101af7:	80 f9 09             	cmp    $0x9,%cl
f0101afa:	74 f5                	je     f0101af1 <strtol+0xe>
f0101afc:	80 f9 20             	cmp    $0x20,%cl
f0101aff:	74 f0                	je     f0101af1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101b01:	80 f9 2b             	cmp    $0x2b,%cl
f0101b04:	75 0a                	jne    f0101b10 <strtol+0x2d>
		s++;
f0101b06:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101b09:	bf 00 00 00 00       	mov    $0x0,%edi
f0101b0e:	eb 11                	jmp    f0101b21 <strtol+0x3e>
f0101b10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101b15:	80 f9 2d             	cmp    $0x2d,%cl
f0101b18:	75 07                	jne    f0101b21 <strtol+0x3e>
		s++, neg = 1;
f0101b1a:	8d 52 01             	lea    0x1(%edx),%edx
f0101b1d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101b21:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0101b26:	75 15                	jne    f0101b3d <strtol+0x5a>
f0101b28:	80 3a 30             	cmpb   $0x30,(%edx)
f0101b2b:	75 10                	jne    f0101b3d <strtol+0x5a>
f0101b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101b31:	75 0a                	jne    f0101b3d <strtol+0x5a>
		s += 2, base = 16;
f0101b33:	83 c2 02             	add    $0x2,%edx
f0101b36:	b8 10 00 00 00       	mov    $0x10,%eax
f0101b3b:	eb 10                	jmp    f0101b4d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0101b3d:	85 c0                	test   %eax,%eax
f0101b3f:	75 0c                	jne    f0101b4d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101b41:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101b43:	80 3a 30             	cmpb   $0x30,(%edx)
f0101b46:	75 05                	jne    f0101b4d <strtol+0x6a>
		s++, base = 8;
f0101b48:	83 c2 01             	add    $0x1,%edx
f0101b4b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0101b4d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101b52:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101b55:	0f b6 0a             	movzbl (%edx),%ecx
f0101b58:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0101b5b:	89 f0                	mov    %esi,%eax
f0101b5d:	3c 09                	cmp    $0x9,%al
f0101b5f:	77 08                	ja     f0101b69 <strtol+0x86>
			dig = *s - '0';
f0101b61:	0f be c9             	movsbl %cl,%ecx
f0101b64:	83 e9 30             	sub    $0x30,%ecx
f0101b67:	eb 20                	jmp    f0101b89 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0101b69:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0101b6c:	89 f0                	mov    %esi,%eax
f0101b6e:	3c 19                	cmp    $0x19,%al
f0101b70:	77 08                	ja     f0101b7a <strtol+0x97>
			dig = *s - 'a' + 10;
f0101b72:	0f be c9             	movsbl %cl,%ecx
f0101b75:	83 e9 57             	sub    $0x57,%ecx
f0101b78:	eb 0f                	jmp    f0101b89 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0101b7a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0101b7d:	89 f0                	mov    %esi,%eax
f0101b7f:	3c 19                	cmp    $0x19,%al
f0101b81:	77 16                	ja     f0101b99 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0101b83:	0f be c9             	movsbl %cl,%ecx
f0101b86:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101b89:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0101b8c:	7d 0f                	jge    f0101b9d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0101b8e:	83 c2 01             	add    $0x1,%edx
f0101b91:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0101b95:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0101b97:	eb bc                	jmp    f0101b55 <strtol+0x72>
f0101b99:	89 d8                	mov    %ebx,%eax
f0101b9b:	eb 02                	jmp    f0101b9f <strtol+0xbc>
f0101b9d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0101b9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101ba3:	74 05                	je     f0101baa <strtol+0xc7>
		*endptr = (char *) s;
f0101ba5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101ba8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0101baa:	f7 d8                	neg    %eax
f0101bac:	85 ff                	test   %edi,%edi
f0101bae:	0f 44 c3             	cmove  %ebx,%eax
}
f0101bb1:	5b                   	pop    %ebx
f0101bb2:	5e                   	pop    %esi
f0101bb3:	5f                   	pop    %edi
f0101bb4:	5d                   	pop    %ebp
f0101bb5:	c3                   	ret    
f0101bb6:	66 90                	xchg   %ax,%ax
f0101bb8:	66 90                	xchg   %ax,%ax
f0101bba:	66 90                	xchg   %ax,%ax
f0101bbc:	66 90                	xchg   %ax,%ax
f0101bbe:	66 90                	xchg   %ax,%ax

f0101bc0 <__udivdi3>:
f0101bc0:	55                   	push   %ebp
f0101bc1:	57                   	push   %edi
f0101bc2:	56                   	push   %esi
f0101bc3:	83 ec 0c             	sub    $0xc,%esp
f0101bc6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101bca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0101bce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0101bd2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101bd6:	85 c0                	test   %eax,%eax
f0101bd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101bdc:	89 ea                	mov    %ebp,%edx
f0101bde:	89 0c 24             	mov    %ecx,(%esp)
f0101be1:	75 2d                	jne    f0101c10 <__udivdi3+0x50>
f0101be3:	39 e9                	cmp    %ebp,%ecx
f0101be5:	77 61                	ja     f0101c48 <__udivdi3+0x88>
f0101be7:	85 c9                	test   %ecx,%ecx
f0101be9:	89 ce                	mov    %ecx,%esi
f0101beb:	75 0b                	jne    f0101bf8 <__udivdi3+0x38>
f0101bed:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bf2:	31 d2                	xor    %edx,%edx
f0101bf4:	f7 f1                	div    %ecx
f0101bf6:	89 c6                	mov    %eax,%esi
f0101bf8:	31 d2                	xor    %edx,%edx
f0101bfa:	89 e8                	mov    %ebp,%eax
f0101bfc:	f7 f6                	div    %esi
f0101bfe:	89 c5                	mov    %eax,%ebp
f0101c00:	89 f8                	mov    %edi,%eax
f0101c02:	f7 f6                	div    %esi
f0101c04:	89 ea                	mov    %ebp,%edx
f0101c06:	83 c4 0c             	add    $0xc,%esp
f0101c09:	5e                   	pop    %esi
f0101c0a:	5f                   	pop    %edi
f0101c0b:	5d                   	pop    %ebp
f0101c0c:	c3                   	ret    
f0101c0d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c10:	39 e8                	cmp    %ebp,%eax
f0101c12:	77 24                	ja     f0101c38 <__udivdi3+0x78>
f0101c14:	0f bd e8             	bsr    %eax,%ebp
f0101c17:	83 f5 1f             	xor    $0x1f,%ebp
f0101c1a:	75 3c                	jne    f0101c58 <__udivdi3+0x98>
f0101c1c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101c20:	39 34 24             	cmp    %esi,(%esp)
f0101c23:	0f 86 9f 00 00 00    	jbe    f0101cc8 <__udivdi3+0x108>
f0101c29:	39 d0                	cmp    %edx,%eax
f0101c2b:	0f 82 97 00 00 00    	jb     f0101cc8 <__udivdi3+0x108>
f0101c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c38:	31 d2                	xor    %edx,%edx
f0101c3a:	31 c0                	xor    %eax,%eax
f0101c3c:	83 c4 0c             	add    $0xc,%esp
f0101c3f:	5e                   	pop    %esi
f0101c40:	5f                   	pop    %edi
f0101c41:	5d                   	pop    %ebp
f0101c42:	c3                   	ret    
f0101c43:	90                   	nop
f0101c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c48:	89 f8                	mov    %edi,%eax
f0101c4a:	f7 f1                	div    %ecx
f0101c4c:	31 d2                	xor    %edx,%edx
f0101c4e:	83 c4 0c             	add    $0xc,%esp
f0101c51:	5e                   	pop    %esi
f0101c52:	5f                   	pop    %edi
f0101c53:	5d                   	pop    %ebp
f0101c54:	c3                   	ret    
f0101c55:	8d 76 00             	lea    0x0(%esi),%esi
f0101c58:	89 e9                	mov    %ebp,%ecx
f0101c5a:	8b 3c 24             	mov    (%esp),%edi
f0101c5d:	d3 e0                	shl    %cl,%eax
f0101c5f:	89 c6                	mov    %eax,%esi
f0101c61:	b8 20 00 00 00       	mov    $0x20,%eax
f0101c66:	29 e8                	sub    %ebp,%eax
f0101c68:	89 c1                	mov    %eax,%ecx
f0101c6a:	d3 ef                	shr    %cl,%edi
f0101c6c:	89 e9                	mov    %ebp,%ecx
f0101c6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101c72:	8b 3c 24             	mov    (%esp),%edi
f0101c75:	09 74 24 08          	or     %esi,0x8(%esp)
f0101c79:	89 d6                	mov    %edx,%esi
f0101c7b:	d3 e7                	shl    %cl,%edi
f0101c7d:	89 c1                	mov    %eax,%ecx
f0101c7f:	89 3c 24             	mov    %edi,(%esp)
f0101c82:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101c86:	d3 ee                	shr    %cl,%esi
f0101c88:	89 e9                	mov    %ebp,%ecx
f0101c8a:	d3 e2                	shl    %cl,%edx
f0101c8c:	89 c1                	mov    %eax,%ecx
f0101c8e:	d3 ef                	shr    %cl,%edi
f0101c90:	09 d7                	or     %edx,%edi
f0101c92:	89 f2                	mov    %esi,%edx
f0101c94:	89 f8                	mov    %edi,%eax
f0101c96:	f7 74 24 08          	divl   0x8(%esp)
f0101c9a:	89 d6                	mov    %edx,%esi
f0101c9c:	89 c7                	mov    %eax,%edi
f0101c9e:	f7 24 24             	mull   (%esp)
f0101ca1:	39 d6                	cmp    %edx,%esi
f0101ca3:	89 14 24             	mov    %edx,(%esp)
f0101ca6:	72 30                	jb     f0101cd8 <__udivdi3+0x118>
f0101ca8:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101cac:	89 e9                	mov    %ebp,%ecx
f0101cae:	d3 e2                	shl    %cl,%edx
f0101cb0:	39 c2                	cmp    %eax,%edx
f0101cb2:	73 05                	jae    f0101cb9 <__udivdi3+0xf9>
f0101cb4:	3b 34 24             	cmp    (%esp),%esi
f0101cb7:	74 1f                	je     f0101cd8 <__udivdi3+0x118>
f0101cb9:	89 f8                	mov    %edi,%eax
f0101cbb:	31 d2                	xor    %edx,%edx
f0101cbd:	e9 7a ff ff ff       	jmp    f0101c3c <__udivdi3+0x7c>
f0101cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101cc8:	31 d2                	xor    %edx,%edx
f0101cca:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ccf:	e9 68 ff ff ff       	jmp    f0101c3c <__udivdi3+0x7c>
f0101cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101cd8:	8d 47 ff             	lea    -0x1(%edi),%eax
f0101cdb:	31 d2                	xor    %edx,%edx
f0101cdd:	83 c4 0c             	add    $0xc,%esp
f0101ce0:	5e                   	pop    %esi
f0101ce1:	5f                   	pop    %edi
f0101ce2:	5d                   	pop    %ebp
f0101ce3:	c3                   	ret    
f0101ce4:	66 90                	xchg   %ax,%ax
f0101ce6:	66 90                	xchg   %ax,%ax
f0101ce8:	66 90                	xchg   %ax,%ax
f0101cea:	66 90                	xchg   %ax,%ax
f0101cec:	66 90                	xchg   %ax,%ax
f0101cee:	66 90                	xchg   %ax,%ax

f0101cf0 <__umoddi3>:
f0101cf0:	55                   	push   %ebp
f0101cf1:	57                   	push   %edi
f0101cf2:	56                   	push   %esi
f0101cf3:	83 ec 14             	sub    $0x14,%esp
f0101cf6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101cfa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101cfe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101d02:	89 c7                	mov    %eax,%edi
f0101d04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d08:	8b 44 24 30          	mov    0x30(%esp),%eax
f0101d0c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101d10:	89 34 24             	mov    %esi,(%esp)
f0101d13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101d17:	85 c0                	test   %eax,%eax
f0101d19:	89 c2                	mov    %eax,%edx
f0101d1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101d1f:	75 17                	jne    f0101d38 <__umoddi3+0x48>
f0101d21:	39 fe                	cmp    %edi,%esi
f0101d23:	76 4b                	jbe    f0101d70 <__umoddi3+0x80>
f0101d25:	89 c8                	mov    %ecx,%eax
f0101d27:	89 fa                	mov    %edi,%edx
f0101d29:	f7 f6                	div    %esi
f0101d2b:	89 d0                	mov    %edx,%eax
f0101d2d:	31 d2                	xor    %edx,%edx
f0101d2f:	83 c4 14             	add    $0x14,%esp
f0101d32:	5e                   	pop    %esi
f0101d33:	5f                   	pop    %edi
f0101d34:	5d                   	pop    %ebp
f0101d35:	c3                   	ret    
f0101d36:	66 90                	xchg   %ax,%ax
f0101d38:	39 f8                	cmp    %edi,%eax
f0101d3a:	77 54                	ja     f0101d90 <__umoddi3+0xa0>
f0101d3c:	0f bd e8             	bsr    %eax,%ebp
f0101d3f:	83 f5 1f             	xor    $0x1f,%ebp
f0101d42:	75 5c                	jne    f0101da0 <__umoddi3+0xb0>
f0101d44:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101d48:	39 3c 24             	cmp    %edi,(%esp)
f0101d4b:	0f 87 e7 00 00 00    	ja     f0101e38 <__umoddi3+0x148>
f0101d51:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101d55:	29 f1                	sub    %esi,%ecx
f0101d57:	19 c7                	sbb    %eax,%edi
f0101d59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101d5d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101d61:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101d65:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101d69:	83 c4 14             	add    $0x14,%esp
f0101d6c:	5e                   	pop    %esi
f0101d6d:	5f                   	pop    %edi
f0101d6e:	5d                   	pop    %ebp
f0101d6f:	c3                   	ret    
f0101d70:	85 f6                	test   %esi,%esi
f0101d72:	89 f5                	mov    %esi,%ebp
f0101d74:	75 0b                	jne    f0101d81 <__umoddi3+0x91>
f0101d76:	b8 01 00 00 00       	mov    $0x1,%eax
f0101d7b:	31 d2                	xor    %edx,%edx
f0101d7d:	f7 f6                	div    %esi
f0101d7f:	89 c5                	mov    %eax,%ebp
f0101d81:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101d85:	31 d2                	xor    %edx,%edx
f0101d87:	f7 f5                	div    %ebp
f0101d89:	89 c8                	mov    %ecx,%eax
f0101d8b:	f7 f5                	div    %ebp
f0101d8d:	eb 9c                	jmp    f0101d2b <__umoddi3+0x3b>
f0101d8f:	90                   	nop
f0101d90:	89 c8                	mov    %ecx,%eax
f0101d92:	89 fa                	mov    %edi,%edx
f0101d94:	83 c4 14             	add    $0x14,%esp
f0101d97:	5e                   	pop    %esi
f0101d98:	5f                   	pop    %edi
f0101d99:	5d                   	pop    %ebp
f0101d9a:	c3                   	ret    
f0101d9b:	90                   	nop
f0101d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101da0:	8b 04 24             	mov    (%esp),%eax
f0101da3:	be 20 00 00 00       	mov    $0x20,%esi
f0101da8:	89 e9                	mov    %ebp,%ecx
f0101daa:	29 ee                	sub    %ebp,%esi
f0101dac:	d3 e2                	shl    %cl,%edx
f0101dae:	89 f1                	mov    %esi,%ecx
f0101db0:	d3 e8                	shr    %cl,%eax
f0101db2:	89 e9                	mov    %ebp,%ecx
f0101db4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101db8:	8b 04 24             	mov    (%esp),%eax
f0101dbb:	09 54 24 04          	or     %edx,0x4(%esp)
f0101dbf:	89 fa                	mov    %edi,%edx
f0101dc1:	d3 e0                	shl    %cl,%eax
f0101dc3:	89 f1                	mov    %esi,%ecx
f0101dc5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101dc9:	8b 44 24 10          	mov    0x10(%esp),%eax
f0101dcd:	d3 ea                	shr    %cl,%edx
f0101dcf:	89 e9                	mov    %ebp,%ecx
f0101dd1:	d3 e7                	shl    %cl,%edi
f0101dd3:	89 f1                	mov    %esi,%ecx
f0101dd5:	d3 e8                	shr    %cl,%eax
f0101dd7:	89 e9                	mov    %ebp,%ecx
f0101dd9:	09 f8                	or     %edi,%eax
f0101ddb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0101ddf:	f7 74 24 04          	divl   0x4(%esp)
f0101de3:	d3 e7                	shl    %cl,%edi
f0101de5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101de9:	89 d7                	mov    %edx,%edi
f0101deb:	f7 64 24 08          	mull   0x8(%esp)
f0101def:	39 d7                	cmp    %edx,%edi
f0101df1:	89 c1                	mov    %eax,%ecx
f0101df3:	89 14 24             	mov    %edx,(%esp)
f0101df6:	72 2c                	jb     f0101e24 <__umoddi3+0x134>
f0101df8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0101dfc:	72 22                	jb     f0101e20 <__umoddi3+0x130>
f0101dfe:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101e02:	29 c8                	sub    %ecx,%eax
f0101e04:	19 d7                	sbb    %edx,%edi
f0101e06:	89 e9                	mov    %ebp,%ecx
f0101e08:	89 fa                	mov    %edi,%edx
f0101e0a:	d3 e8                	shr    %cl,%eax
f0101e0c:	89 f1                	mov    %esi,%ecx
f0101e0e:	d3 e2                	shl    %cl,%edx
f0101e10:	89 e9                	mov    %ebp,%ecx
f0101e12:	d3 ef                	shr    %cl,%edi
f0101e14:	09 d0                	or     %edx,%eax
f0101e16:	89 fa                	mov    %edi,%edx
f0101e18:	83 c4 14             	add    $0x14,%esp
f0101e1b:	5e                   	pop    %esi
f0101e1c:	5f                   	pop    %edi
f0101e1d:	5d                   	pop    %ebp
f0101e1e:	c3                   	ret    
f0101e1f:	90                   	nop
f0101e20:	39 d7                	cmp    %edx,%edi
f0101e22:	75 da                	jne    f0101dfe <__umoddi3+0x10e>
f0101e24:	8b 14 24             	mov    (%esp),%edx
f0101e27:	89 c1                	mov    %eax,%ecx
f0101e29:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0101e2d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0101e31:	eb cb                	jmp    f0101dfe <__umoddi3+0x10e>
f0101e33:	90                   	nop
f0101e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101e38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0101e3c:	0f 82 0f ff ff ff    	jb     f0101d51 <__umoddi3+0x61>
f0101e42:	e9 1a ff ff ff       	jmp    f0101d61 <__umoddi3+0x71>
