
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a0013103          	ld	sp,-1536(sp) # 80008a00 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	a2070713          	addi	a4,a4,-1504 # 80008a70 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	01e78793          	addi	a5,a5,30 # 80006080 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc91f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e9478793          	addi	a5,a5,-364 # 80000f40 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	60e080e7          	jalr	1550(ra) # 80002738 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	796080e7          	jalr	1942(ra) # 800008d0 <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    }

    return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
    for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000186:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	a2650513          	addi	a0,a0,-1498 # 80010bb0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	b0c080e7          	jalr	-1268(ra) # 80000c9e <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	a1648493          	addi	s1,s1,-1514 # 80010bb0 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	aa690913          	addi	s2,s2,-1370 # 80010c48 <cons+0x98>
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

        if (c == C('D'))
    800001aa:	4b91                	li	s7,4
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
            break;

        dst++;
        --n;

        if (c == '\n')
    800001ae:	4ca9                	li	s9,10
    while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
        while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
            if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	9b2080e7          	jalr	-1614(ra) # 80001b72 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	3ba080e7          	jalr	954(ra) # 80002582 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	104080e7          	jalr	260(ra) # 800022da <sleep>
        while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
        if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
        cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	4d0080e7          	jalr	1232(ra) # 800026e2 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
        dst++;
    8000021e:	0a05                	addi	s4,s4,1
        --n;
    80000220:	39fd                	addiw	s3,s3,-1
        if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
            // a whole line has arrived, return to
            // the user-level read().
            break;
        }
    }
    release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	98a50513          	addi	a0,a0,-1654 # 80010bb0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	b24080e7          	jalr	-1244(ra) # 80000d52 <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	97450513          	addi	a0,a0,-1676 # 80010bb0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	b0e080e7          	jalr	-1266(ra) # 80000d52 <release>
                return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
            if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
                cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	9cf72b23          	sw	a5,-1578(a4) # 80010c48 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
        uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	572080e7          	jalr	1394(ra) # 800007fe <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
        uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	560080e7          	jalr	1376(ra) # 800007fe <uartputc_sync>
        uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	554080e7          	jalr	1364(ra) # 800007fe <uartputc_sync>
        uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	54a080e7          	jalr	1354(ra) # 800007fe <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	8e450513          	addi	a0,a0,-1820 # 80010bb0 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	9ca080e7          	jalr	-1590(ra) # 80000c9e <acquire>

    switch (c)
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
    {
    case C('P'): // Print process list.
        procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	49c080e7          	jalr	1180(ra) # 8000278e <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	8b650513          	addi	a0,a0,-1866 # 80010bb0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	a50080e7          	jalr	-1456(ra) # 80000d52 <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
    switch (c)
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	89270713          	addi	a4,a4,-1902 # 80010bb0 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
            c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
            consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	86878793          	addi	a5,a5,-1944 # 80010bb0 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	8d27a783          	lw	a5,-1838(a5) # 80010c48 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
        while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	82670713          	addi	a4,a4,-2010 # 80010bb0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	81648493          	addi	s1,s1,-2026 # 80010bb0 <cons>
        while (cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
            cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
        while (cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
        if (cons.e != cons.w)
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	7da70713          	addi	a4,a4,2010 # 80010bb0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
            cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	86f72223          	sw	a5,-1948(a4) # 80010c50 <cons+0xa0>
            consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
            consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	79e78793          	addi	a5,a5,1950 # 80010bb0 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	80c7ab23          	sw	a2,-2026(a5) # 80010c4c <cons+0x9c>
                wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	80a50513          	addi	a0,a0,-2038 # 80010c48 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	ef8080e7          	jalr	-264(ra) # 8000233e <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bc858593          	addi	a1,a1,-1080 # 80008020 <__func__.1+0x18>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	75050513          	addi	a0,a0,1872 # 80010bb0 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	7a6080e7          	jalr	1958(ra) # 80000c0e <initlock>

    uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	33e080e7          	jalr	830(ra) # 800007ae <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	8d078793          	addi	a5,a5,-1840 # 80020d48 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
    char buf[16];
    int i;
    uint x;

    if (sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
        x = -xx;
    else
        x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

    i = 0;
    800004b6:	4701                	li	a4,0
    do
    {
        buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b9660613          	addi	a2,a2,-1130 # 80008050 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

    if (sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
        buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
        consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
    while (--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
        x = -xx;
    80000538:	40a0053b          	negw	a0,a0
    if (sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
        x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000540:	711d                	addi	sp,sp,-96
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
    8000054c:	e40c                	sd	a1,8(s0)
    8000054e:	e810                	sd	a2,16(s0)
    80000550:	ec14                	sd	a3,24(s0)
    80000552:	f018                	sd	a4,32(s0)
    80000554:	f41c                	sd	a5,40(s0)
    80000556:	03043823          	sd	a6,48(s0)
    8000055a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000055e:	00010797          	auipc	a5,0x10
    80000562:	7007a923          	sw	zero,1810(a5) # 80010c70 <pr+0x18>
    printf("panic: ");
    80000566:	00008517          	auipc	a0,0x8
    8000056a:	ac250513          	addi	a0,a0,-1342 # 80008028 <__func__.1+0x20>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	02e080e7          	jalr	46(ra) # 8000059c <printf>
    printf(s);
    80000576:	8526                	mv	a0,s1
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	024080e7          	jalr	36(ra) # 8000059c <printf>
    printf("\n");
    80000580:	00008517          	auipc	a0,0x8
    80000584:	b0850513          	addi	a0,a0,-1272 # 80008088 <digits+0x38>
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	014080e7          	jalr	20(ra) # 8000059c <printf>
    panicked = 1; // freeze uart output from other CPUs
    80000590:	4785                	li	a5,1
    80000592:	00008717          	auipc	a4,0x8
    80000596:	48f72723          	sw	a5,1166(a4) # 80008a20 <panicked>
    for (;;)
    8000059a:	a001                	j	8000059a <panic+0x5a>

000000008000059c <printf>:
{
    8000059c:	7131                	addi	sp,sp,-192
    8000059e:	fc86                	sd	ra,120(sp)
    800005a0:	f8a2                	sd	s0,112(sp)
    800005a2:	f4a6                	sd	s1,104(sp)
    800005a4:	f0ca                	sd	s2,96(sp)
    800005a6:	ecce                	sd	s3,88(sp)
    800005a8:	e8d2                	sd	s4,80(sp)
    800005aa:	e4d6                	sd	s5,72(sp)
    800005ac:	e0da                	sd	s6,64(sp)
    800005ae:	fc5e                	sd	s7,56(sp)
    800005b0:	f862                	sd	s8,48(sp)
    800005b2:	f466                	sd	s9,40(sp)
    800005b4:	f06a                	sd	s10,32(sp)
    800005b6:	ec6e                	sd	s11,24(sp)
    800005b8:	0100                	addi	s0,sp,128
    800005ba:	8a2a                	mv	s4,a0
    800005bc:	e40c                	sd	a1,8(s0)
    800005be:	e810                	sd	a2,16(s0)
    800005c0:	ec14                	sd	a3,24(s0)
    800005c2:	f018                	sd	a4,32(s0)
    800005c4:	f41c                	sd	a5,40(s0)
    800005c6:	03043823          	sd	a6,48(s0)
    800005ca:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005ce:	00010d97          	auipc	s11,0x10
    800005d2:	6a2dad83          	lw	s11,1698(s11) # 80010c70 <pr+0x18>
    if (locking)
    800005d6:	020d9b63          	bnez	s11,8000060c <printf+0x70>
    if (fmt == 0)
    800005da:	040a0263          	beqz	s4,8000061e <printf+0x82>
    va_start(ap, fmt);
    800005de:	00840793          	addi	a5,s0,8
    800005e2:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005e6:	000a4503          	lbu	a0,0(s4)
    800005ea:	14050f63          	beqz	a0,80000748 <printf+0x1ac>
    800005ee:	4981                	li	s3,0
        if (c != '%')
    800005f0:	02500a93          	li	s5,37
        switch (c)
    800005f4:	07000b93          	li	s7,112
    consputc('x');
    800005f8:	4d41                	li	s10,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005fa:	00008b17          	auipc	s6,0x8
    800005fe:	a56b0b13          	addi	s6,s6,-1450 # 80008050 <digits>
        switch (c)
    80000602:	07300c93          	li	s9,115
    80000606:	06400c13          	li	s8,100
    8000060a:	a82d                	j	80000644 <printf+0xa8>
        acquire(&pr.lock);
    8000060c:	00010517          	auipc	a0,0x10
    80000610:	64c50513          	addi	a0,a0,1612 # 80010c58 <pr>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	68a080e7          	jalr	1674(ra) # 80000c9e <acquire>
    8000061c:	bf7d                	j	800005da <printf+0x3e>
        panic("null fmt");
    8000061e:	00008517          	auipc	a0,0x8
    80000622:	a1a50513          	addi	a0,a0,-1510 # 80008038 <__func__.1+0x30>
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	f1a080e7          	jalr	-230(ra) # 80000540 <panic>
            consputc(c);
    8000062e:	00000097          	auipc	ra,0x0
    80000632:	c4e080e7          	jalr	-946(ra) # 8000027c <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c503          	lbu	a0,0(a5)
    80000640:	10050463          	beqz	a0,80000748 <printf+0x1ac>
        if (c != '%')
    80000644:	ff5515e3          	bne	a0,s5,8000062e <printf+0x92>
        c = fmt[++i] & 0xff;
    80000648:	2985                	addiw	s3,s3,1
    8000064a:	013a07b3          	add	a5,s4,s3
    8000064e:	0007c783          	lbu	a5,0(a5)
    80000652:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000656:	cbed                	beqz	a5,80000748 <printf+0x1ac>
        switch (c)
    80000658:	05778a63          	beq	a5,s7,800006ac <printf+0x110>
    8000065c:	02fbf663          	bgeu	s7,a5,80000688 <printf+0xec>
    80000660:	09978863          	beq	a5,s9,800006f0 <printf+0x154>
    80000664:	07800713          	li	a4,120
    80000668:	0ce79563          	bne	a5,a4,80000732 <printf+0x196>
            printint(va_arg(ap, int), 16, 1);
    8000066c:	f8843783          	ld	a5,-120(s0)
    80000670:	00878713          	addi	a4,a5,8
    80000674:	f8e43423          	sd	a4,-120(s0)
    80000678:	4605                	li	a2,1
    8000067a:	85ea                	mv	a1,s10
    8000067c:	4388                	lw	a0,0(a5)
    8000067e:	00000097          	auipc	ra,0x0
    80000682:	e1e080e7          	jalr	-482(ra) # 8000049c <printint>
            break;
    80000686:	bf45                	j	80000636 <printf+0x9a>
        switch (c)
    80000688:	09578f63          	beq	a5,s5,80000726 <printf+0x18a>
    8000068c:	0b879363          	bne	a5,s8,80000732 <printf+0x196>
            printint(va_arg(ap, int), 10, 1);
    80000690:	f8843783          	ld	a5,-120(s0)
    80000694:	00878713          	addi	a4,a5,8
    80000698:	f8e43423          	sd	a4,-120(s0)
    8000069c:	4605                	li	a2,1
    8000069e:	45a9                	li	a1,10
    800006a0:	4388                	lw	a0,0(a5)
    800006a2:	00000097          	auipc	ra,0x0
    800006a6:	dfa080e7          	jalr	-518(ra) # 8000049c <printint>
            break;
    800006aa:	b771                	j	80000636 <printf+0x9a>
            printptr(va_arg(ap, uint64));
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	addi	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006bc:	03000513          	li	a0,48
    800006c0:	00000097          	auipc	ra,0x0
    800006c4:	bbc080e7          	jalr	-1092(ra) # 8000027c <consputc>
    consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
    800006d4:	84ea                	mv	s1,s10
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d6:	03c95793          	srli	a5,s2,0x3c
    800006da:	97da                	add	a5,a5,s6
    800006dc:	0007c503          	lbu	a0,0(a5)
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	b9c080e7          	jalr	-1124(ra) # 8000027c <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0912                	slli	s2,s2,0x4
    800006ea:	34fd                	addiw	s1,s1,-1
    800006ec:	f4ed                	bnez	s1,800006d6 <printf+0x13a>
    800006ee:	b7a1                	j	80000636 <printf+0x9a>
            if ((s = va_arg(ap, char *)) == 0)
    800006f0:	f8843783          	ld	a5,-120(s0)
    800006f4:	00878713          	addi	a4,a5,8
    800006f8:	f8e43423          	sd	a4,-120(s0)
    800006fc:	6384                	ld	s1,0(a5)
    800006fe:	cc89                	beqz	s1,80000718 <printf+0x17c>
            for (; *s; s++)
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	d90d                	beqz	a0,80000636 <printf+0x9a>
                consputc(*s);
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	b76080e7          	jalr	-1162(ra) # 8000027c <consputc>
            for (; *s; s++)
    8000070e:	0485                	addi	s1,s1,1
    80000710:	0004c503          	lbu	a0,0(s1)
    80000714:	f96d                	bnez	a0,80000706 <printf+0x16a>
    80000716:	b705                	j	80000636 <printf+0x9a>
                s = "(null)";
    80000718:	00008497          	auipc	s1,0x8
    8000071c:	91848493          	addi	s1,s1,-1768 # 80008030 <__func__.1+0x28>
            for (; *s; s++)
    80000720:	02800513          	li	a0,40
    80000724:	b7cd                	j	80000706 <printf+0x16a>
            consputc('%');
    80000726:	8556                	mv	a0,s5
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b54080e7          	jalr	-1196(ra) # 8000027c <consputc>
            break;
    80000730:	b719                	j	80000636 <printf+0x9a>
            consputc('%');
    80000732:	8556                	mv	a0,s5
    80000734:	00000097          	auipc	ra,0x0
    80000738:	b48080e7          	jalr	-1208(ra) # 8000027c <consputc>
            consputc(c);
    8000073c:	8526                	mv	a0,s1
    8000073e:	00000097          	auipc	ra,0x0
    80000742:	b3e080e7          	jalr	-1218(ra) # 8000027c <consputc>
            break;
    80000746:	bdc5                	j	80000636 <printf+0x9a>
    if (locking)
    80000748:	020d9163          	bnez	s11,8000076a <printf+0x1ce>
}
    8000074c:	70e6                	ld	ra,120(sp)
    8000074e:	7446                	ld	s0,112(sp)
    80000750:	74a6                	ld	s1,104(sp)
    80000752:	7906                	ld	s2,96(sp)
    80000754:	69e6                	ld	s3,88(sp)
    80000756:	6a46                	ld	s4,80(sp)
    80000758:	6aa6                	ld	s5,72(sp)
    8000075a:	6b06                	ld	s6,64(sp)
    8000075c:	7be2                	ld	s7,56(sp)
    8000075e:	7c42                	ld	s8,48(sp)
    80000760:	7ca2                	ld	s9,40(sp)
    80000762:	7d02                	ld	s10,32(sp)
    80000764:	6de2                	ld	s11,24(sp)
    80000766:	6129                	addi	sp,sp,192
    80000768:	8082                	ret
        release(&pr.lock);
    8000076a:	00010517          	auipc	a0,0x10
    8000076e:	4ee50513          	addi	a0,a0,1262 # 80010c58 <pr>
    80000772:	00000097          	auipc	ra,0x0
    80000776:	5e0080e7          	jalr	1504(ra) # 80000d52 <release>
}
    8000077a:	bfc9                	j	8000074c <printf+0x1b0>

000000008000077c <printfinit>:
        ;
}

void printfinit(void)
{
    8000077c:	1101                	addi	sp,sp,-32
    8000077e:	ec06                	sd	ra,24(sp)
    80000780:	e822                	sd	s0,16(sp)
    80000782:	e426                	sd	s1,8(sp)
    80000784:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    80000786:	00010497          	auipc	s1,0x10
    8000078a:	4d248493          	addi	s1,s1,1234 # 80010c58 <pr>
    8000078e:	00008597          	auipc	a1,0x8
    80000792:	8ba58593          	addi	a1,a1,-1862 # 80008048 <__func__.1+0x40>
    80000796:	8526                	mv	a0,s1
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	476080e7          	jalr	1142(ra) # 80000c0e <initlock>
    pr.locking = 1;
    800007a0:	4785                	li	a5,1
    800007a2:	cc9c                	sw	a5,24(s1)
}
    800007a4:	60e2                	ld	ra,24(sp)
    800007a6:	6442                	ld	s0,16(sp)
    800007a8:	64a2                	ld	s1,8(sp)
    800007aa:	6105                	addi	sp,sp,32
    800007ac:	8082                	ret

00000000800007ae <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007ae:	1141                	addi	sp,sp,-16
    800007b0:	e406                	sd	ra,8(sp)
    800007b2:	e022                	sd	s0,0(sp)
    800007b4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b6:	100007b7          	lui	a5,0x10000
    800007ba:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007be:	f8000713          	li	a4,-128
    800007c2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c6:	470d                	li	a4,3
    800007c8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007cc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007d0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d4:	469d                	li	a3,7
    800007d6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007da:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007de:	00008597          	auipc	a1,0x8
    800007e2:	88a58593          	addi	a1,a1,-1910 # 80008068 <digits+0x18>
    800007e6:	00010517          	auipc	a0,0x10
    800007ea:	49250513          	addi	a0,a0,1170 # 80010c78 <uart_tx_lock>
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	420080e7          	jalr	1056(ra) # 80000c0e <initlock>
}
    800007f6:	60a2                	ld	ra,8(sp)
    800007f8:	6402                	ld	s0,0(sp)
    800007fa:	0141                	addi	sp,sp,16
    800007fc:	8082                	ret

00000000800007fe <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fe:	1101                	addi	sp,sp,-32
    80000800:	ec06                	sd	ra,24(sp)
    80000802:	e822                	sd	s0,16(sp)
    80000804:	e426                	sd	s1,8(sp)
    80000806:	1000                	addi	s0,sp,32
    80000808:	84aa                	mv	s1,a0
  push_off();
    8000080a:	00000097          	auipc	ra,0x0
    8000080e:	448080e7          	jalr	1096(ra) # 80000c52 <push_off>

  if(panicked){
    80000812:	00008797          	auipc	a5,0x8
    80000816:	20e7a783          	lw	a5,526(a5) # 80008a20 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081e:	c391                	beqz	a5,80000822 <uartputc_sync+0x24>
    for(;;)
    80000820:	a001                	j	80000820 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000822:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dfe5                	beqz	a5,80000822 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f513          	zext.b	a0,s1
    80000830:	100007b7          	lui	a5,0x10000
    80000834:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	4ba080e7          	jalr	1210(ra) # 80000cf2 <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	1de7b783          	ld	a5,478(a5) # 80008a28 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	1de73703          	ld	a4,478(a4) # 80008a30 <uart_tx_w>
    8000085a:	06f70a63          	beq	a4,a5,800008ce <uartstart+0x84>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000874:	00010a17          	auipc	s4,0x10
    80000878:	404a0a13          	addi	s4,s4,1028 # 80010c78 <uart_tx_lock>
    uart_tx_r += 1;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	1ac48493          	addi	s1,s1,428 # 80008a28 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	1ac98993          	addi	s3,s3,428 # 80008a30 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	02077713          	andi	a4,a4,32
    80000894:	c705                	beqz	a4,800008bc <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f7f713          	andi	a4,a5,31
    8000089a:	9752                	add	a4,a4,s4
    8000089c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800008a0:	0785                	addi	a5,a5,1
    800008a2:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	a98080e7          	jalr	-1384(ra) # 8000233e <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	609c                	ld	a5,0(s1)
    800008b4:	0009b703          	ld	a4,0(s3)
    800008b8:	fcf71ae3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	39650513          	addi	a0,a0,918 # 80010c78 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	3b4080e7          	jalr	948(ra) # 80000c9e <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	12e7a783          	lw	a5,302(a5) # 80008a20 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008717          	auipc	a4,0x8
    80000900:	13473703          	ld	a4,308(a4) # 80008a30 <uart_tx_w>
    80000904:	00008797          	auipc	a5,0x8
    80000908:	1247b783          	ld	a5,292(a5) # 80008a28 <uart_tx_r>
    8000090c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010997          	auipc	s3,0x10
    80000914:	36898993          	addi	s3,s3,872 # 80010c78 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	11048493          	addi	s1,s1,272 # 80008a28 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	11090913          	addi	s2,s2,272 # 80008a30 <uart_tx_w>
    80000928:	00e79f63          	bne	a5,a4,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85ce                	mv	a1,s3
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	9aa080e7          	jalr	-1622(ra) # 800022da <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093703          	ld	a4,0(s2)
    8000093c:	609c                	ld	a5,0(s1)
    8000093e:	02078793          	addi	a5,a5,32
    80000942:	fee785e3          	beq	a5,a4,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	33248493          	addi	s1,s1,818 # 80010c78 <uart_tx_lock>
    8000094e:	01f77793          	andi	a5,a4,31
    80000952:	97a6                	add	a5,a5,s1
    80000954:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000958:	0705                	addi	a4,a4,1
    8000095a:	00008797          	auipc	a5,0x8
    8000095e:	0ce7bb23          	sd	a4,214(a5) # 80008a30 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee8080e7          	jalr	-280(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	3e6080e7          	jalr	998(ra) # 80000d52 <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb81                	beqz	a5,800009a6 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a0:	6422                	ld	s0,8(sp)
    800009a2:	0141                	addi	sp,sp,16
    800009a4:	8082                	ret
    return -1;
    800009a6:	557d                	li	a0,-1
    800009a8:	bfe5                	j	800009a0 <uartgetc+0x1a>

00000000800009aa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009aa:	1101                	addi	sp,sp,-32
    800009ac:	ec06                	sd	ra,24(sp)
    800009ae:	e822                	sd	s0,16(sp)
    800009b0:	e426                	sd	s1,8(sp)
    800009b2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b4:	54fd                	li	s1,-1
    800009b6:	a029                	j	800009c0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	906080e7          	jalr	-1786(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	fc6080e7          	jalr	-58(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c8:	fe9518e3          	bne	a0,s1,800009b8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009cc:	00010497          	auipc	s1,0x10
    800009d0:	2ac48493          	addi	s1,s1,684 # 80010c78 <uart_tx_lock>
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2c8080e7          	jalr	712(ra) # 80000c9e <acquire>
  uartstart();
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	e6c080e7          	jalr	-404(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    800009e6:	8526                	mv	a0,s1
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	36a080e7          	jalr	874(ra) # 80000d52 <release>
}
    800009f0:	60e2                	ld	ra,24(sp)
    800009f2:	6442                	ld	s0,16(sp)
    800009f4:	64a2                	ld	s1,8(sp)
    800009f6:	6105                	addi	sp,sp,32
    800009f8:	8082                	ret

00000000800009fa <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	e04a                	sd	s2,0(sp)
    80000a04:	1000                	addi	s0,sp,32
    80000a06:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a08:	00008797          	auipc	a5,0x8
    80000a0c:	0387b783          	ld	a5,56(a5) # 80008a40 <MAX_PAGES>
    80000a10:	c799                	beqz	a5,80000a1e <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a12:	00008717          	auipc	a4,0x8
    80000a16:	02673703          	ld	a4,38(a4) # 80008a38 <FREE_PAGES>
    80000a1a:	06f77663          	bgeu	a4,a5,80000a86 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03449793          	slli	a5,s1,0x34
    80000a22:	efc1                	bnez	a5,80000aba <kfree+0xc0>
    80000a24:	00021797          	auipc	a5,0x21
    80000a28:	4bc78793          	addi	a5,a5,1212 # 80021ee0 <end>
    80000a2c:	08f4e763          	bltu	s1,a5,80000aba <kfree+0xc0>
    80000a30:	47c5                	li	a5,17
    80000a32:	07ee                	slli	a5,a5,0x1b
    80000a34:	08f4f363          	bgeu	s1,a5,80000aba <kfree+0xc0>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a38:	6605                	lui	a2,0x1
    80000a3a:	4585                	li	a1,1
    80000a3c:	8526                	mv	a0,s1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	35c080e7          	jalr	860(ra) # 80000d9a <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000a46:	00010917          	auipc	s2,0x10
    80000a4a:	26a90913          	addi	s2,s2,618 # 80010cb0 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	24e080e7          	jalr	590(ra) # 80000c9e <acquire>
    r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000a62:	00008717          	auipc	a4,0x8
    80000a66:	fd670713          	addi	a4,a4,-42 # 80008a38 <FREE_PAGES>
    80000a6a:	631c                	ld	a5,0(a4)
    80000a6c:	0785                	addi	a5,a5,1
    80000a6e:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000a70:	854a                	mv	a0,s2
    80000a72:	00000097          	auipc	ra,0x0
    80000a76:	2e0080e7          	jalr	736(ra) # 80000d52 <release>
}
    80000a7a:	60e2                	ld	ra,24(sp)
    80000a7c:	6442                	ld	s0,16(sp)
    80000a7e:	64a2                	ld	s1,8(sp)
    80000a80:	6902                	ld	s2,0(sp)
    80000a82:	6105                	addi	sp,sp,32
    80000a84:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000a86:	03700693          	li	a3,55
    80000a8a:	00007617          	auipc	a2,0x7
    80000a8e:	57e60613          	addi	a2,a2,1406 # 80008008 <__func__.1>
    80000a92:	00007597          	auipc	a1,0x7
    80000a96:	5de58593          	addi	a1,a1,1502 # 80008070 <digits+0x20>
    80000a9a:	00007517          	auipc	a0,0x7
    80000a9e:	5e650513          	addi	a0,a0,1510 # 80008080 <digits+0x30>
    80000aa2:	00000097          	auipc	ra,0x0
    80000aa6:	afa080e7          	jalr	-1286(ra) # 8000059c <printf>
    80000aaa:	00007517          	auipc	a0,0x7
    80000aae:	5e650513          	addi	a0,a0,1510 # 80008090 <digits+0x40>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	a8e080e7          	jalr	-1394(ra) # 80000540 <panic>
        panic("kfree");
    80000aba:	00007517          	auipc	a0,0x7
    80000abe:	5e650513          	addi	a0,a0,1510 # 800080a0 <digits+0x50>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	a7e080e7          	jalr	-1410(ra) # 80000540 <panic>

0000000080000aca <freerange>:
{
    80000aca:	7179                	addi	sp,sp,-48
    80000acc:	f406                	sd	ra,40(sp)
    80000ace:	f022                	sd	s0,32(sp)
    80000ad0:	ec26                	sd	s1,24(sp)
    80000ad2:	e84a                	sd	s2,16(sp)
    80000ad4:	e44e                	sd	s3,8(sp)
    80000ad6:	e052                	sd	s4,0(sp)
    80000ad8:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000ada:	6785                	lui	a5,0x1
    80000adc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae0:	00e504b3          	add	s1,a0,a4
    80000ae4:	777d                	lui	a4,0xfffff
    80000ae6:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ae8:	94be                	add	s1,s1,a5
    80000aea:	0095ee63          	bltu	a1,s1,80000b06 <freerange+0x3c>
    80000aee:	892e                	mv	s2,a1
        kfree(p);
    80000af0:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000af2:	6985                	lui	s3,0x1
        kfree(p);
    80000af4:	01448533          	add	a0,s1,s4
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	f02080e7          	jalr	-254(ra) # 800009fa <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b00:	94ce                	add	s1,s1,s3
    80000b02:	fe9979e3          	bgeu	s2,s1,80000af4 <freerange+0x2a>
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6942                	ld	s2,16(sp)
    80000b0e:	69a2                	ld	s3,8(sp)
    80000b10:	6a02                	ld	s4,0(sp)
    80000b12:	6145                	addi	sp,sp,48
    80000b14:	8082                	ret

0000000080000b16 <kinit>:
{
    80000b16:	1141                	addi	sp,sp,-16
    80000b18:	e406                	sd	ra,8(sp)
    80000b1a:	e022                	sd	s0,0(sp)
    80000b1c:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000b1e:	00007597          	auipc	a1,0x7
    80000b22:	58a58593          	addi	a1,a1,1418 # 800080a8 <digits+0x58>
    80000b26:	00010517          	auipc	a0,0x10
    80000b2a:	18a50513          	addi	a0,a0,394 # 80010cb0 <kmem>
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	0e0080e7          	jalr	224(ra) # 80000c0e <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00021517          	auipc	a0,0x21
    80000b3e:	3a650513          	addi	a0,a0,934 # 80021ee0 <end>
    80000b42:	00000097          	auipc	ra,0x0
    80000b46:	f88080e7          	jalr	-120(ra) # 80000aca <freerange>
    MAX_PAGES = FREE_PAGES;
    80000b4a:	00008797          	auipc	a5,0x8
    80000b4e:	eee7b783          	ld	a5,-274(a5) # 80008a38 <FREE_PAGES>
    80000b52:	00008717          	auipc	a4,0x8
    80000b56:	eef73723          	sd	a5,-274(a4) # 80008a40 <MAX_PAGES>
}
    80000b5a:	60a2                	ld	ra,8(sp)
    80000b5c:	6402                	ld	s0,0(sp)
    80000b5e:	0141                	addi	sp,sp,16
    80000b60:	8082                	ret

0000000080000b62 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b62:	1101                	addi	sp,sp,-32
    80000b64:	ec06                	sd	ra,24(sp)
    80000b66:	e822                	sd	s0,16(sp)
    80000b68:	e426                	sd	s1,8(sp)
    80000b6a:	1000                	addi	s0,sp,32
    assert(FREE_PAGES > 0);
    80000b6c:	00008797          	auipc	a5,0x8
    80000b70:	ecc7b783          	ld	a5,-308(a5) # 80008a38 <FREE_PAGES>
    80000b74:	cbb1                	beqz	a5,80000bc8 <kalloc+0x66>
    struct run *r;

    acquire(&kmem.lock);
    80000b76:	00010497          	auipc	s1,0x10
    80000b7a:	13a48493          	addi	s1,s1,314 # 80010cb0 <kmem>
    80000b7e:	8526                	mv	a0,s1
    80000b80:	00000097          	auipc	ra,0x0
    80000b84:	11e080e7          	jalr	286(ra) # 80000c9e <acquire>
    r = kmem.freelist;
    80000b88:	6c84                	ld	s1,24(s1)
    if (r)
    80000b8a:	c8ad                	beqz	s1,80000bfc <kalloc+0x9a>
        kmem.freelist = r->next;
    80000b8c:	609c                	ld	a5,0(s1)
    80000b8e:	00010517          	auipc	a0,0x10
    80000b92:	12250513          	addi	a0,a0,290 # 80010cb0 <kmem>
    80000b96:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	1ba080e7          	jalr	442(ra) # 80000d52 <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000ba0:	6605                	lui	a2,0x1
    80000ba2:	4595                	li	a1,5
    80000ba4:	8526                	mv	a0,s1
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	1f4080e7          	jalr	500(ra) # 80000d9a <memset>
    FREE_PAGES--;
    80000bae:	00008717          	auipc	a4,0x8
    80000bb2:	e8a70713          	addi	a4,a4,-374 # 80008a38 <FREE_PAGES>
    80000bb6:	631c                	ld	a5,0(a4)
    80000bb8:	17fd                	addi	a5,a5,-1
    80000bba:	e31c                	sd	a5,0(a4)
    return (void *)r;
}
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	60e2                	ld	ra,24(sp)
    80000bc0:	6442                	ld	s0,16(sp)
    80000bc2:	64a2                	ld	s1,8(sp)
    80000bc4:	6105                	addi	sp,sp,32
    80000bc6:	8082                	ret
    assert(FREE_PAGES > 0);
    80000bc8:	04f00693          	li	a3,79
    80000bcc:	00007617          	auipc	a2,0x7
    80000bd0:	43460613          	addi	a2,a2,1076 # 80008000 <etext>
    80000bd4:	00007597          	auipc	a1,0x7
    80000bd8:	49c58593          	addi	a1,a1,1180 # 80008070 <digits+0x20>
    80000bdc:	00007517          	auipc	a0,0x7
    80000be0:	4a450513          	addi	a0,a0,1188 # 80008080 <digits+0x30>
    80000be4:	00000097          	auipc	ra,0x0
    80000be8:	9b8080e7          	jalr	-1608(ra) # 8000059c <printf>
    80000bec:	00007517          	auipc	a0,0x7
    80000bf0:	4a450513          	addi	a0,a0,1188 # 80008090 <digits+0x40>
    80000bf4:	00000097          	auipc	ra,0x0
    80000bf8:	94c080e7          	jalr	-1716(ra) # 80000540 <panic>
    release(&kmem.lock);
    80000bfc:	00010517          	auipc	a0,0x10
    80000c00:	0b450513          	addi	a0,a0,180 # 80010cb0 <kmem>
    80000c04:	00000097          	auipc	ra,0x0
    80000c08:	14e080e7          	jalr	334(ra) # 80000d52 <release>
    if (r)
    80000c0c:	b74d                	j	80000bae <kalloc+0x4c>

0000000080000c0e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c0e:	1141                	addi	sp,sp,-16
    80000c10:	e422                	sd	s0,8(sp)
    80000c12:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c14:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c16:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c1a:	00053823          	sd	zero,16(a0)
}
    80000c1e:	6422                	ld	s0,8(sp)
    80000c20:	0141                	addi	sp,sp,16
    80000c22:	8082                	ret

0000000080000c24 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c24:	411c                	lw	a5,0(a0)
    80000c26:	e399                	bnez	a5,80000c2c <holding+0x8>
    80000c28:	4501                	li	a0,0
  return r;
}
    80000c2a:	8082                	ret
{
    80000c2c:	1101                	addi	sp,sp,-32
    80000c2e:	ec06                	sd	ra,24(sp)
    80000c30:	e822                	sd	s0,16(sp)
    80000c32:	e426                	sd	s1,8(sp)
    80000c34:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c36:	6904                	ld	s1,16(a0)
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	f1e080e7          	jalr	-226(ra) # 80001b56 <mycpu>
    80000c40:	40a48533          	sub	a0,s1,a0
    80000c44:	00153513          	seqz	a0,a0
}
    80000c48:	60e2                	ld	ra,24(sp)
    80000c4a:	6442                	ld	s0,16(sp)
    80000c4c:	64a2                	ld	s1,8(sp)
    80000c4e:	6105                	addi	sp,sp,32
    80000c50:	8082                	ret

0000000080000c52 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c52:	1101                	addi	sp,sp,-32
    80000c54:	ec06                	sd	ra,24(sp)
    80000c56:	e822                	sd	s0,16(sp)
    80000c58:	e426                	sd	s1,8(sp)
    80000c5a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c5c:	100024f3          	csrr	s1,sstatus
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c64:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c66:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c6a:	00001097          	auipc	ra,0x1
    80000c6e:	eec080e7          	jalr	-276(ra) # 80001b56 <mycpu>
    80000c72:	5d3c                	lw	a5,120(a0)
    80000c74:	cf89                	beqz	a5,80000c8e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c76:	00001097          	auipc	ra,0x1
    80000c7a:	ee0080e7          	jalr	-288(ra) # 80001b56 <mycpu>
    80000c7e:	5d3c                	lw	a5,120(a0)
    80000c80:	2785                	addiw	a5,a5,1
    80000c82:	dd3c                	sw	a5,120(a0)
}
    80000c84:	60e2                	ld	ra,24(sp)
    80000c86:	6442                	ld	s0,16(sp)
    80000c88:	64a2                	ld	s1,8(sp)
    80000c8a:	6105                	addi	sp,sp,32
    80000c8c:	8082                	ret
    mycpu()->intena = old;
    80000c8e:	00001097          	auipc	ra,0x1
    80000c92:	ec8080e7          	jalr	-312(ra) # 80001b56 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c96:	8085                	srli	s1,s1,0x1
    80000c98:	8885                	andi	s1,s1,1
    80000c9a:	dd64                	sw	s1,124(a0)
    80000c9c:	bfe9                	j	80000c76 <push_off+0x24>

0000000080000c9e <acquire>:
{
    80000c9e:	1101                	addi	sp,sp,-32
    80000ca0:	ec06                	sd	ra,24(sp)
    80000ca2:	e822                	sd	s0,16(sp)
    80000ca4:	e426                	sd	s1,8(sp)
    80000ca6:	1000                	addi	s0,sp,32
    80000ca8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	fa8080e7          	jalr	-88(ra) # 80000c52 <push_off>
  if(holding(lk))
    80000cb2:	8526                	mv	a0,s1
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	f70080e7          	jalr	-144(ra) # 80000c24 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cbc:	4705                	li	a4,1
  if(holding(lk))
    80000cbe:	e115                	bnez	a0,80000ce2 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cc0:	87ba                	mv	a5,a4
    80000cc2:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cc6:	2781                	sext.w	a5,a5
    80000cc8:	ffe5                	bnez	a5,80000cc0 <acquire+0x22>
  __sync_synchronize();
    80000cca:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cce:	00001097          	auipc	ra,0x1
    80000cd2:	e88080e7          	jalr	-376(ra) # 80001b56 <mycpu>
    80000cd6:	e888                	sd	a0,16(s1)
}
    80000cd8:	60e2                	ld	ra,24(sp)
    80000cda:	6442                	ld	s0,16(sp)
    80000cdc:	64a2                	ld	s1,8(sp)
    80000cde:	6105                	addi	sp,sp,32
    80000ce0:	8082                	ret
    panic("acquire");
    80000ce2:	00007517          	auipc	a0,0x7
    80000ce6:	3ce50513          	addi	a0,a0,974 # 800080b0 <digits+0x60>
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	856080e7          	jalr	-1962(ra) # 80000540 <panic>

0000000080000cf2 <pop_off>:

void
pop_off(void)
{
    80000cf2:	1141                	addi	sp,sp,-16
    80000cf4:	e406                	sd	ra,8(sp)
    80000cf6:	e022                	sd	s0,0(sp)
    80000cf8:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cfa:	00001097          	auipc	ra,0x1
    80000cfe:	e5c080e7          	jalr	-420(ra) # 80001b56 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d02:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d06:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d08:	e78d                	bnez	a5,80000d32 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d0a:	5d3c                	lw	a5,120(a0)
    80000d0c:	02f05b63          	blez	a5,80000d42 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d10:	37fd                	addiw	a5,a5,-1
    80000d12:	0007871b          	sext.w	a4,a5
    80000d16:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d18:	eb09                	bnez	a4,80000d2a <pop_off+0x38>
    80000d1a:	5d7c                	lw	a5,124(a0)
    80000d1c:	c799                	beqz	a5,80000d2a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d1e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d22:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d26:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d2a:	60a2                	ld	ra,8(sp)
    80000d2c:	6402                	ld	s0,0(sp)
    80000d2e:	0141                	addi	sp,sp,16
    80000d30:	8082                	ret
    panic("pop_off - interruptible");
    80000d32:	00007517          	auipc	a0,0x7
    80000d36:	38650513          	addi	a0,a0,902 # 800080b8 <digits+0x68>
    80000d3a:	00000097          	auipc	ra,0x0
    80000d3e:	806080e7          	jalr	-2042(ra) # 80000540 <panic>
    panic("pop_off");
    80000d42:	00007517          	auipc	a0,0x7
    80000d46:	38e50513          	addi	a0,a0,910 # 800080d0 <digits+0x80>
    80000d4a:	fffff097          	auipc	ra,0xfffff
    80000d4e:	7f6080e7          	jalr	2038(ra) # 80000540 <panic>

0000000080000d52 <release>:
{
    80000d52:	1101                	addi	sp,sp,-32
    80000d54:	ec06                	sd	ra,24(sp)
    80000d56:	e822                	sd	s0,16(sp)
    80000d58:	e426                	sd	s1,8(sp)
    80000d5a:	1000                	addi	s0,sp,32
    80000d5c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d5e:	00000097          	auipc	ra,0x0
    80000d62:	ec6080e7          	jalr	-314(ra) # 80000c24 <holding>
    80000d66:	c115                	beqz	a0,80000d8a <release+0x38>
  lk->cpu = 0;
    80000d68:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d6c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d70:	0f50000f          	fence	iorw,ow
    80000d74:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d78:	00000097          	auipc	ra,0x0
    80000d7c:	f7a080e7          	jalr	-134(ra) # 80000cf2 <pop_off>
}
    80000d80:	60e2                	ld	ra,24(sp)
    80000d82:	6442                	ld	s0,16(sp)
    80000d84:	64a2                	ld	s1,8(sp)
    80000d86:	6105                	addi	sp,sp,32
    80000d88:	8082                	ret
    panic("release");
    80000d8a:	00007517          	auipc	a0,0x7
    80000d8e:	34e50513          	addi	a0,a0,846 # 800080d8 <digits+0x88>
    80000d92:	fffff097          	auipc	ra,0xfffff
    80000d96:	7ae080e7          	jalr	1966(ra) # 80000540 <panic>

0000000080000d9a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e422                	sd	s0,8(sp)
    80000d9e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000da0:	ca19                	beqz	a2,80000db6 <memset+0x1c>
    80000da2:	87aa                	mv	a5,a0
    80000da4:	1602                	slli	a2,a2,0x20
    80000da6:	9201                	srli	a2,a2,0x20
    80000da8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000dac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000db0:	0785                	addi	a5,a5,1
    80000db2:	fee79de3          	bne	a5,a4,80000dac <memset+0x12>
  }
  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret

0000000080000dbc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000dbc:	1141                	addi	sp,sp,-16
    80000dbe:	e422                	sd	s0,8(sp)
    80000dc0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dc2:	ca05                	beqz	a2,80000df2 <memcmp+0x36>
    80000dc4:	fff6069b          	addiw	a3,a2,-1
    80000dc8:	1682                	slli	a3,a3,0x20
    80000dca:	9281                	srli	a3,a3,0x20
    80000dcc:	0685                	addi	a3,a3,1
    80000dce:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dd0:	00054783          	lbu	a5,0(a0)
    80000dd4:	0005c703          	lbu	a4,0(a1)
    80000dd8:	00e79863          	bne	a5,a4,80000de8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ddc:	0505                	addi	a0,a0,1
    80000dde:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000de0:	fed518e3          	bne	a0,a3,80000dd0 <memcmp+0x14>
  }

  return 0;
    80000de4:	4501                	li	a0,0
    80000de6:	a019                	j	80000dec <memcmp+0x30>
      return *s1 - *s2;
    80000de8:	40e7853b          	subw	a0,a5,a4
}
    80000dec:	6422                	ld	s0,8(sp)
    80000dee:	0141                	addi	sp,sp,16
    80000df0:	8082                	ret
  return 0;
    80000df2:	4501                	li	a0,0
    80000df4:	bfe5                	j	80000dec <memcmp+0x30>

0000000080000df6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000df6:	1141                	addi	sp,sp,-16
    80000df8:	e422                	sd	s0,8(sp)
    80000dfa:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000dfc:	c205                	beqz	a2,80000e1c <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dfe:	02a5e263          	bltu	a1,a0,80000e22 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e02:	1602                	slli	a2,a2,0x20
    80000e04:	9201                	srli	a2,a2,0x20
    80000e06:	00c587b3          	add	a5,a1,a2
{
    80000e0a:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e0c:	0585                	addi	a1,a1,1
    80000e0e:	0705                	addi	a4,a4,1
    80000e10:	fff5c683          	lbu	a3,-1(a1)
    80000e14:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e18:	fef59ae3          	bne	a1,a5,80000e0c <memmove+0x16>

  return dst;
}
    80000e1c:	6422                	ld	s0,8(sp)
    80000e1e:	0141                	addi	sp,sp,16
    80000e20:	8082                	ret
  if(s < d && s + n > d){
    80000e22:	02061693          	slli	a3,a2,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	00d58733          	add	a4,a1,a3
    80000e2c:	fce57be3          	bgeu	a0,a4,80000e02 <memmove+0xc>
    d += n;
    80000e30:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e32:	fff6079b          	addiw	a5,a2,-1
    80000e36:	1782                	slli	a5,a5,0x20
    80000e38:	9381                	srli	a5,a5,0x20
    80000e3a:	fff7c793          	not	a5,a5
    80000e3e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e40:	177d                	addi	a4,a4,-1
    80000e42:	16fd                	addi	a3,a3,-1
    80000e44:	00074603          	lbu	a2,0(a4)
    80000e48:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e4c:	fee79ae3          	bne	a5,a4,80000e40 <memmove+0x4a>
    80000e50:	b7f1                	j	80000e1c <memmove+0x26>

0000000080000e52 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e52:	1141                	addi	sp,sp,-16
    80000e54:	e406                	sd	ra,8(sp)
    80000e56:	e022                	sd	s0,0(sp)
    80000e58:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e5a:	00000097          	auipc	ra,0x0
    80000e5e:	f9c080e7          	jalr	-100(ra) # 80000df6 <memmove>
}
    80000e62:	60a2                	ld	ra,8(sp)
    80000e64:	6402                	ld	s0,0(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e70:	ce11                	beqz	a2,80000e8c <strncmp+0x22>
    80000e72:	00054783          	lbu	a5,0(a0)
    80000e76:	cf89                	beqz	a5,80000e90 <strncmp+0x26>
    80000e78:	0005c703          	lbu	a4,0(a1)
    80000e7c:	00f71a63          	bne	a4,a5,80000e90 <strncmp+0x26>
    n--, p++, q++;
    80000e80:	367d                	addiw	a2,a2,-1
    80000e82:	0505                	addi	a0,a0,1
    80000e84:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e86:	f675                	bnez	a2,80000e72 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e88:	4501                	li	a0,0
    80000e8a:	a809                	j	80000e9c <strncmp+0x32>
    80000e8c:	4501                	li	a0,0
    80000e8e:	a039                	j	80000e9c <strncmp+0x32>
  if(n == 0)
    80000e90:	ca09                	beqz	a2,80000ea2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e92:	00054503          	lbu	a0,0(a0)
    80000e96:	0005c783          	lbu	a5,0(a1)
    80000e9a:	9d1d                	subw	a0,a0,a5
}
    80000e9c:	6422                	ld	s0,8(sp)
    80000e9e:	0141                	addi	sp,sp,16
    80000ea0:	8082                	ret
    return 0;
    80000ea2:	4501                	li	a0,0
    80000ea4:	bfe5                	j	80000e9c <strncmp+0x32>

0000000080000ea6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e422                	sd	s0,8(sp)
    80000eaa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000eac:	872a                	mv	a4,a0
    80000eae:	8832                	mv	a6,a2
    80000eb0:	367d                	addiw	a2,a2,-1
    80000eb2:	01005963          	blez	a6,80000ec4 <strncpy+0x1e>
    80000eb6:	0705                	addi	a4,a4,1
    80000eb8:	0005c783          	lbu	a5,0(a1)
    80000ebc:	fef70fa3          	sb	a5,-1(a4)
    80000ec0:	0585                	addi	a1,a1,1
    80000ec2:	f7f5                	bnez	a5,80000eae <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ec4:	86ba                	mv	a3,a4
    80000ec6:	00c05c63          	blez	a2,80000ede <strncpy+0x38>
    *s++ = 0;
    80000eca:	0685                	addi	a3,a3,1
    80000ecc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ed0:	40d707bb          	subw	a5,a4,a3
    80000ed4:	37fd                	addiw	a5,a5,-1
    80000ed6:	010787bb          	addw	a5,a5,a6
    80000eda:	fef048e3          	bgtz	a5,80000eca <strncpy+0x24>
  return os;
}
    80000ede:	6422                	ld	s0,8(sp)
    80000ee0:	0141                	addi	sp,sp,16
    80000ee2:	8082                	ret

0000000080000ee4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ee4:	1141                	addi	sp,sp,-16
    80000ee6:	e422                	sd	s0,8(sp)
    80000ee8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eea:	02c05363          	blez	a2,80000f10 <safestrcpy+0x2c>
    80000eee:	fff6069b          	addiw	a3,a2,-1
    80000ef2:	1682                	slli	a3,a3,0x20
    80000ef4:	9281                	srli	a3,a3,0x20
    80000ef6:	96ae                	add	a3,a3,a1
    80000ef8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000efa:	00d58963          	beq	a1,a3,80000f0c <safestrcpy+0x28>
    80000efe:	0585                	addi	a1,a1,1
    80000f00:	0785                	addi	a5,a5,1
    80000f02:	fff5c703          	lbu	a4,-1(a1)
    80000f06:	fee78fa3          	sb	a4,-1(a5)
    80000f0a:	fb65                	bnez	a4,80000efa <safestrcpy+0x16>
    ;
  *s = 0;
    80000f0c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <strlen>:

int
strlen(const char *s)
{
    80000f16:	1141                	addi	sp,sp,-16
    80000f18:	e422                	sd	s0,8(sp)
    80000f1a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f1c:	00054783          	lbu	a5,0(a0)
    80000f20:	cf91                	beqz	a5,80000f3c <strlen+0x26>
    80000f22:	0505                	addi	a0,a0,1
    80000f24:	87aa                	mv	a5,a0
    80000f26:	4685                	li	a3,1
    80000f28:	9e89                	subw	a3,a3,a0
    80000f2a:	00f6853b          	addw	a0,a3,a5
    80000f2e:	0785                	addi	a5,a5,1
    80000f30:	fff7c703          	lbu	a4,-1(a5)
    80000f34:	fb7d                	bnez	a4,80000f2a <strlen+0x14>
    ;
  return n;
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f3c:	4501                	li	a0,0
    80000f3e:	bfe5                	j	80000f36 <strlen+0x20>

0000000080000f40 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f40:	1141                	addi	sp,sp,-16
    80000f42:	e406                	sd	ra,8(sp)
    80000f44:	e022                	sd	s0,0(sp)
    80000f46:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f48:	00001097          	auipc	ra,0x1
    80000f4c:	bfe080e7          	jalr	-1026(ra) # 80001b46 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f50:	00008717          	auipc	a4,0x8
    80000f54:	af870713          	addi	a4,a4,-1288 # 80008a48 <started>
  if(cpuid() == 0){
    80000f58:	c139                	beqz	a0,80000f9e <main+0x5e>
    while(started == 0)
    80000f5a:	431c                	lw	a5,0(a4)
    80000f5c:	2781                	sext.w	a5,a5
    80000f5e:	dff5                	beqz	a5,80000f5a <main+0x1a>
      ;
    __sync_synchronize();
    80000f60:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f64:	00001097          	auipc	ra,0x1
    80000f68:	be2080e7          	jalr	-1054(ra) # 80001b46 <cpuid>
    80000f6c:	85aa                	mv	a1,a0
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	18a50513          	addi	a0,a0,394 # 800080f8 <digits+0xa8>
    80000f76:	fffff097          	auipc	ra,0xfffff
    80000f7a:	626080e7          	jalr	1574(ra) # 8000059c <printf>
    kvminithart();    // turn on paging
    80000f7e:	00000097          	auipc	ra,0x0
    80000f82:	0d8080e7          	jalr	216(ra) # 80001056 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f86:	00002097          	auipc	ra,0x2
    80000f8a:	a86080e7          	jalr	-1402(ra) # 80002a0c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f8e:	00005097          	auipc	ra,0x5
    80000f92:	132080e7          	jalr	306(ra) # 800060c0 <plicinithart>
  }

  scheduler();        
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	222080e7          	jalr	546(ra) # 800021b8 <scheduler>
    consoleinit();
    80000f9e:	fffff097          	auipc	ra,0xfffff
    80000fa2:	4b2080e7          	jalr	1202(ra) # 80000450 <consoleinit>
    printfinit();
    80000fa6:	fffff097          	auipc	ra,0xfffff
    80000faa:	7d6080e7          	jalr	2006(ra) # 8000077c <printfinit>
    printf("\n");
    80000fae:	00007517          	auipc	a0,0x7
    80000fb2:	0da50513          	addi	a0,a0,218 # 80008088 <digits+0x38>
    80000fb6:	fffff097          	auipc	ra,0xfffff
    80000fba:	5e6080e7          	jalr	1510(ra) # 8000059c <printf>
    printf("xv6 kernel is booting\n");
    80000fbe:	00007517          	auipc	a0,0x7
    80000fc2:	12250513          	addi	a0,a0,290 # 800080e0 <digits+0x90>
    80000fc6:	fffff097          	auipc	ra,0xfffff
    80000fca:	5d6080e7          	jalr	1494(ra) # 8000059c <printf>
    printf("\n");
    80000fce:	00007517          	auipc	a0,0x7
    80000fd2:	0ba50513          	addi	a0,a0,186 # 80008088 <digits+0x38>
    80000fd6:	fffff097          	auipc	ra,0xfffff
    80000fda:	5c6080e7          	jalr	1478(ra) # 8000059c <printf>
    kinit();         // physical page allocator
    80000fde:	00000097          	auipc	ra,0x0
    80000fe2:	b38080e7          	jalr	-1224(ra) # 80000b16 <kinit>
    kvminit();       // create kernel page table
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	326080e7          	jalr	806(ra) # 8000130c <kvminit>
    kvminithart();   // turn on paging
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	068080e7          	jalr	104(ra) # 80001056 <kvminithart>
    procinit();      // process table
    80000ff6:	00001097          	auipc	ra,0x1
    80000ffa:	a6e080e7          	jalr	-1426(ra) # 80001a64 <procinit>
    trapinit();      // trap vectors
    80000ffe:	00002097          	auipc	ra,0x2
    80001002:	9e6080e7          	jalr	-1562(ra) # 800029e4 <trapinit>
    trapinithart();  // install kernel trap vector
    80001006:	00002097          	auipc	ra,0x2
    8000100a:	a06080e7          	jalr	-1530(ra) # 80002a0c <trapinithart>
    plicinit();      // set up interrupt controller
    8000100e:	00005097          	auipc	ra,0x5
    80001012:	09c080e7          	jalr	156(ra) # 800060aa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001016:	00005097          	auipc	ra,0x5
    8000101a:	0aa080e7          	jalr	170(ra) # 800060c0 <plicinithart>
    binit();         // buffer cache
    8000101e:	00002097          	auipc	ra,0x2
    80001022:	242080e7          	jalr	578(ra) # 80003260 <binit>
    iinit();         // inode table
    80001026:	00003097          	auipc	ra,0x3
    8000102a:	8e2080e7          	jalr	-1822(ra) # 80003908 <iinit>
    fileinit();      // file table
    8000102e:	00004097          	auipc	ra,0x4
    80001032:	888080e7          	jalr	-1912(ra) # 800048b6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001036:	00005097          	auipc	ra,0x5
    8000103a:	192080e7          	jalr	402(ra) # 800061c8 <virtio_disk_init>
    userinit();      // first user process
    8000103e:	00001097          	auipc	ra,0x1
    80001042:	e0c080e7          	jalr	-500(ra) # 80001e4a <userinit>
    __sync_synchronize();
    80001046:	0ff0000f          	fence
    started = 1;
    8000104a:	4785                	li	a5,1
    8000104c:	00008717          	auipc	a4,0x8
    80001050:	9ef72e23          	sw	a5,-1540(a4) # 80008a48 <started>
    80001054:	b789                	j	80000f96 <main+0x56>

0000000080001056 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001056:	1141                	addi	sp,sp,-16
    80001058:	e422                	sd	s0,8(sp)
    8000105a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000105c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001060:	00008797          	auipc	a5,0x8
    80001064:	9f07b783          	ld	a5,-1552(a5) # 80008a50 <kernel_pagetable>
    80001068:	83b1                	srli	a5,a5,0xc
    8000106a:	577d                	li	a4,-1
    8000106c:	177e                	slli	a4,a4,0x3f
    8000106e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001070:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001074:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001078:	6422                	ld	s0,8(sp)
    8000107a:	0141                	addi	sp,sp,16
    8000107c:	8082                	ret

000000008000107e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000107e:	7139                	addi	sp,sp,-64
    80001080:	fc06                	sd	ra,56(sp)
    80001082:	f822                	sd	s0,48(sp)
    80001084:	f426                	sd	s1,40(sp)
    80001086:	f04a                	sd	s2,32(sp)
    80001088:	ec4e                	sd	s3,24(sp)
    8000108a:	e852                	sd	s4,16(sp)
    8000108c:	e456                	sd	s5,8(sp)
    8000108e:	e05a                	sd	s6,0(sp)
    80001090:	0080                	addi	s0,sp,64
    80001092:	84aa                	mv	s1,a0
    80001094:	89ae                	mv	s3,a1
    80001096:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001098:	57fd                	li	a5,-1
    8000109a:	83e9                	srli	a5,a5,0x1a
    8000109c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000109e:	4b31                	li	s6,12
  if(va >= MAXVA)
    800010a0:	04b7f263          	bgeu	a5,a1,800010e4 <walk+0x66>
    panic("walk");
    800010a4:	00007517          	auipc	a0,0x7
    800010a8:	06c50513          	addi	a0,a0,108 # 80008110 <digits+0xc0>
    800010ac:	fffff097          	auipc	ra,0xfffff
    800010b0:	494080e7          	jalr	1172(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010b4:	060a8663          	beqz	s5,80001120 <walk+0xa2>
    800010b8:	00000097          	auipc	ra,0x0
    800010bc:	aaa080e7          	jalr	-1366(ra) # 80000b62 <kalloc>
    800010c0:	84aa                	mv	s1,a0
    800010c2:	c529                	beqz	a0,8000110c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010c4:	6605                	lui	a2,0x1
    800010c6:	4581                	li	a1,0
    800010c8:	00000097          	auipc	ra,0x0
    800010cc:	cd2080e7          	jalr	-814(ra) # 80000d9a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010d0:	00c4d793          	srli	a5,s1,0xc
    800010d4:	07aa                	slli	a5,a5,0xa
    800010d6:	0017e793          	ori	a5,a5,1
    800010da:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010de:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd117>
    800010e0:	036a0063          	beq	s4,s6,80001100 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010e4:	0149d933          	srl	s2,s3,s4
    800010e8:	1ff97913          	andi	s2,s2,511
    800010ec:	090e                	slli	s2,s2,0x3
    800010ee:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010f0:	00093483          	ld	s1,0(s2)
    800010f4:	0014f793          	andi	a5,s1,1
    800010f8:	dfd5                	beqz	a5,800010b4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010fa:	80a9                	srli	s1,s1,0xa
    800010fc:	04b2                	slli	s1,s1,0xc
    800010fe:	b7c5                	j	800010de <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001100:	00c9d513          	srli	a0,s3,0xc
    80001104:	1ff57513          	andi	a0,a0,511
    80001108:	050e                	slli	a0,a0,0x3
    8000110a:	9526                	add	a0,a0,s1
}
    8000110c:	70e2                	ld	ra,56(sp)
    8000110e:	7442                	ld	s0,48(sp)
    80001110:	74a2                	ld	s1,40(sp)
    80001112:	7902                	ld	s2,32(sp)
    80001114:	69e2                	ld	s3,24(sp)
    80001116:	6a42                	ld	s4,16(sp)
    80001118:	6aa2                	ld	s5,8(sp)
    8000111a:	6b02                	ld	s6,0(sp)
    8000111c:	6121                	addi	sp,sp,64
    8000111e:	8082                	ret
        return 0;
    80001120:	4501                	li	a0,0
    80001122:	b7ed                	j	8000110c <walk+0x8e>

0000000080001124 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001124:	57fd                	li	a5,-1
    80001126:	83e9                	srli	a5,a5,0x1a
    80001128:	00b7f463          	bgeu	a5,a1,80001130 <walkaddr+0xc>
    return 0;
    8000112c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000112e:	8082                	ret
{
    80001130:	1141                	addi	sp,sp,-16
    80001132:	e406                	sd	ra,8(sp)
    80001134:	e022                	sd	s0,0(sp)
    80001136:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001138:	4601                	li	a2,0
    8000113a:	00000097          	auipc	ra,0x0
    8000113e:	f44080e7          	jalr	-188(ra) # 8000107e <walk>
  if(pte == 0)
    80001142:	c105                	beqz	a0,80001162 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001144:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001146:	0117f693          	andi	a3,a5,17
    8000114a:	4745                	li	a4,17
    return 0;
    8000114c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000114e:	00e68663          	beq	a3,a4,8000115a <walkaddr+0x36>
}
    80001152:	60a2                	ld	ra,8(sp)
    80001154:	6402                	ld	s0,0(sp)
    80001156:	0141                	addi	sp,sp,16
    80001158:	8082                	ret
  pa = PTE2PA(*pte);
    8000115a:	83a9                	srli	a5,a5,0xa
    8000115c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001160:	bfcd                	j	80001152 <walkaddr+0x2e>
    return 0;
    80001162:	4501                	li	a0,0
    80001164:	b7fd                	j	80001152 <walkaddr+0x2e>

0000000080001166 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001166:	715d                	addi	sp,sp,-80
    80001168:	e486                	sd	ra,72(sp)
    8000116a:	e0a2                	sd	s0,64(sp)
    8000116c:	fc26                	sd	s1,56(sp)
    8000116e:	f84a                	sd	s2,48(sp)
    80001170:	f44e                	sd	s3,40(sp)
    80001172:	f052                	sd	s4,32(sp)
    80001174:	ec56                	sd	s5,24(sp)
    80001176:	e85a                	sd	s6,16(sp)
    80001178:	e45e                	sd	s7,8(sp)
    8000117a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000117c:	c639                	beqz	a2,800011ca <mappages+0x64>
    8000117e:	8aaa                	mv	s5,a0
    80001180:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001182:	777d                	lui	a4,0xfffff
    80001184:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001188:	fff58993          	addi	s3,a1,-1
    8000118c:	99b2                	add	s3,s3,a2
    8000118e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001192:	893e                	mv	s2,a5
    80001194:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001198:	6b85                	lui	s7,0x1
    8000119a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000119e:	4605                	li	a2,1
    800011a0:	85ca                	mv	a1,s2
    800011a2:	8556                	mv	a0,s5
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	eda080e7          	jalr	-294(ra) # 8000107e <walk>
    800011ac:	cd1d                	beqz	a0,800011ea <mappages+0x84>
    if(*pte & PTE_V)
    800011ae:	611c                	ld	a5,0(a0)
    800011b0:	8b85                	andi	a5,a5,1
    800011b2:	e785                	bnez	a5,800011da <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011b4:	80b1                	srli	s1,s1,0xc
    800011b6:	04aa                	slli	s1,s1,0xa
    800011b8:	0164e4b3          	or	s1,s1,s6
    800011bc:	0014e493          	ori	s1,s1,1
    800011c0:	e104                	sd	s1,0(a0)
    if(a == last)
    800011c2:	05390063          	beq	s2,s3,80001202 <mappages+0x9c>
    a += PGSIZE;
    800011c6:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011c8:	bfc9                	j	8000119a <mappages+0x34>
    panic("mappages: size");
    800011ca:	00007517          	auipc	a0,0x7
    800011ce:	f4e50513          	addi	a0,a0,-178 # 80008118 <digits+0xc8>
    800011d2:	fffff097          	auipc	ra,0xfffff
    800011d6:	36e080e7          	jalr	878(ra) # 80000540 <panic>
      panic("mappages: remap");
    800011da:	00007517          	auipc	a0,0x7
    800011de:	f4e50513          	addi	a0,a0,-178 # 80008128 <digits+0xd8>
    800011e2:	fffff097          	auipc	ra,0xfffff
    800011e6:	35e080e7          	jalr	862(ra) # 80000540 <panic>
      return -1;
    800011ea:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011ec:	60a6                	ld	ra,72(sp)
    800011ee:	6406                	ld	s0,64(sp)
    800011f0:	74e2                	ld	s1,56(sp)
    800011f2:	7942                	ld	s2,48(sp)
    800011f4:	79a2                	ld	s3,40(sp)
    800011f6:	7a02                	ld	s4,32(sp)
    800011f8:	6ae2                	ld	s5,24(sp)
    800011fa:	6b42                	ld	s6,16(sp)
    800011fc:	6ba2                	ld	s7,8(sp)
    800011fe:	6161                	addi	sp,sp,80
    80001200:	8082                	ret
  return 0;
    80001202:	4501                	li	a0,0
    80001204:	b7e5                	j	800011ec <mappages+0x86>

0000000080001206 <kvmmap>:
{
    80001206:	1141                	addi	sp,sp,-16
    80001208:	e406                	sd	ra,8(sp)
    8000120a:	e022                	sd	s0,0(sp)
    8000120c:	0800                	addi	s0,sp,16
    8000120e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001210:	86b2                	mv	a3,a2
    80001212:	863e                	mv	a2,a5
    80001214:	00000097          	auipc	ra,0x0
    80001218:	f52080e7          	jalr	-174(ra) # 80001166 <mappages>
    8000121c:	e509                	bnez	a0,80001226 <kvmmap+0x20>
}
    8000121e:	60a2                	ld	ra,8(sp)
    80001220:	6402                	ld	s0,0(sp)
    80001222:	0141                	addi	sp,sp,16
    80001224:	8082                	ret
    panic("kvmmap");
    80001226:	00007517          	auipc	a0,0x7
    8000122a:	f1250513          	addi	a0,a0,-238 # 80008138 <digits+0xe8>
    8000122e:	fffff097          	auipc	ra,0xfffff
    80001232:	312080e7          	jalr	786(ra) # 80000540 <panic>

0000000080001236 <kvmmake>:
{
    80001236:	1101                	addi	sp,sp,-32
    80001238:	ec06                	sd	ra,24(sp)
    8000123a:	e822                	sd	s0,16(sp)
    8000123c:	e426                	sd	s1,8(sp)
    8000123e:	e04a                	sd	s2,0(sp)
    80001240:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	920080e7          	jalr	-1760(ra) # 80000b62 <kalloc>
    8000124a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000124c:	6605                	lui	a2,0x1
    8000124e:	4581                	li	a1,0
    80001250:	00000097          	auipc	ra,0x0
    80001254:	b4a080e7          	jalr	-1206(ra) # 80000d9a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001258:	4719                	li	a4,6
    8000125a:	6685                	lui	a3,0x1
    8000125c:	10000637          	lui	a2,0x10000
    80001260:	100005b7          	lui	a1,0x10000
    80001264:	8526                	mv	a0,s1
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	fa0080e7          	jalr	-96(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000126e:	4719                	li	a4,6
    80001270:	6685                	lui	a3,0x1
    80001272:	10001637          	lui	a2,0x10001
    80001276:	100015b7          	lui	a1,0x10001
    8000127a:	8526                	mv	a0,s1
    8000127c:	00000097          	auipc	ra,0x0
    80001280:	f8a080e7          	jalr	-118(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001284:	4719                	li	a4,6
    80001286:	004006b7          	lui	a3,0x400
    8000128a:	0c000637          	lui	a2,0xc000
    8000128e:	0c0005b7          	lui	a1,0xc000
    80001292:	8526                	mv	a0,s1
    80001294:	00000097          	auipc	ra,0x0
    80001298:	f72080e7          	jalr	-142(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000129c:	00007917          	auipc	s2,0x7
    800012a0:	d6490913          	addi	s2,s2,-668 # 80008000 <etext>
    800012a4:	4729                	li	a4,10
    800012a6:	80007697          	auipc	a3,0x80007
    800012aa:	d5a68693          	addi	a3,a3,-678 # 8000 <_entry-0x7fff8000>
    800012ae:	4605                	li	a2,1
    800012b0:	067e                	slli	a2,a2,0x1f
    800012b2:	85b2                	mv	a1,a2
    800012b4:	8526                	mv	a0,s1
    800012b6:	00000097          	auipc	ra,0x0
    800012ba:	f50080e7          	jalr	-176(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012be:	4719                	li	a4,6
    800012c0:	46c5                	li	a3,17
    800012c2:	06ee                	slli	a3,a3,0x1b
    800012c4:	412686b3          	sub	a3,a3,s2
    800012c8:	864a                	mv	a2,s2
    800012ca:	85ca                	mv	a1,s2
    800012cc:	8526                	mv	a0,s1
    800012ce:	00000097          	auipc	ra,0x0
    800012d2:	f38080e7          	jalr	-200(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012d6:	4729                	li	a4,10
    800012d8:	6685                	lui	a3,0x1
    800012da:	00006617          	auipc	a2,0x6
    800012de:	d2660613          	addi	a2,a2,-730 # 80007000 <_trampoline>
    800012e2:	040005b7          	lui	a1,0x4000
    800012e6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012e8:	05b2                	slli	a1,a1,0xc
    800012ea:	8526                	mv	a0,s1
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	f1a080e7          	jalr	-230(ra) # 80001206 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012f4:	8526                	mv	a0,s1
    800012f6:	00000097          	auipc	ra,0x0
    800012fa:	6d8080e7          	jalr	1752(ra) # 800019ce <proc_mapstacks>
}
    800012fe:	8526                	mv	a0,s1
    80001300:	60e2                	ld	ra,24(sp)
    80001302:	6442                	ld	s0,16(sp)
    80001304:	64a2                	ld	s1,8(sp)
    80001306:	6902                	ld	s2,0(sp)
    80001308:	6105                	addi	sp,sp,32
    8000130a:	8082                	ret

000000008000130c <kvminit>:
{
    8000130c:	1141                	addi	sp,sp,-16
    8000130e:	e406                	sd	ra,8(sp)
    80001310:	e022                	sd	s0,0(sp)
    80001312:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001314:	00000097          	auipc	ra,0x0
    80001318:	f22080e7          	jalr	-222(ra) # 80001236 <kvmmake>
    8000131c:	00007797          	auipc	a5,0x7
    80001320:	72a7ba23          	sd	a0,1844(a5) # 80008a50 <kernel_pagetable>
}
    80001324:	60a2                	ld	ra,8(sp)
    80001326:	6402                	ld	s0,0(sp)
    80001328:	0141                	addi	sp,sp,16
    8000132a:	8082                	ret

000000008000132c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000132c:	715d                	addi	sp,sp,-80
    8000132e:	e486                	sd	ra,72(sp)
    80001330:	e0a2                	sd	s0,64(sp)
    80001332:	fc26                	sd	s1,56(sp)
    80001334:	f84a                	sd	s2,48(sp)
    80001336:	f44e                	sd	s3,40(sp)
    80001338:	f052                	sd	s4,32(sp)
    8000133a:	ec56                	sd	s5,24(sp)
    8000133c:	e85a                	sd	s6,16(sp)
    8000133e:	e45e                	sd	s7,8(sp)
    80001340:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001342:	03459793          	slli	a5,a1,0x34
    80001346:	e795                	bnez	a5,80001372 <uvmunmap+0x46>
    80001348:	8a2a                	mv	s4,a0
    8000134a:	892e                	mv	s2,a1
    8000134c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000134e:	0632                	slli	a2,a2,0xc
    80001350:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001354:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001356:	6b05                	lui	s6,0x1
    80001358:	0735e263          	bltu	a1,s3,800013bc <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000135c:	60a6                	ld	ra,72(sp)
    8000135e:	6406                	ld	s0,64(sp)
    80001360:	74e2                	ld	s1,56(sp)
    80001362:	7942                	ld	s2,48(sp)
    80001364:	79a2                	ld	s3,40(sp)
    80001366:	7a02                	ld	s4,32(sp)
    80001368:	6ae2                	ld	s5,24(sp)
    8000136a:	6b42                	ld	s6,16(sp)
    8000136c:	6ba2                	ld	s7,8(sp)
    8000136e:	6161                	addi	sp,sp,80
    80001370:	8082                	ret
    panic("uvmunmap: not aligned");
    80001372:	00007517          	auipc	a0,0x7
    80001376:	dce50513          	addi	a0,a0,-562 # 80008140 <digits+0xf0>
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	1c6080e7          	jalr	454(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    80001382:	00007517          	auipc	a0,0x7
    80001386:	dd650513          	addi	a0,a0,-554 # 80008158 <digits+0x108>
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	1b6080e7          	jalr	438(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    80001392:	00007517          	auipc	a0,0x7
    80001396:	dd650513          	addi	a0,a0,-554 # 80008168 <digits+0x118>
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	1a6080e7          	jalr	422(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800013a2:	00007517          	auipc	a0,0x7
    800013a6:	dde50513          	addi	a0,a0,-546 # 80008180 <digits+0x130>
    800013aa:	fffff097          	auipc	ra,0xfffff
    800013ae:	196080e7          	jalr	406(ra) # 80000540 <panic>
    *pte = 0;
    800013b2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013b6:	995a                	add	s2,s2,s6
    800013b8:	fb3972e3          	bgeu	s2,s3,8000135c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013bc:	4601                	li	a2,0
    800013be:	85ca                	mv	a1,s2
    800013c0:	8552                	mv	a0,s4
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	cbc080e7          	jalr	-836(ra) # 8000107e <walk>
    800013ca:	84aa                	mv	s1,a0
    800013cc:	d95d                	beqz	a0,80001382 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013ce:	6108                	ld	a0,0(a0)
    800013d0:	00157793          	andi	a5,a0,1
    800013d4:	dfdd                	beqz	a5,80001392 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013d6:	3ff57793          	andi	a5,a0,1023
    800013da:	fd7784e3          	beq	a5,s7,800013a2 <uvmunmap+0x76>
    if(do_free){
    800013de:	fc0a8ae3          	beqz	s5,800013b2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013e2:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013e4:	0532                	slli	a0,a0,0xc
    800013e6:	fffff097          	auipc	ra,0xfffff
    800013ea:	614080e7          	jalr	1556(ra) # 800009fa <kfree>
    800013ee:	b7d1                	j	800013b2 <uvmunmap+0x86>

00000000800013f0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013f0:	1101                	addi	sp,sp,-32
    800013f2:	ec06                	sd	ra,24(sp)
    800013f4:	e822                	sd	s0,16(sp)
    800013f6:	e426                	sd	s1,8(sp)
    800013f8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013fa:	fffff097          	auipc	ra,0xfffff
    800013fe:	768080e7          	jalr	1896(ra) # 80000b62 <kalloc>
    80001402:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001404:	c519                	beqz	a0,80001412 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001406:	6605                	lui	a2,0x1
    80001408:	4581                	li	a1,0
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	990080e7          	jalr	-1648(ra) # 80000d9a <memset>
  return pagetable;
}
    80001412:	8526                	mv	a0,s1
    80001414:	60e2                	ld	ra,24(sp)
    80001416:	6442                	ld	s0,16(sp)
    80001418:	64a2                	ld	s1,8(sp)
    8000141a:	6105                	addi	sp,sp,32
    8000141c:	8082                	ret

000000008000141e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000141e:	7179                	addi	sp,sp,-48
    80001420:	f406                	sd	ra,40(sp)
    80001422:	f022                	sd	s0,32(sp)
    80001424:	ec26                	sd	s1,24(sp)
    80001426:	e84a                	sd	s2,16(sp)
    80001428:	e44e                	sd	s3,8(sp)
    8000142a:	e052                	sd	s4,0(sp)
    8000142c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000142e:	6785                	lui	a5,0x1
    80001430:	04f67863          	bgeu	a2,a5,80001480 <uvmfirst+0x62>
    80001434:	8a2a                	mv	s4,a0
    80001436:	89ae                	mv	s3,a1
    80001438:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	728080e7          	jalr	1832(ra) # 80000b62 <kalloc>
    80001442:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001444:	6605                	lui	a2,0x1
    80001446:	4581                	li	a1,0
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	952080e7          	jalr	-1710(ra) # 80000d9a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001450:	4779                	li	a4,30
    80001452:	86ca                	mv	a3,s2
    80001454:	6605                	lui	a2,0x1
    80001456:	4581                	li	a1,0
    80001458:	8552                	mv	a0,s4
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	d0c080e7          	jalr	-756(ra) # 80001166 <mappages>
  memmove(mem, src, sz);
    80001462:	8626                	mv	a2,s1
    80001464:	85ce                	mv	a1,s3
    80001466:	854a                	mv	a0,s2
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	98e080e7          	jalr	-1650(ra) # 80000df6 <memmove>
}
    80001470:	70a2                	ld	ra,40(sp)
    80001472:	7402                	ld	s0,32(sp)
    80001474:	64e2                	ld	s1,24(sp)
    80001476:	6942                	ld	s2,16(sp)
    80001478:	69a2                	ld	s3,8(sp)
    8000147a:	6a02                	ld	s4,0(sp)
    8000147c:	6145                	addi	sp,sp,48
    8000147e:	8082                	ret
    panic("uvmfirst: more than a page");
    80001480:	00007517          	auipc	a0,0x7
    80001484:	d1850513          	addi	a0,a0,-744 # 80008198 <digits+0x148>
    80001488:	fffff097          	auipc	ra,0xfffff
    8000148c:	0b8080e7          	jalr	184(ra) # 80000540 <panic>

0000000080001490 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001490:	1101                	addi	sp,sp,-32
    80001492:	ec06                	sd	ra,24(sp)
    80001494:	e822                	sd	s0,16(sp)
    80001496:	e426                	sd	s1,8(sp)
    80001498:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000149a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000149c:	00b67d63          	bgeu	a2,a1,800014b6 <uvmdealloc+0x26>
    800014a0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014a2:	6785                	lui	a5,0x1
    800014a4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014a6:	00f60733          	add	a4,a2,a5
    800014aa:	76fd                	lui	a3,0xfffff
    800014ac:	8f75                	and	a4,a4,a3
    800014ae:	97ae                	add	a5,a5,a1
    800014b0:	8ff5                	and	a5,a5,a3
    800014b2:	00f76863          	bltu	a4,a5,800014c2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014b6:	8526                	mv	a0,s1
    800014b8:	60e2                	ld	ra,24(sp)
    800014ba:	6442                	ld	s0,16(sp)
    800014bc:	64a2                	ld	s1,8(sp)
    800014be:	6105                	addi	sp,sp,32
    800014c0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014c2:	8f99                	sub	a5,a5,a4
    800014c4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014c6:	4685                	li	a3,1
    800014c8:	0007861b          	sext.w	a2,a5
    800014cc:	85ba                	mv	a1,a4
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	e5e080e7          	jalr	-418(ra) # 8000132c <uvmunmap>
    800014d6:	b7c5                	j	800014b6 <uvmdealloc+0x26>

00000000800014d8 <uvmalloc>:
  if(newsz < oldsz)
    800014d8:	0ab66563          	bltu	a2,a1,80001582 <uvmalloc+0xaa>
{
    800014dc:	7139                	addi	sp,sp,-64
    800014de:	fc06                	sd	ra,56(sp)
    800014e0:	f822                	sd	s0,48(sp)
    800014e2:	f426                	sd	s1,40(sp)
    800014e4:	f04a                	sd	s2,32(sp)
    800014e6:	ec4e                	sd	s3,24(sp)
    800014e8:	e852                	sd	s4,16(sp)
    800014ea:	e456                	sd	s5,8(sp)
    800014ec:	e05a                	sd	s6,0(sp)
    800014ee:	0080                	addi	s0,sp,64
    800014f0:	8aaa                	mv	s5,a0
    800014f2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014f4:	6785                	lui	a5,0x1
    800014f6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014f8:	95be                	add	a1,a1,a5
    800014fa:	77fd                	lui	a5,0xfffff
    800014fc:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001500:	08c9f363          	bgeu	s3,a2,80001586 <uvmalloc+0xae>
    80001504:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001506:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	658080e7          	jalr	1624(ra) # 80000b62 <kalloc>
    80001512:	84aa                	mv	s1,a0
    if(mem == 0){
    80001514:	c51d                	beqz	a0,80001542 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001516:	6605                	lui	a2,0x1
    80001518:	4581                	li	a1,0
    8000151a:	00000097          	auipc	ra,0x0
    8000151e:	880080e7          	jalr	-1920(ra) # 80000d9a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001522:	875a                	mv	a4,s6
    80001524:	86a6                	mv	a3,s1
    80001526:	6605                	lui	a2,0x1
    80001528:	85ca                	mv	a1,s2
    8000152a:	8556                	mv	a0,s5
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	c3a080e7          	jalr	-966(ra) # 80001166 <mappages>
    80001534:	e90d                	bnez	a0,80001566 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001536:	6785                	lui	a5,0x1
    80001538:	993e                	add	s2,s2,a5
    8000153a:	fd4968e3          	bltu	s2,s4,8000150a <uvmalloc+0x32>
  return newsz;
    8000153e:	8552                	mv	a0,s4
    80001540:	a809                	j	80001552 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001542:	864e                	mv	a2,s3
    80001544:	85ca                	mv	a1,s2
    80001546:	8556                	mv	a0,s5
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	f48080e7          	jalr	-184(ra) # 80001490 <uvmdealloc>
      return 0;
    80001550:	4501                	li	a0,0
}
    80001552:	70e2                	ld	ra,56(sp)
    80001554:	7442                	ld	s0,48(sp)
    80001556:	74a2                	ld	s1,40(sp)
    80001558:	7902                	ld	s2,32(sp)
    8000155a:	69e2                	ld	s3,24(sp)
    8000155c:	6a42                	ld	s4,16(sp)
    8000155e:	6aa2                	ld	s5,8(sp)
    80001560:	6b02                	ld	s6,0(sp)
    80001562:	6121                	addi	sp,sp,64
    80001564:	8082                	ret
      kfree(mem);
    80001566:	8526                	mv	a0,s1
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	492080e7          	jalr	1170(ra) # 800009fa <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001570:	864e                	mv	a2,s3
    80001572:	85ca                	mv	a1,s2
    80001574:	8556                	mv	a0,s5
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	f1a080e7          	jalr	-230(ra) # 80001490 <uvmdealloc>
      return 0;
    8000157e:	4501                	li	a0,0
    80001580:	bfc9                	j	80001552 <uvmalloc+0x7a>
    return oldsz;
    80001582:	852e                	mv	a0,a1
}
    80001584:	8082                	ret
  return newsz;
    80001586:	8532                	mv	a0,a2
    80001588:	b7e9                	j	80001552 <uvmalloc+0x7a>

000000008000158a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000158a:	7179                	addi	sp,sp,-48
    8000158c:	f406                	sd	ra,40(sp)
    8000158e:	f022                	sd	s0,32(sp)
    80001590:	ec26                	sd	s1,24(sp)
    80001592:	e84a                	sd	s2,16(sp)
    80001594:	e44e                	sd	s3,8(sp)
    80001596:	e052                	sd	s4,0(sp)
    80001598:	1800                	addi	s0,sp,48
    8000159a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000159c:	84aa                	mv	s1,a0
    8000159e:	6905                	lui	s2,0x1
    800015a0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a2:	4985                	li	s3,1
    800015a4:	a829                	j	800015be <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015a6:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015a8:	00c79513          	slli	a0,a5,0xc
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	fde080e7          	jalr	-34(ra) # 8000158a <freewalk>
      pagetable[i] = 0;
    800015b4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015b8:	04a1                	addi	s1,s1,8
    800015ba:	03248163          	beq	s1,s2,800015dc <freewalk+0x52>
    pte_t pte = pagetable[i];
    800015be:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c0:	00f7f713          	andi	a4,a5,15
    800015c4:	ff3701e3          	beq	a4,s3,800015a6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015c8:	8b85                	andi	a5,a5,1
    800015ca:	d7fd                	beqz	a5,800015b8 <freewalk+0x2e>
      panic("freewalk: leaf");
    800015cc:	00007517          	auipc	a0,0x7
    800015d0:	bec50513          	addi	a0,a0,-1044 # 800081b8 <digits+0x168>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	f6c080e7          	jalr	-148(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    800015dc:	8552                	mv	a0,s4
    800015de:	fffff097          	auipc	ra,0xfffff
    800015e2:	41c080e7          	jalr	1052(ra) # 800009fa <kfree>
}
    800015e6:	70a2                	ld	ra,40(sp)
    800015e8:	7402                	ld	s0,32(sp)
    800015ea:	64e2                	ld	s1,24(sp)
    800015ec:	6942                	ld	s2,16(sp)
    800015ee:	69a2                	ld	s3,8(sp)
    800015f0:	6a02                	ld	s4,0(sp)
    800015f2:	6145                	addi	sp,sp,48
    800015f4:	8082                	ret

00000000800015f6 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015f6:	1101                	addi	sp,sp,-32
    800015f8:	ec06                	sd	ra,24(sp)
    800015fa:	e822                	sd	s0,16(sp)
    800015fc:	e426                	sd	s1,8(sp)
    800015fe:	1000                	addi	s0,sp,32
    80001600:	84aa                	mv	s1,a0
  if(sz > 0)
    80001602:	e999                	bnez	a1,80001618 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001604:	8526                	mv	a0,s1
    80001606:	00000097          	auipc	ra,0x0
    8000160a:	f84080e7          	jalr	-124(ra) # 8000158a <freewalk>
}
    8000160e:	60e2                	ld	ra,24(sp)
    80001610:	6442                	ld	s0,16(sp)
    80001612:	64a2                	ld	s1,8(sp)
    80001614:	6105                	addi	sp,sp,32
    80001616:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001618:	6785                	lui	a5,0x1
    8000161a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000161c:	95be                	add	a1,a1,a5
    8000161e:	4685                	li	a3,1
    80001620:	00c5d613          	srli	a2,a1,0xc
    80001624:	4581                	li	a1,0
    80001626:	00000097          	auipc	ra,0x0
    8000162a:	d06080e7          	jalr	-762(ra) # 8000132c <uvmunmap>
    8000162e:	bfd9                	j	80001604 <uvmfree+0xe>

0000000080001630 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001630:	c679                	beqz	a2,800016fe <uvmcopy+0xce>
{
    80001632:	715d                	addi	sp,sp,-80
    80001634:	e486                	sd	ra,72(sp)
    80001636:	e0a2                	sd	s0,64(sp)
    80001638:	fc26                	sd	s1,56(sp)
    8000163a:	f84a                	sd	s2,48(sp)
    8000163c:	f44e                	sd	s3,40(sp)
    8000163e:	f052                	sd	s4,32(sp)
    80001640:	ec56                	sd	s5,24(sp)
    80001642:	e85a                	sd	s6,16(sp)
    80001644:	e45e                	sd	s7,8(sp)
    80001646:	0880                	addi	s0,sp,80
    80001648:	8b2a                	mv	s6,a0
    8000164a:	8aae                	mv	s5,a1
    8000164c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001650:	4601                	li	a2,0
    80001652:	85ce                	mv	a1,s3
    80001654:	855a                	mv	a0,s6
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	a28080e7          	jalr	-1496(ra) # 8000107e <walk>
    8000165e:	c531                	beqz	a0,800016aa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001660:	6118                	ld	a4,0(a0)
    80001662:	00177793          	andi	a5,a4,1
    80001666:	cbb1                	beqz	a5,800016ba <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001668:	00a75593          	srli	a1,a4,0xa
    8000166c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001670:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	4ee080e7          	jalr	1262(ra) # 80000b62 <kalloc>
    8000167c:	892a                	mv	s2,a0
    8000167e:	c939                	beqz	a0,800016d4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001680:	6605                	lui	a2,0x1
    80001682:	85de                	mv	a1,s7
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	772080e7          	jalr	1906(ra) # 80000df6 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000168c:	8726                	mv	a4,s1
    8000168e:	86ca                	mv	a3,s2
    80001690:	6605                	lui	a2,0x1
    80001692:	85ce                	mv	a1,s3
    80001694:	8556                	mv	a0,s5
    80001696:	00000097          	auipc	ra,0x0
    8000169a:	ad0080e7          	jalr	-1328(ra) # 80001166 <mappages>
    8000169e:	e515                	bnez	a0,800016ca <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800016a0:	6785                	lui	a5,0x1
    800016a2:	99be                	add	s3,s3,a5
    800016a4:	fb49e6e3          	bltu	s3,s4,80001650 <uvmcopy+0x20>
    800016a8:	a081                	j	800016e8 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016aa:	00007517          	auipc	a0,0x7
    800016ae:	b1e50513          	addi	a0,a0,-1250 # 800081c8 <digits+0x178>
    800016b2:	fffff097          	auipc	ra,0xfffff
    800016b6:	e8e080e7          	jalr	-370(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800016ba:	00007517          	auipc	a0,0x7
    800016be:	b2e50513          	addi	a0,a0,-1234 # 800081e8 <digits+0x198>
    800016c2:	fffff097          	auipc	ra,0xfffff
    800016c6:	e7e080e7          	jalr	-386(ra) # 80000540 <panic>
      kfree(mem);
    800016ca:	854a                	mv	a0,s2
    800016cc:	fffff097          	auipc	ra,0xfffff
    800016d0:	32e080e7          	jalr	814(ra) # 800009fa <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016d4:	4685                	li	a3,1
    800016d6:	00c9d613          	srli	a2,s3,0xc
    800016da:	4581                	li	a1,0
    800016dc:	8556                	mv	a0,s5
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	c4e080e7          	jalr	-946(ra) # 8000132c <uvmunmap>
  return -1;
    800016e6:	557d                	li	a0,-1
}
    800016e8:	60a6                	ld	ra,72(sp)
    800016ea:	6406                	ld	s0,64(sp)
    800016ec:	74e2                	ld	s1,56(sp)
    800016ee:	7942                	ld	s2,48(sp)
    800016f0:	79a2                	ld	s3,40(sp)
    800016f2:	7a02                	ld	s4,32(sp)
    800016f4:	6ae2                	ld	s5,24(sp)
    800016f6:	6b42                	ld	s6,16(sp)
    800016f8:	6ba2                	ld	s7,8(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret
  return 0;
    800016fe:	4501                	li	a0,0
}
    80001700:	8082                	ret

0000000080001702 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001702:	1141                	addi	sp,sp,-16
    80001704:	e406                	sd	ra,8(sp)
    80001706:	e022                	sd	s0,0(sp)
    80001708:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000170a:	4601                	li	a2,0
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	972080e7          	jalr	-1678(ra) # 8000107e <walk>
  if(pte == 0)
    80001714:	c901                	beqz	a0,80001724 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001716:	611c                	ld	a5,0(a0)
    80001718:	9bbd                	andi	a5,a5,-17
    8000171a:	e11c                	sd	a5,0(a0)
}
    8000171c:	60a2                	ld	ra,8(sp)
    8000171e:	6402                	ld	s0,0(sp)
    80001720:	0141                	addi	sp,sp,16
    80001722:	8082                	ret
    panic("uvmclear");
    80001724:	00007517          	auipc	a0,0x7
    80001728:	ae450513          	addi	a0,a0,-1308 # 80008208 <digits+0x1b8>
    8000172c:	fffff097          	auipc	ra,0xfffff
    80001730:	e14080e7          	jalr	-492(ra) # 80000540 <panic>

0000000080001734 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001734:	c6bd                	beqz	a3,800017a2 <copyout+0x6e>
{
    80001736:	715d                	addi	sp,sp,-80
    80001738:	e486                	sd	ra,72(sp)
    8000173a:	e0a2                	sd	s0,64(sp)
    8000173c:	fc26                	sd	s1,56(sp)
    8000173e:	f84a                	sd	s2,48(sp)
    80001740:	f44e                	sd	s3,40(sp)
    80001742:	f052                	sd	s4,32(sp)
    80001744:	ec56                	sd	s5,24(sp)
    80001746:	e85a                	sd	s6,16(sp)
    80001748:	e45e                	sd	s7,8(sp)
    8000174a:	e062                	sd	s8,0(sp)
    8000174c:	0880                	addi	s0,sp,80
    8000174e:	8b2a                	mv	s6,a0
    80001750:	8c2e                	mv	s8,a1
    80001752:	8a32                	mv	s4,a2
    80001754:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001756:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001758:	6a85                	lui	s5,0x1
    8000175a:	a015                	j	8000177e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000175c:	9562                	add	a0,a0,s8
    8000175e:	0004861b          	sext.w	a2,s1
    80001762:	85d2                	mv	a1,s4
    80001764:	41250533          	sub	a0,a0,s2
    80001768:	fffff097          	auipc	ra,0xfffff
    8000176c:	68e080e7          	jalr	1678(ra) # 80000df6 <memmove>

    len -= n;
    80001770:	409989b3          	sub	s3,s3,s1
    src += n;
    80001774:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001776:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000177a:	02098263          	beqz	s3,8000179e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000177e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001782:	85ca                	mv	a1,s2
    80001784:	855a                	mv	a0,s6
    80001786:	00000097          	auipc	ra,0x0
    8000178a:	99e080e7          	jalr	-1634(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    8000178e:	cd01                	beqz	a0,800017a6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001790:	418904b3          	sub	s1,s2,s8
    80001794:	94d6                	add	s1,s1,s5
    80001796:	fc99f3e3          	bgeu	s3,s1,8000175c <copyout+0x28>
    8000179a:	84ce                	mv	s1,s3
    8000179c:	b7c1                	j	8000175c <copyout+0x28>
  }
  return 0;
    8000179e:	4501                	li	a0,0
    800017a0:	a021                	j	800017a8 <copyout+0x74>
    800017a2:	4501                	li	a0,0
}
    800017a4:	8082                	ret
      return -1;
    800017a6:	557d                	li	a0,-1
}
    800017a8:	60a6                	ld	ra,72(sp)
    800017aa:	6406                	ld	s0,64(sp)
    800017ac:	74e2                	ld	s1,56(sp)
    800017ae:	7942                	ld	s2,48(sp)
    800017b0:	79a2                	ld	s3,40(sp)
    800017b2:	7a02                	ld	s4,32(sp)
    800017b4:	6ae2                	ld	s5,24(sp)
    800017b6:	6b42                	ld	s6,16(sp)
    800017b8:	6ba2                	ld	s7,8(sp)
    800017ba:	6c02                	ld	s8,0(sp)
    800017bc:	6161                	addi	sp,sp,80
    800017be:	8082                	ret

00000000800017c0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017c0:	caa5                	beqz	a3,80001830 <copyin+0x70>
{
    800017c2:	715d                	addi	sp,sp,-80
    800017c4:	e486                	sd	ra,72(sp)
    800017c6:	e0a2                	sd	s0,64(sp)
    800017c8:	fc26                	sd	s1,56(sp)
    800017ca:	f84a                	sd	s2,48(sp)
    800017cc:	f44e                	sd	s3,40(sp)
    800017ce:	f052                	sd	s4,32(sp)
    800017d0:	ec56                	sd	s5,24(sp)
    800017d2:	e85a                	sd	s6,16(sp)
    800017d4:	e45e                	sd	s7,8(sp)
    800017d6:	e062                	sd	s8,0(sp)
    800017d8:	0880                	addi	s0,sp,80
    800017da:	8b2a                	mv	s6,a0
    800017dc:	8a2e                	mv	s4,a1
    800017de:	8c32                	mv	s8,a2
    800017e0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017e2:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e4:	6a85                	lui	s5,0x1
    800017e6:	a01d                	j	8000180c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017e8:	018505b3          	add	a1,a0,s8
    800017ec:	0004861b          	sext.w	a2,s1
    800017f0:	412585b3          	sub	a1,a1,s2
    800017f4:	8552                	mv	a0,s4
    800017f6:	fffff097          	auipc	ra,0xfffff
    800017fa:	600080e7          	jalr	1536(ra) # 80000df6 <memmove>

    len -= n;
    800017fe:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001802:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001804:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001808:	02098263          	beqz	s3,8000182c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000180c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001810:	85ca                	mv	a1,s2
    80001812:	855a                	mv	a0,s6
    80001814:	00000097          	auipc	ra,0x0
    80001818:	910080e7          	jalr	-1776(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    8000181c:	cd01                	beqz	a0,80001834 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000181e:	418904b3          	sub	s1,s2,s8
    80001822:	94d6                	add	s1,s1,s5
    80001824:	fc99f2e3          	bgeu	s3,s1,800017e8 <copyin+0x28>
    80001828:	84ce                	mv	s1,s3
    8000182a:	bf7d                	j	800017e8 <copyin+0x28>
  }
  return 0;
    8000182c:	4501                	li	a0,0
    8000182e:	a021                	j	80001836 <copyin+0x76>
    80001830:	4501                	li	a0,0
}
    80001832:	8082                	ret
      return -1;
    80001834:	557d                	li	a0,-1
}
    80001836:	60a6                	ld	ra,72(sp)
    80001838:	6406                	ld	s0,64(sp)
    8000183a:	74e2                	ld	s1,56(sp)
    8000183c:	7942                	ld	s2,48(sp)
    8000183e:	79a2                	ld	s3,40(sp)
    80001840:	7a02                	ld	s4,32(sp)
    80001842:	6ae2                	ld	s5,24(sp)
    80001844:	6b42                	ld	s6,16(sp)
    80001846:	6ba2                	ld	s7,8(sp)
    80001848:	6c02                	ld	s8,0(sp)
    8000184a:	6161                	addi	sp,sp,80
    8000184c:	8082                	ret

000000008000184e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000184e:	c2dd                	beqz	a3,800018f4 <copyinstr+0xa6>
{
    80001850:	715d                	addi	sp,sp,-80
    80001852:	e486                	sd	ra,72(sp)
    80001854:	e0a2                	sd	s0,64(sp)
    80001856:	fc26                	sd	s1,56(sp)
    80001858:	f84a                	sd	s2,48(sp)
    8000185a:	f44e                	sd	s3,40(sp)
    8000185c:	f052                	sd	s4,32(sp)
    8000185e:	ec56                	sd	s5,24(sp)
    80001860:	e85a                	sd	s6,16(sp)
    80001862:	e45e                	sd	s7,8(sp)
    80001864:	0880                	addi	s0,sp,80
    80001866:	8a2a                	mv	s4,a0
    80001868:	8b2e                	mv	s6,a1
    8000186a:	8bb2                	mv	s7,a2
    8000186c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000186e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001870:	6985                	lui	s3,0x1
    80001872:	a02d                	j	8000189c <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001874:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001878:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000187a:	37fd                	addiw	a5,a5,-1
    8000187c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001880:	60a6                	ld	ra,72(sp)
    80001882:	6406                	ld	s0,64(sp)
    80001884:	74e2                	ld	s1,56(sp)
    80001886:	7942                	ld	s2,48(sp)
    80001888:	79a2                	ld	s3,40(sp)
    8000188a:	7a02                	ld	s4,32(sp)
    8000188c:	6ae2                	ld	s5,24(sp)
    8000188e:	6b42                	ld	s6,16(sp)
    80001890:	6ba2                	ld	s7,8(sp)
    80001892:	6161                	addi	sp,sp,80
    80001894:	8082                	ret
    srcva = va0 + PGSIZE;
    80001896:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000189a:	c8a9                	beqz	s1,800018ec <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000189c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800018a0:	85ca                	mv	a1,s2
    800018a2:	8552                	mv	a0,s4
    800018a4:	00000097          	auipc	ra,0x0
    800018a8:	880080e7          	jalr	-1920(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    800018ac:	c131                	beqz	a0,800018f0 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800018ae:	417906b3          	sub	a3,s2,s7
    800018b2:	96ce                	add	a3,a3,s3
    800018b4:	00d4f363          	bgeu	s1,a3,800018ba <copyinstr+0x6c>
    800018b8:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018ba:	955e                	add	a0,a0,s7
    800018bc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018c0:	daf9                	beqz	a3,80001896 <copyinstr+0x48>
    800018c2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018c4:	41650633          	sub	a2,a0,s6
    800018c8:	fff48593          	addi	a1,s1,-1
    800018cc:	95da                	add	a1,a1,s6
    while(n > 0){
    800018ce:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800018d0:	00f60733          	add	a4,a2,a5
    800018d4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd120>
    800018d8:	df51                	beqz	a4,80001874 <copyinstr+0x26>
        *dst = *p;
    800018da:	00e78023          	sb	a4,0(a5)
      --max;
    800018de:	40f584b3          	sub	s1,a1,a5
      dst++;
    800018e2:	0785                	addi	a5,a5,1
    while(n > 0){
    800018e4:	fed796e3          	bne	a5,a3,800018d0 <copyinstr+0x82>
      dst++;
    800018e8:	8b3e                	mv	s6,a5
    800018ea:	b775                	j	80001896 <copyinstr+0x48>
    800018ec:	4781                	li	a5,0
    800018ee:	b771                	j	8000187a <copyinstr+0x2c>
      return -1;
    800018f0:	557d                	li	a0,-1
    800018f2:	b779                	j	80001880 <copyinstr+0x32>
  int got_null = 0;
    800018f4:	4781                	li	a5,0
  if(got_null){
    800018f6:	37fd                	addiw	a5,a5,-1
    800018f8:	0007851b          	sext.w	a0,a5
}
    800018fc:	8082                	ret

00000000800018fe <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    800018fe:	715d                	addi	sp,sp,-80
    80001900:	e486                	sd	ra,72(sp)
    80001902:	e0a2                	sd	s0,64(sp)
    80001904:	fc26                	sd	s1,56(sp)
    80001906:	f84a                	sd	s2,48(sp)
    80001908:	f44e                	sd	s3,40(sp)
    8000190a:	f052                	sd	s4,32(sp)
    8000190c:	ec56                	sd	s5,24(sp)
    8000190e:	e85a                	sd	s6,16(sp)
    80001910:	e45e                	sd	s7,8(sp)
    80001912:	e062                	sd	s8,0(sp)
    80001914:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    80001916:	8792                	mv	a5,tp
    int id = r_tp();
    80001918:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    8000191a:	0000fa97          	auipc	s5,0xf
    8000191e:	3b6a8a93          	addi	s5,s5,950 # 80010cd0 <cpus>
    80001922:	00779713          	slli	a4,a5,0x7
    80001926:	00ea86b3          	add	a3,s5,a4
    8000192a:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdd120>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    8000192e:	0721                	addi	a4,a4,8
    80001930:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001932:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001934:	00007c17          	auipc	s8,0x7
    80001938:	054c0c13          	addi	s8,s8,84 # 80008988 <sched_pointer>
    8000193c:	00000b97          	auipc	s7,0x0
    80001940:	fc2b8b93          	addi	s7,s7,-62 # 800018fe <rr_scheduler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001944:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001948:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000194c:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001950:	0000f497          	auipc	s1,0xf
    80001954:	7b048493          	addi	s1,s1,1968 # 80011100 <proc>
            if (p->state == RUNNABLE)
    80001958:	498d                	li	s3,3
                p->state = RUNNING;
    8000195a:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    8000195c:	00015a17          	auipc	s4,0x15
    80001960:	1a4a0a13          	addi	s4,s4,420 # 80016b00 <tickslock>
    80001964:	a81d                	j	8000199a <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001966:	8526                	mv	a0,s1
    80001968:	fffff097          	auipc	ra,0xfffff
    8000196c:	3ea080e7          	jalr	1002(ra) # 80000d52 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001970:	60a6                	ld	ra,72(sp)
    80001972:	6406                	ld	s0,64(sp)
    80001974:	74e2                	ld	s1,56(sp)
    80001976:	7942                	ld	s2,48(sp)
    80001978:	79a2                	ld	s3,40(sp)
    8000197a:	7a02                	ld	s4,32(sp)
    8000197c:	6ae2                	ld	s5,24(sp)
    8000197e:	6b42                	ld	s6,16(sp)
    80001980:	6ba2                	ld	s7,8(sp)
    80001982:	6c02                	ld	s8,0(sp)
    80001984:	6161                	addi	sp,sp,80
    80001986:	8082                	ret
            release(&p->lock);
    80001988:	8526                	mv	a0,s1
    8000198a:	fffff097          	auipc	ra,0xfffff
    8000198e:	3c8080e7          	jalr	968(ra) # 80000d52 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001992:	16848493          	addi	s1,s1,360
    80001996:	fb4487e3          	beq	s1,s4,80001944 <rr_scheduler+0x46>
            acquire(&p->lock);
    8000199a:	8526                	mv	a0,s1
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	302080e7          	jalr	770(ra) # 80000c9e <acquire>
            if (p->state == RUNNABLE)
    800019a4:	4c9c                	lw	a5,24(s1)
    800019a6:	ff3791e3          	bne	a5,s3,80001988 <rr_scheduler+0x8a>
                p->state = RUNNING;
    800019aa:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    800019ae:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    800019b2:	06048593          	addi	a1,s1,96
    800019b6:	8556                	mv	a0,s5
    800019b8:	00001097          	auipc	ra,0x1
    800019bc:	fc2080e7          	jalr	-62(ra) # 8000297a <swtch>
                if (sched_pointer != &rr_scheduler)
    800019c0:	000c3783          	ld	a5,0(s8)
    800019c4:	fb7791e3          	bne	a5,s7,80001966 <rr_scheduler+0x68>
                c->proc = 0;
    800019c8:	00093023          	sd	zero,0(s2)
    800019cc:	bf75                	j	80001988 <rr_scheduler+0x8a>

00000000800019ce <proc_mapstacks>:
{
    800019ce:	7139                	addi	sp,sp,-64
    800019d0:	fc06                	sd	ra,56(sp)
    800019d2:	f822                	sd	s0,48(sp)
    800019d4:	f426                	sd	s1,40(sp)
    800019d6:	f04a                	sd	s2,32(sp)
    800019d8:	ec4e                	sd	s3,24(sp)
    800019da:	e852                	sd	s4,16(sp)
    800019dc:	e456                	sd	s5,8(sp)
    800019de:	e05a                	sd	s6,0(sp)
    800019e0:	0080                	addi	s0,sp,64
    800019e2:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    800019e4:	0000f497          	auipc	s1,0xf
    800019e8:	71c48493          	addi	s1,s1,1820 # 80011100 <proc>
        uint64 va = KSTACK((int)(p - proc));
    800019ec:	8b26                	mv	s6,s1
    800019ee:	00006a97          	auipc	s5,0x6
    800019f2:	622a8a93          	addi	s5,s5,1570 # 80008010 <__func__.1+0x8>
    800019f6:	04000937          	lui	s2,0x4000
    800019fa:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800019fc:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    800019fe:	00015a17          	auipc	s4,0x15
    80001a02:	102a0a13          	addi	s4,s4,258 # 80016b00 <tickslock>
        char *pa = kalloc();
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	15c080e7          	jalr	348(ra) # 80000b62 <kalloc>
    80001a0e:	862a                	mv	a2,a0
        if (pa == 0)
    80001a10:	c131                	beqz	a0,80001a54 <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001a12:	416485b3          	sub	a1,s1,s6
    80001a16:	858d                	srai	a1,a1,0x3
    80001a18:	000ab783          	ld	a5,0(s5)
    80001a1c:	02f585b3          	mul	a1,a1,a5
    80001a20:	2585                	addiw	a1,a1,1
    80001a22:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a26:	4719                	li	a4,6
    80001a28:	6685                	lui	a3,0x1
    80001a2a:	40b905b3          	sub	a1,s2,a1
    80001a2e:	854e                	mv	a0,s3
    80001a30:	fffff097          	auipc	ra,0xfffff
    80001a34:	7d6080e7          	jalr	2006(ra) # 80001206 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001a38:	16848493          	addi	s1,s1,360
    80001a3c:	fd4495e3          	bne	s1,s4,80001a06 <proc_mapstacks+0x38>
}
    80001a40:	70e2                	ld	ra,56(sp)
    80001a42:	7442                	ld	s0,48(sp)
    80001a44:	74a2                	ld	s1,40(sp)
    80001a46:	7902                	ld	s2,32(sp)
    80001a48:	69e2                	ld	s3,24(sp)
    80001a4a:	6a42                	ld	s4,16(sp)
    80001a4c:	6aa2                	ld	s5,8(sp)
    80001a4e:	6b02                	ld	s6,0(sp)
    80001a50:	6121                	addi	sp,sp,64
    80001a52:	8082                	ret
            panic("kalloc");
    80001a54:	00006517          	auipc	a0,0x6
    80001a58:	7c450513          	addi	a0,a0,1988 # 80008218 <digits+0x1c8>
    80001a5c:	fffff097          	auipc	ra,0xfffff
    80001a60:	ae4080e7          	jalr	-1308(ra) # 80000540 <panic>

0000000080001a64 <procinit>:
{
    80001a64:	7139                	addi	sp,sp,-64
    80001a66:	fc06                	sd	ra,56(sp)
    80001a68:	f822                	sd	s0,48(sp)
    80001a6a:	f426                	sd	s1,40(sp)
    80001a6c:	f04a                	sd	s2,32(sp)
    80001a6e:	ec4e                	sd	s3,24(sp)
    80001a70:	e852                	sd	s4,16(sp)
    80001a72:	e456                	sd	s5,8(sp)
    80001a74:	e05a                	sd	s6,0(sp)
    80001a76:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001a78:	00006597          	auipc	a1,0x6
    80001a7c:	7a858593          	addi	a1,a1,1960 # 80008220 <digits+0x1d0>
    80001a80:	0000f517          	auipc	a0,0xf
    80001a84:	65050513          	addi	a0,a0,1616 # 800110d0 <pid_lock>
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	186080e7          	jalr	390(ra) # 80000c0e <initlock>
    initlock(&wait_lock, "wait_lock");
    80001a90:	00006597          	auipc	a1,0x6
    80001a94:	79858593          	addi	a1,a1,1944 # 80008228 <digits+0x1d8>
    80001a98:	0000f517          	auipc	a0,0xf
    80001a9c:	65050513          	addi	a0,a0,1616 # 800110e8 <wait_lock>
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	16e080e7          	jalr	366(ra) # 80000c0e <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001aa8:	0000f497          	auipc	s1,0xf
    80001aac:	65848493          	addi	s1,s1,1624 # 80011100 <proc>
        initlock(&p->lock, "proc");
    80001ab0:	00006b17          	auipc	s6,0x6
    80001ab4:	788b0b13          	addi	s6,s6,1928 # 80008238 <digits+0x1e8>
        p->kstack = KSTACK((int)(p - proc));
    80001ab8:	8aa6                	mv	s5,s1
    80001aba:	00006a17          	auipc	s4,0x6
    80001abe:	556a0a13          	addi	s4,s4,1366 # 80008010 <__func__.1+0x8>
    80001ac2:	04000937          	lui	s2,0x4000
    80001ac6:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001ac8:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001aca:	00015997          	auipc	s3,0x15
    80001ace:	03698993          	addi	s3,s3,54 # 80016b00 <tickslock>
        initlock(&p->lock, "proc");
    80001ad2:	85da                	mv	a1,s6
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	138080e7          	jalr	312(ra) # 80000c0e <initlock>
        p->state = UNUSED;
    80001ade:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001ae2:	415487b3          	sub	a5,s1,s5
    80001ae6:	878d                	srai	a5,a5,0x3
    80001ae8:	000a3703          	ld	a4,0(s4)
    80001aec:	02e787b3          	mul	a5,a5,a4
    80001af0:	2785                	addiw	a5,a5,1
    80001af2:	00d7979b          	slliw	a5,a5,0xd
    80001af6:	40f907b3          	sub	a5,s2,a5
    80001afa:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001afc:	16848493          	addi	s1,s1,360
    80001b00:	fd3499e3          	bne	s1,s3,80001ad2 <procinit+0x6e>
}
    80001b04:	70e2                	ld	ra,56(sp)
    80001b06:	7442                	ld	s0,48(sp)
    80001b08:	74a2                	ld	s1,40(sp)
    80001b0a:	7902                	ld	s2,32(sp)
    80001b0c:	69e2                	ld	s3,24(sp)
    80001b0e:	6a42                	ld	s4,16(sp)
    80001b10:	6aa2                	ld	s5,8(sp)
    80001b12:	6b02                	ld	s6,0(sp)
    80001b14:	6121                	addi	sp,sp,64
    80001b16:	8082                	ret

0000000080001b18 <copy_array>:
{
    80001b18:	1141                	addi	sp,sp,-16
    80001b1a:	e422                	sd	s0,8(sp)
    80001b1c:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001b1e:	02c05163          	blez	a2,80001b40 <copy_array+0x28>
    80001b22:	87aa                	mv	a5,a0
    80001b24:	0505                	addi	a0,a0,1
    80001b26:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001b28:	1602                	slli	a2,a2,0x20
    80001b2a:	9201                	srli	a2,a2,0x20
    80001b2c:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001b30:	0007c703          	lbu	a4,0(a5)
    80001b34:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001b38:	0785                	addi	a5,a5,1
    80001b3a:	0585                	addi	a1,a1,1
    80001b3c:	fed79ae3          	bne	a5,a3,80001b30 <copy_array+0x18>
}
    80001b40:	6422                	ld	s0,8(sp)
    80001b42:	0141                	addi	sp,sp,16
    80001b44:	8082                	ret

0000000080001b46 <cpuid>:
{
    80001b46:	1141                	addi	sp,sp,-16
    80001b48:	e422                	sd	s0,8(sp)
    80001b4a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b4c:	8512                	mv	a0,tp
}
    80001b4e:	2501                	sext.w	a0,a0
    80001b50:	6422                	ld	s0,8(sp)
    80001b52:	0141                	addi	sp,sp,16
    80001b54:	8082                	ret

0000000080001b56 <mycpu>:
{
    80001b56:	1141                	addi	sp,sp,-16
    80001b58:	e422                	sd	s0,8(sp)
    80001b5a:	0800                	addi	s0,sp,16
    80001b5c:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001b5e:	2781                	sext.w	a5,a5
    80001b60:	079e                	slli	a5,a5,0x7
}
    80001b62:	0000f517          	auipc	a0,0xf
    80001b66:	16e50513          	addi	a0,a0,366 # 80010cd0 <cpus>
    80001b6a:	953e                	add	a0,a0,a5
    80001b6c:	6422                	ld	s0,8(sp)
    80001b6e:	0141                	addi	sp,sp,16
    80001b70:	8082                	ret

0000000080001b72 <myproc>:
{
    80001b72:	1101                	addi	sp,sp,-32
    80001b74:	ec06                	sd	ra,24(sp)
    80001b76:	e822                	sd	s0,16(sp)
    80001b78:	e426                	sd	s1,8(sp)
    80001b7a:	1000                	addi	s0,sp,32
    push_off();
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	0d6080e7          	jalr	214(ra) # 80000c52 <push_off>
    80001b84:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001b86:	2781                	sext.w	a5,a5
    80001b88:	079e                	slli	a5,a5,0x7
    80001b8a:	0000f717          	auipc	a4,0xf
    80001b8e:	14670713          	addi	a4,a4,326 # 80010cd0 <cpus>
    80001b92:	97ba                	add	a5,a5,a4
    80001b94:	6384                	ld	s1,0(a5)
    pop_off();
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	15c080e7          	jalr	348(ra) # 80000cf2 <pop_off>
}
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	60e2                	ld	ra,24(sp)
    80001ba2:	6442                	ld	s0,16(sp)
    80001ba4:	64a2                	ld	s1,8(sp)
    80001ba6:	6105                	addi	sp,sp,32
    80001ba8:	8082                	ret

0000000080001baa <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001baa:	1141                	addi	sp,sp,-16
    80001bac:	e406                	sd	ra,8(sp)
    80001bae:	e022                	sd	s0,0(sp)
    80001bb0:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001bb2:	00000097          	auipc	ra,0x0
    80001bb6:	fc0080e7          	jalr	-64(ra) # 80001b72 <myproc>
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	198080e7          	jalr	408(ra) # 80000d52 <release>

    if (first)
    80001bc2:	00007797          	auipc	a5,0x7
    80001bc6:	dbe7a783          	lw	a5,-578(a5) # 80008980 <first.1>
    80001bca:	eb89                	bnez	a5,80001bdc <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001bcc:	00001097          	auipc	ra,0x1
    80001bd0:	e58080e7          	jalr	-424(ra) # 80002a24 <usertrapret>
}
    80001bd4:	60a2                	ld	ra,8(sp)
    80001bd6:	6402                	ld	s0,0(sp)
    80001bd8:	0141                	addi	sp,sp,16
    80001bda:	8082                	ret
        first = 0;
    80001bdc:	00007797          	auipc	a5,0x7
    80001be0:	da07a223          	sw	zero,-604(a5) # 80008980 <first.1>
        fsinit(ROOTDEV);
    80001be4:	4505                	li	a0,1
    80001be6:	00002097          	auipc	ra,0x2
    80001bea:	ca2080e7          	jalr	-862(ra) # 80003888 <fsinit>
    80001bee:	bff9                	j	80001bcc <forkret+0x22>

0000000080001bf0 <allocpid>:
{
    80001bf0:	1101                	addi	sp,sp,-32
    80001bf2:	ec06                	sd	ra,24(sp)
    80001bf4:	e822                	sd	s0,16(sp)
    80001bf6:	e426                	sd	s1,8(sp)
    80001bf8:	e04a                	sd	s2,0(sp)
    80001bfa:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001bfc:	0000f917          	auipc	s2,0xf
    80001c00:	4d490913          	addi	s2,s2,1236 # 800110d0 <pid_lock>
    80001c04:	854a                	mv	a0,s2
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	098080e7          	jalr	152(ra) # 80000c9e <acquire>
    pid = nextpid;
    80001c0e:	00007797          	auipc	a5,0x7
    80001c12:	d8278793          	addi	a5,a5,-638 # 80008990 <nextpid>
    80001c16:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001c18:	0014871b          	addiw	a4,s1,1
    80001c1c:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001c1e:	854a                	mv	a0,s2
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	132080e7          	jalr	306(ra) # 80000d52 <release>
}
    80001c28:	8526                	mv	a0,s1
    80001c2a:	60e2                	ld	ra,24(sp)
    80001c2c:	6442                	ld	s0,16(sp)
    80001c2e:	64a2                	ld	s1,8(sp)
    80001c30:	6902                	ld	s2,0(sp)
    80001c32:	6105                	addi	sp,sp,32
    80001c34:	8082                	ret

0000000080001c36 <proc_pagetable>:
{
    80001c36:	1101                	addi	sp,sp,-32
    80001c38:	ec06                	sd	ra,24(sp)
    80001c3a:	e822                	sd	s0,16(sp)
    80001c3c:	e426                	sd	s1,8(sp)
    80001c3e:	e04a                	sd	s2,0(sp)
    80001c40:	1000                	addi	s0,sp,32
    80001c42:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	7ac080e7          	jalr	1964(ra) # 800013f0 <uvmcreate>
    80001c4c:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001c4e:	c121                	beqz	a0,80001c8e <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c50:	4729                	li	a4,10
    80001c52:	00005697          	auipc	a3,0x5
    80001c56:	3ae68693          	addi	a3,a3,942 # 80007000 <_trampoline>
    80001c5a:	6605                	lui	a2,0x1
    80001c5c:	040005b7          	lui	a1,0x4000
    80001c60:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c62:	05b2                	slli	a1,a1,0xc
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	502080e7          	jalr	1282(ra) # 80001166 <mappages>
    80001c6c:	02054863          	bltz	a0,80001c9c <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c70:	4719                	li	a4,6
    80001c72:	05893683          	ld	a3,88(s2)
    80001c76:	6605                	lui	a2,0x1
    80001c78:	020005b7          	lui	a1,0x2000
    80001c7c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c7e:	05b6                	slli	a1,a1,0xd
    80001c80:	8526                	mv	a0,s1
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	4e4080e7          	jalr	1252(ra) # 80001166 <mappages>
    80001c8a:	02054163          	bltz	a0,80001cac <proc_pagetable+0x76>
}
    80001c8e:	8526                	mv	a0,s1
    80001c90:	60e2                	ld	ra,24(sp)
    80001c92:	6442                	ld	s0,16(sp)
    80001c94:	64a2                	ld	s1,8(sp)
    80001c96:	6902                	ld	s2,0(sp)
    80001c98:	6105                	addi	sp,sp,32
    80001c9a:	8082                	ret
        uvmfree(pagetable, 0);
    80001c9c:	4581                	li	a1,0
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	00000097          	auipc	ra,0x0
    80001ca4:	956080e7          	jalr	-1706(ra) # 800015f6 <uvmfree>
        return 0;
    80001ca8:	4481                	li	s1,0
    80001caa:	b7d5                	j	80001c8e <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cac:	4681                	li	a3,0
    80001cae:	4605                	li	a2,1
    80001cb0:	040005b7          	lui	a1,0x4000
    80001cb4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cb6:	05b2                	slli	a1,a1,0xc
    80001cb8:	8526                	mv	a0,s1
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	672080e7          	jalr	1650(ra) # 8000132c <uvmunmap>
        uvmfree(pagetable, 0);
    80001cc2:	4581                	li	a1,0
    80001cc4:	8526                	mv	a0,s1
    80001cc6:	00000097          	auipc	ra,0x0
    80001cca:	930080e7          	jalr	-1744(ra) # 800015f6 <uvmfree>
        return 0;
    80001cce:	4481                	li	s1,0
    80001cd0:	bf7d                	j	80001c8e <proc_pagetable+0x58>

0000000080001cd2 <proc_freepagetable>:
{
    80001cd2:	1101                	addi	sp,sp,-32
    80001cd4:	ec06                	sd	ra,24(sp)
    80001cd6:	e822                	sd	s0,16(sp)
    80001cd8:	e426                	sd	s1,8(sp)
    80001cda:	e04a                	sd	s2,0(sp)
    80001cdc:	1000                	addi	s0,sp,32
    80001cde:	84aa                	mv	s1,a0
    80001ce0:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ce2:	4681                	li	a3,0
    80001ce4:	4605                	li	a2,1
    80001ce6:	040005b7          	lui	a1,0x4000
    80001cea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cec:	05b2                	slli	a1,a1,0xc
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	63e080e7          	jalr	1598(ra) # 8000132c <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cf6:	4681                	li	a3,0
    80001cf8:	4605                	li	a2,1
    80001cfa:	020005b7          	lui	a1,0x2000
    80001cfe:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d00:	05b6                	slli	a1,a1,0xd
    80001d02:	8526                	mv	a0,s1
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	628080e7          	jalr	1576(ra) # 8000132c <uvmunmap>
    uvmfree(pagetable, sz);
    80001d0c:	85ca                	mv	a1,s2
    80001d0e:	8526                	mv	a0,s1
    80001d10:	00000097          	auipc	ra,0x0
    80001d14:	8e6080e7          	jalr	-1818(ra) # 800015f6 <uvmfree>
}
    80001d18:	60e2                	ld	ra,24(sp)
    80001d1a:	6442                	ld	s0,16(sp)
    80001d1c:	64a2                	ld	s1,8(sp)
    80001d1e:	6902                	ld	s2,0(sp)
    80001d20:	6105                	addi	sp,sp,32
    80001d22:	8082                	ret

0000000080001d24 <freeproc>:
{
    80001d24:	1101                	addi	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	1000                	addi	s0,sp,32
    80001d2e:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001d30:	6d28                	ld	a0,88(a0)
    80001d32:	c509                	beqz	a0,80001d3c <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	cc6080e7          	jalr	-826(ra) # 800009fa <kfree>
    p->trapframe = 0;
    80001d3c:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001d40:	68a8                	ld	a0,80(s1)
    80001d42:	c511                	beqz	a0,80001d4e <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001d44:	64ac                	ld	a1,72(s1)
    80001d46:	00000097          	auipc	ra,0x0
    80001d4a:	f8c080e7          	jalr	-116(ra) # 80001cd2 <proc_freepagetable>
    p->pagetable = 0;
    80001d4e:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001d52:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001d56:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001d5a:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001d5e:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001d62:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001d66:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001d6a:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001d6e:	0004ac23          	sw	zero,24(s1)
}
    80001d72:	60e2                	ld	ra,24(sp)
    80001d74:	6442                	ld	s0,16(sp)
    80001d76:	64a2                	ld	s1,8(sp)
    80001d78:	6105                	addi	sp,sp,32
    80001d7a:	8082                	ret

0000000080001d7c <allocproc>:
{
    80001d7c:	1101                	addi	sp,sp,-32
    80001d7e:	ec06                	sd	ra,24(sp)
    80001d80:	e822                	sd	s0,16(sp)
    80001d82:	e426                	sd	s1,8(sp)
    80001d84:	e04a                	sd	s2,0(sp)
    80001d86:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001d88:	0000f497          	auipc	s1,0xf
    80001d8c:	37848493          	addi	s1,s1,888 # 80011100 <proc>
    80001d90:	00015917          	auipc	s2,0x15
    80001d94:	d7090913          	addi	s2,s2,-656 # 80016b00 <tickslock>
        acquire(&p->lock);
    80001d98:	8526                	mv	a0,s1
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	f04080e7          	jalr	-252(ra) # 80000c9e <acquire>
        if (p->state == UNUSED)
    80001da2:	4c9c                	lw	a5,24(s1)
    80001da4:	cf81                	beqz	a5,80001dbc <allocproc+0x40>
            release(&p->lock);
    80001da6:	8526                	mv	a0,s1
    80001da8:	fffff097          	auipc	ra,0xfffff
    80001dac:	faa080e7          	jalr	-86(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001db0:	16848493          	addi	s1,s1,360
    80001db4:	ff2492e3          	bne	s1,s2,80001d98 <allocproc+0x1c>
    return 0;
    80001db8:	4481                	li	s1,0
    80001dba:	a889                	j	80001e0c <allocproc+0x90>
    p->pid = allocpid();
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	e34080e7          	jalr	-460(ra) # 80001bf0 <allocpid>
    80001dc4:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001dc6:	4785                	li	a5,1
    80001dc8:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	d98080e7          	jalr	-616(ra) # 80000b62 <kalloc>
    80001dd2:	892a                	mv	s2,a0
    80001dd4:	eca8                	sd	a0,88(s1)
    80001dd6:	c131                	beqz	a0,80001e1a <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001dd8:	8526                	mv	a0,s1
    80001dda:	00000097          	auipc	ra,0x0
    80001dde:	e5c080e7          	jalr	-420(ra) # 80001c36 <proc_pagetable>
    80001de2:	892a                	mv	s2,a0
    80001de4:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001de6:	c531                	beqz	a0,80001e32 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001de8:	07000613          	li	a2,112
    80001dec:	4581                	li	a1,0
    80001dee:	06048513          	addi	a0,s1,96
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	fa8080e7          	jalr	-88(ra) # 80000d9a <memset>
    p->context.ra = (uint64)forkret;
    80001dfa:	00000797          	auipc	a5,0x0
    80001dfe:	db078793          	addi	a5,a5,-592 # 80001baa <forkret>
    80001e02:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001e04:	60bc                	ld	a5,64(s1)
    80001e06:	6705                	lui	a4,0x1
    80001e08:	97ba                	add	a5,a5,a4
    80001e0a:	f4bc                	sd	a5,104(s1)
}
    80001e0c:	8526                	mv	a0,s1
    80001e0e:	60e2                	ld	ra,24(sp)
    80001e10:	6442                	ld	s0,16(sp)
    80001e12:	64a2                	ld	s1,8(sp)
    80001e14:	6902                	ld	s2,0(sp)
    80001e16:	6105                	addi	sp,sp,32
    80001e18:	8082                	ret
        freeproc(p);
    80001e1a:	8526                	mv	a0,s1
    80001e1c:	00000097          	auipc	ra,0x0
    80001e20:	f08080e7          	jalr	-248(ra) # 80001d24 <freeproc>
        release(&p->lock);
    80001e24:	8526                	mv	a0,s1
    80001e26:	fffff097          	auipc	ra,0xfffff
    80001e2a:	f2c080e7          	jalr	-212(ra) # 80000d52 <release>
        return 0;
    80001e2e:	84ca                	mv	s1,s2
    80001e30:	bff1                	j	80001e0c <allocproc+0x90>
        freeproc(p);
    80001e32:	8526                	mv	a0,s1
    80001e34:	00000097          	auipc	ra,0x0
    80001e38:	ef0080e7          	jalr	-272(ra) # 80001d24 <freeproc>
        release(&p->lock);
    80001e3c:	8526                	mv	a0,s1
    80001e3e:	fffff097          	auipc	ra,0xfffff
    80001e42:	f14080e7          	jalr	-236(ra) # 80000d52 <release>
        return 0;
    80001e46:	84ca                	mv	s1,s2
    80001e48:	b7d1                	j	80001e0c <allocproc+0x90>

0000000080001e4a <userinit>:
{
    80001e4a:	1101                	addi	sp,sp,-32
    80001e4c:	ec06                	sd	ra,24(sp)
    80001e4e:	e822                	sd	s0,16(sp)
    80001e50:	e426                	sd	s1,8(sp)
    80001e52:	1000                	addi	s0,sp,32
    p = allocproc();
    80001e54:	00000097          	auipc	ra,0x0
    80001e58:	f28080e7          	jalr	-216(ra) # 80001d7c <allocproc>
    80001e5c:	84aa                	mv	s1,a0
    initproc = p;
    80001e5e:	00007797          	auipc	a5,0x7
    80001e62:	bea7bd23          	sd	a0,-1030(a5) # 80008a58 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e66:	03400613          	li	a2,52
    80001e6a:	00007597          	auipc	a1,0x7
    80001e6e:	b3658593          	addi	a1,a1,-1226 # 800089a0 <initcode>
    80001e72:	6928                	ld	a0,80(a0)
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	5aa080e7          	jalr	1450(ra) # 8000141e <uvmfirst>
    p->sz = PGSIZE;
    80001e7c:	6785                	lui	a5,0x1
    80001e7e:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001e80:	6cb8                	ld	a4,88(s1)
    80001e82:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001e86:	6cb8                	ld	a4,88(s1)
    80001e88:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e8a:	4641                	li	a2,16
    80001e8c:	00006597          	auipc	a1,0x6
    80001e90:	3b458593          	addi	a1,a1,948 # 80008240 <digits+0x1f0>
    80001e94:	15848513          	addi	a0,s1,344
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	04c080e7          	jalr	76(ra) # 80000ee4 <safestrcpy>
    p->cwd = namei("/");
    80001ea0:	00006517          	auipc	a0,0x6
    80001ea4:	3b050513          	addi	a0,a0,944 # 80008250 <digits+0x200>
    80001ea8:	00002097          	auipc	ra,0x2
    80001eac:	40a080e7          	jalr	1034(ra) # 800042b2 <namei>
    80001eb0:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001eb4:	478d                	li	a5,3
    80001eb6:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001eb8:	8526                	mv	a0,s1
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	e98080e7          	jalr	-360(ra) # 80000d52 <release>
}
    80001ec2:	60e2                	ld	ra,24(sp)
    80001ec4:	6442                	ld	s0,16(sp)
    80001ec6:	64a2                	ld	s1,8(sp)
    80001ec8:	6105                	addi	sp,sp,32
    80001eca:	8082                	ret

0000000080001ecc <growproc>:
{
    80001ecc:	1101                	addi	sp,sp,-32
    80001ece:	ec06                	sd	ra,24(sp)
    80001ed0:	e822                	sd	s0,16(sp)
    80001ed2:	e426                	sd	s1,8(sp)
    80001ed4:	e04a                	sd	s2,0(sp)
    80001ed6:	1000                	addi	s0,sp,32
    80001ed8:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001eda:	00000097          	auipc	ra,0x0
    80001ede:	c98080e7          	jalr	-872(ra) # 80001b72 <myproc>
    80001ee2:	84aa                	mv	s1,a0
    sz = p->sz;
    80001ee4:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001ee6:	01204c63          	bgtz	s2,80001efe <growproc+0x32>
    else if (n < 0)
    80001eea:	02094663          	bltz	s2,80001f16 <growproc+0x4a>
    p->sz = sz;
    80001eee:	e4ac                	sd	a1,72(s1)
    return 0;
    80001ef0:	4501                	li	a0,0
}
    80001ef2:	60e2                	ld	ra,24(sp)
    80001ef4:	6442                	ld	s0,16(sp)
    80001ef6:	64a2                	ld	s1,8(sp)
    80001ef8:	6902                	ld	s2,0(sp)
    80001efa:	6105                	addi	sp,sp,32
    80001efc:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001efe:	4691                	li	a3,4
    80001f00:	00b90633          	add	a2,s2,a1
    80001f04:	6928                	ld	a0,80(a0)
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	5d2080e7          	jalr	1490(ra) # 800014d8 <uvmalloc>
    80001f0e:	85aa                	mv	a1,a0
    80001f10:	fd79                	bnez	a0,80001eee <growproc+0x22>
            return -1;
    80001f12:	557d                	li	a0,-1
    80001f14:	bff9                	j	80001ef2 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f16:	00b90633          	add	a2,s2,a1
    80001f1a:	6928                	ld	a0,80(a0)
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	574080e7          	jalr	1396(ra) # 80001490 <uvmdealloc>
    80001f24:	85aa                	mv	a1,a0
    80001f26:	b7e1                	j	80001eee <growproc+0x22>

0000000080001f28 <ps>:
{
    80001f28:	715d                	addi	sp,sp,-80
    80001f2a:	e486                	sd	ra,72(sp)
    80001f2c:	e0a2                	sd	s0,64(sp)
    80001f2e:	fc26                	sd	s1,56(sp)
    80001f30:	f84a                	sd	s2,48(sp)
    80001f32:	f44e                	sd	s3,40(sp)
    80001f34:	f052                	sd	s4,32(sp)
    80001f36:	ec56                	sd	s5,24(sp)
    80001f38:	e85a                	sd	s6,16(sp)
    80001f3a:	e45e                	sd	s7,8(sp)
    80001f3c:	e062                	sd	s8,0(sp)
    80001f3e:	0880                	addi	s0,sp,80
    80001f40:	84aa                	mv	s1,a0
    80001f42:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80001f44:	00000097          	auipc	ra,0x0
    80001f48:	c2e080e7          	jalr	-978(ra) # 80001b72 <myproc>
    if (count == 0)
    80001f4c:	120b8063          	beqz	s7,8000206c <ps+0x144>
    void *result = (void *)myproc()->sz;
    80001f50:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80001f54:	003b951b          	slliw	a0,s7,0x3
    80001f58:	0175053b          	addw	a0,a0,s7
    80001f5c:	0025151b          	slliw	a0,a0,0x2
    80001f60:	00000097          	auipc	ra,0x0
    80001f64:	f6c080e7          	jalr	-148(ra) # 80001ecc <growproc>
    80001f68:	10054463          	bltz	a0,80002070 <ps+0x148>
    struct user_proc loc_result[count];
    80001f6c:	003b9a13          	slli	s4,s7,0x3
    80001f70:	9a5e                	add	s4,s4,s7
    80001f72:	0a0a                	slli	s4,s4,0x2
    80001f74:	00fa0793          	addi	a5,s4,15
    80001f78:	8391                	srli	a5,a5,0x4
    80001f7a:	0792                	slli	a5,a5,0x4
    80001f7c:	40f10133          	sub	sp,sp,a5
    80001f80:	8a8a                	mv	s5,sp
    struct proc *p = proc + (start * sizeof(proc));
    80001f82:	007e97b7          	lui	a5,0x7e9
    80001f86:	02f484b3          	mul	s1,s1,a5
    80001f8a:	0000f797          	auipc	a5,0xf
    80001f8e:	17678793          	addi	a5,a5,374 # 80011100 <proc>
    80001f92:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    80001f94:	00015797          	auipc	a5,0x15
    80001f98:	b6c78793          	addi	a5,a5,-1172 # 80016b00 <tickslock>
    80001f9c:	0cf4fc63          	bgeu	s1,a5,80002074 <ps+0x14c>
    80001fa0:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80001fa4:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80001fa6:	8c3e                	mv	s8,a5
    80001fa8:	a069                	j	80002032 <ps+0x10a>
            loc_result[localCount].state = UNUSED;
    80001faa:	00399793          	slli	a5,s3,0x3
    80001fae:	97ce                	add	a5,a5,s3
    80001fb0:	078a                	slli	a5,a5,0x2
    80001fb2:	97d6                	add	a5,a5,s5
    80001fb4:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80001fb8:	8526                	mv	a0,s1
    80001fba:	fffff097          	auipc	ra,0xfffff
    80001fbe:	d98080e7          	jalr	-616(ra) # 80000d52 <release>
    if (localCount < count)
    80001fc2:	0179f963          	bgeu	s3,s7,80001fd4 <ps+0xac>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80001fc6:	00399793          	slli	a5,s3,0x3
    80001fca:	97ce                	add	a5,a5,s3
    80001fcc:	078a                	slli	a5,a5,0x2
    80001fce:	97d6                	add	a5,a5,s5
    80001fd0:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80001fd4:	84da                	mv	s1,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	b9c080e7          	jalr	-1124(ra) # 80001b72 <myproc>
    80001fde:	86d2                	mv	a3,s4
    80001fe0:	8656                	mv	a2,s5
    80001fe2:	85da                	mv	a1,s6
    80001fe4:	6928                	ld	a0,80(a0)
    80001fe6:	fffff097          	auipc	ra,0xfffff
    80001fea:	74e080e7          	jalr	1870(ra) # 80001734 <copyout>
}
    80001fee:	8526                	mv	a0,s1
    80001ff0:	fb040113          	addi	sp,s0,-80
    80001ff4:	60a6                	ld	ra,72(sp)
    80001ff6:	6406                	ld	s0,64(sp)
    80001ff8:	74e2                	ld	s1,56(sp)
    80001ffa:	7942                	ld	s2,48(sp)
    80001ffc:	79a2                	ld	s3,40(sp)
    80001ffe:	7a02                	ld	s4,32(sp)
    80002000:	6ae2                	ld	s5,24(sp)
    80002002:	6b42                	ld	s6,16(sp)
    80002004:	6ba2                	ld	s7,8(sp)
    80002006:	6c02                	ld	s8,0(sp)
    80002008:	6161                	addi	sp,sp,80
    8000200a:	8082                	ret
            loc_result[localCount].parent_id = p->parent->pid;
    8000200c:	5b9c                	lw	a5,48(a5)
    8000200e:	fef92e23          	sw	a5,-4(s2)
        release(&p->lock);
    80002012:	8526                	mv	a0,s1
    80002014:	fffff097          	auipc	ra,0xfffff
    80002018:	d3e080e7          	jalr	-706(ra) # 80000d52 <release>
        localCount++;
    8000201c:	2985                	addiw	s3,s3,1
    8000201e:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    80002022:	16848493          	addi	s1,s1,360
    80002026:	f984fee3          	bgeu	s1,s8,80001fc2 <ps+0x9a>
        if (localCount == count)
    8000202a:	02490913          	addi	s2,s2,36
    8000202e:	fb3b83e3          	beq	s7,s3,80001fd4 <ps+0xac>
        acquire(&p->lock);
    80002032:	8526                	mv	a0,s1
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	c6a080e7          	jalr	-918(ra) # 80000c9e <acquire>
        if (p->state == UNUSED)
    8000203c:	4c9c                	lw	a5,24(s1)
    8000203e:	d7b5                	beqz	a5,80001faa <ps+0x82>
        loc_result[localCount].state = p->state;
    80002040:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    80002044:	549c                	lw	a5,40(s1)
    80002046:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    8000204a:	54dc                	lw	a5,44(s1)
    8000204c:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    80002050:	589c                	lw	a5,48(s1)
    80002052:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002056:	4641                	li	a2,16
    80002058:	85ca                	mv	a1,s2
    8000205a:	15848513          	addi	a0,s1,344
    8000205e:	00000097          	auipc	ra,0x0
    80002062:	aba080e7          	jalr	-1350(ra) # 80001b18 <copy_array>
        if (p->parent != 0) // init
    80002066:	7c9c                	ld	a5,56(s1)
    80002068:	f3d5                	bnez	a5,8000200c <ps+0xe4>
    8000206a:	b765                	j	80002012 <ps+0xea>
        return result;
    8000206c:	4481                	li	s1,0
    8000206e:	b741                	j	80001fee <ps+0xc6>
        return result;
    80002070:	4481                	li	s1,0
    80002072:	bfb5                	j	80001fee <ps+0xc6>
        return result;
    80002074:	4481                	li	s1,0
    80002076:	bfa5                	j	80001fee <ps+0xc6>

0000000080002078 <fork>:
{
    80002078:	7139                	addi	sp,sp,-64
    8000207a:	fc06                	sd	ra,56(sp)
    8000207c:	f822                	sd	s0,48(sp)
    8000207e:	f426                	sd	s1,40(sp)
    80002080:	f04a                	sd	s2,32(sp)
    80002082:	ec4e                	sd	s3,24(sp)
    80002084:	e852                	sd	s4,16(sp)
    80002086:	e456                	sd	s5,8(sp)
    80002088:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	ae8080e7          	jalr	-1304(ra) # 80001b72 <myproc>
    80002092:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002094:	00000097          	auipc	ra,0x0
    80002098:	ce8080e7          	jalr	-792(ra) # 80001d7c <allocproc>
    8000209c:	10050c63          	beqz	a0,800021b4 <fork+0x13c>
    800020a0:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    800020a2:	048ab603          	ld	a2,72(s5)
    800020a6:	692c                	ld	a1,80(a0)
    800020a8:	050ab503          	ld	a0,80(s5)
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	584080e7          	jalr	1412(ra) # 80001630 <uvmcopy>
    800020b4:	04054863          	bltz	a0,80002104 <fork+0x8c>
    np->sz = p->sz;
    800020b8:	048ab783          	ld	a5,72(s5)
    800020bc:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    800020c0:	058ab683          	ld	a3,88(s5)
    800020c4:	87b6                	mv	a5,a3
    800020c6:	058a3703          	ld	a4,88(s4)
    800020ca:	12068693          	addi	a3,a3,288
    800020ce:	0007b803          	ld	a6,0(a5)
    800020d2:	6788                	ld	a0,8(a5)
    800020d4:	6b8c                	ld	a1,16(a5)
    800020d6:	6f90                	ld	a2,24(a5)
    800020d8:	01073023          	sd	a6,0(a4)
    800020dc:	e708                	sd	a0,8(a4)
    800020de:	eb0c                	sd	a1,16(a4)
    800020e0:	ef10                	sd	a2,24(a4)
    800020e2:	02078793          	addi	a5,a5,32
    800020e6:	02070713          	addi	a4,a4,32
    800020ea:	fed792e3          	bne	a5,a3,800020ce <fork+0x56>
    np->trapframe->a0 = 0;
    800020ee:	058a3783          	ld	a5,88(s4)
    800020f2:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800020f6:	0d0a8493          	addi	s1,s5,208
    800020fa:	0d0a0913          	addi	s2,s4,208
    800020fe:	150a8993          	addi	s3,s5,336
    80002102:	a00d                	j	80002124 <fork+0xac>
        freeproc(np);
    80002104:	8552                	mv	a0,s4
    80002106:	00000097          	auipc	ra,0x0
    8000210a:	c1e080e7          	jalr	-994(ra) # 80001d24 <freeproc>
        release(&np->lock);
    8000210e:	8552                	mv	a0,s4
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	c42080e7          	jalr	-958(ra) # 80000d52 <release>
        return -1;
    80002118:	597d                	li	s2,-1
    8000211a:	a059                	j	800021a0 <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    8000211c:	04a1                	addi	s1,s1,8
    8000211e:	0921                	addi	s2,s2,8
    80002120:	01348b63          	beq	s1,s3,80002136 <fork+0xbe>
        if (p->ofile[i])
    80002124:	6088                	ld	a0,0(s1)
    80002126:	d97d                	beqz	a0,8000211c <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    80002128:	00003097          	auipc	ra,0x3
    8000212c:	820080e7          	jalr	-2016(ra) # 80004948 <filedup>
    80002130:	00a93023          	sd	a0,0(s2)
    80002134:	b7e5                	j	8000211c <fork+0xa4>
    np->cwd = idup(p->cwd);
    80002136:	150ab503          	ld	a0,336(s5)
    8000213a:	00002097          	auipc	ra,0x2
    8000213e:	98e080e7          	jalr	-1650(ra) # 80003ac8 <idup>
    80002142:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002146:	4641                	li	a2,16
    80002148:	158a8593          	addi	a1,s5,344
    8000214c:	158a0513          	addi	a0,s4,344
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	d94080e7          	jalr	-620(ra) # 80000ee4 <safestrcpy>
    pid = np->pid;
    80002158:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    8000215c:	8552                	mv	a0,s4
    8000215e:	fffff097          	auipc	ra,0xfffff
    80002162:	bf4080e7          	jalr	-1036(ra) # 80000d52 <release>
    acquire(&wait_lock);
    80002166:	0000f497          	auipc	s1,0xf
    8000216a:	f8248493          	addi	s1,s1,-126 # 800110e8 <wait_lock>
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	b2e080e7          	jalr	-1234(ra) # 80000c9e <acquire>
    np->parent = p;
    80002178:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    8000217c:	8526                	mv	a0,s1
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	bd4080e7          	jalr	-1068(ra) # 80000d52 <release>
    acquire(&np->lock);
    80002186:	8552                	mv	a0,s4
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	b16080e7          	jalr	-1258(ra) # 80000c9e <acquire>
    np->state = RUNNABLE;
    80002190:	478d                	li	a5,3
    80002192:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002196:	8552                	mv	a0,s4
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	bba080e7          	jalr	-1094(ra) # 80000d52 <release>
}
    800021a0:	854a                	mv	a0,s2
    800021a2:	70e2                	ld	ra,56(sp)
    800021a4:	7442                	ld	s0,48(sp)
    800021a6:	74a2                	ld	s1,40(sp)
    800021a8:	7902                	ld	s2,32(sp)
    800021aa:	69e2                	ld	s3,24(sp)
    800021ac:	6a42                	ld	s4,16(sp)
    800021ae:	6aa2                	ld	s5,8(sp)
    800021b0:	6121                	addi	sp,sp,64
    800021b2:	8082                	ret
        return -1;
    800021b4:	597d                	li	s2,-1
    800021b6:	b7ed                	j	800021a0 <fork+0x128>

00000000800021b8 <scheduler>:
{
    800021b8:	1101                	addi	sp,sp,-32
    800021ba:	ec06                	sd	ra,24(sp)
    800021bc:	e822                	sd	s0,16(sp)
    800021be:	e426                	sd	s1,8(sp)
    800021c0:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    800021c2:	00006497          	auipc	s1,0x6
    800021c6:	7c648493          	addi	s1,s1,1990 # 80008988 <sched_pointer>
    800021ca:	609c                	ld	a5,0(s1)
    800021cc:	9782                	jalr	a5
    while (1)
    800021ce:	bff5                	j	800021ca <scheduler+0x12>

00000000800021d0 <sched>:
{
    800021d0:	7179                	addi	sp,sp,-48
    800021d2:	f406                	sd	ra,40(sp)
    800021d4:	f022                	sd	s0,32(sp)
    800021d6:	ec26                	sd	s1,24(sp)
    800021d8:	e84a                	sd	s2,16(sp)
    800021da:	e44e                	sd	s3,8(sp)
    800021dc:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    800021de:	00000097          	auipc	ra,0x0
    800021e2:	994080e7          	jalr	-1644(ra) # 80001b72 <myproc>
    800021e6:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	a3c080e7          	jalr	-1476(ra) # 80000c24 <holding>
    800021f0:	c53d                	beqz	a0,8000225e <sched+0x8e>
    800021f2:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800021f4:	2781                	sext.w	a5,a5
    800021f6:	079e                	slli	a5,a5,0x7
    800021f8:	0000f717          	auipc	a4,0xf
    800021fc:	ad870713          	addi	a4,a4,-1320 # 80010cd0 <cpus>
    80002200:	97ba                	add	a5,a5,a4
    80002202:	5fb8                	lw	a4,120(a5)
    80002204:	4785                	li	a5,1
    80002206:	06f71463          	bne	a4,a5,8000226e <sched+0x9e>
    if (p->state == RUNNING)
    8000220a:	4c98                	lw	a4,24(s1)
    8000220c:	4791                	li	a5,4
    8000220e:	06f70863          	beq	a4,a5,8000227e <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002212:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002216:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002218:	ebbd                	bnez	a5,8000228e <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000221a:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    8000221c:	0000f917          	auipc	s2,0xf
    80002220:	ab490913          	addi	s2,s2,-1356 # 80010cd0 <cpus>
    80002224:	2781                	sext.w	a5,a5
    80002226:	079e                	slli	a5,a5,0x7
    80002228:	97ca                	add	a5,a5,s2
    8000222a:	07c7a983          	lw	s3,124(a5)
    8000222e:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    80002230:	2581                	sext.w	a1,a1
    80002232:	059e                	slli	a1,a1,0x7
    80002234:	05a1                	addi	a1,a1,8
    80002236:	95ca                	add	a1,a1,s2
    80002238:	06048513          	addi	a0,s1,96
    8000223c:	00000097          	auipc	ra,0x0
    80002240:	73e080e7          	jalr	1854(ra) # 8000297a <swtch>
    80002244:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002246:	2781                	sext.w	a5,a5
    80002248:	079e                	slli	a5,a5,0x7
    8000224a:	993e                	add	s2,s2,a5
    8000224c:	07392e23          	sw	s3,124(s2)
}
    80002250:	70a2                	ld	ra,40(sp)
    80002252:	7402                	ld	s0,32(sp)
    80002254:	64e2                	ld	s1,24(sp)
    80002256:	6942                	ld	s2,16(sp)
    80002258:	69a2                	ld	s3,8(sp)
    8000225a:	6145                	addi	sp,sp,48
    8000225c:	8082                	ret
        panic("sched p->lock");
    8000225e:	00006517          	auipc	a0,0x6
    80002262:	ffa50513          	addi	a0,a0,-6 # 80008258 <digits+0x208>
    80002266:	ffffe097          	auipc	ra,0xffffe
    8000226a:	2da080e7          	jalr	730(ra) # 80000540 <panic>
        panic("sched locks");
    8000226e:	00006517          	auipc	a0,0x6
    80002272:	ffa50513          	addi	a0,a0,-6 # 80008268 <digits+0x218>
    80002276:	ffffe097          	auipc	ra,0xffffe
    8000227a:	2ca080e7          	jalr	714(ra) # 80000540 <panic>
        panic("sched running");
    8000227e:	00006517          	auipc	a0,0x6
    80002282:	ffa50513          	addi	a0,a0,-6 # 80008278 <digits+0x228>
    80002286:	ffffe097          	auipc	ra,0xffffe
    8000228a:	2ba080e7          	jalr	698(ra) # 80000540 <panic>
        panic("sched interruptible");
    8000228e:	00006517          	auipc	a0,0x6
    80002292:	ffa50513          	addi	a0,a0,-6 # 80008288 <digits+0x238>
    80002296:	ffffe097          	auipc	ra,0xffffe
    8000229a:	2aa080e7          	jalr	682(ra) # 80000540 <panic>

000000008000229e <yield>:
{
    8000229e:	1101                	addi	sp,sp,-32
    800022a0:	ec06                	sd	ra,24(sp)
    800022a2:	e822                	sd	s0,16(sp)
    800022a4:	e426                	sd	s1,8(sp)
    800022a6:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800022a8:	00000097          	auipc	ra,0x0
    800022ac:	8ca080e7          	jalr	-1846(ra) # 80001b72 <myproc>
    800022b0:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	9ec080e7          	jalr	-1556(ra) # 80000c9e <acquire>
    p->state = RUNNABLE;
    800022ba:	478d                	li	a5,3
    800022bc:	cc9c                	sw	a5,24(s1)
    sched();
    800022be:	00000097          	auipc	ra,0x0
    800022c2:	f12080e7          	jalr	-238(ra) # 800021d0 <sched>
    release(&p->lock);
    800022c6:	8526                	mv	a0,s1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	a8a080e7          	jalr	-1398(ra) # 80000d52 <release>
}
    800022d0:	60e2                	ld	ra,24(sp)
    800022d2:	6442                	ld	s0,16(sp)
    800022d4:	64a2                	ld	s1,8(sp)
    800022d6:	6105                	addi	sp,sp,32
    800022d8:	8082                	ret

00000000800022da <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800022da:	7179                	addi	sp,sp,-48
    800022dc:	f406                	sd	ra,40(sp)
    800022de:	f022                	sd	s0,32(sp)
    800022e0:	ec26                	sd	s1,24(sp)
    800022e2:	e84a                	sd	s2,16(sp)
    800022e4:	e44e                	sd	s3,8(sp)
    800022e6:	1800                	addi	s0,sp,48
    800022e8:	89aa                	mv	s3,a0
    800022ea:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800022ec:	00000097          	auipc	ra,0x0
    800022f0:	886080e7          	jalr	-1914(ra) # 80001b72 <myproc>
    800022f4:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	9a8080e7          	jalr	-1624(ra) # 80000c9e <acquire>
    release(lk);
    800022fe:	854a                	mv	a0,s2
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	a52080e7          	jalr	-1454(ra) # 80000d52 <release>

    // Go to sleep.
    p->chan = chan;
    80002308:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    8000230c:	4789                	li	a5,2
    8000230e:	cc9c                	sw	a5,24(s1)

    sched();
    80002310:	00000097          	auipc	ra,0x0
    80002314:	ec0080e7          	jalr	-320(ra) # 800021d0 <sched>

    // Tidy up.
    p->chan = 0;
    80002318:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    8000231c:	8526                	mv	a0,s1
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	a34080e7          	jalr	-1484(ra) # 80000d52 <release>
    acquire(lk);
    80002326:	854a                	mv	a0,s2
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	976080e7          	jalr	-1674(ra) # 80000c9e <acquire>
}
    80002330:	70a2                	ld	ra,40(sp)
    80002332:	7402                	ld	s0,32(sp)
    80002334:	64e2                	ld	s1,24(sp)
    80002336:	6942                	ld	s2,16(sp)
    80002338:	69a2                	ld	s3,8(sp)
    8000233a:	6145                	addi	sp,sp,48
    8000233c:	8082                	ret

000000008000233e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000233e:	7139                	addi	sp,sp,-64
    80002340:	fc06                	sd	ra,56(sp)
    80002342:	f822                	sd	s0,48(sp)
    80002344:	f426                	sd	s1,40(sp)
    80002346:	f04a                	sd	s2,32(sp)
    80002348:	ec4e                	sd	s3,24(sp)
    8000234a:	e852                	sd	s4,16(sp)
    8000234c:	e456                	sd	s5,8(sp)
    8000234e:	0080                	addi	s0,sp,64
    80002350:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002352:	0000f497          	auipc	s1,0xf
    80002356:	dae48493          	addi	s1,s1,-594 # 80011100 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    8000235a:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    8000235c:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    8000235e:	00014917          	auipc	s2,0x14
    80002362:	7a290913          	addi	s2,s2,1954 # 80016b00 <tickslock>
    80002366:	a811                	j	8000237a <wakeup+0x3c>
            }
            release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	9e8080e7          	jalr	-1560(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002372:	16848493          	addi	s1,s1,360
    80002376:	03248663          	beq	s1,s2,800023a2 <wakeup+0x64>
        if (p != myproc())
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	7f8080e7          	jalr	2040(ra) # 80001b72 <myproc>
    80002382:	fea488e3          	beq	s1,a0,80002372 <wakeup+0x34>
            acquire(&p->lock);
    80002386:	8526                	mv	a0,s1
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	916080e7          	jalr	-1770(ra) # 80000c9e <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002390:	4c9c                	lw	a5,24(s1)
    80002392:	fd379be3          	bne	a5,s3,80002368 <wakeup+0x2a>
    80002396:	709c                	ld	a5,32(s1)
    80002398:	fd4798e3          	bne	a5,s4,80002368 <wakeup+0x2a>
                p->state = RUNNABLE;
    8000239c:	0154ac23          	sw	s5,24(s1)
    800023a0:	b7e1                	j	80002368 <wakeup+0x2a>
        }
    }
}
    800023a2:	70e2                	ld	ra,56(sp)
    800023a4:	7442                	ld	s0,48(sp)
    800023a6:	74a2                	ld	s1,40(sp)
    800023a8:	7902                	ld	s2,32(sp)
    800023aa:	69e2                	ld	s3,24(sp)
    800023ac:	6a42                	ld	s4,16(sp)
    800023ae:	6aa2                	ld	s5,8(sp)
    800023b0:	6121                	addi	sp,sp,64
    800023b2:	8082                	ret

00000000800023b4 <reparent>:
{
    800023b4:	7179                	addi	sp,sp,-48
    800023b6:	f406                	sd	ra,40(sp)
    800023b8:	f022                	sd	s0,32(sp)
    800023ba:	ec26                	sd	s1,24(sp)
    800023bc:	e84a                	sd	s2,16(sp)
    800023be:	e44e                	sd	s3,8(sp)
    800023c0:	e052                	sd	s4,0(sp)
    800023c2:	1800                	addi	s0,sp,48
    800023c4:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023c6:	0000f497          	auipc	s1,0xf
    800023ca:	d3a48493          	addi	s1,s1,-710 # 80011100 <proc>
            pp->parent = initproc;
    800023ce:	00006a17          	auipc	s4,0x6
    800023d2:	68aa0a13          	addi	s4,s4,1674 # 80008a58 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023d6:	00014997          	auipc	s3,0x14
    800023da:	72a98993          	addi	s3,s3,1834 # 80016b00 <tickslock>
    800023de:	a029                	j	800023e8 <reparent+0x34>
    800023e0:	16848493          	addi	s1,s1,360
    800023e4:	01348d63          	beq	s1,s3,800023fe <reparent+0x4a>
        if (pp->parent == p)
    800023e8:	7c9c                	ld	a5,56(s1)
    800023ea:	ff279be3          	bne	a5,s2,800023e0 <reparent+0x2c>
            pp->parent = initproc;
    800023ee:	000a3503          	ld	a0,0(s4)
    800023f2:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800023f4:	00000097          	auipc	ra,0x0
    800023f8:	f4a080e7          	jalr	-182(ra) # 8000233e <wakeup>
    800023fc:	b7d5                	j	800023e0 <reparent+0x2c>
}
    800023fe:	70a2                	ld	ra,40(sp)
    80002400:	7402                	ld	s0,32(sp)
    80002402:	64e2                	ld	s1,24(sp)
    80002404:	6942                	ld	s2,16(sp)
    80002406:	69a2                	ld	s3,8(sp)
    80002408:	6a02                	ld	s4,0(sp)
    8000240a:	6145                	addi	sp,sp,48
    8000240c:	8082                	ret

000000008000240e <exit>:
{
    8000240e:	7179                	addi	sp,sp,-48
    80002410:	f406                	sd	ra,40(sp)
    80002412:	f022                	sd	s0,32(sp)
    80002414:	ec26                	sd	s1,24(sp)
    80002416:	e84a                	sd	s2,16(sp)
    80002418:	e44e                	sd	s3,8(sp)
    8000241a:	e052                	sd	s4,0(sp)
    8000241c:	1800                	addi	s0,sp,48
    8000241e:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	752080e7          	jalr	1874(ra) # 80001b72 <myproc>
    80002428:	89aa                	mv	s3,a0
    if (p == initproc)
    8000242a:	00006797          	auipc	a5,0x6
    8000242e:	62e7b783          	ld	a5,1582(a5) # 80008a58 <initproc>
    80002432:	0d050493          	addi	s1,a0,208
    80002436:	15050913          	addi	s2,a0,336
    8000243a:	02a79363          	bne	a5,a0,80002460 <exit+0x52>
        panic("init exiting");
    8000243e:	00006517          	auipc	a0,0x6
    80002442:	e6250513          	addi	a0,a0,-414 # 800082a0 <digits+0x250>
    80002446:	ffffe097          	auipc	ra,0xffffe
    8000244a:	0fa080e7          	jalr	250(ra) # 80000540 <panic>
            fileclose(f);
    8000244e:	00002097          	auipc	ra,0x2
    80002452:	54c080e7          	jalr	1356(ra) # 8000499a <fileclose>
            p->ofile[fd] = 0;
    80002456:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    8000245a:	04a1                	addi	s1,s1,8
    8000245c:	01248563          	beq	s1,s2,80002466 <exit+0x58>
        if (p->ofile[fd])
    80002460:	6088                	ld	a0,0(s1)
    80002462:	f575                	bnez	a0,8000244e <exit+0x40>
    80002464:	bfdd                	j	8000245a <exit+0x4c>
    begin_op();
    80002466:	00002097          	auipc	ra,0x2
    8000246a:	06c080e7          	jalr	108(ra) # 800044d2 <begin_op>
    iput(p->cwd);
    8000246e:	1509b503          	ld	a0,336(s3)
    80002472:	00002097          	auipc	ra,0x2
    80002476:	84e080e7          	jalr	-1970(ra) # 80003cc0 <iput>
    end_op();
    8000247a:	00002097          	auipc	ra,0x2
    8000247e:	0d6080e7          	jalr	214(ra) # 80004550 <end_op>
    p->cwd = 0;
    80002482:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002486:	0000f497          	auipc	s1,0xf
    8000248a:	c6248493          	addi	s1,s1,-926 # 800110e8 <wait_lock>
    8000248e:	8526                	mv	a0,s1
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	80e080e7          	jalr	-2034(ra) # 80000c9e <acquire>
    reparent(p);
    80002498:	854e                	mv	a0,s3
    8000249a:	00000097          	auipc	ra,0x0
    8000249e:	f1a080e7          	jalr	-230(ra) # 800023b4 <reparent>
    wakeup(p->parent);
    800024a2:	0389b503          	ld	a0,56(s3)
    800024a6:	00000097          	auipc	ra,0x0
    800024aa:	e98080e7          	jalr	-360(ra) # 8000233e <wakeup>
    acquire(&p->lock);
    800024ae:	854e                	mv	a0,s3
    800024b0:	ffffe097          	auipc	ra,0xffffe
    800024b4:	7ee080e7          	jalr	2030(ra) # 80000c9e <acquire>
    p->xstate = status;
    800024b8:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    800024bc:	4795                	li	a5,5
    800024be:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    800024c2:	8526                	mv	a0,s1
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	88e080e7          	jalr	-1906(ra) # 80000d52 <release>
    sched();
    800024cc:	00000097          	auipc	ra,0x0
    800024d0:	d04080e7          	jalr	-764(ra) # 800021d0 <sched>
    panic("zombie exit");
    800024d4:	00006517          	auipc	a0,0x6
    800024d8:	ddc50513          	addi	a0,a0,-548 # 800082b0 <digits+0x260>
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	064080e7          	jalr	100(ra) # 80000540 <panic>

00000000800024e4 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800024e4:	7179                	addi	sp,sp,-48
    800024e6:	f406                	sd	ra,40(sp)
    800024e8:	f022                	sd	s0,32(sp)
    800024ea:	ec26                	sd	s1,24(sp)
    800024ec:	e84a                	sd	s2,16(sp)
    800024ee:	e44e                	sd	s3,8(sp)
    800024f0:	1800                	addi	s0,sp,48
    800024f2:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800024f4:	0000f497          	auipc	s1,0xf
    800024f8:	c0c48493          	addi	s1,s1,-1012 # 80011100 <proc>
    800024fc:	00014997          	auipc	s3,0x14
    80002500:	60498993          	addi	s3,s3,1540 # 80016b00 <tickslock>
    {
        acquire(&p->lock);
    80002504:	8526                	mv	a0,s1
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	798080e7          	jalr	1944(ra) # 80000c9e <acquire>
        if (p->pid == pid)
    8000250e:	589c                	lw	a5,48(s1)
    80002510:	01278d63          	beq	a5,s2,8000252a <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002514:	8526                	mv	a0,s1
    80002516:	fffff097          	auipc	ra,0xfffff
    8000251a:	83c080e7          	jalr	-1988(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000251e:	16848493          	addi	s1,s1,360
    80002522:	ff3491e3          	bne	s1,s3,80002504 <kill+0x20>
    }
    return -1;
    80002526:	557d                	li	a0,-1
    80002528:	a829                	j	80002542 <kill+0x5e>
            p->killed = 1;
    8000252a:	4785                	li	a5,1
    8000252c:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    8000252e:	4c98                	lw	a4,24(s1)
    80002530:	4789                	li	a5,2
    80002532:	00f70f63          	beq	a4,a5,80002550 <kill+0x6c>
            release(&p->lock);
    80002536:	8526                	mv	a0,s1
    80002538:	fffff097          	auipc	ra,0xfffff
    8000253c:	81a080e7          	jalr	-2022(ra) # 80000d52 <release>
            return 0;
    80002540:	4501                	li	a0,0
}
    80002542:	70a2                	ld	ra,40(sp)
    80002544:	7402                	ld	s0,32(sp)
    80002546:	64e2                	ld	s1,24(sp)
    80002548:	6942                	ld	s2,16(sp)
    8000254a:	69a2                	ld	s3,8(sp)
    8000254c:	6145                	addi	sp,sp,48
    8000254e:	8082                	ret
                p->state = RUNNABLE;
    80002550:	478d                	li	a5,3
    80002552:	cc9c                	sw	a5,24(s1)
    80002554:	b7cd                	j	80002536 <kill+0x52>

0000000080002556 <setkilled>:

void setkilled(struct proc *p)
{
    80002556:	1101                	addi	sp,sp,-32
    80002558:	ec06                	sd	ra,24(sp)
    8000255a:	e822                	sd	s0,16(sp)
    8000255c:	e426                	sd	s1,8(sp)
    8000255e:	1000                	addi	s0,sp,32
    80002560:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	73c080e7          	jalr	1852(ra) # 80000c9e <acquire>
    p->killed = 1;
    8000256a:	4785                	li	a5,1
    8000256c:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    8000256e:	8526                	mv	a0,s1
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	7e2080e7          	jalr	2018(ra) # 80000d52 <release>
}
    80002578:	60e2                	ld	ra,24(sp)
    8000257a:	6442                	ld	s0,16(sp)
    8000257c:	64a2                	ld	s1,8(sp)
    8000257e:	6105                	addi	sp,sp,32
    80002580:	8082                	ret

0000000080002582 <killed>:

int killed(struct proc *p)
{
    80002582:	1101                	addi	sp,sp,-32
    80002584:	ec06                	sd	ra,24(sp)
    80002586:	e822                	sd	s0,16(sp)
    80002588:	e426                	sd	s1,8(sp)
    8000258a:	e04a                	sd	s2,0(sp)
    8000258c:	1000                	addi	s0,sp,32
    8000258e:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	70e080e7          	jalr	1806(ra) # 80000c9e <acquire>
    k = p->killed;
    80002598:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    8000259c:	8526                	mv	a0,s1
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	7b4080e7          	jalr	1972(ra) # 80000d52 <release>
    return k;
}
    800025a6:	854a                	mv	a0,s2
    800025a8:	60e2                	ld	ra,24(sp)
    800025aa:	6442                	ld	s0,16(sp)
    800025ac:	64a2                	ld	s1,8(sp)
    800025ae:	6902                	ld	s2,0(sp)
    800025b0:	6105                	addi	sp,sp,32
    800025b2:	8082                	ret

00000000800025b4 <wait>:
{
    800025b4:	715d                	addi	sp,sp,-80
    800025b6:	e486                	sd	ra,72(sp)
    800025b8:	e0a2                	sd	s0,64(sp)
    800025ba:	fc26                	sd	s1,56(sp)
    800025bc:	f84a                	sd	s2,48(sp)
    800025be:	f44e                	sd	s3,40(sp)
    800025c0:	f052                	sd	s4,32(sp)
    800025c2:	ec56                	sd	s5,24(sp)
    800025c4:	e85a                	sd	s6,16(sp)
    800025c6:	e45e                	sd	s7,8(sp)
    800025c8:	e062                	sd	s8,0(sp)
    800025ca:	0880                	addi	s0,sp,80
    800025cc:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    800025ce:	fffff097          	auipc	ra,0xfffff
    800025d2:	5a4080e7          	jalr	1444(ra) # 80001b72 <myproc>
    800025d6:	892a                	mv	s2,a0
    acquire(&wait_lock);
    800025d8:	0000f517          	auipc	a0,0xf
    800025dc:	b1050513          	addi	a0,a0,-1264 # 800110e8 <wait_lock>
    800025e0:	ffffe097          	auipc	ra,0xffffe
    800025e4:	6be080e7          	jalr	1726(ra) # 80000c9e <acquire>
        havekids = 0;
    800025e8:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    800025ea:	4a15                	li	s4,5
                havekids = 1;
    800025ec:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800025ee:	00014997          	auipc	s3,0x14
    800025f2:	51298993          	addi	s3,s3,1298 # 80016b00 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800025f6:	0000fc17          	auipc	s8,0xf
    800025fa:	af2c0c13          	addi	s8,s8,-1294 # 800110e8 <wait_lock>
        havekids = 0;
    800025fe:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002600:	0000f497          	auipc	s1,0xf
    80002604:	b0048493          	addi	s1,s1,-1280 # 80011100 <proc>
    80002608:	a0bd                	j	80002676 <wait+0xc2>
                    pid = pp->pid;
    8000260a:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000260e:	000b0e63          	beqz	s6,8000262a <wait+0x76>
    80002612:	4691                	li	a3,4
    80002614:	02c48613          	addi	a2,s1,44
    80002618:	85da                	mv	a1,s6
    8000261a:	05093503          	ld	a0,80(s2)
    8000261e:	fffff097          	auipc	ra,0xfffff
    80002622:	116080e7          	jalr	278(ra) # 80001734 <copyout>
    80002626:	02054563          	bltz	a0,80002650 <wait+0x9c>
                    freeproc(pp);
    8000262a:	8526                	mv	a0,s1
    8000262c:	fffff097          	auipc	ra,0xfffff
    80002630:	6f8080e7          	jalr	1784(ra) # 80001d24 <freeproc>
                    release(&pp->lock);
    80002634:	8526                	mv	a0,s1
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	71c080e7          	jalr	1820(ra) # 80000d52 <release>
                    release(&wait_lock);
    8000263e:	0000f517          	auipc	a0,0xf
    80002642:	aaa50513          	addi	a0,a0,-1366 # 800110e8 <wait_lock>
    80002646:	ffffe097          	auipc	ra,0xffffe
    8000264a:	70c080e7          	jalr	1804(ra) # 80000d52 <release>
                    return pid;
    8000264e:	a0b5                	j	800026ba <wait+0x106>
                        release(&pp->lock);
    80002650:	8526                	mv	a0,s1
    80002652:	ffffe097          	auipc	ra,0xffffe
    80002656:	700080e7          	jalr	1792(ra) # 80000d52 <release>
                        release(&wait_lock);
    8000265a:	0000f517          	auipc	a0,0xf
    8000265e:	a8e50513          	addi	a0,a0,-1394 # 800110e8 <wait_lock>
    80002662:	ffffe097          	auipc	ra,0xffffe
    80002666:	6f0080e7          	jalr	1776(ra) # 80000d52 <release>
                        return -1;
    8000266a:	59fd                	li	s3,-1
    8000266c:	a0b9                	j	800026ba <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    8000266e:	16848493          	addi	s1,s1,360
    80002672:	03348463          	beq	s1,s3,8000269a <wait+0xe6>
            if (pp->parent == p)
    80002676:	7c9c                	ld	a5,56(s1)
    80002678:	ff279be3          	bne	a5,s2,8000266e <wait+0xba>
                acquire(&pp->lock);
    8000267c:	8526                	mv	a0,s1
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	620080e7          	jalr	1568(ra) # 80000c9e <acquire>
                if (pp->state == ZOMBIE)
    80002686:	4c9c                	lw	a5,24(s1)
    80002688:	f94781e3          	beq	a5,s4,8000260a <wait+0x56>
                release(&pp->lock);
    8000268c:	8526                	mv	a0,s1
    8000268e:	ffffe097          	auipc	ra,0xffffe
    80002692:	6c4080e7          	jalr	1732(ra) # 80000d52 <release>
                havekids = 1;
    80002696:	8756                	mv	a4,s5
    80002698:	bfd9                	j	8000266e <wait+0xba>
        if (!havekids || killed(p))
    8000269a:	c719                	beqz	a4,800026a8 <wait+0xf4>
    8000269c:	854a                	mv	a0,s2
    8000269e:	00000097          	auipc	ra,0x0
    800026a2:	ee4080e7          	jalr	-284(ra) # 80002582 <killed>
    800026a6:	c51d                	beqz	a0,800026d4 <wait+0x120>
            release(&wait_lock);
    800026a8:	0000f517          	auipc	a0,0xf
    800026ac:	a4050513          	addi	a0,a0,-1472 # 800110e8 <wait_lock>
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	6a2080e7          	jalr	1698(ra) # 80000d52 <release>
            return -1;
    800026b8:	59fd                	li	s3,-1
}
    800026ba:	854e                	mv	a0,s3
    800026bc:	60a6                	ld	ra,72(sp)
    800026be:	6406                	ld	s0,64(sp)
    800026c0:	74e2                	ld	s1,56(sp)
    800026c2:	7942                	ld	s2,48(sp)
    800026c4:	79a2                	ld	s3,40(sp)
    800026c6:	7a02                	ld	s4,32(sp)
    800026c8:	6ae2                	ld	s5,24(sp)
    800026ca:	6b42                	ld	s6,16(sp)
    800026cc:	6ba2                	ld	s7,8(sp)
    800026ce:	6c02                	ld	s8,0(sp)
    800026d0:	6161                	addi	sp,sp,80
    800026d2:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    800026d4:	85e2                	mv	a1,s8
    800026d6:	854a                	mv	a0,s2
    800026d8:	00000097          	auipc	ra,0x0
    800026dc:	c02080e7          	jalr	-1022(ra) # 800022da <sleep>
        havekids = 0;
    800026e0:	bf39                	j	800025fe <wait+0x4a>

00000000800026e2 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026e2:	7179                	addi	sp,sp,-48
    800026e4:	f406                	sd	ra,40(sp)
    800026e6:	f022                	sd	s0,32(sp)
    800026e8:	ec26                	sd	s1,24(sp)
    800026ea:	e84a                	sd	s2,16(sp)
    800026ec:	e44e                	sd	s3,8(sp)
    800026ee:	e052                	sd	s4,0(sp)
    800026f0:	1800                	addi	s0,sp,48
    800026f2:	84aa                	mv	s1,a0
    800026f4:	892e                	mv	s2,a1
    800026f6:	89b2                	mv	s3,a2
    800026f8:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800026fa:	fffff097          	auipc	ra,0xfffff
    800026fe:	478080e7          	jalr	1144(ra) # 80001b72 <myproc>
    if (user_dst)
    80002702:	c08d                	beqz	s1,80002724 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002704:	86d2                	mv	a3,s4
    80002706:	864e                	mv	a2,s3
    80002708:	85ca                	mv	a1,s2
    8000270a:	6928                	ld	a0,80(a0)
    8000270c:	fffff097          	auipc	ra,0xfffff
    80002710:	028080e7          	jalr	40(ra) # 80001734 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002714:	70a2                	ld	ra,40(sp)
    80002716:	7402                	ld	s0,32(sp)
    80002718:	64e2                	ld	s1,24(sp)
    8000271a:	6942                	ld	s2,16(sp)
    8000271c:	69a2                	ld	s3,8(sp)
    8000271e:	6a02                	ld	s4,0(sp)
    80002720:	6145                	addi	sp,sp,48
    80002722:	8082                	ret
        memmove((char *)dst, src, len);
    80002724:	000a061b          	sext.w	a2,s4
    80002728:	85ce                	mv	a1,s3
    8000272a:	854a                	mv	a0,s2
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	6ca080e7          	jalr	1738(ra) # 80000df6 <memmove>
        return 0;
    80002734:	8526                	mv	a0,s1
    80002736:	bff9                	j	80002714 <either_copyout+0x32>

0000000080002738 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002738:	7179                	addi	sp,sp,-48
    8000273a:	f406                	sd	ra,40(sp)
    8000273c:	f022                	sd	s0,32(sp)
    8000273e:	ec26                	sd	s1,24(sp)
    80002740:	e84a                	sd	s2,16(sp)
    80002742:	e44e                	sd	s3,8(sp)
    80002744:	e052                	sd	s4,0(sp)
    80002746:	1800                	addi	s0,sp,48
    80002748:	892a                	mv	s2,a0
    8000274a:	84ae                	mv	s1,a1
    8000274c:	89b2                	mv	s3,a2
    8000274e:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002750:	fffff097          	auipc	ra,0xfffff
    80002754:	422080e7          	jalr	1058(ra) # 80001b72 <myproc>
    if (user_src)
    80002758:	c08d                	beqz	s1,8000277a <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    8000275a:	86d2                	mv	a3,s4
    8000275c:	864e                	mv	a2,s3
    8000275e:	85ca                	mv	a1,s2
    80002760:	6928                	ld	a0,80(a0)
    80002762:	fffff097          	auipc	ra,0xfffff
    80002766:	05e080e7          	jalr	94(ra) # 800017c0 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    8000276a:	70a2                	ld	ra,40(sp)
    8000276c:	7402                	ld	s0,32(sp)
    8000276e:	64e2                	ld	s1,24(sp)
    80002770:	6942                	ld	s2,16(sp)
    80002772:	69a2                	ld	s3,8(sp)
    80002774:	6a02                	ld	s4,0(sp)
    80002776:	6145                	addi	sp,sp,48
    80002778:	8082                	ret
        memmove(dst, (char *)src, len);
    8000277a:	000a061b          	sext.w	a2,s4
    8000277e:	85ce                	mv	a1,s3
    80002780:	854a                	mv	a0,s2
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	674080e7          	jalr	1652(ra) # 80000df6 <memmove>
        return 0;
    8000278a:	8526                	mv	a0,s1
    8000278c:	bff9                	j	8000276a <either_copyin+0x32>

000000008000278e <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000278e:	715d                	addi	sp,sp,-80
    80002790:	e486                	sd	ra,72(sp)
    80002792:	e0a2                	sd	s0,64(sp)
    80002794:	fc26                	sd	s1,56(sp)
    80002796:	f84a                	sd	s2,48(sp)
    80002798:	f44e                	sd	s3,40(sp)
    8000279a:	f052                	sd	s4,32(sp)
    8000279c:	ec56                	sd	s5,24(sp)
    8000279e:	e85a                	sd	s6,16(sp)
    800027a0:	e45e                	sd	s7,8(sp)
    800027a2:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    800027a4:	00006517          	auipc	a0,0x6
    800027a8:	8e450513          	addi	a0,a0,-1820 # 80008088 <digits+0x38>
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	df0080e7          	jalr	-528(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800027b4:	0000f497          	auipc	s1,0xf
    800027b8:	aa448493          	addi	s1,s1,-1372 # 80011258 <proc+0x158>
    800027bc:	00014917          	auipc	s2,0x14
    800027c0:	49c90913          	addi	s2,s2,1180 # 80016c58 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027c4:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    800027c6:	00006997          	auipc	s3,0x6
    800027ca:	afa98993          	addi	s3,s3,-1286 # 800082c0 <digits+0x270>
        printf("%d <%s %s", p->pid, state, p->name);
    800027ce:	00006a97          	auipc	s5,0x6
    800027d2:	afaa8a93          	addi	s5,s5,-1286 # 800082c8 <digits+0x278>
        printf("\n");
    800027d6:	00006a17          	auipc	s4,0x6
    800027da:	8b2a0a13          	addi	s4,s4,-1870 # 80008088 <digits+0x38>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027de:	00006b97          	auipc	s7,0x6
    800027e2:	bfab8b93          	addi	s7,s7,-1030 # 800083d8 <states.0>
    800027e6:	a00d                	j	80002808 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    800027e8:	ed86a583          	lw	a1,-296(a3)
    800027ec:	8556                	mv	a0,s5
    800027ee:	ffffe097          	auipc	ra,0xffffe
    800027f2:	dae080e7          	jalr	-594(ra) # 8000059c <printf>
        printf("\n");
    800027f6:	8552                	mv	a0,s4
    800027f8:	ffffe097          	auipc	ra,0xffffe
    800027fc:	da4080e7          	jalr	-604(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002800:	16848493          	addi	s1,s1,360
    80002804:	03248263          	beq	s1,s2,80002828 <procdump+0x9a>
        if (p->state == UNUSED)
    80002808:	86a6                	mv	a3,s1
    8000280a:	ec04a783          	lw	a5,-320(s1)
    8000280e:	dbed                	beqz	a5,80002800 <procdump+0x72>
            state = "???";
    80002810:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002812:	fcfb6be3          	bltu	s6,a5,800027e8 <procdump+0x5a>
    80002816:	02079713          	slli	a4,a5,0x20
    8000281a:	01d75793          	srli	a5,a4,0x1d
    8000281e:	97de                	add	a5,a5,s7
    80002820:	6390                	ld	a2,0(a5)
    80002822:	f279                	bnez	a2,800027e8 <procdump+0x5a>
            state = "???";
    80002824:	864e                	mv	a2,s3
    80002826:	b7c9                	j	800027e8 <procdump+0x5a>
    }
}
    80002828:	60a6                	ld	ra,72(sp)
    8000282a:	6406                	ld	s0,64(sp)
    8000282c:	74e2                	ld	s1,56(sp)
    8000282e:	7942                	ld	s2,48(sp)
    80002830:	79a2                	ld	s3,40(sp)
    80002832:	7a02                	ld	s4,32(sp)
    80002834:	6ae2                	ld	s5,24(sp)
    80002836:	6b42                	ld	s6,16(sp)
    80002838:	6ba2                	ld	s7,8(sp)
    8000283a:	6161                	addi	sp,sp,80
    8000283c:	8082                	ret

000000008000283e <schedls>:

void schedls()
{
    8000283e:	1141                	addi	sp,sp,-16
    80002840:	e406                	sd	ra,8(sp)
    80002842:	e022                	sd	s0,0(sp)
    80002844:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002846:	00006517          	auipc	a0,0x6
    8000284a:	a9250513          	addi	a0,a0,-1390 # 800082d8 <digits+0x288>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	d4e080e7          	jalr	-690(ra) # 8000059c <printf>
    printf("====================================\n");
    80002856:	00006517          	auipc	a0,0x6
    8000285a:	aaa50513          	addi	a0,a0,-1366 # 80008300 <digits+0x2b0>
    8000285e:	ffffe097          	auipc	ra,0xffffe
    80002862:	d3e080e7          	jalr	-706(ra) # 8000059c <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002866:	00006717          	auipc	a4,0x6
    8000286a:	18273703          	ld	a4,386(a4) # 800089e8 <available_schedulers+0x10>
    8000286e:	00006797          	auipc	a5,0x6
    80002872:	11a7b783          	ld	a5,282(a5) # 80008988 <sched_pointer>
    80002876:	04f70663          	beq	a4,a5,800028c2 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    8000287a:	00006517          	auipc	a0,0x6
    8000287e:	ab650513          	addi	a0,a0,-1354 # 80008330 <digits+0x2e0>
    80002882:	ffffe097          	auipc	ra,0xffffe
    80002886:	d1a080e7          	jalr	-742(ra) # 8000059c <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    8000288a:	00006617          	auipc	a2,0x6
    8000288e:	16662603          	lw	a2,358(a2) # 800089f0 <available_schedulers+0x18>
    80002892:	00006597          	auipc	a1,0x6
    80002896:	14658593          	addi	a1,a1,326 # 800089d8 <available_schedulers>
    8000289a:	00006517          	auipc	a0,0x6
    8000289e:	a9e50513          	addi	a0,a0,-1378 # 80008338 <digits+0x2e8>
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	cfa080e7          	jalr	-774(ra) # 8000059c <printf>
    }
    printf("\n*: current scheduler\n\n");
    800028aa:	00006517          	auipc	a0,0x6
    800028ae:	a9650513          	addi	a0,a0,-1386 # 80008340 <digits+0x2f0>
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	cea080e7          	jalr	-790(ra) # 8000059c <printf>
}
    800028ba:	60a2                	ld	ra,8(sp)
    800028bc:	6402                	ld	s0,0(sp)
    800028be:	0141                	addi	sp,sp,16
    800028c0:	8082                	ret
            printf("[*]\t");
    800028c2:	00006517          	auipc	a0,0x6
    800028c6:	a6650513          	addi	a0,a0,-1434 # 80008328 <digits+0x2d8>
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	cd2080e7          	jalr	-814(ra) # 8000059c <printf>
    800028d2:	bf65                	j	8000288a <schedls+0x4c>

00000000800028d4 <schedset>:

void schedset(int id)
{
    800028d4:	1141                	addi	sp,sp,-16
    800028d6:	e406                	sd	ra,8(sp)
    800028d8:	e022                	sd	s0,0(sp)
    800028da:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    800028dc:	e90d                	bnez	a0,8000290e <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    800028de:	00006797          	auipc	a5,0x6
    800028e2:	10a7b783          	ld	a5,266(a5) # 800089e8 <available_schedulers+0x10>
    800028e6:	00006717          	auipc	a4,0x6
    800028ea:	0af73123          	sd	a5,162(a4) # 80008988 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    800028ee:	00006597          	auipc	a1,0x6
    800028f2:	0ea58593          	addi	a1,a1,234 # 800089d8 <available_schedulers>
    800028f6:	00006517          	auipc	a0,0x6
    800028fa:	a8a50513          	addi	a0,a0,-1398 # 80008380 <digits+0x330>
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	c9e080e7          	jalr	-866(ra) # 8000059c <printf>
}
    80002906:	60a2                	ld	ra,8(sp)
    80002908:	6402                	ld	s0,0(sp)
    8000290a:	0141                	addi	sp,sp,16
    8000290c:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    8000290e:	00006517          	auipc	a0,0x6
    80002912:	a4a50513          	addi	a0,a0,-1462 # 80008358 <digits+0x308>
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	c86080e7          	jalr	-890(ra) # 8000059c <printf>
        return;
    8000291e:	b7e5                	j	80002906 <schedset+0x32>

0000000080002920 <va2pa>:

int va2pa (int addr, int pid)
{
    80002920:	862a                	mv	a2,a0
    struct proc *p;

    for (p=proc; p < &proc[NPROC]; p++){
    80002922:	0000e797          	auipc	a5,0xe
    80002926:	7de78793          	addi	a5,a5,2014 # 80011100 <proc>
    8000292a:	00014697          	auipc	a3,0x14
    8000292e:	1d668693          	addi	a3,a3,470 # 80016b00 <tickslock>
        if(p->pid == pid)
    80002932:	5b98                	lw	a4,48(a5)
    80002934:	00b70863          	beq	a4,a1,80002944 <va2pa+0x24>
    for (p=proc; p < &proc[NPROC]; p++){
    80002938:	16878793          	addi	a5,a5,360
    8000293c:	fed79be3          	bne	a5,a3,80002932 <va2pa+0x12>
            break;
    }

    if ( p >= &proc[NPROC] || p->state == UNUSED){
        return 0;
    80002940:	4501                	li	a0,0
    80002942:	8082                	ret
    if ( p >= &proc[NPROC] || p->state == UNUSED){
    80002944:	00014717          	auipc	a4,0x14
    80002948:	1bc70713          	addi	a4,a4,444 # 80016b00 <tickslock>
    8000294c:	02e7f563          	bgeu	a5,a4,80002976 <va2pa+0x56>
    80002950:	4f98                	lw	a4,24(a5)
        return 0;
    80002952:	4501                	li	a0,0
    if ( p >= &proc[NPROC] || p->state == UNUSED){
    80002954:	e311                	bnez	a4,80002958 <va2pa+0x38>
    }

    return walkaddr(p->pagetable, addr);
}
    80002956:	8082                	ret
{
    80002958:	1141                	addi	sp,sp,-16
    8000295a:	e406                	sd	ra,8(sp)
    8000295c:	e022                	sd	s0,0(sp)
    8000295e:	0800                	addi	s0,sp,16
    return walkaddr(p->pagetable, addr);
    80002960:	85b2                	mv	a1,a2
    80002962:	6ba8                	ld	a0,80(a5)
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	7c0080e7          	jalr	1984(ra) # 80001124 <walkaddr>
    8000296c:	2501                	sext.w	a0,a0
}
    8000296e:	60a2                	ld	ra,8(sp)
    80002970:	6402                	ld	s0,0(sp)
    80002972:	0141                	addi	sp,sp,16
    80002974:	8082                	ret
        return 0;
    80002976:	4501                	li	a0,0
    80002978:	8082                	ret

000000008000297a <swtch>:
    8000297a:	00153023          	sd	ra,0(a0)
    8000297e:	00253423          	sd	sp,8(a0)
    80002982:	e900                	sd	s0,16(a0)
    80002984:	ed04                	sd	s1,24(a0)
    80002986:	03253023          	sd	s2,32(a0)
    8000298a:	03353423          	sd	s3,40(a0)
    8000298e:	03453823          	sd	s4,48(a0)
    80002992:	03553c23          	sd	s5,56(a0)
    80002996:	05653023          	sd	s6,64(a0)
    8000299a:	05753423          	sd	s7,72(a0)
    8000299e:	05853823          	sd	s8,80(a0)
    800029a2:	05953c23          	sd	s9,88(a0)
    800029a6:	07a53023          	sd	s10,96(a0)
    800029aa:	07b53423          	sd	s11,104(a0)
    800029ae:	0005b083          	ld	ra,0(a1)
    800029b2:	0085b103          	ld	sp,8(a1)
    800029b6:	6980                	ld	s0,16(a1)
    800029b8:	6d84                	ld	s1,24(a1)
    800029ba:	0205b903          	ld	s2,32(a1)
    800029be:	0285b983          	ld	s3,40(a1)
    800029c2:	0305ba03          	ld	s4,48(a1)
    800029c6:	0385ba83          	ld	s5,56(a1)
    800029ca:	0405bb03          	ld	s6,64(a1)
    800029ce:	0485bb83          	ld	s7,72(a1)
    800029d2:	0505bc03          	ld	s8,80(a1)
    800029d6:	0585bc83          	ld	s9,88(a1)
    800029da:	0605bd03          	ld	s10,96(a1)
    800029de:	0685bd83          	ld	s11,104(a1)
    800029e2:	8082                	ret

00000000800029e4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800029e4:	1141                	addi	sp,sp,-16
    800029e6:	e406                	sd	ra,8(sp)
    800029e8:	e022                	sd	s0,0(sp)
    800029ea:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029ec:	00006597          	auipc	a1,0x6
    800029f0:	a1c58593          	addi	a1,a1,-1508 # 80008408 <states.0+0x30>
    800029f4:	00014517          	auipc	a0,0x14
    800029f8:	10c50513          	addi	a0,a0,268 # 80016b00 <tickslock>
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	212080e7          	jalr	530(ra) # 80000c0e <initlock>
}
    80002a04:	60a2                	ld	ra,8(sp)
    80002a06:	6402                	ld	s0,0(sp)
    80002a08:	0141                	addi	sp,sp,16
    80002a0a:	8082                	ret

0000000080002a0c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a0c:	1141                	addi	sp,sp,-16
    80002a0e:	e422                	sd	s0,8(sp)
    80002a10:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a12:	00003797          	auipc	a5,0x3
    80002a16:	5de78793          	addi	a5,a5,1502 # 80005ff0 <kernelvec>
    80002a1a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a1e:	6422                	ld	s0,8(sp)
    80002a20:	0141                	addi	sp,sp,16
    80002a22:	8082                	ret

0000000080002a24 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a24:	1141                	addi	sp,sp,-16
    80002a26:	e406                	sd	ra,8(sp)
    80002a28:	e022                	sd	s0,0(sp)
    80002a2a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a2c:	fffff097          	auipc	ra,0xfffff
    80002a30:	146080e7          	jalr	326(ra) # 80001b72 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a34:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a38:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a3a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a3e:	00004697          	auipc	a3,0x4
    80002a42:	5c268693          	addi	a3,a3,1474 # 80007000 <_trampoline>
    80002a46:	00004717          	auipc	a4,0x4
    80002a4a:	5ba70713          	addi	a4,a4,1466 # 80007000 <_trampoline>
    80002a4e:	8f15                	sub	a4,a4,a3
    80002a50:	040007b7          	lui	a5,0x4000
    80002a54:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002a56:	07b2                	slli	a5,a5,0xc
    80002a58:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a5a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a5e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a60:	18002673          	csrr	a2,satp
    80002a64:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a66:	6d30                	ld	a2,88(a0)
    80002a68:	6138                	ld	a4,64(a0)
    80002a6a:	6585                	lui	a1,0x1
    80002a6c:	972e                	add	a4,a4,a1
    80002a6e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a70:	6d38                	ld	a4,88(a0)
    80002a72:	00000617          	auipc	a2,0x0
    80002a76:	13060613          	addi	a2,a2,304 # 80002ba2 <usertrap>
    80002a7a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a7c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a7e:	8612                	mv	a2,tp
    80002a80:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a82:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a86:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a8a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a8e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a92:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a94:	6f18                	ld	a4,24(a4)
    80002a96:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a9a:	6928                	ld	a0,80(a0)
    80002a9c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a9e:	00004717          	auipc	a4,0x4
    80002aa2:	5fe70713          	addi	a4,a4,1534 # 8000709c <userret>
    80002aa6:	8f15                	sub	a4,a4,a3
    80002aa8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002aaa:	577d                	li	a4,-1
    80002aac:	177e                	slli	a4,a4,0x3f
    80002aae:	8d59                	or	a0,a0,a4
    80002ab0:	9782                	jalr	a5
}
    80002ab2:	60a2                	ld	ra,8(sp)
    80002ab4:	6402                	ld	s0,0(sp)
    80002ab6:	0141                	addi	sp,sp,16
    80002ab8:	8082                	ret

0000000080002aba <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002aba:	1101                	addi	sp,sp,-32
    80002abc:	ec06                	sd	ra,24(sp)
    80002abe:	e822                	sd	s0,16(sp)
    80002ac0:	e426                	sd	s1,8(sp)
    80002ac2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ac4:	00014497          	auipc	s1,0x14
    80002ac8:	03c48493          	addi	s1,s1,60 # 80016b00 <tickslock>
    80002acc:	8526                	mv	a0,s1
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	1d0080e7          	jalr	464(ra) # 80000c9e <acquire>
  ticks++;
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	f8a50513          	addi	a0,a0,-118 # 80008a60 <ticks>
    80002ade:	411c                	lw	a5,0(a0)
    80002ae0:	2785                	addiw	a5,a5,1
    80002ae2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ae4:	00000097          	auipc	ra,0x0
    80002ae8:	85a080e7          	jalr	-1958(ra) # 8000233e <wakeup>
  release(&tickslock);
    80002aec:	8526                	mv	a0,s1
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	264080e7          	jalr	612(ra) # 80000d52 <release>
}
    80002af6:	60e2                	ld	ra,24(sp)
    80002af8:	6442                	ld	s0,16(sp)
    80002afa:	64a2                	ld	s1,8(sp)
    80002afc:	6105                	addi	sp,sp,32
    80002afe:	8082                	ret

0000000080002b00 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b00:	1101                	addi	sp,sp,-32
    80002b02:	ec06                	sd	ra,24(sp)
    80002b04:	e822                	sd	s0,16(sp)
    80002b06:	e426                	sd	s1,8(sp)
    80002b08:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b0a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b0e:	00074d63          	bltz	a4,80002b28 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b12:	57fd                	li	a5,-1
    80002b14:	17fe                	slli	a5,a5,0x3f
    80002b16:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b18:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b1a:	06f70363          	beq	a4,a5,80002b80 <devintr+0x80>
  }
}
    80002b1e:	60e2                	ld	ra,24(sp)
    80002b20:	6442                	ld	s0,16(sp)
    80002b22:	64a2                	ld	s1,8(sp)
    80002b24:	6105                	addi	sp,sp,32
    80002b26:	8082                	ret
     (scause & 0xff) == 9){
    80002b28:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002b2c:	46a5                	li	a3,9
    80002b2e:	fed792e3          	bne	a5,a3,80002b12 <devintr+0x12>
    int irq = plic_claim();
    80002b32:	00003097          	auipc	ra,0x3
    80002b36:	5c6080e7          	jalr	1478(ra) # 800060f8 <plic_claim>
    80002b3a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b3c:	47a9                	li	a5,10
    80002b3e:	02f50763          	beq	a0,a5,80002b6c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b42:	4785                	li	a5,1
    80002b44:	02f50963          	beq	a0,a5,80002b76 <devintr+0x76>
    return 1;
    80002b48:	4505                	li	a0,1
    } else if(irq){
    80002b4a:	d8f1                	beqz	s1,80002b1e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b4c:	85a6                	mv	a1,s1
    80002b4e:	00006517          	auipc	a0,0x6
    80002b52:	8c250513          	addi	a0,a0,-1854 # 80008410 <states.0+0x38>
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	a46080e7          	jalr	-1466(ra) # 8000059c <printf>
      plic_complete(irq);
    80002b5e:	8526                	mv	a0,s1
    80002b60:	00003097          	auipc	ra,0x3
    80002b64:	5bc080e7          	jalr	1468(ra) # 8000611c <plic_complete>
    return 1;
    80002b68:	4505                	li	a0,1
    80002b6a:	bf55                	j	80002b1e <devintr+0x1e>
      uartintr();
    80002b6c:	ffffe097          	auipc	ra,0xffffe
    80002b70:	e3e080e7          	jalr	-450(ra) # 800009aa <uartintr>
    80002b74:	b7ed                	j	80002b5e <devintr+0x5e>
      virtio_disk_intr();
    80002b76:	00004097          	auipc	ra,0x4
    80002b7a:	a6e080e7          	jalr	-1426(ra) # 800065e4 <virtio_disk_intr>
    80002b7e:	b7c5                	j	80002b5e <devintr+0x5e>
    if(cpuid() == 0){
    80002b80:	fffff097          	auipc	ra,0xfffff
    80002b84:	fc6080e7          	jalr	-58(ra) # 80001b46 <cpuid>
    80002b88:	c901                	beqz	a0,80002b98 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b8a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b8e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b90:	14479073          	csrw	sip,a5
    return 2;
    80002b94:	4509                	li	a0,2
    80002b96:	b761                	j	80002b1e <devintr+0x1e>
      clockintr();
    80002b98:	00000097          	auipc	ra,0x0
    80002b9c:	f22080e7          	jalr	-222(ra) # 80002aba <clockintr>
    80002ba0:	b7ed                	j	80002b8a <devintr+0x8a>

0000000080002ba2 <usertrap>:
{
    80002ba2:	1101                	addi	sp,sp,-32
    80002ba4:	ec06                	sd	ra,24(sp)
    80002ba6:	e822                	sd	s0,16(sp)
    80002ba8:	e426                	sd	s1,8(sp)
    80002baa:	e04a                	sd	s2,0(sp)
    80002bac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bae:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bb2:	1007f793          	andi	a5,a5,256
    80002bb6:	e3b1                	bnez	a5,80002bfa <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bb8:	00003797          	auipc	a5,0x3
    80002bbc:	43878793          	addi	a5,a5,1080 # 80005ff0 <kernelvec>
    80002bc0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bc4:	fffff097          	auipc	ra,0xfffff
    80002bc8:	fae080e7          	jalr	-82(ra) # 80001b72 <myproc>
    80002bcc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bce:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bd0:	14102773          	csrr	a4,sepc
    80002bd4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bda:	47a1                	li	a5,8
    80002bdc:	02f70763          	beq	a4,a5,80002c0a <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002be0:	00000097          	auipc	ra,0x0
    80002be4:	f20080e7          	jalr	-224(ra) # 80002b00 <devintr>
    80002be8:	892a                	mv	s2,a0
    80002bea:	c151                	beqz	a0,80002c6e <usertrap+0xcc>
  if(killed(p))
    80002bec:	8526                	mv	a0,s1
    80002bee:	00000097          	auipc	ra,0x0
    80002bf2:	994080e7          	jalr	-1644(ra) # 80002582 <killed>
    80002bf6:	c929                	beqz	a0,80002c48 <usertrap+0xa6>
    80002bf8:	a099                	j	80002c3e <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002bfa:	00006517          	auipc	a0,0x6
    80002bfe:	83650513          	addi	a0,a0,-1994 # 80008430 <states.0+0x58>
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	93e080e7          	jalr	-1730(ra) # 80000540 <panic>
    if(killed(p))
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	978080e7          	jalr	-1672(ra) # 80002582 <killed>
    80002c12:	e921                	bnez	a0,80002c62 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002c14:	6cb8                	ld	a4,88(s1)
    80002c16:	6f1c                	ld	a5,24(a4)
    80002c18:	0791                	addi	a5,a5,4
    80002c1a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c20:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c24:	10079073          	csrw	sstatus,a5
    syscall();
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	2d4080e7          	jalr	724(ra) # 80002efc <syscall>
  if(killed(p))
    80002c30:	8526                	mv	a0,s1
    80002c32:	00000097          	auipc	ra,0x0
    80002c36:	950080e7          	jalr	-1712(ra) # 80002582 <killed>
    80002c3a:	c911                	beqz	a0,80002c4e <usertrap+0xac>
    80002c3c:	4901                	li	s2,0
    exit(-1);
    80002c3e:	557d                	li	a0,-1
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	7ce080e7          	jalr	1998(ra) # 8000240e <exit>
  if(which_dev == 2)
    80002c48:	4789                	li	a5,2
    80002c4a:	04f90f63          	beq	s2,a5,80002ca8 <usertrap+0x106>
  usertrapret();
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	dd6080e7          	jalr	-554(ra) # 80002a24 <usertrapret>
}
    80002c56:	60e2                	ld	ra,24(sp)
    80002c58:	6442                	ld	s0,16(sp)
    80002c5a:	64a2                	ld	s1,8(sp)
    80002c5c:	6902                	ld	s2,0(sp)
    80002c5e:	6105                	addi	sp,sp,32
    80002c60:	8082                	ret
      exit(-1);
    80002c62:	557d                	li	a0,-1
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	7aa080e7          	jalr	1962(ra) # 8000240e <exit>
    80002c6c:	b765                	j	80002c14 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c72:	5890                	lw	a2,48(s1)
    80002c74:	00005517          	auipc	a0,0x5
    80002c78:	7dc50513          	addi	a0,a0,2012 # 80008450 <states.0+0x78>
    80002c7c:	ffffe097          	auipc	ra,0xffffe
    80002c80:	920080e7          	jalr	-1760(ra) # 8000059c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c84:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c88:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c8c:	00005517          	auipc	a0,0x5
    80002c90:	7f450513          	addi	a0,a0,2036 # 80008480 <states.0+0xa8>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	908080e7          	jalr	-1784(ra) # 8000059c <printf>
    setkilled(p);
    80002c9c:	8526                	mv	a0,s1
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	8b8080e7          	jalr	-1864(ra) # 80002556 <setkilled>
    80002ca6:	b769                	j	80002c30 <usertrap+0x8e>
    yield();
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	5f6080e7          	jalr	1526(ra) # 8000229e <yield>
    80002cb0:	bf79                	j	80002c4e <usertrap+0xac>

0000000080002cb2 <kerneltrap>:
{
    80002cb2:	7179                	addi	sp,sp,-48
    80002cb4:	f406                	sd	ra,40(sp)
    80002cb6:	f022                	sd	s0,32(sp)
    80002cb8:	ec26                	sd	s1,24(sp)
    80002cba:	e84a                	sd	s2,16(sp)
    80002cbc:	e44e                	sd	s3,8(sp)
    80002cbe:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cc0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ccc:	1004f793          	andi	a5,s1,256
    80002cd0:	cb85                	beqz	a5,80002d00 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cd2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cd6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cd8:	ef85                	bnez	a5,80002d10 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cda:	00000097          	auipc	ra,0x0
    80002cde:	e26080e7          	jalr	-474(ra) # 80002b00 <devintr>
    80002ce2:	cd1d                	beqz	a0,80002d20 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ce4:	4789                	li	a5,2
    80002ce6:	06f50a63          	beq	a0,a5,80002d5a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cea:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cee:	10049073          	csrw	sstatus,s1
}
    80002cf2:	70a2                	ld	ra,40(sp)
    80002cf4:	7402                	ld	s0,32(sp)
    80002cf6:	64e2                	ld	s1,24(sp)
    80002cf8:	6942                	ld	s2,16(sp)
    80002cfa:	69a2                	ld	s3,8(sp)
    80002cfc:	6145                	addi	sp,sp,48
    80002cfe:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d00:	00005517          	auipc	a0,0x5
    80002d04:	7a050513          	addi	a0,a0,1952 # 800084a0 <states.0+0xc8>
    80002d08:	ffffe097          	auipc	ra,0xffffe
    80002d0c:	838080e7          	jalr	-1992(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d10:	00005517          	auipc	a0,0x5
    80002d14:	7b850513          	addi	a0,a0,1976 # 800084c8 <states.0+0xf0>
    80002d18:	ffffe097          	auipc	ra,0xffffe
    80002d1c:	828080e7          	jalr	-2008(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002d20:	85ce                	mv	a1,s3
    80002d22:	00005517          	auipc	a0,0x5
    80002d26:	7c650513          	addi	a0,a0,1990 # 800084e8 <states.0+0x110>
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	872080e7          	jalr	-1934(ra) # 8000059c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d32:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d36:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d3a:	00005517          	auipc	a0,0x5
    80002d3e:	7be50513          	addi	a0,a0,1982 # 800084f8 <states.0+0x120>
    80002d42:	ffffe097          	auipc	ra,0xffffe
    80002d46:	85a080e7          	jalr	-1958(ra) # 8000059c <printf>
    panic("kerneltrap");
    80002d4a:	00005517          	auipc	a0,0x5
    80002d4e:	7c650513          	addi	a0,a0,1990 # 80008510 <states.0+0x138>
    80002d52:	ffffd097          	auipc	ra,0xffffd
    80002d56:	7ee080e7          	jalr	2030(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	e18080e7          	jalr	-488(ra) # 80001b72 <myproc>
    80002d62:	d541                	beqz	a0,80002cea <kerneltrap+0x38>
    80002d64:	fffff097          	auipc	ra,0xfffff
    80002d68:	e0e080e7          	jalr	-498(ra) # 80001b72 <myproc>
    80002d6c:	4d18                	lw	a4,24(a0)
    80002d6e:	4791                	li	a5,4
    80002d70:	f6f71de3          	bne	a4,a5,80002cea <kerneltrap+0x38>
    yield();
    80002d74:	fffff097          	auipc	ra,0xfffff
    80002d78:	52a080e7          	jalr	1322(ra) # 8000229e <yield>
    80002d7c:	b7bd                	j	80002cea <kerneltrap+0x38>

0000000080002d7e <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	1000                	addi	s0,sp,32
    80002d88:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	de8080e7          	jalr	-536(ra) # 80001b72 <myproc>
    switch (n)
    80002d92:	4795                	li	a5,5
    80002d94:	0497e163          	bltu	a5,s1,80002dd6 <argraw+0x58>
    80002d98:	048a                	slli	s1,s1,0x2
    80002d9a:	00005717          	auipc	a4,0x5
    80002d9e:	7ae70713          	addi	a4,a4,1966 # 80008548 <states.0+0x170>
    80002da2:	94ba                	add	s1,s1,a4
    80002da4:	409c                	lw	a5,0(s1)
    80002da6:	97ba                	add	a5,a5,a4
    80002da8:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002daa:	6d3c                	ld	a5,88(a0)
    80002dac:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002dae:	60e2                	ld	ra,24(sp)
    80002db0:	6442                	ld	s0,16(sp)
    80002db2:	64a2                	ld	s1,8(sp)
    80002db4:	6105                	addi	sp,sp,32
    80002db6:	8082                	ret
        return p->trapframe->a1;
    80002db8:	6d3c                	ld	a5,88(a0)
    80002dba:	7fa8                	ld	a0,120(a5)
    80002dbc:	bfcd                	j	80002dae <argraw+0x30>
        return p->trapframe->a2;
    80002dbe:	6d3c                	ld	a5,88(a0)
    80002dc0:	63c8                	ld	a0,128(a5)
    80002dc2:	b7f5                	j	80002dae <argraw+0x30>
        return p->trapframe->a3;
    80002dc4:	6d3c                	ld	a5,88(a0)
    80002dc6:	67c8                	ld	a0,136(a5)
    80002dc8:	b7dd                	j	80002dae <argraw+0x30>
        return p->trapframe->a4;
    80002dca:	6d3c                	ld	a5,88(a0)
    80002dcc:	6bc8                	ld	a0,144(a5)
    80002dce:	b7c5                	j	80002dae <argraw+0x30>
        return p->trapframe->a5;
    80002dd0:	6d3c                	ld	a5,88(a0)
    80002dd2:	6fc8                	ld	a0,152(a5)
    80002dd4:	bfe9                	j	80002dae <argraw+0x30>
    panic("argraw");
    80002dd6:	00005517          	auipc	a0,0x5
    80002dda:	74a50513          	addi	a0,a0,1866 # 80008520 <states.0+0x148>
    80002dde:	ffffd097          	auipc	ra,0xffffd
    80002de2:	762080e7          	jalr	1890(ra) # 80000540 <panic>

0000000080002de6 <fetchaddr>:
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	e04a                	sd	s2,0(sp)
    80002df0:	1000                	addi	s0,sp,32
    80002df2:	84aa                	mv	s1,a0
    80002df4:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	d7c080e7          	jalr	-644(ra) # 80001b72 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002dfe:	653c                	ld	a5,72(a0)
    80002e00:	02f4f863          	bgeu	s1,a5,80002e30 <fetchaddr+0x4a>
    80002e04:	00848713          	addi	a4,s1,8
    80002e08:	02e7e663          	bltu	a5,a4,80002e34 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e0c:	46a1                	li	a3,8
    80002e0e:	8626                	mv	a2,s1
    80002e10:	85ca                	mv	a1,s2
    80002e12:	6928                	ld	a0,80(a0)
    80002e14:	fffff097          	auipc	ra,0xfffff
    80002e18:	9ac080e7          	jalr	-1620(ra) # 800017c0 <copyin>
    80002e1c:	00a03533          	snez	a0,a0
    80002e20:	40a00533          	neg	a0,a0
}
    80002e24:	60e2                	ld	ra,24(sp)
    80002e26:	6442                	ld	s0,16(sp)
    80002e28:	64a2                	ld	s1,8(sp)
    80002e2a:	6902                	ld	s2,0(sp)
    80002e2c:	6105                	addi	sp,sp,32
    80002e2e:	8082                	ret
        return -1;
    80002e30:	557d                	li	a0,-1
    80002e32:	bfcd                	j	80002e24 <fetchaddr+0x3e>
    80002e34:	557d                	li	a0,-1
    80002e36:	b7fd                	j	80002e24 <fetchaddr+0x3e>

0000000080002e38 <fetchstr>:
{
    80002e38:	7179                	addi	sp,sp,-48
    80002e3a:	f406                	sd	ra,40(sp)
    80002e3c:	f022                	sd	s0,32(sp)
    80002e3e:	ec26                	sd	s1,24(sp)
    80002e40:	e84a                	sd	s2,16(sp)
    80002e42:	e44e                	sd	s3,8(sp)
    80002e44:	1800                	addi	s0,sp,48
    80002e46:	892a                	mv	s2,a0
    80002e48:	84ae                	mv	s1,a1
    80002e4a:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002e4c:	fffff097          	auipc	ra,0xfffff
    80002e50:	d26080e7          	jalr	-730(ra) # 80001b72 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e54:	86ce                	mv	a3,s3
    80002e56:	864a                	mv	a2,s2
    80002e58:	85a6                	mv	a1,s1
    80002e5a:	6928                	ld	a0,80(a0)
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	9f2080e7          	jalr	-1550(ra) # 8000184e <copyinstr>
    80002e64:	00054e63          	bltz	a0,80002e80 <fetchstr+0x48>
    return strlen(buf);
    80002e68:	8526                	mv	a0,s1
    80002e6a:	ffffe097          	auipc	ra,0xffffe
    80002e6e:	0ac080e7          	jalr	172(ra) # 80000f16 <strlen>
}
    80002e72:	70a2                	ld	ra,40(sp)
    80002e74:	7402                	ld	s0,32(sp)
    80002e76:	64e2                	ld	s1,24(sp)
    80002e78:	6942                	ld	s2,16(sp)
    80002e7a:	69a2                	ld	s3,8(sp)
    80002e7c:	6145                	addi	sp,sp,48
    80002e7e:	8082                	ret
        return -1;
    80002e80:	557d                	li	a0,-1
    80002e82:	bfc5                	j	80002e72 <fetchstr+0x3a>

0000000080002e84 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002e84:	1101                	addi	sp,sp,-32
    80002e86:	ec06                	sd	ra,24(sp)
    80002e88:	e822                	sd	s0,16(sp)
    80002e8a:	e426                	sd	s1,8(sp)
    80002e8c:	1000                	addi	s0,sp,32
    80002e8e:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002e90:	00000097          	auipc	ra,0x0
    80002e94:	eee080e7          	jalr	-274(ra) # 80002d7e <argraw>
    80002e98:	c088                	sw	a0,0(s1)
}
    80002e9a:	60e2                	ld	ra,24(sp)
    80002e9c:	6442                	ld	s0,16(sp)
    80002e9e:	64a2                	ld	s1,8(sp)
    80002ea0:	6105                	addi	sp,sp,32
    80002ea2:	8082                	ret

0000000080002ea4 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002ea4:	1101                	addi	sp,sp,-32
    80002ea6:	ec06                	sd	ra,24(sp)
    80002ea8:	e822                	sd	s0,16(sp)
    80002eaa:	e426                	sd	s1,8(sp)
    80002eac:	1000                	addi	s0,sp,32
    80002eae:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002eb0:	00000097          	auipc	ra,0x0
    80002eb4:	ece080e7          	jalr	-306(ra) # 80002d7e <argraw>
    80002eb8:	e088                	sd	a0,0(s1)
}
    80002eba:	60e2                	ld	ra,24(sp)
    80002ebc:	6442                	ld	s0,16(sp)
    80002ebe:	64a2                	ld	s1,8(sp)
    80002ec0:	6105                	addi	sp,sp,32
    80002ec2:	8082                	ret

0000000080002ec4 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002ec4:	7179                	addi	sp,sp,-48
    80002ec6:	f406                	sd	ra,40(sp)
    80002ec8:	f022                	sd	s0,32(sp)
    80002eca:	ec26                	sd	s1,24(sp)
    80002ecc:	e84a                	sd	s2,16(sp)
    80002ece:	1800                	addi	s0,sp,48
    80002ed0:	84ae                	mv	s1,a1
    80002ed2:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80002ed4:	fd840593          	addi	a1,s0,-40
    80002ed8:	00000097          	auipc	ra,0x0
    80002edc:	fcc080e7          	jalr	-52(ra) # 80002ea4 <argaddr>
    return fetchstr(addr, buf, max);
    80002ee0:	864a                	mv	a2,s2
    80002ee2:	85a6                	mv	a1,s1
    80002ee4:	fd843503          	ld	a0,-40(s0)
    80002ee8:	00000097          	auipc	ra,0x0
    80002eec:	f50080e7          	jalr	-176(ra) # 80002e38 <fetchstr>
}
    80002ef0:	70a2                	ld	ra,40(sp)
    80002ef2:	7402                	ld	s0,32(sp)
    80002ef4:	64e2                	ld	s1,24(sp)
    80002ef6:	6942                	ld	s2,16(sp)
    80002ef8:	6145                	addi	sp,sp,48
    80002efa:	8082                	ret

0000000080002efc <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80002efc:	1101                	addi	sp,sp,-32
    80002efe:	ec06                	sd	ra,24(sp)
    80002f00:	e822                	sd	s0,16(sp)
    80002f02:	e426                	sd	s1,8(sp)
    80002f04:	e04a                	sd	s2,0(sp)
    80002f06:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80002f08:	fffff097          	auipc	ra,0xfffff
    80002f0c:	c6a080e7          	jalr	-918(ra) # 80001b72 <myproc>
    80002f10:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80002f12:	05853903          	ld	s2,88(a0)
    80002f16:	0a893783          	ld	a5,168(s2)
    80002f1a:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002f1e:	37fd                	addiw	a5,a5,-1
    80002f20:	4765                	li	a4,25
    80002f22:	00f76f63          	bltu	a4,a5,80002f40 <syscall+0x44>
    80002f26:	00369713          	slli	a4,a3,0x3
    80002f2a:	00005797          	auipc	a5,0x5
    80002f2e:	63678793          	addi	a5,a5,1590 # 80008560 <syscalls>
    80002f32:	97ba                	add	a5,a5,a4
    80002f34:	639c                	ld	a5,0(a5)
    80002f36:	c789                	beqz	a5,80002f40 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80002f38:	9782                	jalr	a5
    80002f3a:	06a93823          	sd	a0,112(s2)
    80002f3e:	a839                	j	80002f5c <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80002f40:	15848613          	addi	a2,s1,344
    80002f44:	588c                	lw	a1,48(s1)
    80002f46:	00005517          	auipc	a0,0x5
    80002f4a:	5e250513          	addi	a0,a0,1506 # 80008528 <states.0+0x150>
    80002f4e:	ffffd097          	auipc	ra,0xffffd
    80002f52:	64e080e7          	jalr	1614(ra) # 8000059c <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80002f56:	6cbc                	ld	a5,88(s1)
    80002f58:	577d                	li	a4,-1
    80002f5a:	fbb8                	sd	a4,112(a5)
    }
}
    80002f5c:	60e2                	ld	ra,24(sp)
    80002f5e:	6442                	ld	s0,16(sp)
    80002f60:	64a2                	ld	s1,8(sp)
    80002f62:	6902                	ld	s2,0(sp)
    80002f64:	6105                	addi	sp,sp,32
    80002f66:	8082                	ret

0000000080002f68 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80002f68:	1101                	addi	sp,sp,-32
    80002f6a:	ec06                	sd	ra,24(sp)
    80002f6c:	e822                	sd	s0,16(sp)
    80002f6e:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    80002f70:	fec40593          	addi	a1,s0,-20
    80002f74:	4501                	li	a0,0
    80002f76:	00000097          	auipc	ra,0x0
    80002f7a:	f0e080e7          	jalr	-242(ra) # 80002e84 <argint>
    exit(n);
    80002f7e:	fec42503          	lw	a0,-20(s0)
    80002f82:	fffff097          	auipc	ra,0xfffff
    80002f86:	48c080e7          	jalr	1164(ra) # 8000240e <exit>
    return 0; // not reached
}
    80002f8a:	4501                	li	a0,0
    80002f8c:	60e2                	ld	ra,24(sp)
    80002f8e:	6442                	ld	s0,16(sp)
    80002f90:	6105                	addi	sp,sp,32
    80002f92:	8082                	ret

0000000080002f94 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f94:	1141                	addi	sp,sp,-16
    80002f96:	e406                	sd	ra,8(sp)
    80002f98:	e022                	sd	s0,0(sp)
    80002f9a:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80002f9c:	fffff097          	auipc	ra,0xfffff
    80002fa0:	bd6080e7          	jalr	-1066(ra) # 80001b72 <myproc>
}
    80002fa4:	5908                	lw	a0,48(a0)
    80002fa6:	60a2                	ld	ra,8(sp)
    80002fa8:	6402                	ld	s0,0(sp)
    80002faa:	0141                	addi	sp,sp,16
    80002fac:	8082                	ret

0000000080002fae <sys_fork>:

uint64
sys_fork(void)
{
    80002fae:	1141                	addi	sp,sp,-16
    80002fb0:	e406                	sd	ra,8(sp)
    80002fb2:	e022                	sd	s0,0(sp)
    80002fb4:	0800                	addi	s0,sp,16
    return fork();
    80002fb6:	fffff097          	auipc	ra,0xfffff
    80002fba:	0c2080e7          	jalr	194(ra) # 80002078 <fork>
}
    80002fbe:	60a2                	ld	ra,8(sp)
    80002fc0:	6402                	ld	s0,0(sp)
    80002fc2:	0141                	addi	sp,sp,16
    80002fc4:	8082                	ret

0000000080002fc6 <sys_wait>:

uint64
sys_wait(void)
{
    80002fc6:	1101                	addi	sp,sp,-32
    80002fc8:	ec06                	sd	ra,24(sp)
    80002fca:	e822                	sd	s0,16(sp)
    80002fcc:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80002fce:	fe840593          	addi	a1,s0,-24
    80002fd2:	4501                	li	a0,0
    80002fd4:	00000097          	auipc	ra,0x0
    80002fd8:	ed0080e7          	jalr	-304(ra) # 80002ea4 <argaddr>
    return wait(p);
    80002fdc:	fe843503          	ld	a0,-24(s0)
    80002fe0:	fffff097          	auipc	ra,0xfffff
    80002fe4:	5d4080e7          	jalr	1492(ra) # 800025b4 <wait>
}
    80002fe8:	60e2                	ld	ra,24(sp)
    80002fea:	6442                	ld	s0,16(sp)
    80002fec:	6105                	addi	sp,sp,32
    80002fee:	8082                	ret

0000000080002ff0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ff0:	7179                	addi	sp,sp,-48
    80002ff2:	f406                	sd	ra,40(sp)
    80002ff4:	f022                	sd	s0,32(sp)
    80002ff6:	ec26                	sd	s1,24(sp)
    80002ff8:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    80002ffa:	fdc40593          	addi	a1,s0,-36
    80002ffe:	4501                	li	a0,0
    80003000:	00000097          	auipc	ra,0x0
    80003004:	e84080e7          	jalr	-380(ra) # 80002e84 <argint>
    addr = myproc()->sz;
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	b6a080e7          	jalr	-1174(ra) # 80001b72 <myproc>
    80003010:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003012:	fdc42503          	lw	a0,-36(s0)
    80003016:	fffff097          	auipc	ra,0xfffff
    8000301a:	eb6080e7          	jalr	-330(ra) # 80001ecc <growproc>
    8000301e:	00054863          	bltz	a0,8000302e <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    80003022:	8526                	mv	a0,s1
    80003024:	70a2                	ld	ra,40(sp)
    80003026:	7402                	ld	s0,32(sp)
    80003028:	64e2                	ld	s1,24(sp)
    8000302a:	6145                	addi	sp,sp,48
    8000302c:	8082                	ret
        return -1;
    8000302e:	54fd                	li	s1,-1
    80003030:	bfcd                	j	80003022 <sys_sbrk+0x32>

0000000080003032 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003032:	7139                	addi	sp,sp,-64
    80003034:	fc06                	sd	ra,56(sp)
    80003036:	f822                	sd	s0,48(sp)
    80003038:	f426                	sd	s1,40(sp)
    8000303a:	f04a                	sd	s2,32(sp)
    8000303c:	ec4e                	sd	s3,24(sp)
    8000303e:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    80003040:	fcc40593          	addi	a1,s0,-52
    80003044:	4501                	li	a0,0
    80003046:	00000097          	auipc	ra,0x0
    8000304a:	e3e080e7          	jalr	-450(ra) # 80002e84 <argint>
    acquire(&tickslock);
    8000304e:	00014517          	auipc	a0,0x14
    80003052:	ab250513          	addi	a0,a0,-1358 # 80016b00 <tickslock>
    80003056:	ffffe097          	auipc	ra,0xffffe
    8000305a:	c48080e7          	jalr	-952(ra) # 80000c9e <acquire>
    ticks0 = ticks;
    8000305e:	00006917          	auipc	s2,0x6
    80003062:	a0292903          	lw	s2,-1534(s2) # 80008a60 <ticks>
    while (ticks - ticks0 < n)
    80003066:	fcc42783          	lw	a5,-52(s0)
    8000306a:	cf9d                	beqz	a5,800030a8 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    8000306c:	00014997          	auipc	s3,0x14
    80003070:	a9498993          	addi	s3,s3,-1388 # 80016b00 <tickslock>
    80003074:	00006497          	auipc	s1,0x6
    80003078:	9ec48493          	addi	s1,s1,-1556 # 80008a60 <ticks>
        if (killed(myproc()))
    8000307c:	fffff097          	auipc	ra,0xfffff
    80003080:	af6080e7          	jalr	-1290(ra) # 80001b72 <myproc>
    80003084:	fffff097          	auipc	ra,0xfffff
    80003088:	4fe080e7          	jalr	1278(ra) # 80002582 <killed>
    8000308c:	ed15                	bnez	a0,800030c8 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    8000308e:	85ce                	mv	a1,s3
    80003090:	8526                	mv	a0,s1
    80003092:	fffff097          	auipc	ra,0xfffff
    80003096:	248080e7          	jalr	584(ra) # 800022da <sleep>
    while (ticks - ticks0 < n)
    8000309a:	409c                	lw	a5,0(s1)
    8000309c:	412787bb          	subw	a5,a5,s2
    800030a0:	fcc42703          	lw	a4,-52(s0)
    800030a4:	fce7ece3          	bltu	a5,a4,8000307c <sys_sleep+0x4a>
    }
    release(&tickslock);
    800030a8:	00014517          	auipc	a0,0x14
    800030ac:	a5850513          	addi	a0,a0,-1448 # 80016b00 <tickslock>
    800030b0:	ffffe097          	auipc	ra,0xffffe
    800030b4:	ca2080e7          	jalr	-862(ra) # 80000d52 <release>
    return 0;
    800030b8:	4501                	li	a0,0
}
    800030ba:	70e2                	ld	ra,56(sp)
    800030bc:	7442                	ld	s0,48(sp)
    800030be:	74a2                	ld	s1,40(sp)
    800030c0:	7902                	ld	s2,32(sp)
    800030c2:	69e2                	ld	s3,24(sp)
    800030c4:	6121                	addi	sp,sp,64
    800030c6:	8082                	ret
            release(&tickslock);
    800030c8:	00014517          	auipc	a0,0x14
    800030cc:	a3850513          	addi	a0,a0,-1480 # 80016b00 <tickslock>
    800030d0:	ffffe097          	auipc	ra,0xffffe
    800030d4:	c82080e7          	jalr	-894(ra) # 80000d52 <release>
            return -1;
    800030d8:	557d                	li	a0,-1
    800030da:	b7c5                	j	800030ba <sys_sleep+0x88>

00000000800030dc <sys_kill>:

uint64
sys_kill(void)
{
    800030dc:	1101                	addi	sp,sp,-32
    800030de:	ec06                	sd	ra,24(sp)
    800030e0:	e822                	sd	s0,16(sp)
    800030e2:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    800030e4:	fec40593          	addi	a1,s0,-20
    800030e8:	4501                	li	a0,0
    800030ea:	00000097          	auipc	ra,0x0
    800030ee:	d9a080e7          	jalr	-614(ra) # 80002e84 <argint>
    return kill(pid);
    800030f2:	fec42503          	lw	a0,-20(s0)
    800030f6:	fffff097          	auipc	ra,0xfffff
    800030fa:	3ee080e7          	jalr	1006(ra) # 800024e4 <kill>
}
    800030fe:	60e2                	ld	ra,24(sp)
    80003100:	6442                	ld	s0,16(sp)
    80003102:	6105                	addi	sp,sp,32
    80003104:	8082                	ret

0000000080003106 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003106:	1101                	addi	sp,sp,-32
    80003108:	ec06                	sd	ra,24(sp)
    8000310a:	e822                	sd	s0,16(sp)
    8000310c:	e426                	sd	s1,8(sp)
    8000310e:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003110:	00014517          	auipc	a0,0x14
    80003114:	9f050513          	addi	a0,a0,-1552 # 80016b00 <tickslock>
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	b86080e7          	jalr	-1146(ra) # 80000c9e <acquire>
    xticks = ticks;
    80003120:	00006497          	auipc	s1,0x6
    80003124:	9404a483          	lw	s1,-1728(s1) # 80008a60 <ticks>
    release(&tickslock);
    80003128:	00014517          	auipc	a0,0x14
    8000312c:	9d850513          	addi	a0,a0,-1576 # 80016b00 <tickslock>
    80003130:	ffffe097          	auipc	ra,0xffffe
    80003134:	c22080e7          	jalr	-990(ra) # 80000d52 <release>
    return xticks;
}
    80003138:	02049513          	slli	a0,s1,0x20
    8000313c:	9101                	srli	a0,a0,0x20
    8000313e:	60e2                	ld	ra,24(sp)
    80003140:	6442                	ld	s0,16(sp)
    80003142:	64a2                	ld	s1,8(sp)
    80003144:	6105                	addi	sp,sp,32
    80003146:	8082                	ret

0000000080003148 <sys_ps>:

void *
sys_ps(void)
{
    80003148:	1101                	addi	sp,sp,-32
    8000314a:	ec06                	sd	ra,24(sp)
    8000314c:	e822                	sd	s0,16(sp)
    8000314e:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003150:	fe042623          	sw	zero,-20(s0)
    80003154:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003158:	fec40593          	addi	a1,s0,-20
    8000315c:	4501                	li	a0,0
    8000315e:	00000097          	auipc	ra,0x0
    80003162:	d26080e7          	jalr	-730(ra) # 80002e84 <argint>
    argint(1, &count);
    80003166:	fe840593          	addi	a1,s0,-24
    8000316a:	4505                	li	a0,1
    8000316c:	00000097          	auipc	ra,0x0
    80003170:	d18080e7          	jalr	-744(ra) # 80002e84 <argint>
    return ps((uint8)start, (uint8)count);
    80003174:	fe844583          	lbu	a1,-24(s0)
    80003178:	fec44503          	lbu	a0,-20(s0)
    8000317c:	fffff097          	auipc	ra,0xfffff
    80003180:	dac080e7          	jalr	-596(ra) # 80001f28 <ps>
}
    80003184:	60e2                	ld	ra,24(sp)
    80003186:	6442                	ld	s0,16(sp)
    80003188:	6105                	addi	sp,sp,32
    8000318a:	8082                	ret

000000008000318c <sys_schedls>:

uint64 sys_schedls(void)
{
    8000318c:	1141                	addi	sp,sp,-16
    8000318e:	e406                	sd	ra,8(sp)
    80003190:	e022                	sd	s0,0(sp)
    80003192:	0800                	addi	s0,sp,16
    schedls();
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	6aa080e7          	jalr	1706(ra) # 8000283e <schedls>
    return 0;
}
    8000319c:	4501                	li	a0,0
    8000319e:	60a2                	ld	ra,8(sp)
    800031a0:	6402                	ld	s0,0(sp)
    800031a2:	0141                	addi	sp,sp,16
    800031a4:	8082                	ret

00000000800031a6 <sys_schedset>:

uint64 sys_schedset(void)
{
    800031a6:	1101                	addi	sp,sp,-32
    800031a8:	ec06                	sd	ra,24(sp)
    800031aa:	e822                	sd	s0,16(sp)
    800031ac:	1000                	addi	s0,sp,32
    int id = 0;
    800031ae:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    800031b2:	fec40593          	addi	a1,s0,-20
    800031b6:	4501                	li	a0,0
    800031b8:	00000097          	auipc	ra,0x0
    800031bc:	ccc080e7          	jalr	-820(ra) # 80002e84 <argint>
    schedset(id - 1);
    800031c0:	fec42503          	lw	a0,-20(s0)
    800031c4:	357d                	addiw	a0,a0,-1
    800031c6:	fffff097          	auipc	ra,0xfffff
    800031ca:	70e080e7          	jalr	1806(ra) # 800028d4 <schedset>
    return 0;
}
    800031ce:	4501                	li	a0,0
    800031d0:	60e2                	ld	ra,24(sp)
    800031d2:	6442                	ld	s0,16(sp)
    800031d4:	6105                	addi	sp,sp,32
    800031d6:	8082                	ret

00000000800031d8 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    800031d8:	1101                	addi	sp,sp,-32
    800031da:	ec06                	sd	ra,24(sp)
    800031dc:	e822                	sd	s0,16(sp)
    800031de:	1000                	addi	s0,sp,32
    int addr = 0, pid = 0;
    800031e0:	fe042623          	sw	zero,-20(s0)
    800031e4:	fe042423          	sw	zero,-24(s0)
    
    argint(0, &addr);
    800031e8:	fec40593          	addi	a1,s0,-20
    800031ec:	4501                	li	a0,0
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	c96080e7          	jalr	-874(ra) # 80002e84 <argint>
    argint(1, &pid);
    800031f6:	fe840593          	addi	a1,s0,-24
    800031fa:	4505                	li	a0,1
    800031fc:	00000097          	auipc	ra,0x0
    80003200:	c88080e7          	jalr	-888(ra) # 80002e84 <argint>

    if(pid == -1){
    80003204:	fe842703          	lw	a4,-24(s0)
    80003208:	57fd                	li	a5,-1
    8000320a:	00f70e63          	beq	a4,a5,80003226 <sys_va2pa+0x4e>
        pid =  myproc()->pid;
    }
    
    return va2pa(addr, pid);
    8000320e:	fe842583          	lw	a1,-24(s0)
    80003212:	fec42503          	lw	a0,-20(s0)
    80003216:	fffff097          	auipc	ra,0xfffff
    8000321a:	70a080e7          	jalr	1802(ra) # 80002920 <va2pa>
}
    8000321e:	60e2                	ld	ra,24(sp)
    80003220:	6442                	ld	s0,16(sp)
    80003222:	6105                	addi	sp,sp,32
    80003224:	8082                	ret
        pid =  myproc()->pid;
    80003226:	fffff097          	auipc	ra,0xfffff
    8000322a:	94c080e7          	jalr	-1716(ra) # 80001b72 <myproc>
    8000322e:	591c                	lw	a5,48(a0)
    80003230:	fef42423          	sw	a5,-24(s0)
    80003234:	bfe9                	j	8000320e <sys_va2pa+0x36>

0000000080003236 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    80003236:	1141                	addi	sp,sp,-16
    80003238:	e406                	sd	ra,8(sp)
    8000323a:	e022                	sd	s0,0(sp)
    8000323c:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    8000323e:	00005597          	auipc	a1,0x5
    80003242:	7fa5b583          	ld	a1,2042(a1) # 80008a38 <FREE_PAGES>
    80003246:	00005517          	auipc	a0,0x5
    8000324a:	2fa50513          	addi	a0,a0,762 # 80008540 <states.0+0x168>
    8000324e:	ffffd097          	auipc	ra,0xffffd
    80003252:	34e080e7          	jalr	846(ra) # 8000059c <printf>
    return 0;
    80003256:	4501                	li	a0,0
    80003258:	60a2                	ld	ra,8(sp)
    8000325a:	6402                	ld	s0,0(sp)
    8000325c:	0141                	addi	sp,sp,16
    8000325e:	8082                	ret

0000000080003260 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003260:	7179                	addi	sp,sp,-48
    80003262:	f406                	sd	ra,40(sp)
    80003264:	f022                	sd	s0,32(sp)
    80003266:	ec26                	sd	s1,24(sp)
    80003268:	e84a                	sd	s2,16(sp)
    8000326a:	e44e                	sd	s3,8(sp)
    8000326c:	e052                	sd	s4,0(sp)
    8000326e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003270:	00005597          	auipc	a1,0x5
    80003274:	3c858593          	addi	a1,a1,968 # 80008638 <syscalls+0xd8>
    80003278:	00014517          	auipc	a0,0x14
    8000327c:	8a050513          	addi	a0,a0,-1888 # 80016b18 <bcache>
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	98e080e7          	jalr	-1650(ra) # 80000c0e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003288:	0001c797          	auipc	a5,0x1c
    8000328c:	89078793          	addi	a5,a5,-1904 # 8001eb18 <bcache+0x8000>
    80003290:	0001c717          	auipc	a4,0x1c
    80003294:	af070713          	addi	a4,a4,-1296 # 8001ed80 <bcache+0x8268>
    80003298:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000329c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032a0:	00014497          	auipc	s1,0x14
    800032a4:	89048493          	addi	s1,s1,-1904 # 80016b30 <bcache+0x18>
    b->next = bcache.head.next;
    800032a8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032aa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032ac:	00005a17          	auipc	s4,0x5
    800032b0:	394a0a13          	addi	s4,s4,916 # 80008640 <syscalls+0xe0>
    b->next = bcache.head.next;
    800032b4:	2b893783          	ld	a5,696(s2)
    800032b8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800032ba:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800032be:	85d2                	mv	a1,s4
    800032c0:	01048513          	addi	a0,s1,16
    800032c4:	00001097          	auipc	ra,0x1
    800032c8:	4c8080e7          	jalr	1224(ra) # 8000478c <initsleeplock>
    bcache.head.next->prev = b;
    800032cc:	2b893783          	ld	a5,696(s2)
    800032d0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032d2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032d6:	45848493          	addi	s1,s1,1112
    800032da:	fd349de3          	bne	s1,s3,800032b4 <binit+0x54>
  }
}
    800032de:	70a2                	ld	ra,40(sp)
    800032e0:	7402                	ld	s0,32(sp)
    800032e2:	64e2                	ld	s1,24(sp)
    800032e4:	6942                	ld	s2,16(sp)
    800032e6:	69a2                	ld	s3,8(sp)
    800032e8:	6a02                	ld	s4,0(sp)
    800032ea:	6145                	addi	sp,sp,48
    800032ec:	8082                	ret

00000000800032ee <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032ee:	7179                	addi	sp,sp,-48
    800032f0:	f406                	sd	ra,40(sp)
    800032f2:	f022                	sd	s0,32(sp)
    800032f4:	ec26                	sd	s1,24(sp)
    800032f6:	e84a                	sd	s2,16(sp)
    800032f8:	e44e                	sd	s3,8(sp)
    800032fa:	1800                	addi	s0,sp,48
    800032fc:	892a                	mv	s2,a0
    800032fe:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003300:	00014517          	auipc	a0,0x14
    80003304:	81850513          	addi	a0,a0,-2024 # 80016b18 <bcache>
    80003308:	ffffe097          	auipc	ra,0xffffe
    8000330c:	996080e7          	jalr	-1642(ra) # 80000c9e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003310:	0001c497          	auipc	s1,0x1c
    80003314:	ac04b483          	ld	s1,-1344(s1) # 8001edd0 <bcache+0x82b8>
    80003318:	0001c797          	auipc	a5,0x1c
    8000331c:	a6878793          	addi	a5,a5,-1432 # 8001ed80 <bcache+0x8268>
    80003320:	02f48f63          	beq	s1,a5,8000335e <bread+0x70>
    80003324:	873e                	mv	a4,a5
    80003326:	a021                	j	8000332e <bread+0x40>
    80003328:	68a4                	ld	s1,80(s1)
    8000332a:	02e48a63          	beq	s1,a4,8000335e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000332e:	449c                	lw	a5,8(s1)
    80003330:	ff279ce3          	bne	a5,s2,80003328 <bread+0x3a>
    80003334:	44dc                	lw	a5,12(s1)
    80003336:	ff3799e3          	bne	a5,s3,80003328 <bread+0x3a>
      b->refcnt++;
    8000333a:	40bc                	lw	a5,64(s1)
    8000333c:	2785                	addiw	a5,a5,1
    8000333e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003340:	00013517          	auipc	a0,0x13
    80003344:	7d850513          	addi	a0,a0,2008 # 80016b18 <bcache>
    80003348:	ffffe097          	auipc	ra,0xffffe
    8000334c:	a0a080e7          	jalr	-1526(ra) # 80000d52 <release>
      acquiresleep(&b->lock);
    80003350:	01048513          	addi	a0,s1,16
    80003354:	00001097          	auipc	ra,0x1
    80003358:	472080e7          	jalr	1138(ra) # 800047c6 <acquiresleep>
      return b;
    8000335c:	a8b9                	j	800033ba <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000335e:	0001c497          	auipc	s1,0x1c
    80003362:	a6a4b483          	ld	s1,-1430(s1) # 8001edc8 <bcache+0x82b0>
    80003366:	0001c797          	auipc	a5,0x1c
    8000336a:	a1a78793          	addi	a5,a5,-1510 # 8001ed80 <bcache+0x8268>
    8000336e:	00f48863          	beq	s1,a5,8000337e <bread+0x90>
    80003372:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003374:	40bc                	lw	a5,64(s1)
    80003376:	cf81                	beqz	a5,8000338e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003378:	64a4                	ld	s1,72(s1)
    8000337a:	fee49de3          	bne	s1,a4,80003374 <bread+0x86>
  panic("bget: no buffers");
    8000337e:	00005517          	auipc	a0,0x5
    80003382:	2ca50513          	addi	a0,a0,714 # 80008648 <syscalls+0xe8>
    80003386:	ffffd097          	auipc	ra,0xffffd
    8000338a:	1ba080e7          	jalr	442(ra) # 80000540 <panic>
      b->dev = dev;
    8000338e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003392:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003396:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000339a:	4785                	li	a5,1
    8000339c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000339e:	00013517          	auipc	a0,0x13
    800033a2:	77a50513          	addi	a0,a0,1914 # 80016b18 <bcache>
    800033a6:	ffffe097          	auipc	ra,0xffffe
    800033aa:	9ac080e7          	jalr	-1620(ra) # 80000d52 <release>
      acquiresleep(&b->lock);
    800033ae:	01048513          	addi	a0,s1,16
    800033b2:	00001097          	auipc	ra,0x1
    800033b6:	414080e7          	jalr	1044(ra) # 800047c6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800033ba:	409c                	lw	a5,0(s1)
    800033bc:	cb89                	beqz	a5,800033ce <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800033be:	8526                	mv	a0,s1
    800033c0:	70a2                	ld	ra,40(sp)
    800033c2:	7402                	ld	s0,32(sp)
    800033c4:	64e2                	ld	s1,24(sp)
    800033c6:	6942                	ld	s2,16(sp)
    800033c8:	69a2                	ld	s3,8(sp)
    800033ca:	6145                	addi	sp,sp,48
    800033cc:	8082                	ret
    virtio_disk_rw(b, 0);
    800033ce:	4581                	li	a1,0
    800033d0:	8526                	mv	a0,s1
    800033d2:	00003097          	auipc	ra,0x3
    800033d6:	fe0080e7          	jalr	-32(ra) # 800063b2 <virtio_disk_rw>
    b->valid = 1;
    800033da:	4785                	li	a5,1
    800033dc:	c09c                	sw	a5,0(s1)
  return b;
    800033de:	b7c5                	j	800033be <bread+0xd0>

00000000800033e0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033e0:	1101                	addi	sp,sp,-32
    800033e2:	ec06                	sd	ra,24(sp)
    800033e4:	e822                	sd	s0,16(sp)
    800033e6:	e426                	sd	s1,8(sp)
    800033e8:	1000                	addi	s0,sp,32
    800033ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033ec:	0541                	addi	a0,a0,16
    800033ee:	00001097          	auipc	ra,0x1
    800033f2:	472080e7          	jalr	1138(ra) # 80004860 <holdingsleep>
    800033f6:	cd01                	beqz	a0,8000340e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033f8:	4585                	li	a1,1
    800033fa:	8526                	mv	a0,s1
    800033fc:	00003097          	auipc	ra,0x3
    80003400:	fb6080e7          	jalr	-74(ra) # 800063b2 <virtio_disk_rw>
}
    80003404:	60e2                	ld	ra,24(sp)
    80003406:	6442                	ld	s0,16(sp)
    80003408:	64a2                	ld	s1,8(sp)
    8000340a:	6105                	addi	sp,sp,32
    8000340c:	8082                	ret
    panic("bwrite");
    8000340e:	00005517          	auipc	a0,0x5
    80003412:	25250513          	addi	a0,a0,594 # 80008660 <syscalls+0x100>
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	12a080e7          	jalr	298(ra) # 80000540 <panic>

000000008000341e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000341e:	1101                	addi	sp,sp,-32
    80003420:	ec06                	sd	ra,24(sp)
    80003422:	e822                	sd	s0,16(sp)
    80003424:	e426                	sd	s1,8(sp)
    80003426:	e04a                	sd	s2,0(sp)
    80003428:	1000                	addi	s0,sp,32
    8000342a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000342c:	01050913          	addi	s2,a0,16
    80003430:	854a                	mv	a0,s2
    80003432:	00001097          	auipc	ra,0x1
    80003436:	42e080e7          	jalr	1070(ra) # 80004860 <holdingsleep>
    8000343a:	c92d                	beqz	a0,800034ac <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000343c:	854a                	mv	a0,s2
    8000343e:	00001097          	auipc	ra,0x1
    80003442:	3de080e7          	jalr	990(ra) # 8000481c <releasesleep>

  acquire(&bcache.lock);
    80003446:	00013517          	auipc	a0,0x13
    8000344a:	6d250513          	addi	a0,a0,1746 # 80016b18 <bcache>
    8000344e:	ffffe097          	auipc	ra,0xffffe
    80003452:	850080e7          	jalr	-1968(ra) # 80000c9e <acquire>
  b->refcnt--;
    80003456:	40bc                	lw	a5,64(s1)
    80003458:	37fd                	addiw	a5,a5,-1
    8000345a:	0007871b          	sext.w	a4,a5
    8000345e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003460:	eb05                	bnez	a4,80003490 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003462:	68bc                	ld	a5,80(s1)
    80003464:	64b8                	ld	a4,72(s1)
    80003466:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003468:	64bc                	ld	a5,72(s1)
    8000346a:	68b8                	ld	a4,80(s1)
    8000346c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000346e:	0001b797          	auipc	a5,0x1b
    80003472:	6aa78793          	addi	a5,a5,1706 # 8001eb18 <bcache+0x8000>
    80003476:	2b87b703          	ld	a4,696(a5)
    8000347a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000347c:	0001c717          	auipc	a4,0x1c
    80003480:	90470713          	addi	a4,a4,-1788 # 8001ed80 <bcache+0x8268>
    80003484:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003486:	2b87b703          	ld	a4,696(a5)
    8000348a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000348c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003490:	00013517          	auipc	a0,0x13
    80003494:	68850513          	addi	a0,a0,1672 # 80016b18 <bcache>
    80003498:	ffffe097          	auipc	ra,0xffffe
    8000349c:	8ba080e7          	jalr	-1862(ra) # 80000d52 <release>
}
    800034a0:	60e2                	ld	ra,24(sp)
    800034a2:	6442                	ld	s0,16(sp)
    800034a4:	64a2                	ld	s1,8(sp)
    800034a6:	6902                	ld	s2,0(sp)
    800034a8:	6105                	addi	sp,sp,32
    800034aa:	8082                	ret
    panic("brelse");
    800034ac:	00005517          	auipc	a0,0x5
    800034b0:	1bc50513          	addi	a0,a0,444 # 80008668 <syscalls+0x108>
    800034b4:	ffffd097          	auipc	ra,0xffffd
    800034b8:	08c080e7          	jalr	140(ra) # 80000540 <panic>

00000000800034bc <bpin>:

void
bpin(struct buf *b) {
    800034bc:	1101                	addi	sp,sp,-32
    800034be:	ec06                	sd	ra,24(sp)
    800034c0:	e822                	sd	s0,16(sp)
    800034c2:	e426                	sd	s1,8(sp)
    800034c4:	1000                	addi	s0,sp,32
    800034c6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034c8:	00013517          	auipc	a0,0x13
    800034cc:	65050513          	addi	a0,a0,1616 # 80016b18 <bcache>
    800034d0:	ffffd097          	auipc	ra,0xffffd
    800034d4:	7ce080e7          	jalr	1998(ra) # 80000c9e <acquire>
  b->refcnt++;
    800034d8:	40bc                	lw	a5,64(s1)
    800034da:	2785                	addiw	a5,a5,1
    800034dc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034de:	00013517          	auipc	a0,0x13
    800034e2:	63a50513          	addi	a0,a0,1594 # 80016b18 <bcache>
    800034e6:	ffffe097          	auipc	ra,0xffffe
    800034ea:	86c080e7          	jalr	-1940(ra) # 80000d52 <release>
}
    800034ee:	60e2                	ld	ra,24(sp)
    800034f0:	6442                	ld	s0,16(sp)
    800034f2:	64a2                	ld	s1,8(sp)
    800034f4:	6105                	addi	sp,sp,32
    800034f6:	8082                	ret

00000000800034f8 <bunpin>:

void
bunpin(struct buf *b) {
    800034f8:	1101                	addi	sp,sp,-32
    800034fa:	ec06                	sd	ra,24(sp)
    800034fc:	e822                	sd	s0,16(sp)
    800034fe:	e426                	sd	s1,8(sp)
    80003500:	1000                	addi	s0,sp,32
    80003502:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003504:	00013517          	auipc	a0,0x13
    80003508:	61450513          	addi	a0,a0,1556 # 80016b18 <bcache>
    8000350c:	ffffd097          	auipc	ra,0xffffd
    80003510:	792080e7          	jalr	1938(ra) # 80000c9e <acquire>
  b->refcnt--;
    80003514:	40bc                	lw	a5,64(s1)
    80003516:	37fd                	addiw	a5,a5,-1
    80003518:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000351a:	00013517          	auipc	a0,0x13
    8000351e:	5fe50513          	addi	a0,a0,1534 # 80016b18 <bcache>
    80003522:	ffffe097          	auipc	ra,0xffffe
    80003526:	830080e7          	jalr	-2000(ra) # 80000d52 <release>
}
    8000352a:	60e2                	ld	ra,24(sp)
    8000352c:	6442                	ld	s0,16(sp)
    8000352e:	64a2                	ld	s1,8(sp)
    80003530:	6105                	addi	sp,sp,32
    80003532:	8082                	ret

0000000080003534 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003534:	1101                	addi	sp,sp,-32
    80003536:	ec06                	sd	ra,24(sp)
    80003538:	e822                	sd	s0,16(sp)
    8000353a:	e426                	sd	s1,8(sp)
    8000353c:	e04a                	sd	s2,0(sp)
    8000353e:	1000                	addi	s0,sp,32
    80003540:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003542:	00d5d59b          	srliw	a1,a1,0xd
    80003546:	0001c797          	auipc	a5,0x1c
    8000354a:	cae7a783          	lw	a5,-850(a5) # 8001f1f4 <sb+0x1c>
    8000354e:	9dbd                	addw	a1,a1,a5
    80003550:	00000097          	auipc	ra,0x0
    80003554:	d9e080e7          	jalr	-610(ra) # 800032ee <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003558:	0074f713          	andi	a4,s1,7
    8000355c:	4785                	li	a5,1
    8000355e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003562:	14ce                	slli	s1,s1,0x33
    80003564:	90d9                	srli	s1,s1,0x36
    80003566:	00950733          	add	a4,a0,s1
    8000356a:	05874703          	lbu	a4,88(a4)
    8000356e:	00e7f6b3          	and	a3,a5,a4
    80003572:	c69d                	beqz	a3,800035a0 <bfree+0x6c>
    80003574:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003576:	94aa                	add	s1,s1,a0
    80003578:	fff7c793          	not	a5,a5
    8000357c:	8f7d                	and	a4,a4,a5
    8000357e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003582:	00001097          	auipc	ra,0x1
    80003586:	126080e7          	jalr	294(ra) # 800046a8 <log_write>
  brelse(bp);
    8000358a:	854a                	mv	a0,s2
    8000358c:	00000097          	auipc	ra,0x0
    80003590:	e92080e7          	jalr	-366(ra) # 8000341e <brelse>
}
    80003594:	60e2                	ld	ra,24(sp)
    80003596:	6442                	ld	s0,16(sp)
    80003598:	64a2                	ld	s1,8(sp)
    8000359a:	6902                	ld	s2,0(sp)
    8000359c:	6105                	addi	sp,sp,32
    8000359e:	8082                	ret
    panic("freeing free block");
    800035a0:	00005517          	auipc	a0,0x5
    800035a4:	0d050513          	addi	a0,a0,208 # 80008670 <syscalls+0x110>
    800035a8:	ffffd097          	auipc	ra,0xffffd
    800035ac:	f98080e7          	jalr	-104(ra) # 80000540 <panic>

00000000800035b0 <balloc>:
{
    800035b0:	711d                	addi	sp,sp,-96
    800035b2:	ec86                	sd	ra,88(sp)
    800035b4:	e8a2                	sd	s0,80(sp)
    800035b6:	e4a6                	sd	s1,72(sp)
    800035b8:	e0ca                	sd	s2,64(sp)
    800035ba:	fc4e                	sd	s3,56(sp)
    800035bc:	f852                	sd	s4,48(sp)
    800035be:	f456                	sd	s5,40(sp)
    800035c0:	f05a                	sd	s6,32(sp)
    800035c2:	ec5e                	sd	s7,24(sp)
    800035c4:	e862                	sd	s8,16(sp)
    800035c6:	e466                	sd	s9,8(sp)
    800035c8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035ca:	0001c797          	auipc	a5,0x1c
    800035ce:	c127a783          	lw	a5,-1006(a5) # 8001f1dc <sb+0x4>
    800035d2:	cff5                	beqz	a5,800036ce <balloc+0x11e>
    800035d4:	8baa                	mv	s7,a0
    800035d6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035d8:	0001cb17          	auipc	s6,0x1c
    800035dc:	c00b0b13          	addi	s6,s6,-1024 # 8001f1d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035e0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035e2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035e4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035e6:	6c89                	lui	s9,0x2
    800035e8:	a061                	j	80003670 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800035ea:	97ca                	add	a5,a5,s2
    800035ec:	8e55                	or	a2,a2,a3
    800035ee:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800035f2:	854a                	mv	a0,s2
    800035f4:	00001097          	auipc	ra,0x1
    800035f8:	0b4080e7          	jalr	180(ra) # 800046a8 <log_write>
        brelse(bp);
    800035fc:	854a                	mv	a0,s2
    800035fe:	00000097          	auipc	ra,0x0
    80003602:	e20080e7          	jalr	-480(ra) # 8000341e <brelse>
  bp = bread(dev, bno);
    80003606:	85a6                	mv	a1,s1
    80003608:	855e                	mv	a0,s7
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	ce4080e7          	jalr	-796(ra) # 800032ee <bread>
    80003612:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003614:	40000613          	li	a2,1024
    80003618:	4581                	li	a1,0
    8000361a:	05850513          	addi	a0,a0,88
    8000361e:	ffffd097          	auipc	ra,0xffffd
    80003622:	77c080e7          	jalr	1916(ra) # 80000d9a <memset>
  log_write(bp);
    80003626:	854a                	mv	a0,s2
    80003628:	00001097          	auipc	ra,0x1
    8000362c:	080080e7          	jalr	128(ra) # 800046a8 <log_write>
  brelse(bp);
    80003630:	854a                	mv	a0,s2
    80003632:	00000097          	auipc	ra,0x0
    80003636:	dec080e7          	jalr	-532(ra) # 8000341e <brelse>
}
    8000363a:	8526                	mv	a0,s1
    8000363c:	60e6                	ld	ra,88(sp)
    8000363e:	6446                	ld	s0,80(sp)
    80003640:	64a6                	ld	s1,72(sp)
    80003642:	6906                	ld	s2,64(sp)
    80003644:	79e2                	ld	s3,56(sp)
    80003646:	7a42                	ld	s4,48(sp)
    80003648:	7aa2                	ld	s5,40(sp)
    8000364a:	7b02                	ld	s6,32(sp)
    8000364c:	6be2                	ld	s7,24(sp)
    8000364e:	6c42                	ld	s8,16(sp)
    80003650:	6ca2                	ld	s9,8(sp)
    80003652:	6125                	addi	sp,sp,96
    80003654:	8082                	ret
    brelse(bp);
    80003656:	854a                	mv	a0,s2
    80003658:	00000097          	auipc	ra,0x0
    8000365c:	dc6080e7          	jalr	-570(ra) # 8000341e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003660:	015c87bb          	addw	a5,s9,s5
    80003664:	00078a9b          	sext.w	s5,a5
    80003668:	004b2703          	lw	a4,4(s6)
    8000366c:	06eaf163          	bgeu	s5,a4,800036ce <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003670:	41fad79b          	sraiw	a5,s5,0x1f
    80003674:	0137d79b          	srliw	a5,a5,0x13
    80003678:	015787bb          	addw	a5,a5,s5
    8000367c:	40d7d79b          	sraiw	a5,a5,0xd
    80003680:	01cb2583          	lw	a1,28(s6)
    80003684:	9dbd                	addw	a1,a1,a5
    80003686:	855e                	mv	a0,s7
    80003688:	00000097          	auipc	ra,0x0
    8000368c:	c66080e7          	jalr	-922(ra) # 800032ee <bread>
    80003690:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003692:	004b2503          	lw	a0,4(s6)
    80003696:	000a849b          	sext.w	s1,s5
    8000369a:	8762                	mv	a4,s8
    8000369c:	faa4fde3          	bgeu	s1,a0,80003656 <balloc+0xa6>
      m = 1 << (bi % 8);
    800036a0:	00777693          	andi	a3,a4,7
    800036a4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800036a8:	41f7579b          	sraiw	a5,a4,0x1f
    800036ac:	01d7d79b          	srliw	a5,a5,0x1d
    800036b0:	9fb9                	addw	a5,a5,a4
    800036b2:	4037d79b          	sraiw	a5,a5,0x3
    800036b6:	00f90633          	add	a2,s2,a5
    800036ba:	05864603          	lbu	a2,88(a2)
    800036be:	00c6f5b3          	and	a1,a3,a2
    800036c2:	d585                	beqz	a1,800035ea <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036c4:	2705                	addiw	a4,a4,1
    800036c6:	2485                	addiw	s1,s1,1
    800036c8:	fd471ae3          	bne	a4,s4,8000369c <balloc+0xec>
    800036cc:	b769                	j	80003656 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800036ce:	00005517          	auipc	a0,0x5
    800036d2:	fba50513          	addi	a0,a0,-70 # 80008688 <syscalls+0x128>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	ec6080e7          	jalr	-314(ra) # 8000059c <printf>
  return 0;
    800036de:	4481                	li	s1,0
    800036e0:	bfa9                	j	8000363a <balloc+0x8a>

00000000800036e2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800036e2:	7179                	addi	sp,sp,-48
    800036e4:	f406                	sd	ra,40(sp)
    800036e6:	f022                	sd	s0,32(sp)
    800036e8:	ec26                	sd	s1,24(sp)
    800036ea:	e84a                	sd	s2,16(sp)
    800036ec:	e44e                	sd	s3,8(sp)
    800036ee:	e052                	sd	s4,0(sp)
    800036f0:	1800                	addi	s0,sp,48
    800036f2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036f4:	47ad                	li	a5,11
    800036f6:	02b7e863          	bltu	a5,a1,80003726 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800036fa:	02059793          	slli	a5,a1,0x20
    800036fe:	01e7d593          	srli	a1,a5,0x1e
    80003702:	00b504b3          	add	s1,a0,a1
    80003706:	0504a903          	lw	s2,80(s1)
    8000370a:	06091e63          	bnez	s2,80003786 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000370e:	4108                	lw	a0,0(a0)
    80003710:	00000097          	auipc	ra,0x0
    80003714:	ea0080e7          	jalr	-352(ra) # 800035b0 <balloc>
    80003718:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000371c:	06090563          	beqz	s2,80003786 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003720:	0524a823          	sw	s2,80(s1)
    80003724:	a08d                	j	80003786 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003726:	ff45849b          	addiw	s1,a1,-12
    8000372a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000372e:	0ff00793          	li	a5,255
    80003732:	08e7e563          	bltu	a5,a4,800037bc <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003736:	08052903          	lw	s2,128(a0)
    8000373a:	00091d63          	bnez	s2,80003754 <bmap+0x72>
      addr = balloc(ip->dev);
    8000373e:	4108                	lw	a0,0(a0)
    80003740:	00000097          	auipc	ra,0x0
    80003744:	e70080e7          	jalr	-400(ra) # 800035b0 <balloc>
    80003748:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000374c:	02090d63          	beqz	s2,80003786 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003750:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003754:	85ca                	mv	a1,s2
    80003756:	0009a503          	lw	a0,0(s3)
    8000375a:	00000097          	auipc	ra,0x0
    8000375e:	b94080e7          	jalr	-1132(ra) # 800032ee <bread>
    80003762:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003764:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003768:	02049713          	slli	a4,s1,0x20
    8000376c:	01e75593          	srli	a1,a4,0x1e
    80003770:	00b784b3          	add	s1,a5,a1
    80003774:	0004a903          	lw	s2,0(s1)
    80003778:	02090063          	beqz	s2,80003798 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000377c:	8552                	mv	a0,s4
    8000377e:	00000097          	auipc	ra,0x0
    80003782:	ca0080e7          	jalr	-864(ra) # 8000341e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003786:	854a                	mv	a0,s2
    80003788:	70a2                	ld	ra,40(sp)
    8000378a:	7402                	ld	s0,32(sp)
    8000378c:	64e2                	ld	s1,24(sp)
    8000378e:	6942                	ld	s2,16(sp)
    80003790:	69a2                	ld	s3,8(sp)
    80003792:	6a02                	ld	s4,0(sp)
    80003794:	6145                	addi	sp,sp,48
    80003796:	8082                	ret
      addr = balloc(ip->dev);
    80003798:	0009a503          	lw	a0,0(s3)
    8000379c:	00000097          	auipc	ra,0x0
    800037a0:	e14080e7          	jalr	-492(ra) # 800035b0 <balloc>
    800037a4:	0005091b          	sext.w	s2,a0
      if(addr){
    800037a8:	fc090ae3          	beqz	s2,8000377c <bmap+0x9a>
        a[bn] = addr;
    800037ac:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800037b0:	8552                	mv	a0,s4
    800037b2:	00001097          	auipc	ra,0x1
    800037b6:	ef6080e7          	jalr	-266(ra) # 800046a8 <log_write>
    800037ba:	b7c9                	j	8000377c <bmap+0x9a>
  panic("bmap: out of range");
    800037bc:	00005517          	auipc	a0,0x5
    800037c0:	ee450513          	addi	a0,a0,-284 # 800086a0 <syscalls+0x140>
    800037c4:	ffffd097          	auipc	ra,0xffffd
    800037c8:	d7c080e7          	jalr	-644(ra) # 80000540 <panic>

00000000800037cc <iget>:
{
    800037cc:	7179                	addi	sp,sp,-48
    800037ce:	f406                	sd	ra,40(sp)
    800037d0:	f022                	sd	s0,32(sp)
    800037d2:	ec26                	sd	s1,24(sp)
    800037d4:	e84a                	sd	s2,16(sp)
    800037d6:	e44e                	sd	s3,8(sp)
    800037d8:	e052                	sd	s4,0(sp)
    800037da:	1800                	addi	s0,sp,48
    800037dc:	89aa                	mv	s3,a0
    800037de:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800037e0:	0001c517          	auipc	a0,0x1c
    800037e4:	a1850513          	addi	a0,a0,-1512 # 8001f1f8 <itable>
    800037e8:	ffffd097          	auipc	ra,0xffffd
    800037ec:	4b6080e7          	jalr	1206(ra) # 80000c9e <acquire>
  empty = 0;
    800037f0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037f2:	0001c497          	auipc	s1,0x1c
    800037f6:	a1e48493          	addi	s1,s1,-1506 # 8001f210 <itable+0x18>
    800037fa:	0001d697          	auipc	a3,0x1d
    800037fe:	4a668693          	addi	a3,a3,1190 # 80020ca0 <log>
    80003802:	a039                	j	80003810 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003804:	02090b63          	beqz	s2,8000383a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003808:	08848493          	addi	s1,s1,136
    8000380c:	02d48a63          	beq	s1,a3,80003840 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003810:	449c                	lw	a5,8(s1)
    80003812:	fef059e3          	blez	a5,80003804 <iget+0x38>
    80003816:	4098                	lw	a4,0(s1)
    80003818:	ff3716e3          	bne	a4,s3,80003804 <iget+0x38>
    8000381c:	40d8                	lw	a4,4(s1)
    8000381e:	ff4713e3          	bne	a4,s4,80003804 <iget+0x38>
      ip->ref++;
    80003822:	2785                	addiw	a5,a5,1
    80003824:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003826:	0001c517          	auipc	a0,0x1c
    8000382a:	9d250513          	addi	a0,a0,-1582 # 8001f1f8 <itable>
    8000382e:	ffffd097          	auipc	ra,0xffffd
    80003832:	524080e7          	jalr	1316(ra) # 80000d52 <release>
      return ip;
    80003836:	8926                	mv	s2,s1
    80003838:	a03d                	j	80003866 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000383a:	f7f9                	bnez	a5,80003808 <iget+0x3c>
    8000383c:	8926                	mv	s2,s1
    8000383e:	b7e9                	j	80003808 <iget+0x3c>
  if(empty == 0)
    80003840:	02090c63          	beqz	s2,80003878 <iget+0xac>
  ip->dev = dev;
    80003844:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003848:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000384c:	4785                	li	a5,1
    8000384e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003852:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003856:	0001c517          	auipc	a0,0x1c
    8000385a:	9a250513          	addi	a0,a0,-1630 # 8001f1f8 <itable>
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	4f4080e7          	jalr	1268(ra) # 80000d52 <release>
}
    80003866:	854a                	mv	a0,s2
    80003868:	70a2                	ld	ra,40(sp)
    8000386a:	7402                	ld	s0,32(sp)
    8000386c:	64e2                	ld	s1,24(sp)
    8000386e:	6942                	ld	s2,16(sp)
    80003870:	69a2                	ld	s3,8(sp)
    80003872:	6a02                	ld	s4,0(sp)
    80003874:	6145                	addi	sp,sp,48
    80003876:	8082                	ret
    panic("iget: no inodes");
    80003878:	00005517          	auipc	a0,0x5
    8000387c:	e4050513          	addi	a0,a0,-448 # 800086b8 <syscalls+0x158>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	cc0080e7          	jalr	-832(ra) # 80000540 <panic>

0000000080003888 <fsinit>:
fsinit(int dev) {
    80003888:	7179                	addi	sp,sp,-48
    8000388a:	f406                	sd	ra,40(sp)
    8000388c:	f022                	sd	s0,32(sp)
    8000388e:	ec26                	sd	s1,24(sp)
    80003890:	e84a                	sd	s2,16(sp)
    80003892:	e44e                	sd	s3,8(sp)
    80003894:	1800                	addi	s0,sp,48
    80003896:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003898:	4585                	li	a1,1
    8000389a:	00000097          	auipc	ra,0x0
    8000389e:	a54080e7          	jalr	-1452(ra) # 800032ee <bread>
    800038a2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800038a4:	0001c997          	auipc	s3,0x1c
    800038a8:	93498993          	addi	s3,s3,-1740 # 8001f1d8 <sb>
    800038ac:	02000613          	li	a2,32
    800038b0:	05850593          	addi	a1,a0,88
    800038b4:	854e                	mv	a0,s3
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	540080e7          	jalr	1344(ra) # 80000df6 <memmove>
  brelse(bp);
    800038be:	8526                	mv	a0,s1
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	b5e080e7          	jalr	-1186(ra) # 8000341e <brelse>
  if(sb.magic != FSMAGIC)
    800038c8:	0009a703          	lw	a4,0(s3)
    800038cc:	102037b7          	lui	a5,0x10203
    800038d0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038d4:	02f71263          	bne	a4,a5,800038f8 <fsinit+0x70>
  initlog(dev, &sb);
    800038d8:	0001c597          	auipc	a1,0x1c
    800038dc:	90058593          	addi	a1,a1,-1792 # 8001f1d8 <sb>
    800038e0:	854a                	mv	a0,s2
    800038e2:	00001097          	auipc	ra,0x1
    800038e6:	b4a080e7          	jalr	-1206(ra) # 8000442c <initlog>
}
    800038ea:	70a2                	ld	ra,40(sp)
    800038ec:	7402                	ld	s0,32(sp)
    800038ee:	64e2                	ld	s1,24(sp)
    800038f0:	6942                	ld	s2,16(sp)
    800038f2:	69a2                	ld	s3,8(sp)
    800038f4:	6145                	addi	sp,sp,48
    800038f6:	8082                	ret
    panic("invalid file system");
    800038f8:	00005517          	auipc	a0,0x5
    800038fc:	dd050513          	addi	a0,a0,-560 # 800086c8 <syscalls+0x168>
    80003900:	ffffd097          	auipc	ra,0xffffd
    80003904:	c40080e7          	jalr	-960(ra) # 80000540 <panic>

0000000080003908 <iinit>:
{
    80003908:	7179                	addi	sp,sp,-48
    8000390a:	f406                	sd	ra,40(sp)
    8000390c:	f022                	sd	s0,32(sp)
    8000390e:	ec26                	sd	s1,24(sp)
    80003910:	e84a                	sd	s2,16(sp)
    80003912:	e44e                	sd	s3,8(sp)
    80003914:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003916:	00005597          	auipc	a1,0x5
    8000391a:	dca58593          	addi	a1,a1,-566 # 800086e0 <syscalls+0x180>
    8000391e:	0001c517          	auipc	a0,0x1c
    80003922:	8da50513          	addi	a0,a0,-1830 # 8001f1f8 <itable>
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	2e8080e7          	jalr	744(ra) # 80000c0e <initlock>
  for(i = 0; i < NINODE; i++) {
    8000392e:	0001c497          	auipc	s1,0x1c
    80003932:	8f248493          	addi	s1,s1,-1806 # 8001f220 <itable+0x28>
    80003936:	0001d997          	auipc	s3,0x1d
    8000393a:	37a98993          	addi	s3,s3,890 # 80020cb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000393e:	00005917          	auipc	s2,0x5
    80003942:	daa90913          	addi	s2,s2,-598 # 800086e8 <syscalls+0x188>
    80003946:	85ca                	mv	a1,s2
    80003948:	8526                	mv	a0,s1
    8000394a:	00001097          	auipc	ra,0x1
    8000394e:	e42080e7          	jalr	-446(ra) # 8000478c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003952:	08848493          	addi	s1,s1,136
    80003956:	ff3498e3          	bne	s1,s3,80003946 <iinit+0x3e>
}
    8000395a:	70a2                	ld	ra,40(sp)
    8000395c:	7402                	ld	s0,32(sp)
    8000395e:	64e2                	ld	s1,24(sp)
    80003960:	6942                	ld	s2,16(sp)
    80003962:	69a2                	ld	s3,8(sp)
    80003964:	6145                	addi	sp,sp,48
    80003966:	8082                	ret

0000000080003968 <ialloc>:
{
    80003968:	715d                	addi	sp,sp,-80
    8000396a:	e486                	sd	ra,72(sp)
    8000396c:	e0a2                	sd	s0,64(sp)
    8000396e:	fc26                	sd	s1,56(sp)
    80003970:	f84a                	sd	s2,48(sp)
    80003972:	f44e                	sd	s3,40(sp)
    80003974:	f052                	sd	s4,32(sp)
    80003976:	ec56                	sd	s5,24(sp)
    80003978:	e85a                	sd	s6,16(sp)
    8000397a:	e45e                	sd	s7,8(sp)
    8000397c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000397e:	0001c717          	auipc	a4,0x1c
    80003982:	86672703          	lw	a4,-1946(a4) # 8001f1e4 <sb+0xc>
    80003986:	4785                	li	a5,1
    80003988:	04e7fa63          	bgeu	a5,a4,800039dc <ialloc+0x74>
    8000398c:	8aaa                	mv	s5,a0
    8000398e:	8bae                	mv	s7,a1
    80003990:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003992:	0001ca17          	auipc	s4,0x1c
    80003996:	846a0a13          	addi	s4,s4,-1978 # 8001f1d8 <sb>
    8000399a:	00048b1b          	sext.w	s6,s1
    8000399e:	0044d593          	srli	a1,s1,0x4
    800039a2:	018a2783          	lw	a5,24(s4)
    800039a6:	9dbd                	addw	a1,a1,a5
    800039a8:	8556                	mv	a0,s5
    800039aa:	00000097          	auipc	ra,0x0
    800039ae:	944080e7          	jalr	-1724(ra) # 800032ee <bread>
    800039b2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800039b4:	05850993          	addi	s3,a0,88
    800039b8:	00f4f793          	andi	a5,s1,15
    800039bc:	079a                	slli	a5,a5,0x6
    800039be:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800039c0:	00099783          	lh	a5,0(s3)
    800039c4:	c3a1                	beqz	a5,80003a04 <ialloc+0x9c>
    brelse(bp);
    800039c6:	00000097          	auipc	ra,0x0
    800039ca:	a58080e7          	jalr	-1448(ra) # 8000341e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800039ce:	0485                	addi	s1,s1,1
    800039d0:	00ca2703          	lw	a4,12(s4)
    800039d4:	0004879b          	sext.w	a5,s1
    800039d8:	fce7e1e3          	bltu	a5,a4,8000399a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800039dc:	00005517          	auipc	a0,0x5
    800039e0:	d1450513          	addi	a0,a0,-748 # 800086f0 <syscalls+0x190>
    800039e4:	ffffd097          	auipc	ra,0xffffd
    800039e8:	bb8080e7          	jalr	-1096(ra) # 8000059c <printf>
  return 0;
    800039ec:	4501                	li	a0,0
}
    800039ee:	60a6                	ld	ra,72(sp)
    800039f0:	6406                	ld	s0,64(sp)
    800039f2:	74e2                	ld	s1,56(sp)
    800039f4:	7942                	ld	s2,48(sp)
    800039f6:	79a2                	ld	s3,40(sp)
    800039f8:	7a02                	ld	s4,32(sp)
    800039fa:	6ae2                	ld	s5,24(sp)
    800039fc:	6b42                	ld	s6,16(sp)
    800039fe:	6ba2                	ld	s7,8(sp)
    80003a00:	6161                	addi	sp,sp,80
    80003a02:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a04:	04000613          	li	a2,64
    80003a08:	4581                	li	a1,0
    80003a0a:	854e                	mv	a0,s3
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	38e080e7          	jalr	910(ra) # 80000d9a <memset>
      dip->type = type;
    80003a14:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a18:	854a                	mv	a0,s2
    80003a1a:	00001097          	auipc	ra,0x1
    80003a1e:	c8e080e7          	jalr	-882(ra) # 800046a8 <log_write>
      brelse(bp);
    80003a22:	854a                	mv	a0,s2
    80003a24:	00000097          	auipc	ra,0x0
    80003a28:	9fa080e7          	jalr	-1542(ra) # 8000341e <brelse>
      return iget(dev, inum);
    80003a2c:	85da                	mv	a1,s6
    80003a2e:	8556                	mv	a0,s5
    80003a30:	00000097          	auipc	ra,0x0
    80003a34:	d9c080e7          	jalr	-612(ra) # 800037cc <iget>
    80003a38:	bf5d                	j	800039ee <ialloc+0x86>

0000000080003a3a <iupdate>:
{
    80003a3a:	1101                	addi	sp,sp,-32
    80003a3c:	ec06                	sd	ra,24(sp)
    80003a3e:	e822                	sd	s0,16(sp)
    80003a40:	e426                	sd	s1,8(sp)
    80003a42:	e04a                	sd	s2,0(sp)
    80003a44:	1000                	addi	s0,sp,32
    80003a46:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a48:	415c                	lw	a5,4(a0)
    80003a4a:	0047d79b          	srliw	a5,a5,0x4
    80003a4e:	0001b597          	auipc	a1,0x1b
    80003a52:	7a25a583          	lw	a1,1954(a1) # 8001f1f0 <sb+0x18>
    80003a56:	9dbd                	addw	a1,a1,a5
    80003a58:	4108                	lw	a0,0(a0)
    80003a5a:	00000097          	auipc	ra,0x0
    80003a5e:	894080e7          	jalr	-1900(ra) # 800032ee <bread>
    80003a62:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a64:	05850793          	addi	a5,a0,88
    80003a68:	40d8                	lw	a4,4(s1)
    80003a6a:	8b3d                	andi	a4,a4,15
    80003a6c:	071a                	slli	a4,a4,0x6
    80003a6e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003a70:	04449703          	lh	a4,68(s1)
    80003a74:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003a78:	04649703          	lh	a4,70(s1)
    80003a7c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003a80:	04849703          	lh	a4,72(s1)
    80003a84:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003a88:	04a49703          	lh	a4,74(s1)
    80003a8c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003a90:	44f8                	lw	a4,76(s1)
    80003a92:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a94:	03400613          	li	a2,52
    80003a98:	05048593          	addi	a1,s1,80
    80003a9c:	00c78513          	addi	a0,a5,12
    80003aa0:	ffffd097          	auipc	ra,0xffffd
    80003aa4:	356080e7          	jalr	854(ra) # 80000df6 <memmove>
  log_write(bp);
    80003aa8:	854a                	mv	a0,s2
    80003aaa:	00001097          	auipc	ra,0x1
    80003aae:	bfe080e7          	jalr	-1026(ra) # 800046a8 <log_write>
  brelse(bp);
    80003ab2:	854a                	mv	a0,s2
    80003ab4:	00000097          	auipc	ra,0x0
    80003ab8:	96a080e7          	jalr	-1686(ra) # 8000341e <brelse>
}
    80003abc:	60e2                	ld	ra,24(sp)
    80003abe:	6442                	ld	s0,16(sp)
    80003ac0:	64a2                	ld	s1,8(sp)
    80003ac2:	6902                	ld	s2,0(sp)
    80003ac4:	6105                	addi	sp,sp,32
    80003ac6:	8082                	ret

0000000080003ac8 <idup>:
{
    80003ac8:	1101                	addi	sp,sp,-32
    80003aca:	ec06                	sd	ra,24(sp)
    80003acc:	e822                	sd	s0,16(sp)
    80003ace:	e426                	sd	s1,8(sp)
    80003ad0:	1000                	addi	s0,sp,32
    80003ad2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ad4:	0001b517          	auipc	a0,0x1b
    80003ad8:	72450513          	addi	a0,a0,1828 # 8001f1f8 <itable>
    80003adc:	ffffd097          	auipc	ra,0xffffd
    80003ae0:	1c2080e7          	jalr	450(ra) # 80000c9e <acquire>
  ip->ref++;
    80003ae4:	449c                	lw	a5,8(s1)
    80003ae6:	2785                	addiw	a5,a5,1
    80003ae8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003aea:	0001b517          	auipc	a0,0x1b
    80003aee:	70e50513          	addi	a0,a0,1806 # 8001f1f8 <itable>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	260080e7          	jalr	608(ra) # 80000d52 <release>
}
    80003afa:	8526                	mv	a0,s1
    80003afc:	60e2                	ld	ra,24(sp)
    80003afe:	6442                	ld	s0,16(sp)
    80003b00:	64a2                	ld	s1,8(sp)
    80003b02:	6105                	addi	sp,sp,32
    80003b04:	8082                	ret

0000000080003b06 <ilock>:
{
    80003b06:	1101                	addi	sp,sp,-32
    80003b08:	ec06                	sd	ra,24(sp)
    80003b0a:	e822                	sd	s0,16(sp)
    80003b0c:	e426                	sd	s1,8(sp)
    80003b0e:	e04a                	sd	s2,0(sp)
    80003b10:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b12:	c115                	beqz	a0,80003b36 <ilock+0x30>
    80003b14:	84aa                	mv	s1,a0
    80003b16:	451c                	lw	a5,8(a0)
    80003b18:	00f05f63          	blez	a5,80003b36 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b1c:	0541                	addi	a0,a0,16
    80003b1e:	00001097          	auipc	ra,0x1
    80003b22:	ca8080e7          	jalr	-856(ra) # 800047c6 <acquiresleep>
  if(ip->valid == 0){
    80003b26:	40bc                	lw	a5,64(s1)
    80003b28:	cf99                	beqz	a5,80003b46 <ilock+0x40>
}
    80003b2a:	60e2                	ld	ra,24(sp)
    80003b2c:	6442                	ld	s0,16(sp)
    80003b2e:	64a2                	ld	s1,8(sp)
    80003b30:	6902                	ld	s2,0(sp)
    80003b32:	6105                	addi	sp,sp,32
    80003b34:	8082                	ret
    panic("ilock");
    80003b36:	00005517          	auipc	a0,0x5
    80003b3a:	bd250513          	addi	a0,a0,-1070 # 80008708 <syscalls+0x1a8>
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	a02080e7          	jalr	-1534(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b46:	40dc                	lw	a5,4(s1)
    80003b48:	0047d79b          	srliw	a5,a5,0x4
    80003b4c:	0001b597          	auipc	a1,0x1b
    80003b50:	6a45a583          	lw	a1,1700(a1) # 8001f1f0 <sb+0x18>
    80003b54:	9dbd                	addw	a1,a1,a5
    80003b56:	4088                	lw	a0,0(s1)
    80003b58:	fffff097          	auipc	ra,0xfffff
    80003b5c:	796080e7          	jalr	1942(ra) # 800032ee <bread>
    80003b60:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b62:	05850593          	addi	a1,a0,88
    80003b66:	40dc                	lw	a5,4(s1)
    80003b68:	8bbd                	andi	a5,a5,15
    80003b6a:	079a                	slli	a5,a5,0x6
    80003b6c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b6e:	00059783          	lh	a5,0(a1)
    80003b72:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b76:	00259783          	lh	a5,2(a1)
    80003b7a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b7e:	00459783          	lh	a5,4(a1)
    80003b82:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b86:	00659783          	lh	a5,6(a1)
    80003b8a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b8e:	459c                	lw	a5,8(a1)
    80003b90:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b92:	03400613          	li	a2,52
    80003b96:	05b1                	addi	a1,a1,12
    80003b98:	05048513          	addi	a0,s1,80
    80003b9c:	ffffd097          	auipc	ra,0xffffd
    80003ba0:	25a080e7          	jalr	602(ra) # 80000df6 <memmove>
    brelse(bp);
    80003ba4:	854a                	mv	a0,s2
    80003ba6:	00000097          	auipc	ra,0x0
    80003baa:	878080e7          	jalr	-1928(ra) # 8000341e <brelse>
    ip->valid = 1;
    80003bae:	4785                	li	a5,1
    80003bb0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003bb2:	04449783          	lh	a5,68(s1)
    80003bb6:	fbb5                	bnez	a5,80003b2a <ilock+0x24>
      panic("ilock: no type");
    80003bb8:	00005517          	auipc	a0,0x5
    80003bbc:	b5850513          	addi	a0,a0,-1192 # 80008710 <syscalls+0x1b0>
    80003bc0:	ffffd097          	auipc	ra,0xffffd
    80003bc4:	980080e7          	jalr	-1664(ra) # 80000540 <panic>

0000000080003bc8 <iunlock>:
{
    80003bc8:	1101                	addi	sp,sp,-32
    80003bca:	ec06                	sd	ra,24(sp)
    80003bcc:	e822                	sd	s0,16(sp)
    80003bce:	e426                	sd	s1,8(sp)
    80003bd0:	e04a                	sd	s2,0(sp)
    80003bd2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bd4:	c905                	beqz	a0,80003c04 <iunlock+0x3c>
    80003bd6:	84aa                	mv	s1,a0
    80003bd8:	01050913          	addi	s2,a0,16
    80003bdc:	854a                	mv	a0,s2
    80003bde:	00001097          	auipc	ra,0x1
    80003be2:	c82080e7          	jalr	-894(ra) # 80004860 <holdingsleep>
    80003be6:	cd19                	beqz	a0,80003c04 <iunlock+0x3c>
    80003be8:	449c                	lw	a5,8(s1)
    80003bea:	00f05d63          	blez	a5,80003c04 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003bee:	854a                	mv	a0,s2
    80003bf0:	00001097          	auipc	ra,0x1
    80003bf4:	c2c080e7          	jalr	-980(ra) # 8000481c <releasesleep>
}
    80003bf8:	60e2                	ld	ra,24(sp)
    80003bfa:	6442                	ld	s0,16(sp)
    80003bfc:	64a2                	ld	s1,8(sp)
    80003bfe:	6902                	ld	s2,0(sp)
    80003c00:	6105                	addi	sp,sp,32
    80003c02:	8082                	ret
    panic("iunlock");
    80003c04:	00005517          	auipc	a0,0x5
    80003c08:	b1c50513          	addi	a0,a0,-1252 # 80008720 <syscalls+0x1c0>
    80003c0c:	ffffd097          	auipc	ra,0xffffd
    80003c10:	934080e7          	jalr	-1740(ra) # 80000540 <panic>

0000000080003c14 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c14:	7179                	addi	sp,sp,-48
    80003c16:	f406                	sd	ra,40(sp)
    80003c18:	f022                	sd	s0,32(sp)
    80003c1a:	ec26                	sd	s1,24(sp)
    80003c1c:	e84a                	sd	s2,16(sp)
    80003c1e:	e44e                	sd	s3,8(sp)
    80003c20:	e052                	sd	s4,0(sp)
    80003c22:	1800                	addi	s0,sp,48
    80003c24:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c26:	05050493          	addi	s1,a0,80
    80003c2a:	08050913          	addi	s2,a0,128
    80003c2e:	a021                	j	80003c36 <itrunc+0x22>
    80003c30:	0491                	addi	s1,s1,4
    80003c32:	01248d63          	beq	s1,s2,80003c4c <itrunc+0x38>
    if(ip->addrs[i]){
    80003c36:	408c                	lw	a1,0(s1)
    80003c38:	dde5                	beqz	a1,80003c30 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c3a:	0009a503          	lw	a0,0(s3)
    80003c3e:	00000097          	auipc	ra,0x0
    80003c42:	8f6080e7          	jalr	-1802(ra) # 80003534 <bfree>
      ip->addrs[i] = 0;
    80003c46:	0004a023          	sw	zero,0(s1)
    80003c4a:	b7dd                	j	80003c30 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c4c:	0809a583          	lw	a1,128(s3)
    80003c50:	e185                	bnez	a1,80003c70 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c52:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c56:	854e                	mv	a0,s3
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	de2080e7          	jalr	-542(ra) # 80003a3a <iupdate>
}
    80003c60:	70a2                	ld	ra,40(sp)
    80003c62:	7402                	ld	s0,32(sp)
    80003c64:	64e2                	ld	s1,24(sp)
    80003c66:	6942                	ld	s2,16(sp)
    80003c68:	69a2                	ld	s3,8(sp)
    80003c6a:	6a02                	ld	s4,0(sp)
    80003c6c:	6145                	addi	sp,sp,48
    80003c6e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c70:	0009a503          	lw	a0,0(s3)
    80003c74:	fffff097          	auipc	ra,0xfffff
    80003c78:	67a080e7          	jalr	1658(ra) # 800032ee <bread>
    80003c7c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c7e:	05850493          	addi	s1,a0,88
    80003c82:	45850913          	addi	s2,a0,1112
    80003c86:	a021                	j	80003c8e <itrunc+0x7a>
    80003c88:	0491                	addi	s1,s1,4
    80003c8a:	01248b63          	beq	s1,s2,80003ca0 <itrunc+0x8c>
      if(a[j])
    80003c8e:	408c                	lw	a1,0(s1)
    80003c90:	dde5                	beqz	a1,80003c88 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c92:	0009a503          	lw	a0,0(s3)
    80003c96:	00000097          	auipc	ra,0x0
    80003c9a:	89e080e7          	jalr	-1890(ra) # 80003534 <bfree>
    80003c9e:	b7ed                	j	80003c88 <itrunc+0x74>
    brelse(bp);
    80003ca0:	8552                	mv	a0,s4
    80003ca2:	fffff097          	auipc	ra,0xfffff
    80003ca6:	77c080e7          	jalr	1916(ra) # 8000341e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003caa:	0809a583          	lw	a1,128(s3)
    80003cae:	0009a503          	lw	a0,0(s3)
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	882080e7          	jalr	-1918(ra) # 80003534 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003cba:	0809a023          	sw	zero,128(s3)
    80003cbe:	bf51                	j	80003c52 <itrunc+0x3e>

0000000080003cc0 <iput>:
{
    80003cc0:	1101                	addi	sp,sp,-32
    80003cc2:	ec06                	sd	ra,24(sp)
    80003cc4:	e822                	sd	s0,16(sp)
    80003cc6:	e426                	sd	s1,8(sp)
    80003cc8:	e04a                	sd	s2,0(sp)
    80003cca:	1000                	addi	s0,sp,32
    80003ccc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cce:	0001b517          	auipc	a0,0x1b
    80003cd2:	52a50513          	addi	a0,a0,1322 # 8001f1f8 <itable>
    80003cd6:	ffffd097          	auipc	ra,0xffffd
    80003cda:	fc8080e7          	jalr	-56(ra) # 80000c9e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cde:	4498                	lw	a4,8(s1)
    80003ce0:	4785                	li	a5,1
    80003ce2:	02f70363          	beq	a4,a5,80003d08 <iput+0x48>
  ip->ref--;
    80003ce6:	449c                	lw	a5,8(s1)
    80003ce8:	37fd                	addiw	a5,a5,-1
    80003cea:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cec:	0001b517          	auipc	a0,0x1b
    80003cf0:	50c50513          	addi	a0,a0,1292 # 8001f1f8 <itable>
    80003cf4:	ffffd097          	auipc	ra,0xffffd
    80003cf8:	05e080e7          	jalr	94(ra) # 80000d52 <release>
}
    80003cfc:	60e2                	ld	ra,24(sp)
    80003cfe:	6442                	ld	s0,16(sp)
    80003d00:	64a2                	ld	s1,8(sp)
    80003d02:	6902                	ld	s2,0(sp)
    80003d04:	6105                	addi	sp,sp,32
    80003d06:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d08:	40bc                	lw	a5,64(s1)
    80003d0a:	dff1                	beqz	a5,80003ce6 <iput+0x26>
    80003d0c:	04a49783          	lh	a5,74(s1)
    80003d10:	fbf9                	bnez	a5,80003ce6 <iput+0x26>
    acquiresleep(&ip->lock);
    80003d12:	01048913          	addi	s2,s1,16
    80003d16:	854a                	mv	a0,s2
    80003d18:	00001097          	auipc	ra,0x1
    80003d1c:	aae080e7          	jalr	-1362(ra) # 800047c6 <acquiresleep>
    release(&itable.lock);
    80003d20:	0001b517          	auipc	a0,0x1b
    80003d24:	4d850513          	addi	a0,a0,1240 # 8001f1f8 <itable>
    80003d28:	ffffd097          	auipc	ra,0xffffd
    80003d2c:	02a080e7          	jalr	42(ra) # 80000d52 <release>
    itrunc(ip);
    80003d30:	8526                	mv	a0,s1
    80003d32:	00000097          	auipc	ra,0x0
    80003d36:	ee2080e7          	jalr	-286(ra) # 80003c14 <itrunc>
    ip->type = 0;
    80003d3a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d3e:	8526                	mv	a0,s1
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	cfa080e7          	jalr	-774(ra) # 80003a3a <iupdate>
    ip->valid = 0;
    80003d48:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d4c:	854a                	mv	a0,s2
    80003d4e:	00001097          	auipc	ra,0x1
    80003d52:	ace080e7          	jalr	-1330(ra) # 8000481c <releasesleep>
    acquire(&itable.lock);
    80003d56:	0001b517          	auipc	a0,0x1b
    80003d5a:	4a250513          	addi	a0,a0,1186 # 8001f1f8 <itable>
    80003d5e:	ffffd097          	auipc	ra,0xffffd
    80003d62:	f40080e7          	jalr	-192(ra) # 80000c9e <acquire>
    80003d66:	b741                	j	80003ce6 <iput+0x26>

0000000080003d68 <iunlockput>:
{
    80003d68:	1101                	addi	sp,sp,-32
    80003d6a:	ec06                	sd	ra,24(sp)
    80003d6c:	e822                	sd	s0,16(sp)
    80003d6e:	e426                	sd	s1,8(sp)
    80003d70:	1000                	addi	s0,sp,32
    80003d72:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	e54080e7          	jalr	-428(ra) # 80003bc8 <iunlock>
  iput(ip);
    80003d7c:	8526                	mv	a0,s1
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	f42080e7          	jalr	-190(ra) # 80003cc0 <iput>
}
    80003d86:	60e2                	ld	ra,24(sp)
    80003d88:	6442                	ld	s0,16(sp)
    80003d8a:	64a2                	ld	s1,8(sp)
    80003d8c:	6105                	addi	sp,sp,32
    80003d8e:	8082                	ret

0000000080003d90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d90:	1141                	addi	sp,sp,-16
    80003d92:	e422                	sd	s0,8(sp)
    80003d94:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d96:	411c                	lw	a5,0(a0)
    80003d98:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d9a:	415c                	lw	a5,4(a0)
    80003d9c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d9e:	04451783          	lh	a5,68(a0)
    80003da2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003da6:	04a51783          	lh	a5,74(a0)
    80003daa:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003dae:	04c56783          	lwu	a5,76(a0)
    80003db2:	e99c                	sd	a5,16(a1)
}
    80003db4:	6422                	ld	s0,8(sp)
    80003db6:	0141                	addi	sp,sp,16
    80003db8:	8082                	ret

0000000080003dba <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dba:	457c                	lw	a5,76(a0)
    80003dbc:	0ed7e963          	bltu	a5,a3,80003eae <readi+0xf4>
{
    80003dc0:	7159                	addi	sp,sp,-112
    80003dc2:	f486                	sd	ra,104(sp)
    80003dc4:	f0a2                	sd	s0,96(sp)
    80003dc6:	eca6                	sd	s1,88(sp)
    80003dc8:	e8ca                	sd	s2,80(sp)
    80003dca:	e4ce                	sd	s3,72(sp)
    80003dcc:	e0d2                	sd	s4,64(sp)
    80003dce:	fc56                	sd	s5,56(sp)
    80003dd0:	f85a                	sd	s6,48(sp)
    80003dd2:	f45e                	sd	s7,40(sp)
    80003dd4:	f062                	sd	s8,32(sp)
    80003dd6:	ec66                	sd	s9,24(sp)
    80003dd8:	e86a                	sd	s10,16(sp)
    80003dda:	e46e                	sd	s11,8(sp)
    80003ddc:	1880                	addi	s0,sp,112
    80003dde:	8b2a                	mv	s6,a0
    80003de0:	8bae                	mv	s7,a1
    80003de2:	8a32                	mv	s4,a2
    80003de4:	84b6                	mv	s1,a3
    80003de6:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003de8:	9f35                	addw	a4,a4,a3
    return 0;
    80003dea:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003dec:	0ad76063          	bltu	a4,a3,80003e8c <readi+0xd2>
  if(off + n > ip->size)
    80003df0:	00e7f463          	bgeu	a5,a4,80003df8 <readi+0x3e>
    n = ip->size - off;
    80003df4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003df8:	0a0a8963          	beqz	s5,80003eaa <readi+0xf0>
    80003dfc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dfe:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e02:	5c7d                	li	s8,-1
    80003e04:	a82d                	j	80003e3e <readi+0x84>
    80003e06:	020d1d93          	slli	s11,s10,0x20
    80003e0a:	020ddd93          	srli	s11,s11,0x20
    80003e0e:	05890613          	addi	a2,s2,88
    80003e12:	86ee                	mv	a3,s11
    80003e14:	963a                	add	a2,a2,a4
    80003e16:	85d2                	mv	a1,s4
    80003e18:	855e                	mv	a0,s7
    80003e1a:	fffff097          	auipc	ra,0xfffff
    80003e1e:	8c8080e7          	jalr	-1848(ra) # 800026e2 <either_copyout>
    80003e22:	05850d63          	beq	a0,s8,80003e7c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e26:	854a                	mv	a0,s2
    80003e28:	fffff097          	auipc	ra,0xfffff
    80003e2c:	5f6080e7          	jalr	1526(ra) # 8000341e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e30:	013d09bb          	addw	s3,s10,s3
    80003e34:	009d04bb          	addw	s1,s10,s1
    80003e38:	9a6e                	add	s4,s4,s11
    80003e3a:	0559f763          	bgeu	s3,s5,80003e88 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003e3e:	00a4d59b          	srliw	a1,s1,0xa
    80003e42:	855a                	mv	a0,s6
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	89e080e7          	jalr	-1890(ra) # 800036e2 <bmap>
    80003e4c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e50:	cd85                	beqz	a1,80003e88 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e52:	000b2503          	lw	a0,0(s6)
    80003e56:	fffff097          	auipc	ra,0xfffff
    80003e5a:	498080e7          	jalr	1176(ra) # 800032ee <bread>
    80003e5e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e60:	3ff4f713          	andi	a4,s1,1023
    80003e64:	40ec87bb          	subw	a5,s9,a4
    80003e68:	413a86bb          	subw	a3,s5,s3
    80003e6c:	8d3e                	mv	s10,a5
    80003e6e:	2781                	sext.w	a5,a5
    80003e70:	0006861b          	sext.w	a2,a3
    80003e74:	f8f679e3          	bgeu	a2,a5,80003e06 <readi+0x4c>
    80003e78:	8d36                	mv	s10,a3
    80003e7a:	b771                	j	80003e06 <readi+0x4c>
      brelse(bp);
    80003e7c:	854a                	mv	a0,s2
    80003e7e:	fffff097          	auipc	ra,0xfffff
    80003e82:	5a0080e7          	jalr	1440(ra) # 8000341e <brelse>
      tot = -1;
    80003e86:	59fd                	li	s3,-1
  }
  return tot;
    80003e88:	0009851b          	sext.w	a0,s3
}
    80003e8c:	70a6                	ld	ra,104(sp)
    80003e8e:	7406                	ld	s0,96(sp)
    80003e90:	64e6                	ld	s1,88(sp)
    80003e92:	6946                	ld	s2,80(sp)
    80003e94:	69a6                	ld	s3,72(sp)
    80003e96:	6a06                	ld	s4,64(sp)
    80003e98:	7ae2                	ld	s5,56(sp)
    80003e9a:	7b42                	ld	s6,48(sp)
    80003e9c:	7ba2                	ld	s7,40(sp)
    80003e9e:	7c02                	ld	s8,32(sp)
    80003ea0:	6ce2                	ld	s9,24(sp)
    80003ea2:	6d42                	ld	s10,16(sp)
    80003ea4:	6da2                	ld	s11,8(sp)
    80003ea6:	6165                	addi	sp,sp,112
    80003ea8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eaa:	89d6                	mv	s3,s5
    80003eac:	bff1                	j	80003e88 <readi+0xce>
    return 0;
    80003eae:	4501                	li	a0,0
}
    80003eb0:	8082                	ret

0000000080003eb2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003eb2:	457c                	lw	a5,76(a0)
    80003eb4:	10d7e863          	bltu	a5,a3,80003fc4 <writei+0x112>
{
    80003eb8:	7159                	addi	sp,sp,-112
    80003eba:	f486                	sd	ra,104(sp)
    80003ebc:	f0a2                	sd	s0,96(sp)
    80003ebe:	eca6                	sd	s1,88(sp)
    80003ec0:	e8ca                	sd	s2,80(sp)
    80003ec2:	e4ce                	sd	s3,72(sp)
    80003ec4:	e0d2                	sd	s4,64(sp)
    80003ec6:	fc56                	sd	s5,56(sp)
    80003ec8:	f85a                	sd	s6,48(sp)
    80003eca:	f45e                	sd	s7,40(sp)
    80003ecc:	f062                	sd	s8,32(sp)
    80003ece:	ec66                	sd	s9,24(sp)
    80003ed0:	e86a                	sd	s10,16(sp)
    80003ed2:	e46e                	sd	s11,8(sp)
    80003ed4:	1880                	addi	s0,sp,112
    80003ed6:	8aaa                	mv	s5,a0
    80003ed8:	8bae                	mv	s7,a1
    80003eda:	8a32                	mv	s4,a2
    80003edc:	8936                	mv	s2,a3
    80003ede:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ee0:	00e687bb          	addw	a5,a3,a4
    80003ee4:	0ed7e263          	bltu	a5,a3,80003fc8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ee8:	00043737          	lui	a4,0x43
    80003eec:	0ef76063          	bltu	a4,a5,80003fcc <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ef0:	0c0b0863          	beqz	s6,80003fc0 <writei+0x10e>
    80003ef4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ef6:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003efa:	5c7d                	li	s8,-1
    80003efc:	a091                	j	80003f40 <writei+0x8e>
    80003efe:	020d1d93          	slli	s11,s10,0x20
    80003f02:	020ddd93          	srli	s11,s11,0x20
    80003f06:	05848513          	addi	a0,s1,88
    80003f0a:	86ee                	mv	a3,s11
    80003f0c:	8652                	mv	a2,s4
    80003f0e:	85de                	mv	a1,s7
    80003f10:	953a                	add	a0,a0,a4
    80003f12:	fffff097          	auipc	ra,0xfffff
    80003f16:	826080e7          	jalr	-2010(ra) # 80002738 <either_copyin>
    80003f1a:	07850263          	beq	a0,s8,80003f7e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	788080e7          	jalr	1928(ra) # 800046a8 <log_write>
    brelse(bp);
    80003f28:	8526                	mv	a0,s1
    80003f2a:	fffff097          	auipc	ra,0xfffff
    80003f2e:	4f4080e7          	jalr	1268(ra) # 8000341e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f32:	013d09bb          	addw	s3,s10,s3
    80003f36:	012d093b          	addw	s2,s10,s2
    80003f3a:	9a6e                	add	s4,s4,s11
    80003f3c:	0569f663          	bgeu	s3,s6,80003f88 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003f40:	00a9559b          	srliw	a1,s2,0xa
    80003f44:	8556                	mv	a0,s5
    80003f46:	fffff097          	auipc	ra,0xfffff
    80003f4a:	79c080e7          	jalr	1948(ra) # 800036e2 <bmap>
    80003f4e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f52:	c99d                	beqz	a1,80003f88 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003f54:	000aa503          	lw	a0,0(s5)
    80003f58:	fffff097          	auipc	ra,0xfffff
    80003f5c:	396080e7          	jalr	918(ra) # 800032ee <bread>
    80003f60:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f62:	3ff97713          	andi	a4,s2,1023
    80003f66:	40ec87bb          	subw	a5,s9,a4
    80003f6a:	413b06bb          	subw	a3,s6,s3
    80003f6e:	8d3e                	mv	s10,a5
    80003f70:	2781                	sext.w	a5,a5
    80003f72:	0006861b          	sext.w	a2,a3
    80003f76:	f8f674e3          	bgeu	a2,a5,80003efe <writei+0x4c>
    80003f7a:	8d36                	mv	s10,a3
    80003f7c:	b749                	j	80003efe <writei+0x4c>
      brelse(bp);
    80003f7e:	8526                	mv	a0,s1
    80003f80:	fffff097          	auipc	ra,0xfffff
    80003f84:	49e080e7          	jalr	1182(ra) # 8000341e <brelse>
  }

  if(off > ip->size)
    80003f88:	04caa783          	lw	a5,76(s5)
    80003f8c:	0127f463          	bgeu	a5,s2,80003f94 <writei+0xe2>
    ip->size = off;
    80003f90:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f94:	8556                	mv	a0,s5
    80003f96:	00000097          	auipc	ra,0x0
    80003f9a:	aa4080e7          	jalr	-1372(ra) # 80003a3a <iupdate>

  return tot;
    80003f9e:	0009851b          	sext.w	a0,s3
}
    80003fa2:	70a6                	ld	ra,104(sp)
    80003fa4:	7406                	ld	s0,96(sp)
    80003fa6:	64e6                	ld	s1,88(sp)
    80003fa8:	6946                	ld	s2,80(sp)
    80003faa:	69a6                	ld	s3,72(sp)
    80003fac:	6a06                	ld	s4,64(sp)
    80003fae:	7ae2                	ld	s5,56(sp)
    80003fb0:	7b42                	ld	s6,48(sp)
    80003fb2:	7ba2                	ld	s7,40(sp)
    80003fb4:	7c02                	ld	s8,32(sp)
    80003fb6:	6ce2                	ld	s9,24(sp)
    80003fb8:	6d42                	ld	s10,16(sp)
    80003fba:	6da2                	ld	s11,8(sp)
    80003fbc:	6165                	addi	sp,sp,112
    80003fbe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fc0:	89da                	mv	s3,s6
    80003fc2:	bfc9                	j	80003f94 <writei+0xe2>
    return -1;
    80003fc4:	557d                	li	a0,-1
}
    80003fc6:	8082                	ret
    return -1;
    80003fc8:	557d                	li	a0,-1
    80003fca:	bfe1                	j	80003fa2 <writei+0xf0>
    return -1;
    80003fcc:	557d                	li	a0,-1
    80003fce:	bfd1                	j	80003fa2 <writei+0xf0>

0000000080003fd0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003fd0:	1141                	addi	sp,sp,-16
    80003fd2:	e406                	sd	ra,8(sp)
    80003fd4:	e022                	sd	s0,0(sp)
    80003fd6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003fd8:	4639                	li	a2,14
    80003fda:	ffffd097          	auipc	ra,0xffffd
    80003fde:	e90080e7          	jalr	-368(ra) # 80000e6a <strncmp>
}
    80003fe2:	60a2                	ld	ra,8(sp)
    80003fe4:	6402                	ld	s0,0(sp)
    80003fe6:	0141                	addi	sp,sp,16
    80003fe8:	8082                	ret

0000000080003fea <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003fea:	7139                	addi	sp,sp,-64
    80003fec:	fc06                	sd	ra,56(sp)
    80003fee:	f822                	sd	s0,48(sp)
    80003ff0:	f426                	sd	s1,40(sp)
    80003ff2:	f04a                	sd	s2,32(sp)
    80003ff4:	ec4e                	sd	s3,24(sp)
    80003ff6:	e852                	sd	s4,16(sp)
    80003ff8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ffa:	04451703          	lh	a4,68(a0)
    80003ffe:	4785                	li	a5,1
    80004000:	00f71a63          	bne	a4,a5,80004014 <dirlookup+0x2a>
    80004004:	892a                	mv	s2,a0
    80004006:	89ae                	mv	s3,a1
    80004008:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000400a:	457c                	lw	a5,76(a0)
    8000400c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000400e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004010:	e79d                	bnez	a5,8000403e <dirlookup+0x54>
    80004012:	a8a5                	j	8000408a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004014:	00004517          	auipc	a0,0x4
    80004018:	71450513          	addi	a0,a0,1812 # 80008728 <syscalls+0x1c8>
    8000401c:	ffffc097          	auipc	ra,0xffffc
    80004020:	524080e7          	jalr	1316(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004024:	00004517          	auipc	a0,0x4
    80004028:	71c50513          	addi	a0,a0,1820 # 80008740 <syscalls+0x1e0>
    8000402c:	ffffc097          	auipc	ra,0xffffc
    80004030:	514080e7          	jalr	1300(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004034:	24c1                	addiw	s1,s1,16
    80004036:	04c92783          	lw	a5,76(s2)
    8000403a:	04f4f763          	bgeu	s1,a5,80004088 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000403e:	4741                	li	a4,16
    80004040:	86a6                	mv	a3,s1
    80004042:	fc040613          	addi	a2,s0,-64
    80004046:	4581                	li	a1,0
    80004048:	854a                	mv	a0,s2
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	d70080e7          	jalr	-656(ra) # 80003dba <readi>
    80004052:	47c1                	li	a5,16
    80004054:	fcf518e3          	bne	a0,a5,80004024 <dirlookup+0x3a>
    if(de.inum == 0)
    80004058:	fc045783          	lhu	a5,-64(s0)
    8000405c:	dfe1                	beqz	a5,80004034 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000405e:	fc240593          	addi	a1,s0,-62
    80004062:	854e                	mv	a0,s3
    80004064:	00000097          	auipc	ra,0x0
    80004068:	f6c080e7          	jalr	-148(ra) # 80003fd0 <namecmp>
    8000406c:	f561                	bnez	a0,80004034 <dirlookup+0x4a>
      if(poff)
    8000406e:	000a0463          	beqz	s4,80004076 <dirlookup+0x8c>
        *poff = off;
    80004072:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004076:	fc045583          	lhu	a1,-64(s0)
    8000407a:	00092503          	lw	a0,0(s2)
    8000407e:	fffff097          	auipc	ra,0xfffff
    80004082:	74e080e7          	jalr	1870(ra) # 800037cc <iget>
    80004086:	a011                	j	8000408a <dirlookup+0xa0>
  return 0;
    80004088:	4501                	li	a0,0
}
    8000408a:	70e2                	ld	ra,56(sp)
    8000408c:	7442                	ld	s0,48(sp)
    8000408e:	74a2                	ld	s1,40(sp)
    80004090:	7902                	ld	s2,32(sp)
    80004092:	69e2                	ld	s3,24(sp)
    80004094:	6a42                	ld	s4,16(sp)
    80004096:	6121                	addi	sp,sp,64
    80004098:	8082                	ret

000000008000409a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000409a:	711d                	addi	sp,sp,-96
    8000409c:	ec86                	sd	ra,88(sp)
    8000409e:	e8a2                	sd	s0,80(sp)
    800040a0:	e4a6                	sd	s1,72(sp)
    800040a2:	e0ca                	sd	s2,64(sp)
    800040a4:	fc4e                	sd	s3,56(sp)
    800040a6:	f852                	sd	s4,48(sp)
    800040a8:	f456                	sd	s5,40(sp)
    800040aa:	f05a                	sd	s6,32(sp)
    800040ac:	ec5e                	sd	s7,24(sp)
    800040ae:	e862                	sd	s8,16(sp)
    800040b0:	e466                	sd	s9,8(sp)
    800040b2:	e06a                	sd	s10,0(sp)
    800040b4:	1080                	addi	s0,sp,96
    800040b6:	84aa                	mv	s1,a0
    800040b8:	8b2e                	mv	s6,a1
    800040ba:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040bc:	00054703          	lbu	a4,0(a0)
    800040c0:	02f00793          	li	a5,47
    800040c4:	02f70363          	beq	a4,a5,800040ea <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040c8:	ffffe097          	auipc	ra,0xffffe
    800040cc:	aaa080e7          	jalr	-1366(ra) # 80001b72 <myproc>
    800040d0:	15053503          	ld	a0,336(a0)
    800040d4:	00000097          	auipc	ra,0x0
    800040d8:	9f4080e7          	jalr	-1548(ra) # 80003ac8 <idup>
    800040dc:	8a2a                	mv	s4,a0
  while(*path == '/')
    800040de:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800040e2:	4cb5                	li	s9,13
  len = path - s;
    800040e4:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040e6:	4c05                	li	s8,1
    800040e8:	a87d                	j	800041a6 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    800040ea:	4585                	li	a1,1
    800040ec:	4505                	li	a0,1
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	6de080e7          	jalr	1758(ra) # 800037cc <iget>
    800040f6:	8a2a                	mv	s4,a0
    800040f8:	b7dd                	j	800040de <namex+0x44>
      iunlockput(ip);
    800040fa:	8552                	mv	a0,s4
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	c6c080e7          	jalr	-916(ra) # 80003d68 <iunlockput>
      return 0;
    80004104:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004106:	8552                	mv	a0,s4
    80004108:	60e6                	ld	ra,88(sp)
    8000410a:	6446                	ld	s0,80(sp)
    8000410c:	64a6                	ld	s1,72(sp)
    8000410e:	6906                	ld	s2,64(sp)
    80004110:	79e2                	ld	s3,56(sp)
    80004112:	7a42                	ld	s4,48(sp)
    80004114:	7aa2                	ld	s5,40(sp)
    80004116:	7b02                	ld	s6,32(sp)
    80004118:	6be2                	ld	s7,24(sp)
    8000411a:	6c42                	ld	s8,16(sp)
    8000411c:	6ca2                	ld	s9,8(sp)
    8000411e:	6d02                	ld	s10,0(sp)
    80004120:	6125                	addi	sp,sp,96
    80004122:	8082                	ret
      iunlock(ip);
    80004124:	8552                	mv	a0,s4
    80004126:	00000097          	auipc	ra,0x0
    8000412a:	aa2080e7          	jalr	-1374(ra) # 80003bc8 <iunlock>
      return ip;
    8000412e:	bfe1                	j	80004106 <namex+0x6c>
      iunlockput(ip);
    80004130:	8552                	mv	a0,s4
    80004132:	00000097          	auipc	ra,0x0
    80004136:	c36080e7          	jalr	-970(ra) # 80003d68 <iunlockput>
      return 0;
    8000413a:	8a4e                	mv	s4,s3
    8000413c:	b7e9                	j	80004106 <namex+0x6c>
  len = path - s;
    8000413e:	40998633          	sub	a2,s3,s1
    80004142:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004146:	09acd863          	bge	s9,s10,800041d6 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000414a:	4639                	li	a2,14
    8000414c:	85a6                	mv	a1,s1
    8000414e:	8556                	mv	a0,s5
    80004150:	ffffd097          	auipc	ra,0xffffd
    80004154:	ca6080e7          	jalr	-858(ra) # 80000df6 <memmove>
    80004158:	84ce                	mv	s1,s3
  while(*path == '/')
    8000415a:	0004c783          	lbu	a5,0(s1)
    8000415e:	01279763          	bne	a5,s2,8000416c <namex+0xd2>
    path++;
    80004162:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004164:	0004c783          	lbu	a5,0(s1)
    80004168:	ff278de3          	beq	a5,s2,80004162 <namex+0xc8>
    ilock(ip);
    8000416c:	8552                	mv	a0,s4
    8000416e:	00000097          	auipc	ra,0x0
    80004172:	998080e7          	jalr	-1640(ra) # 80003b06 <ilock>
    if(ip->type != T_DIR){
    80004176:	044a1783          	lh	a5,68(s4)
    8000417a:	f98790e3          	bne	a5,s8,800040fa <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000417e:	000b0563          	beqz	s6,80004188 <namex+0xee>
    80004182:	0004c783          	lbu	a5,0(s1)
    80004186:	dfd9                	beqz	a5,80004124 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004188:	865e                	mv	a2,s7
    8000418a:	85d6                	mv	a1,s5
    8000418c:	8552                	mv	a0,s4
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	e5c080e7          	jalr	-420(ra) # 80003fea <dirlookup>
    80004196:	89aa                	mv	s3,a0
    80004198:	dd41                	beqz	a0,80004130 <namex+0x96>
    iunlockput(ip);
    8000419a:	8552                	mv	a0,s4
    8000419c:	00000097          	auipc	ra,0x0
    800041a0:	bcc080e7          	jalr	-1076(ra) # 80003d68 <iunlockput>
    ip = next;
    800041a4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800041a6:	0004c783          	lbu	a5,0(s1)
    800041aa:	01279763          	bne	a5,s2,800041b8 <namex+0x11e>
    path++;
    800041ae:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041b0:	0004c783          	lbu	a5,0(s1)
    800041b4:	ff278de3          	beq	a5,s2,800041ae <namex+0x114>
  if(*path == 0)
    800041b8:	cb9d                	beqz	a5,800041ee <namex+0x154>
  while(*path != '/' && *path != 0)
    800041ba:	0004c783          	lbu	a5,0(s1)
    800041be:	89a6                	mv	s3,s1
  len = path - s;
    800041c0:	8d5e                	mv	s10,s7
    800041c2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800041c4:	01278963          	beq	a5,s2,800041d6 <namex+0x13c>
    800041c8:	dbbd                	beqz	a5,8000413e <namex+0xa4>
    path++;
    800041ca:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800041cc:	0009c783          	lbu	a5,0(s3)
    800041d0:	ff279ce3          	bne	a5,s2,800041c8 <namex+0x12e>
    800041d4:	b7ad                	j	8000413e <namex+0xa4>
    memmove(name, s, len);
    800041d6:	2601                	sext.w	a2,a2
    800041d8:	85a6                	mv	a1,s1
    800041da:	8556                	mv	a0,s5
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	c1a080e7          	jalr	-998(ra) # 80000df6 <memmove>
    name[len] = 0;
    800041e4:	9d56                	add	s10,s10,s5
    800041e6:	000d0023          	sb	zero,0(s10)
    800041ea:	84ce                	mv	s1,s3
    800041ec:	b7bd                	j	8000415a <namex+0xc0>
  if(nameiparent){
    800041ee:	f00b0ce3          	beqz	s6,80004106 <namex+0x6c>
    iput(ip);
    800041f2:	8552                	mv	a0,s4
    800041f4:	00000097          	auipc	ra,0x0
    800041f8:	acc080e7          	jalr	-1332(ra) # 80003cc0 <iput>
    return 0;
    800041fc:	4a01                	li	s4,0
    800041fe:	b721                	j	80004106 <namex+0x6c>

0000000080004200 <dirlink>:
{
    80004200:	7139                	addi	sp,sp,-64
    80004202:	fc06                	sd	ra,56(sp)
    80004204:	f822                	sd	s0,48(sp)
    80004206:	f426                	sd	s1,40(sp)
    80004208:	f04a                	sd	s2,32(sp)
    8000420a:	ec4e                	sd	s3,24(sp)
    8000420c:	e852                	sd	s4,16(sp)
    8000420e:	0080                	addi	s0,sp,64
    80004210:	892a                	mv	s2,a0
    80004212:	8a2e                	mv	s4,a1
    80004214:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004216:	4601                	li	a2,0
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	dd2080e7          	jalr	-558(ra) # 80003fea <dirlookup>
    80004220:	e93d                	bnez	a0,80004296 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004222:	04c92483          	lw	s1,76(s2)
    80004226:	c49d                	beqz	s1,80004254 <dirlink+0x54>
    80004228:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000422a:	4741                	li	a4,16
    8000422c:	86a6                	mv	a3,s1
    8000422e:	fc040613          	addi	a2,s0,-64
    80004232:	4581                	li	a1,0
    80004234:	854a                	mv	a0,s2
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	b84080e7          	jalr	-1148(ra) # 80003dba <readi>
    8000423e:	47c1                	li	a5,16
    80004240:	06f51163          	bne	a0,a5,800042a2 <dirlink+0xa2>
    if(de.inum == 0)
    80004244:	fc045783          	lhu	a5,-64(s0)
    80004248:	c791                	beqz	a5,80004254 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000424a:	24c1                	addiw	s1,s1,16
    8000424c:	04c92783          	lw	a5,76(s2)
    80004250:	fcf4ede3          	bltu	s1,a5,8000422a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004254:	4639                	li	a2,14
    80004256:	85d2                	mv	a1,s4
    80004258:	fc240513          	addi	a0,s0,-62
    8000425c:	ffffd097          	auipc	ra,0xffffd
    80004260:	c4a080e7          	jalr	-950(ra) # 80000ea6 <strncpy>
  de.inum = inum;
    80004264:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004268:	4741                	li	a4,16
    8000426a:	86a6                	mv	a3,s1
    8000426c:	fc040613          	addi	a2,s0,-64
    80004270:	4581                	li	a1,0
    80004272:	854a                	mv	a0,s2
    80004274:	00000097          	auipc	ra,0x0
    80004278:	c3e080e7          	jalr	-962(ra) # 80003eb2 <writei>
    8000427c:	1541                	addi	a0,a0,-16
    8000427e:	00a03533          	snez	a0,a0
    80004282:	40a00533          	neg	a0,a0
}
    80004286:	70e2                	ld	ra,56(sp)
    80004288:	7442                	ld	s0,48(sp)
    8000428a:	74a2                	ld	s1,40(sp)
    8000428c:	7902                	ld	s2,32(sp)
    8000428e:	69e2                	ld	s3,24(sp)
    80004290:	6a42                	ld	s4,16(sp)
    80004292:	6121                	addi	sp,sp,64
    80004294:	8082                	ret
    iput(ip);
    80004296:	00000097          	auipc	ra,0x0
    8000429a:	a2a080e7          	jalr	-1494(ra) # 80003cc0 <iput>
    return -1;
    8000429e:	557d                	li	a0,-1
    800042a0:	b7dd                	j	80004286 <dirlink+0x86>
      panic("dirlink read");
    800042a2:	00004517          	auipc	a0,0x4
    800042a6:	4ae50513          	addi	a0,a0,1198 # 80008750 <syscalls+0x1f0>
    800042aa:	ffffc097          	auipc	ra,0xffffc
    800042ae:	296080e7          	jalr	662(ra) # 80000540 <panic>

00000000800042b2 <namei>:

struct inode*
namei(char *path)
{
    800042b2:	1101                	addi	sp,sp,-32
    800042b4:	ec06                	sd	ra,24(sp)
    800042b6:	e822                	sd	s0,16(sp)
    800042b8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042ba:	fe040613          	addi	a2,s0,-32
    800042be:	4581                	li	a1,0
    800042c0:	00000097          	auipc	ra,0x0
    800042c4:	dda080e7          	jalr	-550(ra) # 8000409a <namex>
}
    800042c8:	60e2                	ld	ra,24(sp)
    800042ca:	6442                	ld	s0,16(sp)
    800042cc:	6105                	addi	sp,sp,32
    800042ce:	8082                	ret

00000000800042d0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042d0:	1141                	addi	sp,sp,-16
    800042d2:	e406                	sd	ra,8(sp)
    800042d4:	e022                	sd	s0,0(sp)
    800042d6:	0800                	addi	s0,sp,16
    800042d8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042da:	4585                	li	a1,1
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	dbe080e7          	jalr	-578(ra) # 8000409a <namex>
}
    800042e4:	60a2                	ld	ra,8(sp)
    800042e6:	6402                	ld	s0,0(sp)
    800042e8:	0141                	addi	sp,sp,16
    800042ea:	8082                	ret

00000000800042ec <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042ec:	1101                	addi	sp,sp,-32
    800042ee:	ec06                	sd	ra,24(sp)
    800042f0:	e822                	sd	s0,16(sp)
    800042f2:	e426                	sd	s1,8(sp)
    800042f4:	e04a                	sd	s2,0(sp)
    800042f6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042f8:	0001d917          	auipc	s2,0x1d
    800042fc:	9a890913          	addi	s2,s2,-1624 # 80020ca0 <log>
    80004300:	01892583          	lw	a1,24(s2)
    80004304:	02892503          	lw	a0,40(s2)
    80004308:	fffff097          	auipc	ra,0xfffff
    8000430c:	fe6080e7          	jalr	-26(ra) # 800032ee <bread>
    80004310:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004312:	02c92683          	lw	a3,44(s2)
    80004316:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004318:	02d05863          	blez	a3,80004348 <write_head+0x5c>
    8000431c:	0001d797          	auipc	a5,0x1d
    80004320:	9b478793          	addi	a5,a5,-1612 # 80020cd0 <log+0x30>
    80004324:	05c50713          	addi	a4,a0,92
    80004328:	36fd                	addiw	a3,a3,-1
    8000432a:	02069613          	slli	a2,a3,0x20
    8000432e:	01e65693          	srli	a3,a2,0x1e
    80004332:	0001d617          	auipc	a2,0x1d
    80004336:	9a260613          	addi	a2,a2,-1630 # 80020cd4 <log+0x34>
    8000433a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000433c:	4390                	lw	a2,0(a5)
    8000433e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004340:	0791                	addi	a5,a5,4
    80004342:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004344:	fed79ce3          	bne	a5,a3,8000433c <write_head+0x50>
  }
  bwrite(buf);
    80004348:	8526                	mv	a0,s1
    8000434a:	fffff097          	auipc	ra,0xfffff
    8000434e:	096080e7          	jalr	150(ra) # 800033e0 <bwrite>
  brelse(buf);
    80004352:	8526                	mv	a0,s1
    80004354:	fffff097          	auipc	ra,0xfffff
    80004358:	0ca080e7          	jalr	202(ra) # 8000341e <brelse>
}
    8000435c:	60e2                	ld	ra,24(sp)
    8000435e:	6442                	ld	s0,16(sp)
    80004360:	64a2                	ld	s1,8(sp)
    80004362:	6902                	ld	s2,0(sp)
    80004364:	6105                	addi	sp,sp,32
    80004366:	8082                	ret

0000000080004368 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004368:	0001d797          	auipc	a5,0x1d
    8000436c:	9647a783          	lw	a5,-1692(a5) # 80020ccc <log+0x2c>
    80004370:	0af05d63          	blez	a5,8000442a <install_trans+0xc2>
{
    80004374:	7139                	addi	sp,sp,-64
    80004376:	fc06                	sd	ra,56(sp)
    80004378:	f822                	sd	s0,48(sp)
    8000437a:	f426                	sd	s1,40(sp)
    8000437c:	f04a                	sd	s2,32(sp)
    8000437e:	ec4e                	sd	s3,24(sp)
    80004380:	e852                	sd	s4,16(sp)
    80004382:	e456                	sd	s5,8(sp)
    80004384:	e05a                	sd	s6,0(sp)
    80004386:	0080                	addi	s0,sp,64
    80004388:	8b2a                	mv	s6,a0
    8000438a:	0001da97          	auipc	s5,0x1d
    8000438e:	946a8a93          	addi	s5,s5,-1722 # 80020cd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004392:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004394:	0001d997          	auipc	s3,0x1d
    80004398:	90c98993          	addi	s3,s3,-1780 # 80020ca0 <log>
    8000439c:	a00d                	j	800043be <install_trans+0x56>
    brelse(lbuf);
    8000439e:	854a                	mv	a0,s2
    800043a0:	fffff097          	auipc	ra,0xfffff
    800043a4:	07e080e7          	jalr	126(ra) # 8000341e <brelse>
    brelse(dbuf);
    800043a8:	8526                	mv	a0,s1
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	074080e7          	jalr	116(ra) # 8000341e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043b2:	2a05                	addiw	s4,s4,1
    800043b4:	0a91                	addi	s5,s5,4
    800043b6:	02c9a783          	lw	a5,44(s3)
    800043ba:	04fa5e63          	bge	s4,a5,80004416 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043be:	0189a583          	lw	a1,24(s3)
    800043c2:	014585bb          	addw	a1,a1,s4
    800043c6:	2585                	addiw	a1,a1,1
    800043c8:	0289a503          	lw	a0,40(s3)
    800043cc:	fffff097          	auipc	ra,0xfffff
    800043d0:	f22080e7          	jalr	-222(ra) # 800032ee <bread>
    800043d4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043d6:	000aa583          	lw	a1,0(s5)
    800043da:	0289a503          	lw	a0,40(s3)
    800043de:	fffff097          	auipc	ra,0xfffff
    800043e2:	f10080e7          	jalr	-240(ra) # 800032ee <bread>
    800043e6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043e8:	40000613          	li	a2,1024
    800043ec:	05890593          	addi	a1,s2,88
    800043f0:	05850513          	addi	a0,a0,88
    800043f4:	ffffd097          	auipc	ra,0xffffd
    800043f8:	a02080e7          	jalr	-1534(ra) # 80000df6 <memmove>
    bwrite(dbuf);  // write dst to disk
    800043fc:	8526                	mv	a0,s1
    800043fe:	fffff097          	auipc	ra,0xfffff
    80004402:	fe2080e7          	jalr	-30(ra) # 800033e0 <bwrite>
    if(recovering == 0)
    80004406:	f80b1ce3          	bnez	s6,8000439e <install_trans+0x36>
      bunpin(dbuf);
    8000440a:	8526                	mv	a0,s1
    8000440c:	fffff097          	auipc	ra,0xfffff
    80004410:	0ec080e7          	jalr	236(ra) # 800034f8 <bunpin>
    80004414:	b769                	j	8000439e <install_trans+0x36>
}
    80004416:	70e2                	ld	ra,56(sp)
    80004418:	7442                	ld	s0,48(sp)
    8000441a:	74a2                	ld	s1,40(sp)
    8000441c:	7902                	ld	s2,32(sp)
    8000441e:	69e2                	ld	s3,24(sp)
    80004420:	6a42                	ld	s4,16(sp)
    80004422:	6aa2                	ld	s5,8(sp)
    80004424:	6b02                	ld	s6,0(sp)
    80004426:	6121                	addi	sp,sp,64
    80004428:	8082                	ret
    8000442a:	8082                	ret

000000008000442c <initlog>:
{
    8000442c:	7179                	addi	sp,sp,-48
    8000442e:	f406                	sd	ra,40(sp)
    80004430:	f022                	sd	s0,32(sp)
    80004432:	ec26                	sd	s1,24(sp)
    80004434:	e84a                	sd	s2,16(sp)
    80004436:	e44e                	sd	s3,8(sp)
    80004438:	1800                	addi	s0,sp,48
    8000443a:	892a                	mv	s2,a0
    8000443c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000443e:	0001d497          	auipc	s1,0x1d
    80004442:	86248493          	addi	s1,s1,-1950 # 80020ca0 <log>
    80004446:	00004597          	auipc	a1,0x4
    8000444a:	31a58593          	addi	a1,a1,794 # 80008760 <syscalls+0x200>
    8000444e:	8526                	mv	a0,s1
    80004450:	ffffc097          	auipc	ra,0xffffc
    80004454:	7be080e7          	jalr	1982(ra) # 80000c0e <initlock>
  log.start = sb->logstart;
    80004458:	0149a583          	lw	a1,20(s3)
    8000445c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000445e:	0109a783          	lw	a5,16(s3)
    80004462:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004464:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004468:	854a                	mv	a0,s2
    8000446a:	fffff097          	auipc	ra,0xfffff
    8000446e:	e84080e7          	jalr	-380(ra) # 800032ee <bread>
  log.lh.n = lh->n;
    80004472:	4d34                	lw	a3,88(a0)
    80004474:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004476:	02d05663          	blez	a3,800044a2 <initlog+0x76>
    8000447a:	05c50793          	addi	a5,a0,92
    8000447e:	0001d717          	auipc	a4,0x1d
    80004482:	85270713          	addi	a4,a4,-1966 # 80020cd0 <log+0x30>
    80004486:	36fd                	addiw	a3,a3,-1
    80004488:	02069613          	slli	a2,a3,0x20
    8000448c:	01e65693          	srli	a3,a2,0x1e
    80004490:	06050613          	addi	a2,a0,96
    80004494:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004496:	4390                	lw	a2,0(a5)
    80004498:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000449a:	0791                	addi	a5,a5,4
    8000449c:	0711                	addi	a4,a4,4
    8000449e:	fed79ce3          	bne	a5,a3,80004496 <initlog+0x6a>
  brelse(buf);
    800044a2:	fffff097          	auipc	ra,0xfffff
    800044a6:	f7c080e7          	jalr	-132(ra) # 8000341e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044aa:	4505                	li	a0,1
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	ebc080e7          	jalr	-324(ra) # 80004368 <install_trans>
  log.lh.n = 0;
    800044b4:	0001d797          	auipc	a5,0x1d
    800044b8:	8007ac23          	sw	zero,-2024(a5) # 80020ccc <log+0x2c>
  write_head(); // clear the log
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	e30080e7          	jalr	-464(ra) # 800042ec <write_head>
}
    800044c4:	70a2                	ld	ra,40(sp)
    800044c6:	7402                	ld	s0,32(sp)
    800044c8:	64e2                	ld	s1,24(sp)
    800044ca:	6942                	ld	s2,16(sp)
    800044cc:	69a2                	ld	s3,8(sp)
    800044ce:	6145                	addi	sp,sp,48
    800044d0:	8082                	ret

00000000800044d2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044d2:	1101                	addi	sp,sp,-32
    800044d4:	ec06                	sd	ra,24(sp)
    800044d6:	e822                	sd	s0,16(sp)
    800044d8:	e426                	sd	s1,8(sp)
    800044da:	e04a                	sd	s2,0(sp)
    800044dc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044de:	0001c517          	auipc	a0,0x1c
    800044e2:	7c250513          	addi	a0,a0,1986 # 80020ca0 <log>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	7b8080e7          	jalr	1976(ra) # 80000c9e <acquire>
  while(1){
    if(log.committing){
    800044ee:	0001c497          	auipc	s1,0x1c
    800044f2:	7b248493          	addi	s1,s1,1970 # 80020ca0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044f6:	4979                	li	s2,30
    800044f8:	a039                	j	80004506 <begin_op+0x34>
      sleep(&log, &log.lock);
    800044fa:	85a6                	mv	a1,s1
    800044fc:	8526                	mv	a0,s1
    800044fe:	ffffe097          	auipc	ra,0xffffe
    80004502:	ddc080e7          	jalr	-548(ra) # 800022da <sleep>
    if(log.committing){
    80004506:	50dc                	lw	a5,36(s1)
    80004508:	fbed                	bnez	a5,800044fa <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000450a:	5098                	lw	a4,32(s1)
    8000450c:	2705                	addiw	a4,a4,1
    8000450e:	0007069b          	sext.w	a3,a4
    80004512:	0027179b          	slliw	a5,a4,0x2
    80004516:	9fb9                	addw	a5,a5,a4
    80004518:	0017979b          	slliw	a5,a5,0x1
    8000451c:	54d8                	lw	a4,44(s1)
    8000451e:	9fb9                	addw	a5,a5,a4
    80004520:	00f95963          	bge	s2,a5,80004532 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004524:	85a6                	mv	a1,s1
    80004526:	8526                	mv	a0,s1
    80004528:	ffffe097          	auipc	ra,0xffffe
    8000452c:	db2080e7          	jalr	-590(ra) # 800022da <sleep>
    80004530:	bfd9                	j	80004506 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004532:	0001c517          	auipc	a0,0x1c
    80004536:	76e50513          	addi	a0,a0,1902 # 80020ca0 <log>
    8000453a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000453c:	ffffd097          	auipc	ra,0xffffd
    80004540:	816080e7          	jalr	-2026(ra) # 80000d52 <release>
      break;
    }
  }
}
    80004544:	60e2                	ld	ra,24(sp)
    80004546:	6442                	ld	s0,16(sp)
    80004548:	64a2                	ld	s1,8(sp)
    8000454a:	6902                	ld	s2,0(sp)
    8000454c:	6105                	addi	sp,sp,32
    8000454e:	8082                	ret

0000000080004550 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004550:	7139                	addi	sp,sp,-64
    80004552:	fc06                	sd	ra,56(sp)
    80004554:	f822                	sd	s0,48(sp)
    80004556:	f426                	sd	s1,40(sp)
    80004558:	f04a                	sd	s2,32(sp)
    8000455a:	ec4e                	sd	s3,24(sp)
    8000455c:	e852                	sd	s4,16(sp)
    8000455e:	e456                	sd	s5,8(sp)
    80004560:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004562:	0001c497          	auipc	s1,0x1c
    80004566:	73e48493          	addi	s1,s1,1854 # 80020ca0 <log>
    8000456a:	8526                	mv	a0,s1
    8000456c:	ffffc097          	auipc	ra,0xffffc
    80004570:	732080e7          	jalr	1842(ra) # 80000c9e <acquire>
  log.outstanding -= 1;
    80004574:	509c                	lw	a5,32(s1)
    80004576:	37fd                	addiw	a5,a5,-1
    80004578:	0007891b          	sext.w	s2,a5
    8000457c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000457e:	50dc                	lw	a5,36(s1)
    80004580:	e7b9                	bnez	a5,800045ce <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004582:	04091e63          	bnez	s2,800045de <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004586:	0001c497          	auipc	s1,0x1c
    8000458a:	71a48493          	addi	s1,s1,1818 # 80020ca0 <log>
    8000458e:	4785                	li	a5,1
    80004590:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004592:	8526                	mv	a0,s1
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	7be080e7          	jalr	1982(ra) # 80000d52 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000459c:	54dc                	lw	a5,44(s1)
    8000459e:	06f04763          	bgtz	a5,8000460c <end_op+0xbc>
    acquire(&log.lock);
    800045a2:	0001c497          	auipc	s1,0x1c
    800045a6:	6fe48493          	addi	s1,s1,1790 # 80020ca0 <log>
    800045aa:	8526                	mv	a0,s1
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	6f2080e7          	jalr	1778(ra) # 80000c9e <acquire>
    log.committing = 0;
    800045b4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800045b8:	8526                	mv	a0,s1
    800045ba:	ffffe097          	auipc	ra,0xffffe
    800045be:	d84080e7          	jalr	-636(ra) # 8000233e <wakeup>
    release(&log.lock);
    800045c2:	8526                	mv	a0,s1
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	78e080e7          	jalr	1934(ra) # 80000d52 <release>
}
    800045cc:	a03d                	j	800045fa <end_op+0xaa>
    panic("log.committing");
    800045ce:	00004517          	auipc	a0,0x4
    800045d2:	19a50513          	addi	a0,a0,410 # 80008768 <syscalls+0x208>
    800045d6:	ffffc097          	auipc	ra,0xffffc
    800045da:	f6a080e7          	jalr	-150(ra) # 80000540 <panic>
    wakeup(&log);
    800045de:	0001c497          	auipc	s1,0x1c
    800045e2:	6c248493          	addi	s1,s1,1730 # 80020ca0 <log>
    800045e6:	8526                	mv	a0,s1
    800045e8:	ffffe097          	auipc	ra,0xffffe
    800045ec:	d56080e7          	jalr	-682(ra) # 8000233e <wakeup>
  release(&log.lock);
    800045f0:	8526                	mv	a0,s1
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	760080e7          	jalr	1888(ra) # 80000d52 <release>
}
    800045fa:	70e2                	ld	ra,56(sp)
    800045fc:	7442                	ld	s0,48(sp)
    800045fe:	74a2                	ld	s1,40(sp)
    80004600:	7902                	ld	s2,32(sp)
    80004602:	69e2                	ld	s3,24(sp)
    80004604:	6a42                	ld	s4,16(sp)
    80004606:	6aa2                	ld	s5,8(sp)
    80004608:	6121                	addi	sp,sp,64
    8000460a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000460c:	0001ca97          	auipc	s5,0x1c
    80004610:	6c4a8a93          	addi	s5,s5,1732 # 80020cd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004614:	0001ca17          	auipc	s4,0x1c
    80004618:	68ca0a13          	addi	s4,s4,1676 # 80020ca0 <log>
    8000461c:	018a2583          	lw	a1,24(s4)
    80004620:	012585bb          	addw	a1,a1,s2
    80004624:	2585                	addiw	a1,a1,1
    80004626:	028a2503          	lw	a0,40(s4)
    8000462a:	fffff097          	auipc	ra,0xfffff
    8000462e:	cc4080e7          	jalr	-828(ra) # 800032ee <bread>
    80004632:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004634:	000aa583          	lw	a1,0(s5)
    80004638:	028a2503          	lw	a0,40(s4)
    8000463c:	fffff097          	auipc	ra,0xfffff
    80004640:	cb2080e7          	jalr	-846(ra) # 800032ee <bread>
    80004644:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004646:	40000613          	li	a2,1024
    8000464a:	05850593          	addi	a1,a0,88
    8000464e:	05848513          	addi	a0,s1,88
    80004652:	ffffc097          	auipc	ra,0xffffc
    80004656:	7a4080e7          	jalr	1956(ra) # 80000df6 <memmove>
    bwrite(to);  // write the log
    8000465a:	8526                	mv	a0,s1
    8000465c:	fffff097          	auipc	ra,0xfffff
    80004660:	d84080e7          	jalr	-636(ra) # 800033e0 <bwrite>
    brelse(from);
    80004664:	854e                	mv	a0,s3
    80004666:	fffff097          	auipc	ra,0xfffff
    8000466a:	db8080e7          	jalr	-584(ra) # 8000341e <brelse>
    brelse(to);
    8000466e:	8526                	mv	a0,s1
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	dae080e7          	jalr	-594(ra) # 8000341e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004678:	2905                	addiw	s2,s2,1
    8000467a:	0a91                	addi	s5,s5,4
    8000467c:	02ca2783          	lw	a5,44(s4)
    80004680:	f8f94ee3          	blt	s2,a5,8000461c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004684:	00000097          	auipc	ra,0x0
    80004688:	c68080e7          	jalr	-920(ra) # 800042ec <write_head>
    install_trans(0); // Now install writes to home locations
    8000468c:	4501                	li	a0,0
    8000468e:	00000097          	auipc	ra,0x0
    80004692:	cda080e7          	jalr	-806(ra) # 80004368 <install_trans>
    log.lh.n = 0;
    80004696:	0001c797          	auipc	a5,0x1c
    8000469a:	6207ab23          	sw	zero,1590(a5) # 80020ccc <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000469e:	00000097          	auipc	ra,0x0
    800046a2:	c4e080e7          	jalr	-946(ra) # 800042ec <write_head>
    800046a6:	bdf5                	j	800045a2 <end_op+0x52>

00000000800046a8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800046a8:	1101                	addi	sp,sp,-32
    800046aa:	ec06                	sd	ra,24(sp)
    800046ac:	e822                	sd	s0,16(sp)
    800046ae:	e426                	sd	s1,8(sp)
    800046b0:	e04a                	sd	s2,0(sp)
    800046b2:	1000                	addi	s0,sp,32
    800046b4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046b6:	0001c917          	auipc	s2,0x1c
    800046ba:	5ea90913          	addi	s2,s2,1514 # 80020ca0 <log>
    800046be:	854a                	mv	a0,s2
    800046c0:	ffffc097          	auipc	ra,0xffffc
    800046c4:	5de080e7          	jalr	1502(ra) # 80000c9e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800046c8:	02c92603          	lw	a2,44(s2)
    800046cc:	47f5                	li	a5,29
    800046ce:	06c7c563          	blt	a5,a2,80004738 <log_write+0x90>
    800046d2:	0001c797          	auipc	a5,0x1c
    800046d6:	5ea7a783          	lw	a5,1514(a5) # 80020cbc <log+0x1c>
    800046da:	37fd                	addiw	a5,a5,-1
    800046dc:	04f65e63          	bge	a2,a5,80004738 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046e0:	0001c797          	auipc	a5,0x1c
    800046e4:	5e07a783          	lw	a5,1504(a5) # 80020cc0 <log+0x20>
    800046e8:	06f05063          	blez	a5,80004748 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046ec:	4781                	li	a5,0
    800046ee:	06c05563          	blez	a2,80004758 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046f2:	44cc                	lw	a1,12(s1)
    800046f4:	0001c717          	auipc	a4,0x1c
    800046f8:	5dc70713          	addi	a4,a4,1500 # 80020cd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046fc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046fe:	4314                	lw	a3,0(a4)
    80004700:	04b68c63          	beq	a3,a1,80004758 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004704:	2785                	addiw	a5,a5,1
    80004706:	0711                	addi	a4,a4,4
    80004708:	fef61be3          	bne	a2,a5,800046fe <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000470c:	0621                	addi	a2,a2,8
    8000470e:	060a                	slli	a2,a2,0x2
    80004710:	0001c797          	auipc	a5,0x1c
    80004714:	59078793          	addi	a5,a5,1424 # 80020ca0 <log>
    80004718:	97b2                	add	a5,a5,a2
    8000471a:	44d8                	lw	a4,12(s1)
    8000471c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000471e:	8526                	mv	a0,s1
    80004720:	fffff097          	auipc	ra,0xfffff
    80004724:	d9c080e7          	jalr	-612(ra) # 800034bc <bpin>
    log.lh.n++;
    80004728:	0001c717          	auipc	a4,0x1c
    8000472c:	57870713          	addi	a4,a4,1400 # 80020ca0 <log>
    80004730:	575c                	lw	a5,44(a4)
    80004732:	2785                	addiw	a5,a5,1
    80004734:	d75c                	sw	a5,44(a4)
    80004736:	a82d                	j	80004770 <log_write+0xc8>
    panic("too big a transaction");
    80004738:	00004517          	auipc	a0,0x4
    8000473c:	04050513          	addi	a0,a0,64 # 80008778 <syscalls+0x218>
    80004740:	ffffc097          	auipc	ra,0xffffc
    80004744:	e00080e7          	jalr	-512(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004748:	00004517          	auipc	a0,0x4
    8000474c:	04850513          	addi	a0,a0,72 # 80008790 <syscalls+0x230>
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	df0080e7          	jalr	-528(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004758:	00878693          	addi	a3,a5,8
    8000475c:	068a                	slli	a3,a3,0x2
    8000475e:	0001c717          	auipc	a4,0x1c
    80004762:	54270713          	addi	a4,a4,1346 # 80020ca0 <log>
    80004766:	9736                	add	a4,a4,a3
    80004768:	44d4                	lw	a3,12(s1)
    8000476a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000476c:	faf609e3          	beq	a2,a5,8000471e <log_write+0x76>
  }
  release(&log.lock);
    80004770:	0001c517          	auipc	a0,0x1c
    80004774:	53050513          	addi	a0,a0,1328 # 80020ca0 <log>
    80004778:	ffffc097          	auipc	ra,0xffffc
    8000477c:	5da080e7          	jalr	1498(ra) # 80000d52 <release>
}
    80004780:	60e2                	ld	ra,24(sp)
    80004782:	6442                	ld	s0,16(sp)
    80004784:	64a2                	ld	s1,8(sp)
    80004786:	6902                	ld	s2,0(sp)
    80004788:	6105                	addi	sp,sp,32
    8000478a:	8082                	ret

000000008000478c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000478c:	1101                	addi	sp,sp,-32
    8000478e:	ec06                	sd	ra,24(sp)
    80004790:	e822                	sd	s0,16(sp)
    80004792:	e426                	sd	s1,8(sp)
    80004794:	e04a                	sd	s2,0(sp)
    80004796:	1000                	addi	s0,sp,32
    80004798:	84aa                	mv	s1,a0
    8000479a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000479c:	00004597          	auipc	a1,0x4
    800047a0:	01458593          	addi	a1,a1,20 # 800087b0 <syscalls+0x250>
    800047a4:	0521                	addi	a0,a0,8
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	468080e7          	jalr	1128(ra) # 80000c0e <initlock>
  lk->name = name;
    800047ae:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047b2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047b6:	0204a423          	sw	zero,40(s1)
}
    800047ba:	60e2                	ld	ra,24(sp)
    800047bc:	6442                	ld	s0,16(sp)
    800047be:	64a2                	ld	s1,8(sp)
    800047c0:	6902                	ld	s2,0(sp)
    800047c2:	6105                	addi	sp,sp,32
    800047c4:	8082                	ret

00000000800047c6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800047c6:	1101                	addi	sp,sp,-32
    800047c8:	ec06                	sd	ra,24(sp)
    800047ca:	e822                	sd	s0,16(sp)
    800047cc:	e426                	sd	s1,8(sp)
    800047ce:	e04a                	sd	s2,0(sp)
    800047d0:	1000                	addi	s0,sp,32
    800047d2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047d4:	00850913          	addi	s2,a0,8
    800047d8:	854a                	mv	a0,s2
    800047da:	ffffc097          	auipc	ra,0xffffc
    800047de:	4c4080e7          	jalr	1220(ra) # 80000c9e <acquire>
  while (lk->locked) {
    800047e2:	409c                	lw	a5,0(s1)
    800047e4:	cb89                	beqz	a5,800047f6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047e6:	85ca                	mv	a1,s2
    800047e8:	8526                	mv	a0,s1
    800047ea:	ffffe097          	auipc	ra,0xffffe
    800047ee:	af0080e7          	jalr	-1296(ra) # 800022da <sleep>
  while (lk->locked) {
    800047f2:	409c                	lw	a5,0(s1)
    800047f4:	fbed                	bnez	a5,800047e6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047f6:	4785                	li	a5,1
    800047f8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047fa:	ffffd097          	auipc	ra,0xffffd
    800047fe:	378080e7          	jalr	888(ra) # 80001b72 <myproc>
    80004802:	591c                	lw	a5,48(a0)
    80004804:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004806:	854a                	mv	a0,s2
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	54a080e7          	jalr	1354(ra) # 80000d52 <release>
}
    80004810:	60e2                	ld	ra,24(sp)
    80004812:	6442                	ld	s0,16(sp)
    80004814:	64a2                	ld	s1,8(sp)
    80004816:	6902                	ld	s2,0(sp)
    80004818:	6105                	addi	sp,sp,32
    8000481a:	8082                	ret

000000008000481c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000481c:	1101                	addi	sp,sp,-32
    8000481e:	ec06                	sd	ra,24(sp)
    80004820:	e822                	sd	s0,16(sp)
    80004822:	e426                	sd	s1,8(sp)
    80004824:	e04a                	sd	s2,0(sp)
    80004826:	1000                	addi	s0,sp,32
    80004828:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000482a:	00850913          	addi	s2,a0,8
    8000482e:	854a                	mv	a0,s2
    80004830:	ffffc097          	auipc	ra,0xffffc
    80004834:	46e080e7          	jalr	1134(ra) # 80000c9e <acquire>
  lk->locked = 0;
    80004838:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000483c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004840:	8526                	mv	a0,s1
    80004842:	ffffe097          	auipc	ra,0xffffe
    80004846:	afc080e7          	jalr	-1284(ra) # 8000233e <wakeup>
  release(&lk->lk);
    8000484a:	854a                	mv	a0,s2
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	506080e7          	jalr	1286(ra) # 80000d52 <release>
}
    80004854:	60e2                	ld	ra,24(sp)
    80004856:	6442                	ld	s0,16(sp)
    80004858:	64a2                	ld	s1,8(sp)
    8000485a:	6902                	ld	s2,0(sp)
    8000485c:	6105                	addi	sp,sp,32
    8000485e:	8082                	ret

0000000080004860 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004860:	7179                	addi	sp,sp,-48
    80004862:	f406                	sd	ra,40(sp)
    80004864:	f022                	sd	s0,32(sp)
    80004866:	ec26                	sd	s1,24(sp)
    80004868:	e84a                	sd	s2,16(sp)
    8000486a:	e44e                	sd	s3,8(sp)
    8000486c:	1800                	addi	s0,sp,48
    8000486e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004870:	00850913          	addi	s2,a0,8
    80004874:	854a                	mv	a0,s2
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	428080e7          	jalr	1064(ra) # 80000c9e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000487e:	409c                	lw	a5,0(s1)
    80004880:	ef99                	bnez	a5,8000489e <holdingsleep+0x3e>
    80004882:	4481                	li	s1,0
  release(&lk->lk);
    80004884:	854a                	mv	a0,s2
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	4cc080e7          	jalr	1228(ra) # 80000d52 <release>
  return r;
}
    8000488e:	8526                	mv	a0,s1
    80004890:	70a2                	ld	ra,40(sp)
    80004892:	7402                	ld	s0,32(sp)
    80004894:	64e2                	ld	s1,24(sp)
    80004896:	6942                	ld	s2,16(sp)
    80004898:	69a2                	ld	s3,8(sp)
    8000489a:	6145                	addi	sp,sp,48
    8000489c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000489e:	0284a983          	lw	s3,40(s1)
    800048a2:	ffffd097          	auipc	ra,0xffffd
    800048a6:	2d0080e7          	jalr	720(ra) # 80001b72 <myproc>
    800048aa:	5904                	lw	s1,48(a0)
    800048ac:	413484b3          	sub	s1,s1,s3
    800048b0:	0014b493          	seqz	s1,s1
    800048b4:	bfc1                	j	80004884 <holdingsleep+0x24>

00000000800048b6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048b6:	1141                	addi	sp,sp,-16
    800048b8:	e406                	sd	ra,8(sp)
    800048ba:	e022                	sd	s0,0(sp)
    800048bc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048be:	00004597          	auipc	a1,0x4
    800048c2:	f0258593          	addi	a1,a1,-254 # 800087c0 <syscalls+0x260>
    800048c6:	0001c517          	auipc	a0,0x1c
    800048ca:	52250513          	addi	a0,a0,1314 # 80020de8 <ftable>
    800048ce:	ffffc097          	auipc	ra,0xffffc
    800048d2:	340080e7          	jalr	832(ra) # 80000c0e <initlock>
}
    800048d6:	60a2                	ld	ra,8(sp)
    800048d8:	6402                	ld	s0,0(sp)
    800048da:	0141                	addi	sp,sp,16
    800048dc:	8082                	ret

00000000800048de <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048de:	1101                	addi	sp,sp,-32
    800048e0:	ec06                	sd	ra,24(sp)
    800048e2:	e822                	sd	s0,16(sp)
    800048e4:	e426                	sd	s1,8(sp)
    800048e6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048e8:	0001c517          	auipc	a0,0x1c
    800048ec:	50050513          	addi	a0,a0,1280 # 80020de8 <ftable>
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	3ae080e7          	jalr	942(ra) # 80000c9e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048f8:	0001c497          	auipc	s1,0x1c
    800048fc:	50848493          	addi	s1,s1,1288 # 80020e00 <ftable+0x18>
    80004900:	0001d717          	auipc	a4,0x1d
    80004904:	4a070713          	addi	a4,a4,1184 # 80021da0 <disk>
    if(f->ref == 0){
    80004908:	40dc                	lw	a5,4(s1)
    8000490a:	cf99                	beqz	a5,80004928 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000490c:	02848493          	addi	s1,s1,40
    80004910:	fee49ce3          	bne	s1,a4,80004908 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004914:	0001c517          	auipc	a0,0x1c
    80004918:	4d450513          	addi	a0,a0,1236 # 80020de8 <ftable>
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	436080e7          	jalr	1078(ra) # 80000d52 <release>
  return 0;
    80004924:	4481                	li	s1,0
    80004926:	a819                	j	8000493c <filealloc+0x5e>
      f->ref = 1;
    80004928:	4785                	li	a5,1
    8000492a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000492c:	0001c517          	auipc	a0,0x1c
    80004930:	4bc50513          	addi	a0,a0,1212 # 80020de8 <ftable>
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	41e080e7          	jalr	1054(ra) # 80000d52 <release>
}
    8000493c:	8526                	mv	a0,s1
    8000493e:	60e2                	ld	ra,24(sp)
    80004940:	6442                	ld	s0,16(sp)
    80004942:	64a2                	ld	s1,8(sp)
    80004944:	6105                	addi	sp,sp,32
    80004946:	8082                	ret

0000000080004948 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004948:	1101                	addi	sp,sp,-32
    8000494a:	ec06                	sd	ra,24(sp)
    8000494c:	e822                	sd	s0,16(sp)
    8000494e:	e426                	sd	s1,8(sp)
    80004950:	1000                	addi	s0,sp,32
    80004952:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004954:	0001c517          	auipc	a0,0x1c
    80004958:	49450513          	addi	a0,a0,1172 # 80020de8 <ftable>
    8000495c:	ffffc097          	auipc	ra,0xffffc
    80004960:	342080e7          	jalr	834(ra) # 80000c9e <acquire>
  if(f->ref < 1)
    80004964:	40dc                	lw	a5,4(s1)
    80004966:	02f05263          	blez	a5,8000498a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000496a:	2785                	addiw	a5,a5,1
    8000496c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000496e:	0001c517          	auipc	a0,0x1c
    80004972:	47a50513          	addi	a0,a0,1146 # 80020de8 <ftable>
    80004976:	ffffc097          	auipc	ra,0xffffc
    8000497a:	3dc080e7          	jalr	988(ra) # 80000d52 <release>
  return f;
}
    8000497e:	8526                	mv	a0,s1
    80004980:	60e2                	ld	ra,24(sp)
    80004982:	6442                	ld	s0,16(sp)
    80004984:	64a2                	ld	s1,8(sp)
    80004986:	6105                	addi	sp,sp,32
    80004988:	8082                	ret
    panic("filedup");
    8000498a:	00004517          	auipc	a0,0x4
    8000498e:	e3e50513          	addi	a0,a0,-450 # 800087c8 <syscalls+0x268>
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	bae080e7          	jalr	-1106(ra) # 80000540 <panic>

000000008000499a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000499a:	7139                	addi	sp,sp,-64
    8000499c:	fc06                	sd	ra,56(sp)
    8000499e:	f822                	sd	s0,48(sp)
    800049a0:	f426                	sd	s1,40(sp)
    800049a2:	f04a                	sd	s2,32(sp)
    800049a4:	ec4e                	sd	s3,24(sp)
    800049a6:	e852                	sd	s4,16(sp)
    800049a8:	e456                	sd	s5,8(sp)
    800049aa:	0080                	addi	s0,sp,64
    800049ac:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800049ae:	0001c517          	auipc	a0,0x1c
    800049b2:	43a50513          	addi	a0,a0,1082 # 80020de8 <ftable>
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	2e8080e7          	jalr	744(ra) # 80000c9e <acquire>
  if(f->ref < 1)
    800049be:	40dc                	lw	a5,4(s1)
    800049c0:	06f05163          	blez	a5,80004a22 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800049c4:	37fd                	addiw	a5,a5,-1
    800049c6:	0007871b          	sext.w	a4,a5
    800049ca:	c0dc                	sw	a5,4(s1)
    800049cc:	06e04363          	bgtz	a4,80004a32 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049d0:	0004a903          	lw	s2,0(s1)
    800049d4:	0094ca83          	lbu	s5,9(s1)
    800049d8:	0104ba03          	ld	s4,16(s1)
    800049dc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049e0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049e4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049e8:	0001c517          	auipc	a0,0x1c
    800049ec:	40050513          	addi	a0,a0,1024 # 80020de8 <ftable>
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	362080e7          	jalr	866(ra) # 80000d52 <release>

  if(ff.type == FD_PIPE){
    800049f8:	4785                	li	a5,1
    800049fa:	04f90d63          	beq	s2,a5,80004a54 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049fe:	3979                	addiw	s2,s2,-2
    80004a00:	4785                	li	a5,1
    80004a02:	0527e063          	bltu	a5,s2,80004a42 <fileclose+0xa8>
    begin_op();
    80004a06:	00000097          	auipc	ra,0x0
    80004a0a:	acc080e7          	jalr	-1332(ra) # 800044d2 <begin_op>
    iput(ff.ip);
    80004a0e:	854e                	mv	a0,s3
    80004a10:	fffff097          	auipc	ra,0xfffff
    80004a14:	2b0080e7          	jalr	688(ra) # 80003cc0 <iput>
    end_op();
    80004a18:	00000097          	auipc	ra,0x0
    80004a1c:	b38080e7          	jalr	-1224(ra) # 80004550 <end_op>
    80004a20:	a00d                	j	80004a42 <fileclose+0xa8>
    panic("fileclose");
    80004a22:	00004517          	auipc	a0,0x4
    80004a26:	dae50513          	addi	a0,a0,-594 # 800087d0 <syscalls+0x270>
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	b16080e7          	jalr	-1258(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004a32:	0001c517          	auipc	a0,0x1c
    80004a36:	3b650513          	addi	a0,a0,950 # 80020de8 <ftable>
    80004a3a:	ffffc097          	auipc	ra,0xffffc
    80004a3e:	318080e7          	jalr	792(ra) # 80000d52 <release>
  }
}
    80004a42:	70e2                	ld	ra,56(sp)
    80004a44:	7442                	ld	s0,48(sp)
    80004a46:	74a2                	ld	s1,40(sp)
    80004a48:	7902                	ld	s2,32(sp)
    80004a4a:	69e2                	ld	s3,24(sp)
    80004a4c:	6a42                	ld	s4,16(sp)
    80004a4e:	6aa2                	ld	s5,8(sp)
    80004a50:	6121                	addi	sp,sp,64
    80004a52:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a54:	85d6                	mv	a1,s5
    80004a56:	8552                	mv	a0,s4
    80004a58:	00000097          	auipc	ra,0x0
    80004a5c:	34c080e7          	jalr	844(ra) # 80004da4 <pipeclose>
    80004a60:	b7cd                	j	80004a42 <fileclose+0xa8>

0000000080004a62 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a62:	715d                	addi	sp,sp,-80
    80004a64:	e486                	sd	ra,72(sp)
    80004a66:	e0a2                	sd	s0,64(sp)
    80004a68:	fc26                	sd	s1,56(sp)
    80004a6a:	f84a                	sd	s2,48(sp)
    80004a6c:	f44e                	sd	s3,40(sp)
    80004a6e:	0880                	addi	s0,sp,80
    80004a70:	84aa                	mv	s1,a0
    80004a72:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a74:	ffffd097          	auipc	ra,0xffffd
    80004a78:	0fe080e7          	jalr	254(ra) # 80001b72 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a7c:	409c                	lw	a5,0(s1)
    80004a7e:	37f9                	addiw	a5,a5,-2
    80004a80:	4705                	li	a4,1
    80004a82:	04f76763          	bltu	a4,a5,80004ad0 <filestat+0x6e>
    80004a86:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a88:	6c88                	ld	a0,24(s1)
    80004a8a:	fffff097          	auipc	ra,0xfffff
    80004a8e:	07c080e7          	jalr	124(ra) # 80003b06 <ilock>
    stati(f->ip, &st);
    80004a92:	fb840593          	addi	a1,s0,-72
    80004a96:	6c88                	ld	a0,24(s1)
    80004a98:	fffff097          	auipc	ra,0xfffff
    80004a9c:	2f8080e7          	jalr	760(ra) # 80003d90 <stati>
    iunlock(f->ip);
    80004aa0:	6c88                	ld	a0,24(s1)
    80004aa2:	fffff097          	auipc	ra,0xfffff
    80004aa6:	126080e7          	jalr	294(ra) # 80003bc8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004aaa:	46e1                	li	a3,24
    80004aac:	fb840613          	addi	a2,s0,-72
    80004ab0:	85ce                	mv	a1,s3
    80004ab2:	05093503          	ld	a0,80(s2)
    80004ab6:	ffffd097          	auipc	ra,0xffffd
    80004aba:	c7e080e7          	jalr	-898(ra) # 80001734 <copyout>
    80004abe:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ac2:	60a6                	ld	ra,72(sp)
    80004ac4:	6406                	ld	s0,64(sp)
    80004ac6:	74e2                	ld	s1,56(sp)
    80004ac8:	7942                	ld	s2,48(sp)
    80004aca:	79a2                	ld	s3,40(sp)
    80004acc:	6161                	addi	sp,sp,80
    80004ace:	8082                	ret
  return -1;
    80004ad0:	557d                	li	a0,-1
    80004ad2:	bfc5                	j	80004ac2 <filestat+0x60>

0000000080004ad4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ad4:	7179                	addi	sp,sp,-48
    80004ad6:	f406                	sd	ra,40(sp)
    80004ad8:	f022                	sd	s0,32(sp)
    80004ada:	ec26                	sd	s1,24(sp)
    80004adc:	e84a                	sd	s2,16(sp)
    80004ade:	e44e                	sd	s3,8(sp)
    80004ae0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004ae2:	00854783          	lbu	a5,8(a0)
    80004ae6:	c3d5                	beqz	a5,80004b8a <fileread+0xb6>
    80004ae8:	84aa                	mv	s1,a0
    80004aea:	89ae                	mv	s3,a1
    80004aec:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004aee:	411c                	lw	a5,0(a0)
    80004af0:	4705                	li	a4,1
    80004af2:	04e78963          	beq	a5,a4,80004b44 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004af6:	470d                	li	a4,3
    80004af8:	04e78d63          	beq	a5,a4,80004b52 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004afc:	4709                	li	a4,2
    80004afe:	06e79e63          	bne	a5,a4,80004b7a <fileread+0xa6>
    ilock(f->ip);
    80004b02:	6d08                	ld	a0,24(a0)
    80004b04:	fffff097          	auipc	ra,0xfffff
    80004b08:	002080e7          	jalr	2(ra) # 80003b06 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b0c:	874a                	mv	a4,s2
    80004b0e:	5094                	lw	a3,32(s1)
    80004b10:	864e                	mv	a2,s3
    80004b12:	4585                	li	a1,1
    80004b14:	6c88                	ld	a0,24(s1)
    80004b16:	fffff097          	auipc	ra,0xfffff
    80004b1a:	2a4080e7          	jalr	676(ra) # 80003dba <readi>
    80004b1e:	892a                	mv	s2,a0
    80004b20:	00a05563          	blez	a0,80004b2a <fileread+0x56>
      f->off += r;
    80004b24:	509c                	lw	a5,32(s1)
    80004b26:	9fa9                	addw	a5,a5,a0
    80004b28:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b2a:	6c88                	ld	a0,24(s1)
    80004b2c:	fffff097          	auipc	ra,0xfffff
    80004b30:	09c080e7          	jalr	156(ra) # 80003bc8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b34:	854a                	mv	a0,s2
    80004b36:	70a2                	ld	ra,40(sp)
    80004b38:	7402                	ld	s0,32(sp)
    80004b3a:	64e2                	ld	s1,24(sp)
    80004b3c:	6942                	ld	s2,16(sp)
    80004b3e:	69a2                	ld	s3,8(sp)
    80004b40:	6145                	addi	sp,sp,48
    80004b42:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b44:	6908                	ld	a0,16(a0)
    80004b46:	00000097          	auipc	ra,0x0
    80004b4a:	3c6080e7          	jalr	966(ra) # 80004f0c <piperead>
    80004b4e:	892a                	mv	s2,a0
    80004b50:	b7d5                	j	80004b34 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b52:	02451783          	lh	a5,36(a0)
    80004b56:	03079693          	slli	a3,a5,0x30
    80004b5a:	92c1                	srli	a3,a3,0x30
    80004b5c:	4725                	li	a4,9
    80004b5e:	02d76863          	bltu	a4,a3,80004b8e <fileread+0xba>
    80004b62:	0792                	slli	a5,a5,0x4
    80004b64:	0001c717          	auipc	a4,0x1c
    80004b68:	1e470713          	addi	a4,a4,484 # 80020d48 <devsw>
    80004b6c:	97ba                	add	a5,a5,a4
    80004b6e:	639c                	ld	a5,0(a5)
    80004b70:	c38d                	beqz	a5,80004b92 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b72:	4505                	li	a0,1
    80004b74:	9782                	jalr	a5
    80004b76:	892a                	mv	s2,a0
    80004b78:	bf75                	j	80004b34 <fileread+0x60>
    panic("fileread");
    80004b7a:	00004517          	auipc	a0,0x4
    80004b7e:	c6650513          	addi	a0,a0,-922 # 800087e0 <syscalls+0x280>
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	9be080e7          	jalr	-1602(ra) # 80000540 <panic>
    return -1;
    80004b8a:	597d                	li	s2,-1
    80004b8c:	b765                	j	80004b34 <fileread+0x60>
      return -1;
    80004b8e:	597d                	li	s2,-1
    80004b90:	b755                	j	80004b34 <fileread+0x60>
    80004b92:	597d                	li	s2,-1
    80004b94:	b745                	j	80004b34 <fileread+0x60>

0000000080004b96 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b96:	715d                	addi	sp,sp,-80
    80004b98:	e486                	sd	ra,72(sp)
    80004b9a:	e0a2                	sd	s0,64(sp)
    80004b9c:	fc26                	sd	s1,56(sp)
    80004b9e:	f84a                	sd	s2,48(sp)
    80004ba0:	f44e                	sd	s3,40(sp)
    80004ba2:	f052                	sd	s4,32(sp)
    80004ba4:	ec56                	sd	s5,24(sp)
    80004ba6:	e85a                	sd	s6,16(sp)
    80004ba8:	e45e                	sd	s7,8(sp)
    80004baa:	e062                	sd	s8,0(sp)
    80004bac:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004bae:	00954783          	lbu	a5,9(a0)
    80004bb2:	10078663          	beqz	a5,80004cbe <filewrite+0x128>
    80004bb6:	892a                	mv	s2,a0
    80004bb8:	8b2e                	mv	s6,a1
    80004bba:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bbc:	411c                	lw	a5,0(a0)
    80004bbe:	4705                	li	a4,1
    80004bc0:	02e78263          	beq	a5,a4,80004be4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bc4:	470d                	li	a4,3
    80004bc6:	02e78663          	beq	a5,a4,80004bf2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bca:	4709                	li	a4,2
    80004bcc:	0ee79163          	bne	a5,a4,80004cae <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004bd0:	0ac05d63          	blez	a2,80004c8a <filewrite+0xf4>
    int i = 0;
    80004bd4:	4981                	li	s3,0
    80004bd6:	6b85                	lui	s7,0x1
    80004bd8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004bdc:	6c05                	lui	s8,0x1
    80004bde:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004be2:	a861                	j	80004c7a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004be4:	6908                	ld	a0,16(a0)
    80004be6:	00000097          	auipc	ra,0x0
    80004bea:	22e080e7          	jalr	558(ra) # 80004e14 <pipewrite>
    80004bee:	8a2a                	mv	s4,a0
    80004bf0:	a045                	j	80004c90 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bf2:	02451783          	lh	a5,36(a0)
    80004bf6:	03079693          	slli	a3,a5,0x30
    80004bfa:	92c1                	srli	a3,a3,0x30
    80004bfc:	4725                	li	a4,9
    80004bfe:	0cd76263          	bltu	a4,a3,80004cc2 <filewrite+0x12c>
    80004c02:	0792                	slli	a5,a5,0x4
    80004c04:	0001c717          	auipc	a4,0x1c
    80004c08:	14470713          	addi	a4,a4,324 # 80020d48 <devsw>
    80004c0c:	97ba                	add	a5,a5,a4
    80004c0e:	679c                	ld	a5,8(a5)
    80004c10:	cbdd                	beqz	a5,80004cc6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c12:	4505                	li	a0,1
    80004c14:	9782                	jalr	a5
    80004c16:	8a2a                	mv	s4,a0
    80004c18:	a8a5                	j	80004c90 <filewrite+0xfa>
    80004c1a:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c1e:	00000097          	auipc	ra,0x0
    80004c22:	8b4080e7          	jalr	-1868(ra) # 800044d2 <begin_op>
      ilock(f->ip);
    80004c26:	01893503          	ld	a0,24(s2)
    80004c2a:	fffff097          	auipc	ra,0xfffff
    80004c2e:	edc080e7          	jalr	-292(ra) # 80003b06 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c32:	8756                	mv	a4,s5
    80004c34:	02092683          	lw	a3,32(s2)
    80004c38:	01698633          	add	a2,s3,s6
    80004c3c:	4585                	li	a1,1
    80004c3e:	01893503          	ld	a0,24(s2)
    80004c42:	fffff097          	auipc	ra,0xfffff
    80004c46:	270080e7          	jalr	624(ra) # 80003eb2 <writei>
    80004c4a:	84aa                	mv	s1,a0
    80004c4c:	00a05763          	blez	a0,80004c5a <filewrite+0xc4>
        f->off += r;
    80004c50:	02092783          	lw	a5,32(s2)
    80004c54:	9fa9                	addw	a5,a5,a0
    80004c56:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c5a:	01893503          	ld	a0,24(s2)
    80004c5e:	fffff097          	auipc	ra,0xfffff
    80004c62:	f6a080e7          	jalr	-150(ra) # 80003bc8 <iunlock>
      end_op();
    80004c66:	00000097          	auipc	ra,0x0
    80004c6a:	8ea080e7          	jalr	-1814(ra) # 80004550 <end_op>

      if(r != n1){
    80004c6e:	009a9f63          	bne	s5,s1,80004c8c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c72:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c76:	0149db63          	bge	s3,s4,80004c8c <filewrite+0xf6>
      int n1 = n - i;
    80004c7a:	413a04bb          	subw	s1,s4,s3
    80004c7e:	0004879b          	sext.w	a5,s1
    80004c82:	f8fbdce3          	bge	s7,a5,80004c1a <filewrite+0x84>
    80004c86:	84e2                	mv	s1,s8
    80004c88:	bf49                	j	80004c1a <filewrite+0x84>
    int i = 0;
    80004c8a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c8c:	013a1f63          	bne	s4,s3,80004caa <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c90:	8552                	mv	a0,s4
    80004c92:	60a6                	ld	ra,72(sp)
    80004c94:	6406                	ld	s0,64(sp)
    80004c96:	74e2                	ld	s1,56(sp)
    80004c98:	7942                	ld	s2,48(sp)
    80004c9a:	79a2                	ld	s3,40(sp)
    80004c9c:	7a02                	ld	s4,32(sp)
    80004c9e:	6ae2                	ld	s5,24(sp)
    80004ca0:	6b42                	ld	s6,16(sp)
    80004ca2:	6ba2                	ld	s7,8(sp)
    80004ca4:	6c02                	ld	s8,0(sp)
    80004ca6:	6161                	addi	sp,sp,80
    80004ca8:	8082                	ret
    ret = (i == n ? n : -1);
    80004caa:	5a7d                	li	s4,-1
    80004cac:	b7d5                	j	80004c90 <filewrite+0xfa>
    panic("filewrite");
    80004cae:	00004517          	auipc	a0,0x4
    80004cb2:	b4250513          	addi	a0,a0,-1214 # 800087f0 <syscalls+0x290>
    80004cb6:	ffffc097          	auipc	ra,0xffffc
    80004cba:	88a080e7          	jalr	-1910(ra) # 80000540 <panic>
    return -1;
    80004cbe:	5a7d                	li	s4,-1
    80004cc0:	bfc1                	j	80004c90 <filewrite+0xfa>
      return -1;
    80004cc2:	5a7d                	li	s4,-1
    80004cc4:	b7f1                	j	80004c90 <filewrite+0xfa>
    80004cc6:	5a7d                	li	s4,-1
    80004cc8:	b7e1                	j	80004c90 <filewrite+0xfa>

0000000080004cca <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004cca:	7179                	addi	sp,sp,-48
    80004ccc:	f406                	sd	ra,40(sp)
    80004cce:	f022                	sd	s0,32(sp)
    80004cd0:	ec26                	sd	s1,24(sp)
    80004cd2:	e84a                	sd	s2,16(sp)
    80004cd4:	e44e                	sd	s3,8(sp)
    80004cd6:	e052                	sd	s4,0(sp)
    80004cd8:	1800                	addi	s0,sp,48
    80004cda:	84aa                	mv	s1,a0
    80004cdc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004cde:	0005b023          	sd	zero,0(a1)
    80004ce2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ce6:	00000097          	auipc	ra,0x0
    80004cea:	bf8080e7          	jalr	-1032(ra) # 800048de <filealloc>
    80004cee:	e088                	sd	a0,0(s1)
    80004cf0:	c551                	beqz	a0,80004d7c <pipealloc+0xb2>
    80004cf2:	00000097          	auipc	ra,0x0
    80004cf6:	bec080e7          	jalr	-1044(ra) # 800048de <filealloc>
    80004cfa:	00aa3023          	sd	a0,0(s4)
    80004cfe:	c92d                	beqz	a0,80004d70 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d00:	ffffc097          	auipc	ra,0xffffc
    80004d04:	e62080e7          	jalr	-414(ra) # 80000b62 <kalloc>
    80004d08:	892a                	mv	s2,a0
    80004d0a:	c125                	beqz	a0,80004d6a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d0c:	4985                	li	s3,1
    80004d0e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d12:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d16:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d1a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d1e:	00004597          	auipc	a1,0x4
    80004d22:	ae258593          	addi	a1,a1,-1310 # 80008800 <syscalls+0x2a0>
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	ee8080e7          	jalr	-280(ra) # 80000c0e <initlock>
  (*f0)->type = FD_PIPE;
    80004d2e:	609c                	ld	a5,0(s1)
    80004d30:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d34:	609c                	ld	a5,0(s1)
    80004d36:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d3a:	609c                	ld	a5,0(s1)
    80004d3c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d40:	609c                	ld	a5,0(s1)
    80004d42:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d46:	000a3783          	ld	a5,0(s4)
    80004d4a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d4e:	000a3783          	ld	a5,0(s4)
    80004d52:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d56:	000a3783          	ld	a5,0(s4)
    80004d5a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d5e:	000a3783          	ld	a5,0(s4)
    80004d62:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d66:	4501                	li	a0,0
    80004d68:	a025                	j	80004d90 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d6a:	6088                	ld	a0,0(s1)
    80004d6c:	e501                	bnez	a0,80004d74 <pipealloc+0xaa>
    80004d6e:	a039                	j	80004d7c <pipealloc+0xb2>
    80004d70:	6088                	ld	a0,0(s1)
    80004d72:	c51d                	beqz	a0,80004da0 <pipealloc+0xd6>
    fileclose(*f0);
    80004d74:	00000097          	auipc	ra,0x0
    80004d78:	c26080e7          	jalr	-986(ra) # 8000499a <fileclose>
  if(*f1)
    80004d7c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d80:	557d                	li	a0,-1
  if(*f1)
    80004d82:	c799                	beqz	a5,80004d90 <pipealloc+0xc6>
    fileclose(*f1);
    80004d84:	853e                	mv	a0,a5
    80004d86:	00000097          	auipc	ra,0x0
    80004d8a:	c14080e7          	jalr	-1004(ra) # 8000499a <fileclose>
  return -1;
    80004d8e:	557d                	li	a0,-1
}
    80004d90:	70a2                	ld	ra,40(sp)
    80004d92:	7402                	ld	s0,32(sp)
    80004d94:	64e2                	ld	s1,24(sp)
    80004d96:	6942                	ld	s2,16(sp)
    80004d98:	69a2                	ld	s3,8(sp)
    80004d9a:	6a02                	ld	s4,0(sp)
    80004d9c:	6145                	addi	sp,sp,48
    80004d9e:	8082                	ret
  return -1;
    80004da0:	557d                	li	a0,-1
    80004da2:	b7fd                	j	80004d90 <pipealloc+0xc6>

0000000080004da4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004da4:	1101                	addi	sp,sp,-32
    80004da6:	ec06                	sd	ra,24(sp)
    80004da8:	e822                	sd	s0,16(sp)
    80004daa:	e426                	sd	s1,8(sp)
    80004dac:	e04a                	sd	s2,0(sp)
    80004dae:	1000                	addi	s0,sp,32
    80004db0:	84aa                	mv	s1,a0
    80004db2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004db4:	ffffc097          	auipc	ra,0xffffc
    80004db8:	eea080e7          	jalr	-278(ra) # 80000c9e <acquire>
  if(writable){
    80004dbc:	02090d63          	beqz	s2,80004df6 <pipeclose+0x52>
    pi->writeopen = 0;
    80004dc0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004dc4:	21848513          	addi	a0,s1,536
    80004dc8:	ffffd097          	auipc	ra,0xffffd
    80004dcc:	576080e7          	jalr	1398(ra) # 8000233e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004dd0:	2204b783          	ld	a5,544(s1)
    80004dd4:	eb95                	bnez	a5,80004e08 <pipeclose+0x64>
    release(&pi->lock);
    80004dd6:	8526                	mv	a0,s1
    80004dd8:	ffffc097          	auipc	ra,0xffffc
    80004ddc:	f7a080e7          	jalr	-134(ra) # 80000d52 <release>
    kfree((char*)pi);
    80004de0:	8526                	mv	a0,s1
    80004de2:	ffffc097          	auipc	ra,0xffffc
    80004de6:	c18080e7          	jalr	-1000(ra) # 800009fa <kfree>
  } else
    release(&pi->lock);
}
    80004dea:	60e2                	ld	ra,24(sp)
    80004dec:	6442                	ld	s0,16(sp)
    80004dee:	64a2                	ld	s1,8(sp)
    80004df0:	6902                	ld	s2,0(sp)
    80004df2:	6105                	addi	sp,sp,32
    80004df4:	8082                	ret
    pi->readopen = 0;
    80004df6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004dfa:	21c48513          	addi	a0,s1,540
    80004dfe:	ffffd097          	auipc	ra,0xffffd
    80004e02:	540080e7          	jalr	1344(ra) # 8000233e <wakeup>
    80004e06:	b7e9                	j	80004dd0 <pipeclose+0x2c>
    release(&pi->lock);
    80004e08:	8526                	mv	a0,s1
    80004e0a:	ffffc097          	auipc	ra,0xffffc
    80004e0e:	f48080e7          	jalr	-184(ra) # 80000d52 <release>
}
    80004e12:	bfe1                	j	80004dea <pipeclose+0x46>

0000000080004e14 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e14:	711d                	addi	sp,sp,-96
    80004e16:	ec86                	sd	ra,88(sp)
    80004e18:	e8a2                	sd	s0,80(sp)
    80004e1a:	e4a6                	sd	s1,72(sp)
    80004e1c:	e0ca                	sd	s2,64(sp)
    80004e1e:	fc4e                	sd	s3,56(sp)
    80004e20:	f852                	sd	s4,48(sp)
    80004e22:	f456                	sd	s5,40(sp)
    80004e24:	f05a                	sd	s6,32(sp)
    80004e26:	ec5e                	sd	s7,24(sp)
    80004e28:	e862                	sd	s8,16(sp)
    80004e2a:	1080                	addi	s0,sp,96
    80004e2c:	84aa                	mv	s1,a0
    80004e2e:	8aae                	mv	s5,a1
    80004e30:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e32:	ffffd097          	auipc	ra,0xffffd
    80004e36:	d40080e7          	jalr	-704(ra) # 80001b72 <myproc>
    80004e3a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e3c:	8526                	mv	a0,s1
    80004e3e:	ffffc097          	auipc	ra,0xffffc
    80004e42:	e60080e7          	jalr	-416(ra) # 80000c9e <acquire>
  while(i < n){
    80004e46:	0b405663          	blez	s4,80004ef2 <pipewrite+0xde>
  int i = 0;
    80004e4a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e4c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e4e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e52:	21c48b93          	addi	s7,s1,540
    80004e56:	a089                	j	80004e98 <pipewrite+0x84>
      release(&pi->lock);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	ef8080e7          	jalr	-264(ra) # 80000d52 <release>
      return -1;
    80004e62:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e64:	854a                	mv	a0,s2
    80004e66:	60e6                	ld	ra,88(sp)
    80004e68:	6446                	ld	s0,80(sp)
    80004e6a:	64a6                	ld	s1,72(sp)
    80004e6c:	6906                	ld	s2,64(sp)
    80004e6e:	79e2                	ld	s3,56(sp)
    80004e70:	7a42                	ld	s4,48(sp)
    80004e72:	7aa2                	ld	s5,40(sp)
    80004e74:	7b02                	ld	s6,32(sp)
    80004e76:	6be2                	ld	s7,24(sp)
    80004e78:	6c42                	ld	s8,16(sp)
    80004e7a:	6125                	addi	sp,sp,96
    80004e7c:	8082                	ret
      wakeup(&pi->nread);
    80004e7e:	8562                	mv	a0,s8
    80004e80:	ffffd097          	auipc	ra,0xffffd
    80004e84:	4be080e7          	jalr	1214(ra) # 8000233e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e88:	85a6                	mv	a1,s1
    80004e8a:	855e                	mv	a0,s7
    80004e8c:	ffffd097          	auipc	ra,0xffffd
    80004e90:	44e080e7          	jalr	1102(ra) # 800022da <sleep>
  while(i < n){
    80004e94:	07495063          	bge	s2,s4,80004ef4 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004e98:	2204a783          	lw	a5,544(s1)
    80004e9c:	dfd5                	beqz	a5,80004e58 <pipewrite+0x44>
    80004e9e:	854e                	mv	a0,s3
    80004ea0:	ffffd097          	auipc	ra,0xffffd
    80004ea4:	6e2080e7          	jalr	1762(ra) # 80002582 <killed>
    80004ea8:	f945                	bnez	a0,80004e58 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004eaa:	2184a783          	lw	a5,536(s1)
    80004eae:	21c4a703          	lw	a4,540(s1)
    80004eb2:	2007879b          	addiw	a5,a5,512
    80004eb6:	fcf704e3          	beq	a4,a5,80004e7e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004eba:	4685                	li	a3,1
    80004ebc:	01590633          	add	a2,s2,s5
    80004ec0:	faf40593          	addi	a1,s0,-81
    80004ec4:	0509b503          	ld	a0,80(s3)
    80004ec8:	ffffd097          	auipc	ra,0xffffd
    80004ecc:	8f8080e7          	jalr	-1800(ra) # 800017c0 <copyin>
    80004ed0:	03650263          	beq	a0,s6,80004ef4 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ed4:	21c4a783          	lw	a5,540(s1)
    80004ed8:	0017871b          	addiw	a4,a5,1
    80004edc:	20e4ae23          	sw	a4,540(s1)
    80004ee0:	1ff7f793          	andi	a5,a5,511
    80004ee4:	97a6                	add	a5,a5,s1
    80004ee6:	faf44703          	lbu	a4,-81(s0)
    80004eea:	00e78c23          	sb	a4,24(a5)
      i++;
    80004eee:	2905                	addiw	s2,s2,1
    80004ef0:	b755                	j	80004e94 <pipewrite+0x80>
  int i = 0;
    80004ef2:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ef4:	21848513          	addi	a0,s1,536
    80004ef8:	ffffd097          	auipc	ra,0xffffd
    80004efc:	446080e7          	jalr	1094(ra) # 8000233e <wakeup>
  release(&pi->lock);
    80004f00:	8526                	mv	a0,s1
    80004f02:	ffffc097          	auipc	ra,0xffffc
    80004f06:	e50080e7          	jalr	-432(ra) # 80000d52 <release>
  return i;
    80004f0a:	bfa9                	j	80004e64 <pipewrite+0x50>

0000000080004f0c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f0c:	715d                	addi	sp,sp,-80
    80004f0e:	e486                	sd	ra,72(sp)
    80004f10:	e0a2                	sd	s0,64(sp)
    80004f12:	fc26                	sd	s1,56(sp)
    80004f14:	f84a                	sd	s2,48(sp)
    80004f16:	f44e                	sd	s3,40(sp)
    80004f18:	f052                	sd	s4,32(sp)
    80004f1a:	ec56                	sd	s5,24(sp)
    80004f1c:	e85a                	sd	s6,16(sp)
    80004f1e:	0880                	addi	s0,sp,80
    80004f20:	84aa                	mv	s1,a0
    80004f22:	892e                	mv	s2,a1
    80004f24:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f26:	ffffd097          	auipc	ra,0xffffd
    80004f2a:	c4c080e7          	jalr	-948(ra) # 80001b72 <myproc>
    80004f2e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f30:	8526                	mv	a0,s1
    80004f32:	ffffc097          	auipc	ra,0xffffc
    80004f36:	d6c080e7          	jalr	-660(ra) # 80000c9e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f3a:	2184a703          	lw	a4,536(s1)
    80004f3e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f42:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f46:	02f71763          	bne	a4,a5,80004f74 <piperead+0x68>
    80004f4a:	2244a783          	lw	a5,548(s1)
    80004f4e:	c39d                	beqz	a5,80004f74 <piperead+0x68>
    if(killed(pr)){
    80004f50:	8552                	mv	a0,s4
    80004f52:	ffffd097          	auipc	ra,0xffffd
    80004f56:	630080e7          	jalr	1584(ra) # 80002582 <killed>
    80004f5a:	e949                	bnez	a0,80004fec <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f5c:	85a6                	mv	a1,s1
    80004f5e:	854e                	mv	a0,s3
    80004f60:	ffffd097          	auipc	ra,0xffffd
    80004f64:	37a080e7          	jalr	890(ra) # 800022da <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f68:	2184a703          	lw	a4,536(s1)
    80004f6c:	21c4a783          	lw	a5,540(s1)
    80004f70:	fcf70de3          	beq	a4,a5,80004f4a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f74:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f76:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f78:	05505463          	blez	s5,80004fc0 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004f7c:	2184a783          	lw	a5,536(s1)
    80004f80:	21c4a703          	lw	a4,540(s1)
    80004f84:	02f70e63          	beq	a4,a5,80004fc0 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f88:	0017871b          	addiw	a4,a5,1
    80004f8c:	20e4ac23          	sw	a4,536(s1)
    80004f90:	1ff7f793          	andi	a5,a5,511
    80004f94:	97a6                	add	a5,a5,s1
    80004f96:	0187c783          	lbu	a5,24(a5)
    80004f9a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f9e:	4685                	li	a3,1
    80004fa0:	fbf40613          	addi	a2,s0,-65
    80004fa4:	85ca                	mv	a1,s2
    80004fa6:	050a3503          	ld	a0,80(s4)
    80004faa:	ffffc097          	auipc	ra,0xffffc
    80004fae:	78a080e7          	jalr	1930(ra) # 80001734 <copyout>
    80004fb2:	01650763          	beq	a0,s6,80004fc0 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fb6:	2985                	addiw	s3,s3,1
    80004fb8:	0905                	addi	s2,s2,1
    80004fba:	fd3a91e3          	bne	s5,s3,80004f7c <piperead+0x70>
    80004fbe:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004fc0:	21c48513          	addi	a0,s1,540
    80004fc4:	ffffd097          	auipc	ra,0xffffd
    80004fc8:	37a080e7          	jalr	890(ra) # 8000233e <wakeup>
  release(&pi->lock);
    80004fcc:	8526                	mv	a0,s1
    80004fce:	ffffc097          	auipc	ra,0xffffc
    80004fd2:	d84080e7          	jalr	-636(ra) # 80000d52 <release>
  return i;
}
    80004fd6:	854e                	mv	a0,s3
    80004fd8:	60a6                	ld	ra,72(sp)
    80004fda:	6406                	ld	s0,64(sp)
    80004fdc:	74e2                	ld	s1,56(sp)
    80004fde:	7942                	ld	s2,48(sp)
    80004fe0:	79a2                	ld	s3,40(sp)
    80004fe2:	7a02                	ld	s4,32(sp)
    80004fe4:	6ae2                	ld	s5,24(sp)
    80004fe6:	6b42                	ld	s6,16(sp)
    80004fe8:	6161                	addi	sp,sp,80
    80004fea:	8082                	ret
      release(&pi->lock);
    80004fec:	8526                	mv	a0,s1
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	d64080e7          	jalr	-668(ra) # 80000d52 <release>
      return -1;
    80004ff6:	59fd                	li	s3,-1
    80004ff8:	bff9                	j	80004fd6 <piperead+0xca>

0000000080004ffa <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004ffa:	1141                	addi	sp,sp,-16
    80004ffc:	e422                	sd	s0,8(sp)
    80004ffe:	0800                	addi	s0,sp,16
    80005000:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005002:	8905                	andi	a0,a0,1
    80005004:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005006:	8b89                	andi	a5,a5,2
    80005008:	c399                	beqz	a5,8000500e <flags2perm+0x14>
      perm |= PTE_W;
    8000500a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000500e:	6422                	ld	s0,8(sp)
    80005010:	0141                	addi	sp,sp,16
    80005012:	8082                	ret

0000000080005014 <exec>:

int
exec(char *path, char **argv)
{
    80005014:	de010113          	addi	sp,sp,-544
    80005018:	20113c23          	sd	ra,536(sp)
    8000501c:	20813823          	sd	s0,528(sp)
    80005020:	20913423          	sd	s1,520(sp)
    80005024:	21213023          	sd	s2,512(sp)
    80005028:	ffce                	sd	s3,504(sp)
    8000502a:	fbd2                	sd	s4,496(sp)
    8000502c:	f7d6                	sd	s5,488(sp)
    8000502e:	f3da                	sd	s6,480(sp)
    80005030:	efde                	sd	s7,472(sp)
    80005032:	ebe2                	sd	s8,464(sp)
    80005034:	e7e6                	sd	s9,456(sp)
    80005036:	e3ea                	sd	s10,448(sp)
    80005038:	ff6e                	sd	s11,440(sp)
    8000503a:	1400                	addi	s0,sp,544
    8000503c:	892a                	mv	s2,a0
    8000503e:	dea43423          	sd	a0,-536(s0)
    80005042:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005046:	ffffd097          	auipc	ra,0xffffd
    8000504a:	b2c080e7          	jalr	-1236(ra) # 80001b72 <myproc>
    8000504e:	84aa                	mv	s1,a0

  begin_op();
    80005050:	fffff097          	auipc	ra,0xfffff
    80005054:	482080e7          	jalr	1154(ra) # 800044d2 <begin_op>

  if((ip = namei(path)) == 0){
    80005058:	854a                	mv	a0,s2
    8000505a:	fffff097          	auipc	ra,0xfffff
    8000505e:	258080e7          	jalr	600(ra) # 800042b2 <namei>
    80005062:	c93d                	beqz	a0,800050d8 <exec+0xc4>
    80005064:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005066:	fffff097          	auipc	ra,0xfffff
    8000506a:	aa0080e7          	jalr	-1376(ra) # 80003b06 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000506e:	04000713          	li	a4,64
    80005072:	4681                	li	a3,0
    80005074:	e5040613          	addi	a2,s0,-432
    80005078:	4581                	li	a1,0
    8000507a:	8556                	mv	a0,s5
    8000507c:	fffff097          	auipc	ra,0xfffff
    80005080:	d3e080e7          	jalr	-706(ra) # 80003dba <readi>
    80005084:	04000793          	li	a5,64
    80005088:	00f51a63          	bne	a0,a5,8000509c <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000508c:	e5042703          	lw	a4,-432(s0)
    80005090:	464c47b7          	lui	a5,0x464c4
    80005094:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005098:	04f70663          	beq	a4,a5,800050e4 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000509c:	8556                	mv	a0,s5
    8000509e:	fffff097          	auipc	ra,0xfffff
    800050a2:	cca080e7          	jalr	-822(ra) # 80003d68 <iunlockput>
    end_op();
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	4aa080e7          	jalr	1194(ra) # 80004550 <end_op>
  }
  return -1;
    800050ae:	557d                	li	a0,-1
}
    800050b0:	21813083          	ld	ra,536(sp)
    800050b4:	21013403          	ld	s0,528(sp)
    800050b8:	20813483          	ld	s1,520(sp)
    800050bc:	20013903          	ld	s2,512(sp)
    800050c0:	79fe                	ld	s3,504(sp)
    800050c2:	7a5e                	ld	s4,496(sp)
    800050c4:	7abe                	ld	s5,488(sp)
    800050c6:	7b1e                	ld	s6,480(sp)
    800050c8:	6bfe                	ld	s7,472(sp)
    800050ca:	6c5e                	ld	s8,464(sp)
    800050cc:	6cbe                	ld	s9,456(sp)
    800050ce:	6d1e                	ld	s10,448(sp)
    800050d0:	7dfa                	ld	s11,440(sp)
    800050d2:	22010113          	addi	sp,sp,544
    800050d6:	8082                	ret
    end_op();
    800050d8:	fffff097          	auipc	ra,0xfffff
    800050dc:	478080e7          	jalr	1144(ra) # 80004550 <end_op>
    return -1;
    800050e0:	557d                	li	a0,-1
    800050e2:	b7f9                	j	800050b0 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800050e4:	8526                	mv	a0,s1
    800050e6:	ffffd097          	auipc	ra,0xffffd
    800050ea:	b50080e7          	jalr	-1200(ra) # 80001c36 <proc_pagetable>
    800050ee:	8b2a                	mv	s6,a0
    800050f0:	d555                	beqz	a0,8000509c <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050f2:	e7042783          	lw	a5,-400(s0)
    800050f6:	e8845703          	lhu	a4,-376(s0)
    800050fa:	c735                	beqz	a4,80005166 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050fc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050fe:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005102:	6a05                	lui	s4,0x1
    80005104:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005108:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000510c:	6d85                	lui	s11,0x1
    8000510e:	7d7d                	lui	s10,0xfffff
    80005110:	ac3d                	j	8000534e <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005112:	00003517          	auipc	a0,0x3
    80005116:	6f650513          	addi	a0,a0,1782 # 80008808 <syscalls+0x2a8>
    8000511a:	ffffb097          	auipc	ra,0xffffb
    8000511e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005122:	874a                	mv	a4,s2
    80005124:	009c86bb          	addw	a3,s9,s1
    80005128:	4581                	li	a1,0
    8000512a:	8556                	mv	a0,s5
    8000512c:	fffff097          	auipc	ra,0xfffff
    80005130:	c8e080e7          	jalr	-882(ra) # 80003dba <readi>
    80005134:	2501                	sext.w	a0,a0
    80005136:	1aa91963          	bne	s2,a0,800052e8 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    8000513a:	009d84bb          	addw	s1,s11,s1
    8000513e:	013d09bb          	addw	s3,s10,s3
    80005142:	1f74f663          	bgeu	s1,s7,8000532e <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005146:	02049593          	slli	a1,s1,0x20
    8000514a:	9181                	srli	a1,a1,0x20
    8000514c:	95e2                	add	a1,a1,s8
    8000514e:	855a                	mv	a0,s6
    80005150:	ffffc097          	auipc	ra,0xffffc
    80005154:	fd4080e7          	jalr	-44(ra) # 80001124 <walkaddr>
    80005158:	862a                	mv	a2,a0
    if(pa == 0)
    8000515a:	dd45                	beqz	a0,80005112 <exec+0xfe>
      n = PGSIZE;
    8000515c:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000515e:	fd49f2e3          	bgeu	s3,s4,80005122 <exec+0x10e>
      n = sz - i;
    80005162:	894e                	mv	s2,s3
    80005164:	bf7d                	j	80005122 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005166:	4901                	li	s2,0
  iunlockput(ip);
    80005168:	8556                	mv	a0,s5
    8000516a:	fffff097          	auipc	ra,0xfffff
    8000516e:	bfe080e7          	jalr	-1026(ra) # 80003d68 <iunlockput>
  end_op();
    80005172:	fffff097          	auipc	ra,0xfffff
    80005176:	3de080e7          	jalr	990(ra) # 80004550 <end_op>
  p = myproc();
    8000517a:	ffffd097          	auipc	ra,0xffffd
    8000517e:	9f8080e7          	jalr	-1544(ra) # 80001b72 <myproc>
    80005182:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005184:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005188:	6785                	lui	a5,0x1
    8000518a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000518c:	97ca                	add	a5,a5,s2
    8000518e:	777d                	lui	a4,0xfffff
    80005190:	8ff9                	and	a5,a5,a4
    80005192:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005196:	4691                	li	a3,4
    80005198:	6609                	lui	a2,0x2
    8000519a:	963e                	add	a2,a2,a5
    8000519c:	85be                	mv	a1,a5
    8000519e:	855a                	mv	a0,s6
    800051a0:	ffffc097          	auipc	ra,0xffffc
    800051a4:	338080e7          	jalr	824(ra) # 800014d8 <uvmalloc>
    800051a8:	8c2a                	mv	s8,a0
  ip = 0;
    800051aa:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051ac:	12050e63          	beqz	a0,800052e8 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800051b0:	75f9                	lui	a1,0xffffe
    800051b2:	95aa                	add	a1,a1,a0
    800051b4:	855a                	mv	a0,s6
    800051b6:	ffffc097          	auipc	ra,0xffffc
    800051ba:	54c080e7          	jalr	1356(ra) # 80001702 <uvmclear>
  stackbase = sp - PGSIZE;
    800051be:	7afd                	lui	s5,0xfffff
    800051c0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800051c2:	df043783          	ld	a5,-528(s0)
    800051c6:	6388                	ld	a0,0(a5)
    800051c8:	c925                	beqz	a0,80005238 <exec+0x224>
    800051ca:	e9040993          	addi	s3,s0,-368
    800051ce:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800051d2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800051d4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800051d6:	ffffc097          	auipc	ra,0xffffc
    800051da:	d40080e7          	jalr	-704(ra) # 80000f16 <strlen>
    800051de:	0015079b          	addiw	a5,a0,1
    800051e2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051e6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800051ea:	13596663          	bltu	s2,s5,80005316 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051ee:	df043d83          	ld	s11,-528(s0)
    800051f2:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800051f6:	8552                	mv	a0,s4
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	d1e080e7          	jalr	-738(ra) # 80000f16 <strlen>
    80005200:	0015069b          	addiw	a3,a0,1
    80005204:	8652                	mv	a2,s4
    80005206:	85ca                	mv	a1,s2
    80005208:	855a                	mv	a0,s6
    8000520a:	ffffc097          	auipc	ra,0xffffc
    8000520e:	52a080e7          	jalr	1322(ra) # 80001734 <copyout>
    80005212:	10054663          	bltz	a0,8000531e <exec+0x30a>
    ustack[argc] = sp;
    80005216:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000521a:	0485                	addi	s1,s1,1
    8000521c:	008d8793          	addi	a5,s11,8
    80005220:	def43823          	sd	a5,-528(s0)
    80005224:	008db503          	ld	a0,8(s11)
    80005228:	c911                	beqz	a0,8000523c <exec+0x228>
    if(argc >= MAXARG)
    8000522a:	09a1                	addi	s3,s3,8
    8000522c:	fb3c95e3          	bne	s9,s3,800051d6 <exec+0x1c2>
  sz = sz1;
    80005230:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005234:	4a81                	li	s5,0
    80005236:	a84d                	j	800052e8 <exec+0x2d4>
  sp = sz;
    80005238:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000523a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000523c:	00349793          	slli	a5,s1,0x3
    80005240:	f9078793          	addi	a5,a5,-112
    80005244:	97a2                	add	a5,a5,s0
    80005246:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000524a:	00148693          	addi	a3,s1,1
    8000524e:	068e                	slli	a3,a3,0x3
    80005250:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005254:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005258:	01597663          	bgeu	s2,s5,80005264 <exec+0x250>
  sz = sz1;
    8000525c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005260:	4a81                	li	s5,0
    80005262:	a059                	j	800052e8 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005264:	e9040613          	addi	a2,s0,-368
    80005268:	85ca                	mv	a1,s2
    8000526a:	855a                	mv	a0,s6
    8000526c:	ffffc097          	auipc	ra,0xffffc
    80005270:	4c8080e7          	jalr	1224(ra) # 80001734 <copyout>
    80005274:	0a054963          	bltz	a0,80005326 <exec+0x312>
  p->trapframe->a1 = sp;
    80005278:	058bb783          	ld	a5,88(s7)
    8000527c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005280:	de843783          	ld	a5,-536(s0)
    80005284:	0007c703          	lbu	a4,0(a5)
    80005288:	cf11                	beqz	a4,800052a4 <exec+0x290>
    8000528a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000528c:	02f00693          	li	a3,47
    80005290:	a039                	j	8000529e <exec+0x28a>
      last = s+1;
    80005292:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005296:	0785                	addi	a5,a5,1
    80005298:	fff7c703          	lbu	a4,-1(a5)
    8000529c:	c701                	beqz	a4,800052a4 <exec+0x290>
    if(*s == '/')
    8000529e:	fed71ce3          	bne	a4,a3,80005296 <exec+0x282>
    800052a2:	bfc5                	j	80005292 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800052a4:	4641                	li	a2,16
    800052a6:	de843583          	ld	a1,-536(s0)
    800052aa:	158b8513          	addi	a0,s7,344
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	c36080e7          	jalr	-970(ra) # 80000ee4 <safestrcpy>
  oldpagetable = p->pagetable;
    800052b6:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800052ba:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800052be:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800052c2:	058bb783          	ld	a5,88(s7)
    800052c6:	e6843703          	ld	a4,-408(s0)
    800052ca:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052cc:	058bb783          	ld	a5,88(s7)
    800052d0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052d4:	85ea                	mv	a1,s10
    800052d6:	ffffd097          	auipc	ra,0xffffd
    800052da:	9fc080e7          	jalr	-1540(ra) # 80001cd2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052de:	0004851b          	sext.w	a0,s1
    800052e2:	b3f9                	j	800050b0 <exec+0x9c>
    800052e4:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800052e8:	df843583          	ld	a1,-520(s0)
    800052ec:	855a                	mv	a0,s6
    800052ee:	ffffd097          	auipc	ra,0xffffd
    800052f2:	9e4080e7          	jalr	-1564(ra) # 80001cd2 <proc_freepagetable>
  if(ip){
    800052f6:	da0a93e3          	bnez	s5,8000509c <exec+0x88>
  return -1;
    800052fa:	557d                	li	a0,-1
    800052fc:	bb55                	j	800050b0 <exec+0x9c>
    800052fe:	df243c23          	sd	s2,-520(s0)
    80005302:	b7dd                	j	800052e8 <exec+0x2d4>
    80005304:	df243c23          	sd	s2,-520(s0)
    80005308:	b7c5                	j	800052e8 <exec+0x2d4>
    8000530a:	df243c23          	sd	s2,-520(s0)
    8000530e:	bfe9                	j	800052e8 <exec+0x2d4>
    80005310:	df243c23          	sd	s2,-520(s0)
    80005314:	bfd1                	j	800052e8 <exec+0x2d4>
  sz = sz1;
    80005316:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000531a:	4a81                	li	s5,0
    8000531c:	b7f1                	j	800052e8 <exec+0x2d4>
  sz = sz1;
    8000531e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005322:	4a81                	li	s5,0
    80005324:	b7d1                	j	800052e8 <exec+0x2d4>
  sz = sz1;
    80005326:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000532a:	4a81                	li	s5,0
    8000532c:	bf75                	j	800052e8 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000532e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005332:	e0843783          	ld	a5,-504(s0)
    80005336:	0017869b          	addiw	a3,a5,1
    8000533a:	e0d43423          	sd	a3,-504(s0)
    8000533e:	e0043783          	ld	a5,-512(s0)
    80005342:	0387879b          	addiw	a5,a5,56
    80005346:	e8845703          	lhu	a4,-376(s0)
    8000534a:	e0e6dfe3          	bge	a3,a4,80005168 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000534e:	2781                	sext.w	a5,a5
    80005350:	e0f43023          	sd	a5,-512(s0)
    80005354:	03800713          	li	a4,56
    80005358:	86be                	mv	a3,a5
    8000535a:	e1840613          	addi	a2,s0,-488
    8000535e:	4581                	li	a1,0
    80005360:	8556                	mv	a0,s5
    80005362:	fffff097          	auipc	ra,0xfffff
    80005366:	a58080e7          	jalr	-1448(ra) # 80003dba <readi>
    8000536a:	03800793          	li	a5,56
    8000536e:	f6f51be3          	bne	a0,a5,800052e4 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80005372:	e1842783          	lw	a5,-488(s0)
    80005376:	4705                	li	a4,1
    80005378:	fae79de3          	bne	a5,a4,80005332 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    8000537c:	e4043483          	ld	s1,-448(s0)
    80005380:	e3843783          	ld	a5,-456(s0)
    80005384:	f6f4ede3          	bltu	s1,a5,800052fe <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005388:	e2843783          	ld	a5,-472(s0)
    8000538c:	94be                	add	s1,s1,a5
    8000538e:	f6f4ebe3          	bltu	s1,a5,80005304 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80005392:	de043703          	ld	a4,-544(s0)
    80005396:	8ff9                	and	a5,a5,a4
    80005398:	fbad                	bnez	a5,8000530a <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000539a:	e1c42503          	lw	a0,-484(s0)
    8000539e:	00000097          	auipc	ra,0x0
    800053a2:	c5c080e7          	jalr	-932(ra) # 80004ffa <flags2perm>
    800053a6:	86aa                	mv	a3,a0
    800053a8:	8626                	mv	a2,s1
    800053aa:	85ca                	mv	a1,s2
    800053ac:	855a                	mv	a0,s6
    800053ae:	ffffc097          	auipc	ra,0xffffc
    800053b2:	12a080e7          	jalr	298(ra) # 800014d8 <uvmalloc>
    800053b6:	dea43c23          	sd	a0,-520(s0)
    800053ba:	d939                	beqz	a0,80005310 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053bc:	e2843c03          	ld	s8,-472(s0)
    800053c0:	e2042c83          	lw	s9,-480(s0)
    800053c4:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800053c8:	f60b83e3          	beqz	s7,8000532e <exec+0x31a>
    800053cc:	89de                	mv	s3,s7
    800053ce:	4481                	li	s1,0
    800053d0:	bb9d                	j	80005146 <exec+0x132>

00000000800053d2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800053d2:	7179                	addi	sp,sp,-48
    800053d4:	f406                	sd	ra,40(sp)
    800053d6:	f022                	sd	s0,32(sp)
    800053d8:	ec26                	sd	s1,24(sp)
    800053da:	e84a                	sd	s2,16(sp)
    800053dc:	1800                	addi	s0,sp,48
    800053de:	892e                	mv	s2,a1
    800053e0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800053e2:	fdc40593          	addi	a1,s0,-36
    800053e6:	ffffe097          	auipc	ra,0xffffe
    800053ea:	a9e080e7          	jalr	-1378(ra) # 80002e84 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053ee:	fdc42703          	lw	a4,-36(s0)
    800053f2:	47bd                	li	a5,15
    800053f4:	02e7eb63          	bltu	a5,a4,8000542a <argfd+0x58>
    800053f8:	ffffc097          	auipc	ra,0xffffc
    800053fc:	77a080e7          	jalr	1914(ra) # 80001b72 <myproc>
    80005400:	fdc42703          	lw	a4,-36(s0)
    80005404:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd13a>
    80005408:	078e                	slli	a5,a5,0x3
    8000540a:	953e                	add	a0,a0,a5
    8000540c:	611c                	ld	a5,0(a0)
    8000540e:	c385                	beqz	a5,8000542e <argfd+0x5c>
    return -1;
  if(pfd)
    80005410:	00090463          	beqz	s2,80005418 <argfd+0x46>
    *pfd = fd;
    80005414:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005418:	4501                	li	a0,0
  if(pf)
    8000541a:	c091                	beqz	s1,8000541e <argfd+0x4c>
    *pf = f;
    8000541c:	e09c                	sd	a5,0(s1)
}
    8000541e:	70a2                	ld	ra,40(sp)
    80005420:	7402                	ld	s0,32(sp)
    80005422:	64e2                	ld	s1,24(sp)
    80005424:	6942                	ld	s2,16(sp)
    80005426:	6145                	addi	sp,sp,48
    80005428:	8082                	ret
    return -1;
    8000542a:	557d                	li	a0,-1
    8000542c:	bfcd                	j	8000541e <argfd+0x4c>
    8000542e:	557d                	li	a0,-1
    80005430:	b7fd                	j	8000541e <argfd+0x4c>

0000000080005432 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005432:	1101                	addi	sp,sp,-32
    80005434:	ec06                	sd	ra,24(sp)
    80005436:	e822                	sd	s0,16(sp)
    80005438:	e426                	sd	s1,8(sp)
    8000543a:	1000                	addi	s0,sp,32
    8000543c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000543e:	ffffc097          	auipc	ra,0xffffc
    80005442:	734080e7          	jalr	1844(ra) # 80001b72 <myproc>
    80005446:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005448:	0d050793          	addi	a5,a0,208
    8000544c:	4501                	li	a0,0
    8000544e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005450:	6398                	ld	a4,0(a5)
    80005452:	cb19                	beqz	a4,80005468 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005454:	2505                	addiw	a0,a0,1
    80005456:	07a1                	addi	a5,a5,8
    80005458:	fed51ce3          	bne	a0,a3,80005450 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000545c:	557d                	li	a0,-1
}
    8000545e:	60e2                	ld	ra,24(sp)
    80005460:	6442                	ld	s0,16(sp)
    80005462:	64a2                	ld	s1,8(sp)
    80005464:	6105                	addi	sp,sp,32
    80005466:	8082                	ret
      p->ofile[fd] = f;
    80005468:	01a50793          	addi	a5,a0,26
    8000546c:	078e                	slli	a5,a5,0x3
    8000546e:	963e                	add	a2,a2,a5
    80005470:	e204                	sd	s1,0(a2)
      return fd;
    80005472:	b7f5                	j	8000545e <fdalloc+0x2c>

0000000080005474 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005474:	715d                	addi	sp,sp,-80
    80005476:	e486                	sd	ra,72(sp)
    80005478:	e0a2                	sd	s0,64(sp)
    8000547a:	fc26                	sd	s1,56(sp)
    8000547c:	f84a                	sd	s2,48(sp)
    8000547e:	f44e                	sd	s3,40(sp)
    80005480:	f052                	sd	s4,32(sp)
    80005482:	ec56                	sd	s5,24(sp)
    80005484:	e85a                	sd	s6,16(sp)
    80005486:	0880                	addi	s0,sp,80
    80005488:	8b2e                	mv	s6,a1
    8000548a:	89b2                	mv	s3,a2
    8000548c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000548e:	fb040593          	addi	a1,s0,-80
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	e3e080e7          	jalr	-450(ra) # 800042d0 <nameiparent>
    8000549a:	84aa                	mv	s1,a0
    8000549c:	14050f63          	beqz	a0,800055fa <create+0x186>
    return 0;

  ilock(dp);
    800054a0:	ffffe097          	auipc	ra,0xffffe
    800054a4:	666080e7          	jalr	1638(ra) # 80003b06 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800054a8:	4601                	li	a2,0
    800054aa:	fb040593          	addi	a1,s0,-80
    800054ae:	8526                	mv	a0,s1
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	b3a080e7          	jalr	-1222(ra) # 80003fea <dirlookup>
    800054b8:	8aaa                	mv	s5,a0
    800054ba:	c931                	beqz	a0,8000550e <create+0x9a>
    iunlockput(dp);
    800054bc:	8526                	mv	a0,s1
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	8aa080e7          	jalr	-1878(ra) # 80003d68 <iunlockput>
    ilock(ip);
    800054c6:	8556                	mv	a0,s5
    800054c8:	ffffe097          	auipc	ra,0xffffe
    800054cc:	63e080e7          	jalr	1598(ra) # 80003b06 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800054d0:	000b059b          	sext.w	a1,s6
    800054d4:	4789                	li	a5,2
    800054d6:	02f59563          	bne	a1,a5,80005500 <create+0x8c>
    800054da:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd164>
    800054de:	37f9                	addiw	a5,a5,-2
    800054e0:	17c2                	slli	a5,a5,0x30
    800054e2:	93c1                	srli	a5,a5,0x30
    800054e4:	4705                	li	a4,1
    800054e6:	00f76d63          	bltu	a4,a5,80005500 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800054ea:	8556                	mv	a0,s5
    800054ec:	60a6                	ld	ra,72(sp)
    800054ee:	6406                	ld	s0,64(sp)
    800054f0:	74e2                	ld	s1,56(sp)
    800054f2:	7942                	ld	s2,48(sp)
    800054f4:	79a2                	ld	s3,40(sp)
    800054f6:	7a02                	ld	s4,32(sp)
    800054f8:	6ae2                	ld	s5,24(sp)
    800054fa:	6b42                	ld	s6,16(sp)
    800054fc:	6161                	addi	sp,sp,80
    800054fe:	8082                	ret
    iunlockput(ip);
    80005500:	8556                	mv	a0,s5
    80005502:	fffff097          	auipc	ra,0xfffff
    80005506:	866080e7          	jalr	-1946(ra) # 80003d68 <iunlockput>
    return 0;
    8000550a:	4a81                	li	s5,0
    8000550c:	bff9                	j	800054ea <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000550e:	85da                	mv	a1,s6
    80005510:	4088                	lw	a0,0(s1)
    80005512:	ffffe097          	auipc	ra,0xffffe
    80005516:	456080e7          	jalr	1110(ra) # 80003968 <ialloc>
    8000551a:	8a2a                	mv	s4,a0
    8000551c:	c539                	beqz	a0,8000556a <create+0xf6>
  ilock(ip);
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	5e8080e7          	jalr	1512(ra) # 80003b06 <ilock>
  ip->major = major;
    80005526:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000552a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000552e:	4905                	li	s2,1
    80005530:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005534:	8552                	mv	a0,s4
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	504080e7          	jalr	1284(ra) # 80003a3a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000553e:	000b059b          	sext.w	a1,s6
    80005542:	03258b63          	beq	a1,s2,80005578 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005546:	004a2603          	lw	a2,4(s4)
    8000554a:	fb040593          	addi	a1,s0,-80
    8000554e:	8526                	mv	a0,s1
    80005550:	fffff097          	auipc	ra,0xfffff
    80005554:	cb0080e7          	jalr	-848(ra) # 80004200 <dirlink>
    80005558:	06054f63          	bltz	a0,800055d6 <create+0x162>
  iunlockput(dp);
    8000555c:	8526                	mv	a0,s1
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	80a080e7          	jalr	-2038(ra) # 80003d68 <iunlockput>
  return ip;
    80005566:	8ad2                	mv	s5,s4
    80005568:	b749                	j	800054ea <create+0x76>
    iunlockput(dp);
    8000556a:	8526                	mv	a0,s1
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	7fc080e7          	jalr	2044(ra) # 80003d68 <iunlockput>
    return 0;
    80005574:	8ad2                	mv	s5,s4
    80005576:	bf95                	j	800054ea <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005578:	004a2603          	lw	a2,4(s4)
    8000557c:	00003597          	auipc	a1,0x3
    80005580:	2ac58593          	addi	a1,a1,684 # 80008828 <syscalls+0x2c8>
    80005584:	8552                	mv	a0,s4
    80005586:	fffff097          	auipc	ra,0xfffff
    8000558a:	c7a080e7          	jalr	-902(ra) # 80004200 <dirlink>
    8000558e:	04054463          	bltz	a0,800055d6 <create+0x162>
    80005592:	40d0                	lw	a2,4(s1)
    80005594:	00003597          	auipc	a1,0x3
    80005598:	29c58593          	addi	a1,a1,668 # 80008830 <syscalls+0x2d0>
    8000559c:	8552                	mv	a0,s4
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	c62080e7          	jalr	-926(ra) # 80004200 <dirlink>
    800055a6:	02054863          	bltz	a0,800055d6 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800055aa:	004a2603          	lw	a2,4(s4)
    800055ae:	fb040593          	addi	a1,s0,-80
    800055b2:	8526                	mv	a0,s1
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	c4c080e7          	jalr	-948(ra) # 80004200 <dirlink>
    800055bc:	00054d63          	bltz	a0,800055d6 <create+0x162>
    dp->nlink++;  // for ".."
    800055c0:	04a4d783          	lhu	a5,74(s1)
    800055c4:	2785                	addiw	a5,a5,1
    800055c6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055ca:	8526                	mv	a0,s1
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	46e080e7          	jalr	1134(ra) # 80003a3a <iupdate>
    800055d4:	b761                	j	8000555c <create+0xe8>
  ip->nlink = 0;
    800055d6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800055da:	8552                	mv	a0,s4
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	45e080e7          	jalr	1118(ra) # 80003a3a <iupdate>
  iunlockput(ip);
    800055e4:	8552                	mv	a0,s4
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	782080e7          	jalr	1922(ra) # 80003d68 <iunlockput>
  iunlockput(dp);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	778080e7          	jalr	1912(ra) # 80003d68 <iunlockput>
  return 0;
    800055f8:	bdcd                	j	800054ea <create+0x76>
    return 0;
    800055fa:	8aaa                	mv	s5,a0
    800055fc:	b5fd                	j	800054ea <create+0x76>

00000000800055fe <sys_dup>:
{
    800055fe:	7179                	addi	sp,sp,-48
    80005600:	f406                	sd	ra,40(sp)
    80005602:	f022                	sd	s0,32(sp)
    80005604:	ec26                	sd	s1,24(sp)
    80005606:	e84a                	sd	s2,16(sp)
    80005608:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000560a:	fd840613          	addi	a2,s0,-40
    8000560e:	4581                	li	a1,0
    80005610:	4501                	li	a0,0
    80005612:	00000097          	auipc	ra,0x0
    80005616:	dc0080e7          	jalr	-576(ra) # 800053d2 <argfd>
    return -1;
    8000561a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000561c:	02054363          	bltz	a0,80005642 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005620:	fd843903          	ld	s2,-40(s0)
    80005624:	854a                	mv	a0,s2
    80005626:	00000097          	auipc	ra,0x0
    8000562a:	e0c080e7          	jalr	-500(ra) # 80005432 <fdalloc>
    8000562e:	84aa                	mv	s1,a0
    return -1;
    80005630:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005632:	00054863          	bltz	a0,80005642 <sys_dup+0x44>
  filedup(f);
    80005636:	854a                	mv	a0,s2
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	310080e7          	jalr	784(ra) # 80004948 <filedup>
  return fd;
    80005640:	87a6                	mv	a5,s1
}
    80005642:	853e                	mv	a0,a5
    80005644:	70a2                	ld	ra,40(sp)
    80005646:	7402                	ld	s0,32(sp)
    80005648:	64e2                	ld	s1,24(sp)
    8000564a:	6942                	ld	s2,16(sp)
    8000564c:	6145                	addi	sp,sp,48
    8000564e:	8082                	ret

0000000080005650 <sys_read>:
{
    80005650:	7179                	addi	sp,sp,-48
    80005652:	f406                	sd	ra,40(sp)
    80005654:	f022                	sd	s0,32(sp)
    80005656:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005658:	fd840593          	addi	a1,s0,-40
    8000565c:	4505                	li	a0,1
    8000565e:	ffffe097          	auipc	ra,0xffffe
    80005662:	846080e7          	jalr	-1978(ra) # 80002ea4 <argaddr>
  argint(2, &n);
    80005666:	fe440593          	addi	a1,s0,-28
    8000566a:	4509                	li	a0,2
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	818080e7          	jalr	-2024(ra) # 80002e84 <argint>
  if(argfd(0, 0, &f) < 0)
    80005674:	fe840613          	addi	a2,s0,-24
    80005678:	4581                	li	a1,0
    8000567a:	4501                	li	a0,0
    8000567c:	00000097          	auipc	ra,0x0
    80005680:	d56080e7          	jalr	-682(ra) # 800053d2 <argfd>
    80005684:	87aa                	mv	a5,a0
    return -1;
    80005686:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005688:	0007cc63          	bltz	a5,800056a0 <sys_read+0x50>
  return fileread(f, p, n);
    8000568c:	fe442603          	lw	a2,-28(s0)
    80005690:	fd843583          	ld	a1,-40(s0)
    80005694:	fe843503          	ld	a0,-24(s0)
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	43c080e7          	jalr	1084(ra) # 80004ad4 <fileread>
}
    800056a0:	70a2                	ld	ra,40(sp)
    800056a2:	7402                	ld	s0,32(sp)
    800056a4:	6145                	addi	sp,sp,48
    800056a6:	8082                	ret

00000000800056a8 <sys_write>:
{
    800056a8:	7179                	addi	sp,sp,-48
    800056aa:	f406                	sd	ra,40(sp)
    800056ac:	f022                	sd	s0,32(sp)
    800056ae:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056b0:	fd840593          	addi	a1,s0,-40
    800056b4:	4505                	li	a0,1
    800056b6:	ffffd097          	auipc	ra,0xffffd
    800056ba:	7ee080e7          	jalr	2030(ra) # 80002ea4 <argaddr>
  argint(2, &n);
    800056be:	fe440593          	addi	a1,s0,-28
    800056c2:	4509                	li	a0,2
    800056c4:	ffffd097          	auipc	ra,0xffffd
    800056c8:	7c0080e7          	jalr	1984(ra) # 80002e84 <argint>
  if(argfd(0, 0, &f) < 0)
    800056cc:	fe840613          	addi	a2,s0,-24
    800056d0:	4581                	li	a1,0
    800056d2:	4501                	li	a0,0
    800056d4:	00000097          	auipc	ra,0x0
    800056d8:	cfe080e7          	jalr	-770(ra) # 800053d2 <argfd>
    800056dc:	87aa                	mv	a5,a0
    return -1;
    800056de:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056e0:	0007cc63          	bltz	a5,800056f8 <sys_write+0x50>
  return filewrite(f, p, n);
    800056e4:	fe442603          	lw	a2,-28(s0)
    800056e8:	fd843583          	ld	a1,-40(s0)
    800056ec:	fe843503          	ld	a0,-24(s0)
    800056f0:	fffff097          	auipc	ra,0xfffff
    800056f4:	4a6080e7          	jalr	1190(ra) # 80004b96 <filewrite>
}
    800056f8:	70a2                	ld	ra,40(sp)
    800056fa:	7402                	ld	s0,32(sp)
    800056fc:	6145                	addi	sp,sp,48
    800056fe:	8082                	ret

0000000080005700 <sys_close>:
{
    80005700:	1101                	addi	sp,sp,-32
    80005702:	ec06                	sd	ra,24(sp)
    80005704:	e822                	sd	s0,16(sp)
    80005706:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005708:	fe040613          	addi	a2,s0,-32
    8000570c:	fec40593          	addi	a1,s0,-20
    80005710:	4501                	li	a0,0
    80005712:	00000097          	auipc	ra,0x0
    80005716:	cc0080e7          	jalr	-832(ra) # 800053d2 <argfd>
    return -1;
    8000571a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000571c:	02054463          	bltz	a0,80005744 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005720:	ffffc097          	auipc	ra,0xffffc
    80005724:	452080e7          	jalr	1106(ra) # 80001b72 <myproc>
    80005728:	fec42783          	lw	a5,-20(s0)
    8000572c:	07e9                	addi	a5,a5,26
    8000572e:	078e                	slli	a5,a5,0x3
    80005730:	953e                	add	a0,a0,a5
    80005732:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005736:	fe043503          	ld	a0,-32(s0)
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	260080e7          	jalr	608(ra) # 8000499a <fileclose>
  return 0;
    80005742:	4781                	li	a5,0
}
    80005744:	853e                	mv	a0,a5
    80005746:	60e2                	ld	ra,24(sp)
    80005748:	6442                	ld	s0,16(sp)
    8000574a:	6105                	addi	sp,sp,32
    8000574c:	8082                	ret

000000008000574e <sys_fstat>:
{
    8000574e:	1101                	addi	sp,sp,-32
    80005750:	ec06                	sd	ra,24(sp)
    80005752:	e822                	sd	s0,16(sp)
    80005754:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005756:	fe040593          	addi	a1,s0,-32
    8000575a:	4505                	li	a0,1
    8000575c:	ffffd097          	auipc	ra,0xffffd
    80005760:	748080e7          	jalr	1864(ra) # 80002ea4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005764:	fe840613          	addi	a2,s0,-24
    80005768:	4581                	li	a1,0
    8000576a:	4501                	li	a0,0
    8000576c:	00000097          	auipc	ra,0x0
    80005770:	c66080e7          	jalr	-922(ra) # 800053d2 <argfd>
    80005774:	87aa                	mv	a5,a0
    return -1;
    80005776:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005778:	0007ca63          	bltz	a5,8000578c <sys_fstat+0x3e>
  return filestat(f, st);
    8000577c:	fe043583          	ld	a1,-32(s0)
    80005780:	fe843503          	ld	a0,-24(s0)
    80005784:	fffff097          	auipc	ra,0xfffff
    80005788:	2de080e7          	jalr	734(ra) # 80004a62 <filestat>
}
    8000578c:	60e2                	ld	ra,24(sp)
    8000578e:	6442                	ld	s0,16(sp)
    80005790:	6105                	addi	sp,sp,32
    80005792:	8082                	ret

0000000080005794 <sys_link>:
{
    80005794:	7169                	addi	sp,sp,-304
    80005796:	f606                	sd	ra,296(sp)
    80005798:	f222                	sd	s0,288(sp)
    8000579a:	ee26                	sd	s1,280(sp)
    8000579c:	ea4a                	sd	s2,272(sp)
    8000579e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057a0:	08000613          	li	a2,128
    800057a4:	ed040593          	addi	a1,s0,-304
    800057a8:	4501                	li	a0,0
    800057aa:	ffffd097          	auipc	ra,0xffffd
    800057ae:	71a080e7          	jalr	1818(ra) # 80002ec4 <argstr>
    return -1;
    800057b2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057b4:	10054e63          	bltz	a0,800058d0 <sys_link+0x13c>
    800057b8:	08000613          	li	a2,128
    800057bc:	f5040593          	addi	a1,s0,-176
    800057c0:	4505                	li	a0,1
    800057c2:	ffffd097          	auipc	ra,0xffffd
    800057c6:	702080e7          	jalr	1794(ra) # 80002ec4 <argstr>
    return -1;
    800057ca:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057cc:	10054263          	bltz	a0,800058d0 <sys_link+0x13c>
  begin_op();
    800057d0:	fffff097          	auipc	ra,0xfffff
    800057d4:	d02080e7          	jalr	-766(ra) # 800044d2 <begin_op>
  if((ip = namei(old)) == 0){
    800057d8:	ed040513          	addi	a0,s0,-304
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	ad6080e7          	jalr	-1322(ra) # 800042b2 <namei>
    800057e4:	84aa                	mv	s1,a0
    800057e6:	c551                	beqz	a0,80005872 <sys_link+0xde>
  ilock(ip);
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	31e080e7          	jalr	798(ra) # 80003b06 <ilock>
  if(ip->type == T_DIR){
    800057f0:	04449703          	lh	a4,68(s1)
    800057f4:	4785                	li	a5,1
    800057f6:	08f70463          	beq	a4,a5,8000587e <sys_link+0xea>
  ip->nlink++;
    800057fa:	04a4d783          	lhu	a5,74(s1)
    800057fe:	2785                	addiw	a5,a5,1
    80005800:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005804:	8526                	mv	a0,s1
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	234080e7          	jalr	564(ra) # 80003a3a <iupdate>
  iunlock(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	3b8080e7          	jalr	952(ra) # 80003bc8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005818:	fd040593          	addi	a1,s0,-48
    8000581c:	f5040513          	addi	a0,s0,-176
    80005820:	fffff097          	auipc	ra,0xfffff
    80005824:	ab0080e7          	jalr	-1360(ra) # 800042d0 <nameiparent>
    80005828:	892a                	mv	s2,a0
    8000582a:	c935                	beqz	a0,8000589e <sys_link+0x10a>
  ilock(dp);
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	2da080e7          	jalr	730(ra) # 80003b06 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005834:	00092703          	lw	a4,0(s2)
    80005838:	409c                	lw	a5,0(s1)
    8000583a:	04f71d63          	bne	a4,a5,80005894 <sys_link+0x100>
    8000583e:	40d0                	lw	a2,4(s1)
    80005840:	fd040593          	addi	a1,s0,-48
    80005844:	854a                	mv	a0,s2
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	9ba080e7          	jalr	-1606(ra) # 80004200 <dirlink>
    8000584e:	04054363          	bltz	a0,80005894 <sys_link+0x100>
  iunlockput(dp);
    80005852:	854a                	mv	a0,s2
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	514080e7          	jalr	1300(ra) # 80003d68 <iunlockput>
  iput(ip);
    8000585c:	8526                	mv	a0,s1
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	462080e7          	jalr	1122(ra) # 80003cc0 <iput>
  end_op();
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	cea080e7          	jalr	-790(ra) # 80004550 <end_op>
  return 0;
    8000586e:	4781                	li	a5,0
    80005870:	a085                	j	800058d0 <sys_link+0x13c>
    end_op();
    80005872:	fffff097          	auipc	ra,0xfffff
    80005876:	cde080e7          	jalr	-802(ra) # 80004550 <end_op>
    return -1;
    8000587a:	57fd                	li	a5,-1
    8000587c:	a891                	j	800058d0 <sys_link+0x13c>
    iunlockput(ip);
    8000587e:	8526                	mv	a0,s1
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	4e8080e7          	jalr	1256(ra) # 80003d68 <iunlockput>
    end_op();
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	cc8080e7          	jalr	-824(ra) # 80004550 <end_op>
    return -1;
    80005890:	57fd                	li	a5,-1
    80005892:	a83d                	j	800058d0 <sys_link+0x13c>
    iunlockput(dp);
    80005894:	854a                	mv	a0,s2
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	4d2080e7          	jalr	1234(ra) # 80003d68 <iunlockput>
  ilock(ip);
    8000589e:	8526                	mv	a0,s1
    800058a0:	ffffe097          	auipc	ra,0xffffe
    800058a4:	266080e7          	jalr	614(ra) # 80003b06 <ilock>
  ip->nlink--;
    800058a8:	04a4d783          	lhu	a5,74(s1)
    800058ac:	37fd                	addiw	a5,a5,-1
    800058ae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058b2:	8526                	mv	a0,s1
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	186080e7          	jalr	390(ra) # 80003a3a <iupdate>
  iunlockput(ip);
    800058bc:	8526                	mv	a0,s1
    800058be:	ffffe097          	auipc	ra,0xffffe
    800058c2:	4aa080e7          	jalr	1194(ra) # 80003d68 <iunlockput>
  end_op();
    800058c6:	fffff097          	auipc	ra,0xfffff
    800058ca:	c8a080e7          	jalr	-886(ra) # 80004550 <end_op>
  return -1;
    800058ce:	57fd                	li	a5,-1
}
    800058d0:	853e                	mv	a0,a5
    800058d2:	70b2                	ld	ra,296(sp)
    800058d4:	7412                	ld	s0,288(sp)
    800058d6:	64f2                	ld	s1,280(sp)
    800058d8:	6952                	ld	s2,272(sp)
    800058da:	6155                	addi	sp,sp,304
    800058dc:	8082                	ret

00000000800058de <sys_unlink>:
{
    800058de:	7151                	addi	sp,sp,-240
    800058e0:	f586                	sd	ra,232(sp)
    800058e2:	f1a2                	sd	s0,224(sp)
    800058e4:	eda6                	sd	s1,216(sp)
    800058e6:	e9ca                	sd	s2,208(sp)
    800058e8:	e5ce                	sd	s3,200(sp)
    800058ea:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058ec:	08000613          	li	a2,128
    800058f0:	f3040593          	addi	a1,s0,-208
    800058f4:	4501                	li	a0,0
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	5ce080e7          	jalr	1486(ra) # 80002ec4 <argstr>
    800058fe:	18054163          	bltz	a0,80005a80 <sys_unlink+0x1a2>
  begin_op();
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	bd0080e7          	jalr	-1072(ra) # 800044d2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000590a:	fb040593          	addi	a1,s0,-80
    8000590e:	f3040513          	addi	a0,s0,-208
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	9be080e7          	jalr	-1602(ra) # 800042d0 <nameiparent>
    8000591a:	84aa                	mv	s1,a0
    8000591c:	c979                	beqz	a0,800059f2 <sys_unlink+0x114>
  ilock(dp);
    8000591e:	ffffe097          	auipc	ra,0xffffe
    80005922:	1e8080e7          	jalr	488(ra) # 80003b06 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005926:	00003597          	auipc	a1,0x3
    8000592a:	f0258593          	addi	a1,a1,-254 # 80008828 <syscalls+0x2c8>
    8000592e:	fb040513          	addi	a0,s0,-80
    80005932:	ffffe097          	auipc	ra,0xffffe
    80005936:	69e080e7          	jalr	1694(ra) # 80003fd0 <namecmp>
    8000593a:	14050a63          	beqz	a0,80005a8e <sys_unlink+0x1b0>
    8000593e:	00003597          	auipc	a1,0x3
    80005942:	ef258593          	addi	a1,a1,-270 # 80008830 <syscalls+0x2d0>
    80005946:	fb040513          	addi	a0,s0,-80
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	686080e7          	jalr	1670(ra) # 80003fd0 <namecmp>
    80005952:	12050e63          	beqz	a0,80005a8e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005956:	f2c40613          	addi	a2,s0,-212
    8000595a:	fb040593          	addi	a1,s0,-80
    8000595e:	8526                	mv	a0,s1
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	68a080e7          	jalr	1674(ra) # 80003fea <dirlookup>
    80005968:	892a                	mv	s2,a0
    8000596a:	12050263          	beqz	a0,80005a8e <sys_unlink+0x1b0>
  ilock(ip);
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	198080e7          	jalr	408(ra) # 80003b06 <ilock>
  if(ip->nlink < 1)
    80005976:	04a91783          	lh	a5,74(s2)
    8000597a:	08f05263          	blez	a5,800059fe <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000597e:	04491703          	lh	a4,68(s2)
    80005982:	4785                	li	a5,1
    80005984:	08f70563          	beq	a4,a5,80005a0e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005988:	4641                	li	a2,16
    8000598a:	4581                	li	a1,0
    8000598c:	fc040513          	addi	a0,s0,-64
    80005990:	ffffb097          	auipc	ra,0xffffb
    80005994:	40a080e7          	jalr	1034(ra) # 80000d9a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005998:	4741                	li	a4,16
    8000599a:	f2c42683          	lw	a3,-212(s0)
    8000599e:	fc040613          	addi	a2,s0,-64
    800059a2:	4581                	li	a1,0
    800059a4:	8526                	mv	a0,s1
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	50c080e7          	jalr	1292(ra) # 80003eb2 <writei>
    800059ae:	47c1                	li	a5,16
    800059b0:	0af51563          	bne	a0,a5,80005a5a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800059b4:	04491703          	lh	a4,68(s2)
    800059b8:	4785                	li	a5,1
    800059ba:	0af70863          	beq	a4,a5,80005a6a <sys_unlink+0x18c>
  iunlockput(dp);
    800059be:	8526                	mv	a0,s1
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	3a8080e7          	jalr	936(ra) # 80003d68 <iunlockput>
  ip->nlink--;
    800059c8:	04a95783          	lhu	a5,74(s2)
    800059cc:	37fd                	addiw	a5,a5,-1
    800059ce:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800059d2:	854a                	mv	a0,s2
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	066080e7          	jalr	102(ra) # 80003a3a <iupdate>
  iunlockput(ip);
    800059dc:	854a                	mv	a0,s2
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	38a080e7          	jalr	906(ra) # 80003d68 <iunlockput>
  end_op();
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	b6a080e7          	jalr	-1174(ra) # 80004550 <end_op>
  return 0;
    800059ee:	4501                	li	a0,0
    800059f0:	a84d                	j	80005aa2 <sys_unlink+0x1c4>
    end_op();
    800059f2:	fffff097          	auipc	ra,0xfffff
    800059f6:	b5e080e7          	jalr	-1186(ra) # 80004550 <end_op>
    return -1;
    800059fa:	557d                	li	a0,-1
    800059fc:	a05d                	j	80005aa2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800059fe:	00003517          	auipc	a0,0x3
    80005a02:	e3a50513          	addi	a0,a0,-454 # 80008838 <syscalls+0x2d8>
    80005a06:	ffffb097          	auipc	ra,0xffffb
    80005a0a:	b3a080e7          	jalr	-1222(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a0e:	04c92703          	lw	a4,76(s2)
    80005a12:	02000793          	li	a5,32
    80005a16:	f6e7f9e3          	bgeu	a5,a4,80005988 <sys_unlink+0xaa>
    80005a1a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a1e:	4741                	li	a4,16
    80005a20:	86ce                	mv	a3,s3
    80005a22:	f1840613          	addi	a2,s0,-232
    80005a26:	4581                	li	a1,0
    80005a28:	854a                	mv	a0,s2
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	390080e7          	jalr	912(ra) # 80003dba <readi>
    80005a32:	47c1                	li	a5,16
    80005a34:	00f51b63          	bne	a0,a5,80005a4a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a38:	f1845783          	lhu	a5,-232(s0)
    80005a3c:	e7a1                	bnez	a5,80005a84 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a3e:	29c1                	addiw	s3,s3,16
    80005a40:	04c92783          	lw	a5,76(s2)
    80005a44:	fcf9ede3          	bltu	s3,a5,80005a1e <sys_unlink+0x140>
    80005a48:	b781                	j	80005988 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a4a:	00003517          	auipc	a0,0x3
    80005a4e:	e0650513          	addi	a0,a0,-506 # 80008850 <syscalls+0x2f0>
    80005a52:	ffffb097          	auipc	ra,0xffffb
    80005a56:	aee080e7          	jalr	-1298(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005a5a:	00003517          	auipc	a0,0x3
    80005a5e:	e0e50513          	addi	a0,a0,-498 # 80008868 <syscalls+0x308>
    80005a62:	ffffb097          	auipc	ra,0xffffb
    80005a66:	ade080e7          	jalr	-1314(ra) # 80000540 <panic>
    dp->nlink--;
    80005a6a:	04a4d783          	lhu	a5,74(s1)
    80005a6e:	37fd                	addiw	a5,a5,-1
    80005a70:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a74:	8526                	mv	a0,s1
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	fc4080e7          	jalr	-60(ra) # 80003a3a <iupdate>
    80005a7e:	b781                	j	800059be <sys_unlink+0xe0>
    return -1;
    80005a80:	557d                	li	a0,-1
    80005a82:	a005                	j	80005aa2 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a84:	854a                	mv	a0,s2
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	2e2080e7          	jalr	738(ra) # 80003d68 <iunlockput>
  iunlockput(dp);
    80005a8e:	8526                	mv	a0,s1
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	2d8080e7          	jalr	728(ra) # 80003d68 <iunlockput>
  end_op();
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	ab8080e7          	jalr	-1352(ra) # 80004550 <end_op>
  return -1;
    80005aa0:	557d                	li	a0,-1
}
    80005aa2:	70ae                	ld	ra,232(sp)
    80005aa4:	740e                	ld	s0,224(sp)
    80005aa6:	64ee                	ld	s1,216(sp)
    80005aa8:	694e                	ld	s2,208(sp)
    80005aaa:	69ae                	ld	s3,200(sp)
    80005aac:	616d                	addi	sp,sp,240
    80005aae:	8082                	ret

0000000080005ab0 <sys_open>:

uint64
sys_open(void)
{
    80005ab0:	7131                	addi	sp,sp,-192
    80005ab2:	fd06                	sd	ra,184(sp)
    80005ab4:	f922                	sd	s0,176(sp)
    80005ab6:	f526                	sd	s1,168(sp)
    80005ab8:	f14a                	sd	s2,160(sp)
    80005aba:	ed4e                	sd	s3,152(sp)
    80005abc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005abe:	f4c40593          	addi	a1,s0,-180
    80005ac2:	4505                	li	a0,1
    80005ac4:	ffffd097          	auipc	ra,0xffffd
    80005ac8:	3c0080e7          	jalr	960(ra) # 80002e84 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005acc:	08000613          	li	a2,128
    80005ad0:	f5040593          	addi	a1,s0,-176
    80005ad4:	4501                	li	a0,0
    80005ad6:	ffffd097          	auipc	ra,0xffffd
    80005ada:	3ee080e7          	jalr	1006(ra) # 80002ec4 <argstr>
    80005ade:	87aa                	mv	a5,a0
    return -1;
    80005ae0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ae2:	0a07c963          	bltz	a5,80005b94 <sys_open+0xe4>

  begin_op();
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	9ec080e7          	jalr	-1556(ra) # 800044d2 <begin_op>

  if(omode & O_CREATE){
    80005aee:	f4c42783          	lw	a5,-180(s0)
    80005af2:	2007f793          	andi	a5,a5,512
    80005af6:	cfc5                	beqz	a5,80005bae <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005af8:	4681                	li	a3,0
    80005afa:	4601                	li	a2,0
    80005afc:	4589                	li	a1,2
    80005afe:	f5040513          	addi	a0,s0,-176
    80005b02:	00000097          	auipc	ra,0x0
    80005b06:	972080e7          	jalr	-1678(ra) # 80005474 <create>
    80005b0a:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b0c:	c959                	beqz	a0,80005ba2 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b0e:	04449703          	lh	a4,68(s1)
    80005b12:	478d                	li	a5,3
    80005b14:	00f71763          	bne	a4,a5,80005b22 <sys_open+0x72>
    80005b18:	0464d703          	lhu	a4,70(s1)
    80005b1c:	47a5                	li	a5,9
    80005b1e:	0ce7ed63          	bltu	a5,a4,80005bf8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	dbc080e7          	jalr	-580(ra) # 800048de <filealloc>
    80005b2a:	89aa                	mv	s3,a0
    80005b2c:	10050363          	beqz	a0,80005c32 <sys_open+0x182>
    80005b30:	00000097          	auipc	ra,0x0
    80005b34:	902080e7          	jalr	-1790(ra) # 80005432 <fdalloc>
    80005b38:	892a                	mv	s2,a0
    80005b3a:	0e054763          	bltz	a0,80005c28 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b3e:	04449703          	lh	a4,68(s1)
    80005b42:	478d                	li	a5,3
    80005b44:	0cf70563          	beq	a4,a5,80005c0e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b48:	4789                	li	a5,2
    80005b4a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b4e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b52:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b56:	f4c42783          	lw	a5,-180(s0)
    80005b5a:	0017c713          	xori	a4,a5,1
    80005b5e:	8b05                	andi	a4,a4,1
    80005b60:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b64:	0037f713          	andi	a4,a5,3
    80005b68:	00e03733          	snez	a4,a4
    80005b6c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b70:	4007f793          	andi	a5,a5,1024
    80005b74:	c791                	beqz	a5,80005b80 <sys_open+0xd0>
    80005b76:	04449703          	lh	a4,68(s1)
    80005b7a:	4789                	li	a5,2
    80005b7c:	0af70063          	beq	a4,a5,80005c1c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b80:	8526                	mv	a0,s1
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	046080e7          	jalr	70(ra) # 80003bc8 <iunlock>
  end_op();
    80005b8a:	fffff097          	auipc	ra,0xfffff
    80005b8e:	9c6080e7          	jalr	-1594(ra) # 80004550 <end_op>

  return fd;
    80005b92:	854a                	mv	a0,s2
}
    80005b94:	70ea                	ld	ra,184(sp)
    80005b96:	744a                	ld	s0,176(sp)
    80005b98:	74aa                	ld	s1,168(sp)
    80005b9a:	790a                	ld	s2,160(sp)
    80005b9c:	69ea                	ld	s3,152(sp)
    80005b9e:	6129                	addi	sp,sp,192
    80005ba0:	8082                	ret
      end_op();
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	9ae080e7          	jalr	-1618(ra) # 80004550 <end_op>
      return -1;
    80005baa:	557d                	li	a0,-1
    80005bac:	b7e5                	j	80005b94 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005bae:	f5040513          	addi	a0,s0,-176
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	700080e7          	jalr	1792(ra) # 800042b2 <namei>
    80005bba:	84aa                	mv	s1,a0
    80005bbc:	c905                	beqz	a0,80005bec <sys_open+0x13c>
    ilock(ip);
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	f48080e7          	jalr	-184(ra) # 80003b06 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005bc6:	04449703          	lh	a4,68(s1)
    80005bca:	4785                	li	a5,1
    80005bcc:	f4f711e3          	bne	a4,a5,80005b0e <sys_open+0x5e>
    80005bd0:	f4c42783          	lw	a5,-180(s0)
    80005bd4:	d7b9                	beqz	a5,80005b22 <sys_open+0x72>
      iunlockput(ip);
    80005bd6:	8526                	mv	a0,s1
    80005bd8:	ffffe097          	auipc	ra,0xffffe
    80005bdc:	190080e7          	jalr	400(ra) # 80003d68 <iunlockput>
      end_op();
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	970080e7          	jalr	-1680(ra) # 80004550 <end_op>
      return -1;
    80005be8:	557d                	li	a0,-1
    80005bea:	b76d                	j	80005b94 <sys_open+0xe4>
      end_op();
    80005bec:	fffff097          	auipc	ra,0xfffff
    80005bf0:	964080e7          	jalr	-1692(ra) # 80004550 <end_op>
      return -1;
    80005bf4:	557d                	li	a0,-1
    80005bf6:	bf79                	j	80005b94 <sys_open+0xe4>
    iunlockput(ip);
    80005bf8:	8526                	mv	a0,s1
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	16e080e7          	jalr	366(ra) # 80003d68 <iunlockput>
    end_op();
    80005c02:	fffff097          	auipc	ra,0xfffff
    80005c06:	94e080e7          	jalr	-1714(ra) # 80004550 <end_op>
    return -1;
    80005c0a:	557d                	li	a0,-1
    80005c0c:	b761                	j	80005b94 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c0e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c12:	04649783          	lh	a5,70(s1)
    80005c16:	02f99223          	sh	a5,36(s3)
    80005c1a:	bf25                	j	80005b52 <sys_open+0xa2>
    itrunc(ip);
    80005c1c:	8526                	mv	a0,s1
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	ff6080e7          	jalr	-10(ra) # 80003c14 <itrunc>
    80005c26:	bfa9                	j	80005b80 <sys_open+0xd0>
      fileclose(f);
    80005c28:	854e                	mv	a0,s3
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	d70080e7          	jalr	-656(ra) # 8000499a <fileclose>
    iunlockput(ip);
    80005c32:	8526                	mv	a0,s1
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	134080e7          	jalr	308(ra) # 80003d68 <iunlockput>
    end_op();
    80005c3c:	fffff097          	auipc	ra,0xfffff
    80005c40:	914080e7          	jalr	-1772(ra) # 80004550 <end_op>
    return -1;
    80005c44:	557d                	li	a0,-1
    80005c46:	b7b9                	j	80005b94 <sys_open+0xe4>

0000000080005c48 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c48:	7175                	addi	sp,sp,-144
    80005c4a:	e506                	sd	ra,136(sp)
    80005c4c:	e122                	sd	s0,128(sp)
    80005c4e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c50:	fffff097          	auipc	ra,0xfffff
    80005c54:	882080e7          	jalr	-1918(ra) # 800044d2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c58:	08000613          	li	a2,128
    80005c5c:	f7040593          	addi	a1,s0,-144
    80005c60:	4501                	li	a0,0
    80005c62:	ffffd097          	auipc	ra,0xffffd
    80005c66:	262080e7          	jalr	610(ra) # 80002ec4 <argstr>
    80005c6a:	02054963          	bltz	a0,80005c9c <sys_mkdir+0x54>
    80005c6e:	4681                	li	a3,0
    80005c70:	4601                	li	a2,0
    80005c72:	4585                	li	a1,1
    80005c74:	f7040513          	addi	a0,s0,-144
    80005c78:	fffff097          	auipc	ra,0xfffff
    80005c7c:	7fc080e7          	jalr	2044(ra) # 80005474 <create>
    80005c80:	cd11                	beqz	a0,80005c9c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c82:	ffffe097          	auipc	ra,0xffffe
    80005c86:	0e6080e7          	jalr	230(ra) # 80003d68 <iunlockput>
  end_op();
    80005c8a:	fffff097          	auipc	ra,0xfffff
    80005c8e:	8c6080e7          	jalr	-1850(ra) # 80004550 <end_op>
  return 0;
    80005c92:	4501                	li	a0,0
}
    80005c94:	60aa                	ld	ra,136(sp)
    80005c96:	640a                	ld	s0,128(sp)
    80005c98:	6149                	addi	sp,sp,144
    80005c9a:	8082                	ret
    end_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	8b4080e7          	jalr	-1868(ra) # 80004550 <end_op>
    return -1;
    80005ca4:	557d                	li	a0,-1
    80005ca6:	b7fd                	j	80005c94 <sys_mkdir+0x4c>

0000000080005ca8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ca8:	7135                	addi	sp,sp,-160
    80005caa:	ed06                	sd	ra,152(sp)
    80005cac:	e922                	sd	s0,144(sp)
    80005cae:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cb0:	fffff097          	auipc	ra,0xfffff
    80005cb4:	822080e7          	jalr	-2014(ra) # 800044d2 <begin_op>
  argint(1, &major);
    80005cb8:	f6c40593          	addi	a1,s0,-148
    80005cbc:	4505                	li	a0,1
    80005cbe:	ffffd097          	auipc	ra,0xffffd
    80005cc2:	1c6080e7          	jalr	454(ra) # 80002e84 <argint>
  argint(2, &minor);
    80005cc6:	f6840593          	addi	a1,s0,-152
    80005cca:	4509                	li	a0,2
    80005ccc:	ffffd097          	auipc	ra,0xffffd
    80005cd0:	1b8080e7          	jalr	440(ra) # 80002e84 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cd4:	08000613          	li	a2,128
    80005cd8:	f7040593          	addi	a1,s0,-144
    80005cdc:	4501                	li	a0,0
    80005cde:	ffffd097          	auipc	ra,0xffffd
    80005ce2:	1e6080e7          	jalr	486(ra) # 80002ec4 <argstr>
    80005ce6:	02054b63          	bltz	a0,80005d1c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005cea:	f6841683          	lh	a3,-152(s0)
    80005cee:	f6c41603          	lh	a2,-148(s0)
    80005cf2:	458d                	li	a1,3
    80005cf4:	f7040513          	addi	a0,s0,-144
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	77c080e7          	jalr	1916(ra) # 80005474 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d00:	cd11                	beqz	a0,80005d1c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	066080e7          	jalr	102(ra) # 80003d68 <iunlockput>
  end_op();
    80005d0a:	fffff097          	auipc	ra,0xfffff
    80005d0e:	846080e7          	jalr	-1978(ra) # 80004550 <end_op>
  return 0;
    80005d12:	4501                	li	a0,0
}
    80005d14:	60ea                	ld	ra,152(sp)
    80005d16:	644a                	ld	s0,144(sp)
    80005d18:	610d                	addi	sp,sp,160
    80005d1a:	8082                	ret
    end_op();
    80005d1c:	fffff097          	auipc	ra,0xfffff
    80005d20:	834080e7          	jalr	-1996(ra) # 80004550 <end_op>
    return -1;
    80005d24:	557d                	li	a0,-1
    80005d26:	b7fd                	j	80005d14 <sys_mknod+0x6c>

0000000080005d28 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d28:	7135                	addi	sp,sp,-160
    80005d2a:	ed06                	sd	ra,152(sp)
    80005d2c:	e922                	sd	s0,144(sp)
    80005d2e:	e526                	sd	s1,136(sp)
    80005d30:	e14a                	sd	s2,128(sp)
    80005d32:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d34:	ffffc097          	auipc	ra,0xffffc
    80005d38:	e3e080e7          	jalr	-450(ra) # 80001b72 <myproc>
    80005d3c:	892a                	mv	s2,a0
  
  begin_op();
    80005d3e:	ffffe097          	auipc	ra,0xffffe
    80005d42:	794080e7          	jalr	1940(ra) # 800044d2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d46:	08000613          	li	a2,128
    80005d4a:	f6040593          	addi	a1,s0,-160
    80005d4e:	4501                	li	a0,0
    80005d50:	ffffd097          	auipc	ra,0xffffd
    80005d54:	174080e7          	jalr	372(ra) # 80002ec4 <argstr>
    80005d58:	04054b63          	bltz	a0,80005dae <sys_chdir+0x86>
    80005d5c:	f6040513          	addi	a0,s0,-160
    80005d60:	ffffe097          	auipc	ra,0xffffe
    80005d64:	552080e7          	jalr	1362(ra) # 800042b2 <namei>
    80005d68:	84aa                	mv	s1,a0
    80005d6a:	c131                	beqz	a0,80005dae <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d6c:	ffffe097          	auipc	ra,0xffffe
    80005d70:	d9a080e7          	jalr	-614(ra) # 80003b06 <ilock>
  if(ip->type != T_DIR){
    80005d74:	04449703          	lh	a4,68(s1)
    80005d78:	4785                	li	a5,1
    80005d7a:	04f71063          	bne	a4,a5,80005dba <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d7e:	8526                	mv	a0,s1
    80005d80:	ffffe097          	auipc	ra,0xffffe
    80005d84:	e48080e7          	jalr	-440(ra) # 80003bc8 <iunlock>
  iput(p->cwd);
    80005d88:	15093503          	ld	a0,336(s2)
    80005d8c:	ffffe097          	auipc	ra,0xffffe
    80005d90:	f34080e7          	jalr	-204(ra) # 80003cc0 <iput>
  end_op();
    80005d94:	ffffe097          	auipc	ra,0xffffe
    80005d98:	7bc080e7          	jalr	1980(ra) # 80004550 <end_op>
  p->cwd = ip;
    80005d9c:	14993823          	sd	s1,336(s2)
  return 0;
    80005da0:	4501                	li	a0,0
}
    80005da2:	60ea                	ld	ra,152(sp)
    80005da4:	644a                	ld	s0,144(sp)
    80005da6:	64aa                	ld	s1,136(sp)
    80005da8:	690a                	ld	s2,128(sp)
    80005daa:	610d                	addi	sp,sp,160
    80005dac:	8082                	ret
    end_op();
    80005dae:	ffffe097          	auipc	ra,0xffffe
    80005db2:	7a2080e7          	jalr	1954(ra) # 80004550 <end_op>
    return -1;
    80005db6:	557d                	li	a0,-1
    80005db8:	b7ed                	j	80005da2 <sys_chdir+0x7a>
    iunlockput(ip);
    80005dba:	8526                	mv	a0,s1
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	fac080e7          	jalr	-84(ra) # 80003d68 <iunlockput>
    end_op();
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	78c080e7          	jalr	1932(ra) # 80004550 <end_op>
    return -1;
    80005dcc:	557d                	li	a0,-1
    80005dce:	bfd1                	j	80005da2 <sys_chdir+0x7a>

0000000080005dd0 <sys_exec>:

uint64
sys_exec(void)
{
    80005dd0:	7145                	addi	sp,sp,-464
    80005dd2:	e786                	sd	ra,456(sp)
    80005dd4:	e3a2                	sd	s0,448(sp)
    80005dd6:	ff26                	sd	s1,440(sp)
    80005dd8:	fb4a                	sd	s2,432(sp)
    80005dda:	f74e                	sd	s3,424(sp)
    80005ddc:	f352                	sd	s4,416(sp)
    80005dde:	ef56                	sd	s5,408(sp)
    80005de0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005de2:	e3840593          	addi	a1,s0,-456
    80005de6:	4505                	li	a0,1
    80005de8:	ffffd097          	auipc	ra,0xffffd
    80005dec:	0bc080e7          	jalr	188(ra) # 80002ea4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005df0:	08000613          	li	a2,128
    80005df4:	f4040593          	addi	a1,s0,-192
    80005df8:	4501                	li	a0,0
    80005dfa:	ffffd097          	auipc	ra,0xffffd
    80005dfe:	0ca080e7          	jalr	202(ra) # 80002ec4 <argstr>
    80005e02:	87aa                	mv	a5,a0
    return -1;
    80005e04:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e06:	0c07c363          	bltz	a5,80005ecc <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005e0a:	10000613          	li	a2,256
    80005e0e:	4581                	li	a1,0
    80005e10:	e4040513          	addi	a0,s0,-448
    80005e14:	ffffb097          	auipc	ra,0xffffb
    80005e18:	f86080e7          	jalr	-122(ra) # 80000d9a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e1c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e20:	89a6                	mv	s3,s1
    80005e22:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e24:	02000a13          	li	s4,32
    80005e28:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e2c:	00391513          	slli	a0,s2,0x3
    80005e30:	e3040593          	addi	a1,s0,-464
    80005e34:	e3843783          	ld	a5,-456(s0)
    80005e38:	953e                	add	a0,a0,a5
    80005e3a:	ffffd097          	auipc	ra,0xffffd
    80005e3e:	fac080e7          	jalr	-84(ra) # 80002de6 <fetchaddr>
    80005e42:	02054a63          	bltz	a0,80005e76 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005e46:	e3043783          	ld	a5,-464(s0)
    80005e4a:	c3b9                	beqz	a5,80005e90 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e4c:	ffffb097          	auipc	ra,0xffffb
    80005e50:	d16080e7          	jalr	-746(ra) # 80000b62 <kalloc>
    80005e54:	85aa                	mv	a1,a0
    80005e56:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e5a:	cd11                	beqz	a0,80005e76 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e5c:	6605                	lui	a2,0x1
    80005e5e:	e3043503          	ld	a0,-464(s0)
    80005e62:	ffffd097          	auipc	ra,0xffffd
    80005e66:	fd6080e7          	jalr	-42(ra) # 80002e38 <fetchstr>
    80005e6a:	00054663          	bltz	a0,80005e76 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e6e:	0905                	addi	s2,s2,1
    80005e70:	09a1                	addi	s3,s3,8
    80005e72:	fb491be3          	bne	s2,s4,80005e28 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e76:	f4040913          	addi	s2,s0,-192
    80005e7a:	6088                	ld	a0,0(s1)
    80005e7c:	c539                	beqz	a0,80005eca <sys_exec+0xfa>
    kfree(argv[i]);
    80005e7e:	ffffb097          	auipc	ra,0xffffb
    80005e82:	b7c080e7          	jalr	-1156(ra) # 800009fa <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e86:	04a1                	addi	s1,s1,8
    80005e88:	ff2499e3          	bne	s1,s2,80005e7a <sys_exec+0xaa>
  return -1;
    80005e8c:	557d                	li	a0,-1
    80005e8e:	a83d                	j	80005ecc <sys_exec+0xfc>
      argv[i] = 0;
    80005e90:	0a8e                	slli	s5,s5,0x3
    80005e92:	fc0a8793          	addi	a5,s5,-64
    80005e96:	00878ab3          	add	s5,a5,s0
    80005e9a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e9e:	e4040593          	addi	a1,s0,-448
    80005ea2:	f4040513          	addi	a0,s0,-192
    80005ea6:	fffff097          	auipc	ra,0xfffff
    80005eaa:	16e080e7          	jalr	366(ra) # 80005014 <exec>
    80005eae:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eb0:	f4040993          	addi	s3,s0,-192
    80005eb4:	6088                	ld	a0,0(s1)
    80005eb6:	c901                	beqz	a0,80005ec6 <sys_exec+0xf6>
    kfree(argv[i]);
    80005eb8:	ffffb097          	auipc	ra,0xffffb
    80005ebc:	b42080e7          	jalr	-1214(ra) # 800009fa <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ec0:	04a1                	addi	s1,s1,8
    80005ec2:	ff3499e3          	bne	s1,s3,80005eb4 <sys_exec+0xe4>
  return ret;
    80005ec6:	854a                	mv	a0,s2
    80005ec8:	a011                	j	80005ecc <sys_exec+0xfc>
  return -1;
    80005eca:	557d                	li	a0,-1
}
    80005ecc:	60be                	ld	ra,456(sp)
    80005ece:	641e                	ld	s0,448(sp)
    80005ed0:	74fa                	ld	s1,440(sp)
    80005ed2:	795a                	ld	s2,432(sp)
    80005ed4:	79ba                	ld	s3,424(sp)
    80005ed6:	7a1a                	ld	s4,416(sp)
    80005ed8:	6afa                	ld	s5,408(sp)
    80005eda:	6179                	addi	sp,sp,464
    80005edc:	8082                	ret

0000000080005ede <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ede:	7139                	addi	sp,sp,-64
    80005ee0:	fc06                	sd	ra,56(sp)
    80005ee2:	f822                	sd	s0,48(sp)
    80005ee4:	f426                	sd	s1,40(sp)
    80005ee6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ee8:	ffffc097          	auipc	ra,0xffffc
    80005eec:	c8a080e7          	jalr	-886(ra) # 80001b72 <myproc>
    80005ef0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005ef2:	fd840593          	addi	a1,s0,-40
    80005ef6:	4501                	li	a0,0
    80005ef8:	ffffd097          	auipc	ra,0xffffd
    80005efc:	fac080e7          	jalr	-84(ra) # 80002ea4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f00:	fc840593          	addi	a1,s0,-56
    80005f04:	fd040513          	addi	a0,s0,-48
    80005f08:	fffff097          	auipc	ra,0xfffff
    80005f0c:	dc2080e7          	jalr	-574(ra) # 80004cca <pipealloc>
    return -1;
    80005f10:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f12:	0c054463          	bltz	a0,80005fda <sys_pipe+0xfc>
  fd0 = -1;
    80005f16:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f1a:	fd043503          	ld	a0,-48(s0)
    80005f1e:	fffff097          	auipc	ra,0xfffff
    80005f22:	514080e7          	jalr	1300(ra) # 80005432 <fdalloc>
    80005f26:	fca42223          	sw	a0,-60(s0)
    80005f2a:	08054b63          	bltz	a0,80005fc0 <sys_pipe+0xe2>
    80005f2e:	fc843503          	ld	a0,-56(s0)
    80005f32:	fffff097          	auipc	ra,0xfffff
    80005f36:	500080e7          	jalr	1280(ra) # 80005432 <fdalloc>
    80005f3a:	fca42023          	sw	a0,-64(s0)
    80005f3e:	06054863          	bltz	a0,80005fae <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f42:	4691                	li	a3,4
    80005f44:	fc440613          	addi	a2,s0,-60
    80005f48:	fd843583          	ld	a1,-40(s0)
    80005f4c:	68a8                	ld	a0,80(s1)
    80005f4e:	ffffb097          	auipc	ra,0xffffb
    80005f52:	7e6080e7          	jalr	2022(ra) # 80001734 <copyout>
    80005f56:	02054063          	bltz	a0,80005f76 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f5a:	4691                	li	a3,4
    80005f5c:	fc040613          	addi	a2,s0,-64
    80005f60:	fd843583          	ld	a1,-40(s0)
    80005f64:	0591                	addi	a1,a1,4
    80005f66:	68a8                	ld	a0,80(s1)
    80005f68:	ffffb097          	auipc	ra,0xffffb
    80005f6c:	7cc080e7          	jalr	1996(ra) # 80001734 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f70:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f72:	06055463          	bgez	a0,80005fda <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f76:	fc442783          	lw	a5,-60(s0)
    80005f7a:	07e9                	addi	a5,a5,26
    80005f7c:	078e                	slli	a5,a5,0x3
    80005f7e:	97a6                	add	a5,a5,s1
    80005f80:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f84:	fc042783          	lw	a5,-64(s0)
    80005f88:	07e9                	addi	a5,a5,26
    80005f8a:	078e                	slli	a5,a5,0x3
    80005f8c:	94be                	add	s1,s1,a5
    80005f8e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f92:	fd043503          	ld	a0,-48(s0)
    80005f96:	fffff097          	auipc	ra,0xfffff
    80005f9a:	a04080e7          	jalr	-1532(ra) # 8000499a <fileclose>
    fileclose(wf);
    80005f9e:	fc843503          	ld	a0,-56(s0)
    80005fa2:	fffff097          	auipc	ra,0xfffff
    80005fa6:	9f8080e7          	jalr	-1544(ra) # 8000499a <fileclose>
    return -1;
    80005faa:	57fd                	li	a5,-1
    80005fac:	a03d                	j	80005fda <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005fae:	fc442783          	lw	a5,-60(s0)
    80005fb2:	0007c763          	bltz	a5,80005fc0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005fb6:	07e9                	addi	a5,a5,26
    80005fb8:	078e                	slli	a5,a5,0x3
    80005fba:	97a6                	add	a5,a5,s1
    80005fbc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005fc0:	fd043503          	ld	a0,-48(s0)
    80005fc4:	fffff097          	auipc	ra,0xfffff
    80005fc8:	9d6080e7          	jalr	-1578(ra) # 8000499a <fileclose>
    fileclose(wf);
    80005fcc:	fc843503          	ld	a0,-56(s0)
    80005fd0:	fffff097          	auipc	ra,0xfffff
    80005fd4:	9ca080e7          	jalr	-1590(ra) # 8000499a <fileclose>
    return -1;
    80005fd8:	57fd                	li	a5,-1
}
    80005fda:	853e                	mv	a0,a5
    80005fdc:	70e2                	ld	ra,56(sp)
    80005fde:	7442                	ld	s0,48(sp)
    80005fe0:	74a2                	ld	s1,40(sp)
    80005fe2:	6121                	addi	sp,sp,64
    80005fe4:	8082                	ret
	...

0000000080005ff0 <kernelvec>:
    80005ff0:	7111                	addi	sp,sp,-256
    80005ff2:	e006                	sd	ra,0(sp)
    80005ff4:	e40a                	sd	sp,8(sp)
    80005ff6:	e80e                	sd	gp,16(sp)
    80005ff8:	ec12                	sd	tp,24(sp)
    80005ffa:	f016                	sd	t0,32(sp)
    80005ffc:	f41a                	sd	t1,40(sp)
    80005ffe:	f81e                	sd	t2,48(sp)
    80006000:	fc22                	sd	s0,56(sp)
    80006002:	e0a6                	sd	s1,64(sp)
    80006004:	e4aa                	sd	a0,72(sp)
    80006006:	e8ae                	sd	a1,80(sp)
    80006008:	ecb2                	sd	a2,88(sp)
    8000600a:	f0b6                	sd	a3,96(sp)
    8000600c:	f4ba                	sd	a4,104(sp)
    8000600e:	f8be                	sd	a5,112(sp)
    80006010:	fcc2                	sd	a6,120(sp)
    80006012:	e146                	sd	a7,128(sp)
    80006014:	e54a                	sd	s2,136(sp)
    80006016:	e94e                	sd	s3,144(sp)
    80006018:	ed52                	sd	s4,152(sp)
    8000601a:	f156                	sd	s5,160(sp)
    8000601c:	f55a                	sd	s6,168(sp)
    8000601e:	f95e                	sd	s7,176(sp)
    80006020:	fd62                	sd	s8,184(sp)
    80006022:	e1e6                	sd	s9,192(sp)
    80006024:	e5ea                	sd	s10,200(sp)
    80006026:	e9ee                	sd	s11,208(sp)
    80006028:	edf2                	sd	t3,216(sp)
    8000602a:	f1f6                	sd	t4,224(sp)
    8000602c:	f5fa                	sd	t5,232(sp)
    8000602e:	f9fe                	sd	t6,240(sp)
    80006030:	c83fc0ef          	jal	ra,80002cb2 <kerneltrap>
    80006034:	6082                	ld	ra,0(sp)
    80006036:	6122                	ld	sp,8(sp)
    80006038:	61c2                	ld	gp,16(sp)
    8000603a:	7282                	ld	t0,32(sp)
    8000603c:	7322                	ld	t1,40(sp)
    8000603e:	73c2                	ld	t2,48(sp)
    80006040:	7462                	ld	s0,56(sp)
    80006042:	6486                	ld	s1,64(sp)
    80006044:	6526                	ld	a0,72(sp)
    80006046:	65c6                	ld	a1,80(sp)
    80006048:	6666                	ld	a2,88(sp)
    8000604a:	7686                	ld	a3,96(sp)
    8000604c:	7726                	ld	a4,104(sp)
    8000604e:	77c6                	ld	a5,112(sp)
    80006050:	7866                	ld	a6,120(sp)
    80006052:	688a                	ld	a7,128(sp)
    80006054:	692a                	ld	s2,136(sp)
    80006056:	69ca                	ld	s3,144(sp)
    80006058:	6a6a                	ld	s4,152(sp)
    8000605a:	7a8a                	ld	s5,160(sp)
    8000605c:	7b2a                	ld	s6,168(sp)
    8000605e:	7bca                	ld	s7,176(sp)
    80006060:	7c6a                	ld	s8,184(sp)
    80006062:	6c8e                	ld	s9,192(sp)
    80006064:	6d2e                	ld	s10,200(sp)
    80006066:	6dce                	ld	s11,208(sp)
    80006068:	6e6e                	ld	t3,216(sp)
    8000606a:	7e8e                	ld	t4,224(sp)
    8000606c:	7f2e                	ld	t5,232(sp)
    8000606e:	7fce                	ld	t6,240(sp)
    80006070:	6111                	addi	sp,sp,256
    80006072:	10200073          	sret
    80006076:	00000013          	nop
    8000607a:	00000013          	nop
    8000607e:	0001                	nop

0000000080006080 <timervec>:
    80006080:	34051573          	csrrw	a0,mscratch,a0
    80006084:	e10c                	sd	a1,0(a0)
    80006086:	e510                	sd	a2,8(a0)
    80006088:	e914                	sd	a3,16(a0)
    8000608a:	6d0c                	ld	a1,24(a0)
    8000608c:	7110                	ld	a2,32(a0)
    8000608e:	6194                	ld	a3,0(a1)
    80006090:	96b2                	add	a3,a3,a2
    80006092:	e194                	sd	a3,0(a1)
    80006094:	4589                	li	a1,2
    80006096:	14459073          	csrw	sip,a1
    8000609a:	6914                	ld	a3,16(a0)
    8000609c:	6510                	ld	a2,8(a0)
    8000609e:	610c                	ld	a1,0(a0)
    800060a0:	34051573          	csrrw	a0,mscratch,a0
    800060a4:	30200073          	mret
	...

00000000800060aa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060aa:	1141                	addi	sp,sp,-16
    800060ac:	e422                	sd	s0,8(sp)
    800060ae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060b0:	0c0007b7          	lui	a5,0xc000
    800060b4:	4705                	li	a4,1
    800060b6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060b8:	c3d8                	sw	a4,4(a5)
}
    800060ba:	6422                	ld	s0,8(sp)
    800060bc:	0141                	addi	sp,sp,16
    800060be:	8082                	ret

00000000800060c0 <plicinithart>:

void
plicinithart(void)
{
    800060c0:	1141                	addi	sp,sp,-16
    800060c2:	e406                	sd	ra,8(sp)
    800060c4:	e022                	sd	s0,0(sp)
    800060c6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	a7e080e7          	jalr	-1410(ra) # 80001b46 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060d0:	0085171b          	slliw	a4,a0,0x8
    800060d4:	0c0027b7          	lui	a5,0xc002
    800060d8:	97ba                	add	a5,a5,a4
    800060da:	40200713          	li	a4,1026
    800060de:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060e2:	00d5151b          	slliw	a0,a0,0xd
    800060e6:	0c2017b7          	lui	a5,0xc201
    800060ea:	97aa                	add	a5,a5,a0
    800060ec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800060f0:	60a2                	ld	ra,8(sp)
    800060f2:	6402                	ld	s0,0(sp)
    800060f4:	0141                	addi	sp,sp,16
    800060f6:	8082                	ret

00000000800060f8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060f8:	1141                	addi	sp,sp,-16
    800060fa:	e406                	sd	ra,8(sp)
    800060fc:	e022                	sd	s0,0(sp)
    800060fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006100:	ffffc097          	auipc	ra,0xffffc
    80006104:	a46080e7          	jalr	-1466(ra) # 80001b46 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006108:	00d5151b          	slliw	a0,a0,0xd
    8000610c:	0c2017b7          	lui	a5,0xc201
    80006110:	97aa                	add	a5,a5,a0
  return irq;
}
    80006112:	43c8                	lw	a0,4(a5)
    80006114:	60a2                	ld	ra,8(sp)
    80006116:	6402                	ld	s0,0(sp)
    80006118:	0141                	addi	sp,sp,16
    8000611a:	8082                	ret

000000008000611c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000611c:	1101                	addi	sp,sp,-32
    8000611e:	ec06                	sd	ra,24(sp)
    80006120:	e822                	sd	s0,16(sp)
    80006122:	e426                	sd	s1,8(sp)
    80006124:	1000                	addi	s0,sp,32
    80006126:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	a1e080e7          	jalr	-1506(ra) # 80001b46 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006130:	00d5151b          	slliw	a0,a0,0xd
    80006134:	0c2017b7          	lui	a5,0xc201
    80006138:	97aa                	add	a5,a5,a0
    8000613a:	c3c4                	sw	s1,4(a5)
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6105                	addi	sp,sp,32
    80006144:	8082                	ret

0000000080006146 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006146:	1141                	addi	sp,sp,-16
    80006148:	e406                	sd	ra,8(sp)
    8000614a:	e022                	sd	s0,0(sp)
    8000614c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000614e:	479d                	li	a5,7
    80006150:	04a7cc63          	blt	a5,a0,800061a8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006154:	0001c797          	auipc	a5,0x1c
    80006158:	c4c78793          	addi	a5,a5,-948 # 80021da0 <disk>
    8000615c:	97aa                	add	a5,a5,a0
    8000615e:	0187c783          	lbu	a5,24(a5)
    80006162:	ebb9                	bnez	a5,800061b8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006164:	00451693          	slli	a3,a0,0x4
    80006168:	0001c797          	auipc	a5,0x1c
    8000616c:	c3878793          	addi	a5,a5,-968 # 80021da0 <disk>
    80006170:	6398                	ld	a4,0(a5)
    80006172:	9736                	add	a4,a4,a3
    80006174:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80006178:	6398                	ld	a4,0(a5)
    8000617a:	9736                	add	a4,a4,a3
    8000617c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006180:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006184:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006188:	97aa                	add	a5,a5,a0
    8000618a:	4705                	li	a4,1
    8000618c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006190:	0001c517          	auipc	a0,0x1c
    80006194:	c2850513          	addi	a0,a0,-984 # 80021db8 <disk+0x18>
    80006198:	ffffc097          	auipc	ra,0xffffc
    8000619c:	1a6080e7          	jalr	422(ra) # 8000233e <wakeup>
}
    800061a0:	60a2                	ld	ra,8(sp)
    800061a2:	6402                	ld	s0,0(sp)
    800061a4:	0141                	addi	sp,sp,16
    800061a6:	8082                	ret
    panic("free_desc 1");
    800061a8:	00002517          	auipc	a0,0x2
    800061ac:	6d050513          	addi	a0,a0,1744 # 80008878 <syscalls+0x318>
    800061b0:	ffffa097          	auipc	ra,0xffffa
    800061b4:	390080e7          	jalr	912(ra) # 80000540 <panic>
    panic("free_desc 2");
    800061b8:	00002517          	auipc	a0,0x2
    800061bc:	6d050513          	addi	a0,a0,1744 # 80008888 <syscalls+0x328>
    800061c0:	ffffa097          	auipc	ra,0xffffa
    800061c4:	380080e7          	jalr	896(ra) # 80000540 <panic>

00000000800061c8 <virtio_disk_init>:
{
    800061c8:	1101                	addi	sp,sp,-32
    800061ca:	ec06                	sd	ra,24(sp)
    800061cc:	e822                	sd	s0,16(sp)
    800061ce:	e426                	sd	s1,8(sp)
    800061d0:	e04a                	sd	s2,0(sp)
    800061d2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061d4:	00002597          	auipc	a1,0x2
    800061d8:	6c458593          	addi	a1,a1,1732 # 80008898 <syscalls+0x338>
    800061dc:	0001c517          	auipc	a0,0x1c
    800061e0:	cec50513          	addi	a0,a0,-788 # 80021ec8 <disk+0x128>
    800061e4:	ffffb097          	auipc	ra,0xffffb
    800061e8:	a2a080e7          	jalr	-1494(ra) # 80000c0e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061ec:	100017b7          	lui	a5,0x10001
    800061f0:	4398                	lw	a4,0(a5)
    800061f2:	2701                	sext.w	a4,a4
    800061f4:	747277b7          	lui	a5,0x74727
    800061f8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061fc:	14f71b63          	bne	a4,a5,80006352 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006200:	100017b7          	lui	a5,0x10001
    80006204:	43dc                	lw	a5,4(a5)
    80006206:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006208:	4709                	li	a4,2
    8000620a:	14e79463          	bne	a5,a4,80006352 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000620e:	100017b7          	lui	a5,0x10001
    80006212:	479c                	lw	a5,8(a5)
    80006214:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006216:	12e79e63          	bne	a5,a4,80006352 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000621a:	100017b7          	lui	a5,0x10001
    8000621e:	47d8                	lw	a4,12(a5)
    80006220:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006222:	554d47b7          	lui	a5,0x554d4
    80006226:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000622a:	12f71463          	bne	a4,a5,80006352 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000622e:	100017b7          	lui	a5,0x10001
    80006232:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006236:	4705                	li	a4,1
    80006238:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000623a:	470d                	li	a4,3
    8000623c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000623e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006240:	c7ffe6b7          	lui	a3,0xc7ffe
    80006244:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc87f>
    80006248:	8f75                	and	a4,a4,a3
    8000624a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000624c:	472d                	li	a4,11
    8000624e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006250:	5bbc                	lw	a5,112(a5)
    80006252:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006256:	8ba1                	andi	a5,a5,8
    80006258:	10078563          	beqz	a5,80006362 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000625c:	100017b7          	lui	a5,0x10001
    80006260:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006264:	43fc                	lw	a5,68(a5)
    80006266:	2781                	sext.w	a5,a5
    80006268:	10079563          	bnez	a5,80006372 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000626c:	100017b7          	lui	a5,0x10001
    80006270:	5bdc                	lw	a5,52(a5)
    80006272:	2781                	sext.w	a5,a5
  if(max == 0)
    80006274:	10078763          	beqz	a5,80006382 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006278:	471d                	li	a4,7
    8000627a:	10f77c63          	bgeu	a4,a5,80006392 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000627e:	ffffb097          	auipc	ra,0xffffb
    80006282:	8e4080e7          	jalr	-1820(ra) # 80000b62 <kalloc>
    80006286:	0001c497          	auipc	s1,0x1c
    8000628a:	b1a48493          	addi	s1,s1,-1254 # 80021da0 <disk>
    8000628e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006290:	ffffb097          	auipc	ra,0xffffb
    80006294:	8d2080e7          	jalr	-1838(ra) # 80000b62 <kalloc>
    80006298:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000629a:	ffffb097          	auipc	ra,0xffffb
    8000629e:	8c8080e7          	jalr	-1848(ra) # 80000b62 <kalloc>
    800062a2:	87aa                	mv	a5,a0
    800062a4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800062a6:	6088                	ld	a0,0(s1)
    800062a8:	cd6d                	beqz	a0,800063a2 <virtio_disk_init+0x1da>
    800062aa:	0001c717          	auipc	a4,0x1c
    800062ae:	afe73703          	ld	a4,-1282(a4) # 80021da8 <disk+0x8>
    800062b2:	cb65                	beqz	a4,800063a2 <virtio_disk_init+0x1da>
    800062b4:	c7fd                	beqz	a5,800063a2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800062b6:	6605                	lui	a2,0x1
    800062b8:	4581                	li	a1,0
    800062ba:	ffffb097          	auipc	ra,0xffffb
    800062be:	ae0080e7          	jalr	-1312(ra) # 80000d9a <memset>
  memset(disk.avail, 0, PGSIZE);
    800062c2:	0001c497          	auipc	s1,0x1c
    800062c6:	ade48493          	addi	s1,s1,-1314 # 80021da0 <disk>
    800062ca:	6605                	lui	a2,0x1
    800062cc:	4581                	li	a1,0
    800062ce:	6488                	ld	a0,8(s1)
    800062d0:	ffffb097          	auipc	ra,0xffffb
    800062d4:	aca080e7          	jalr	-1334(ra) # 80000d9a <memset>
  memset(disk.used, 0, PGSIZE);
    800062d8:	6605                	lui	a2,0x1
    800062da:	4581                	li	a1,0
    800062dc:	6888                	ld	a0,16(s1)
    800062de:	ffffb097          	auipc	ra,0xffffb
    800062e2:	abc080e7          	jalr	-1348(ra) # 80000d9a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800062e6:	100017b7          	lui	a5,0x10001
    800062ea:	4721                	li	a4,8
    800062ec:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800062ee:	4098                	lw	a4,0(s1)
    800062f0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800062f4:	40d8                	lw	a4,4(s1)
    800062f6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800062fa:	6498                	ld	a4,8(s1)
    800062fc:	0007069b          	sext.w	a3,a4
    80006300:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006304:	9701                	srai	a4,a4,0x20
    80006306:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000630a:	6898                	ld	a4,16(s1)
    8000630c:	0007069b          	sext.w	a3,a4
    80006310:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006314:	9701                	srai	a4,a4,0x20
    80006316:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000631a:	4705                	li	a4,1
    8000631c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000631e:	00e48c23          	sb	a4,24(s1)
    80006322:	00e48ca3          	sb	a4,25(s1)
    80006326:	00e48d23          	sb	a4,26(s1)
    8000632a:	00e48da3          	sb	a4,27(s1)
    8000632e:	00e48e23          	sb	a4,28(s1)
    80006332:	00e48ea3          	sb	a4,29(s1)
    80006336:	00e48f23          	sb	a4,30(s1)
    8000633a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000633e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006342:	0727a823          	sw	s2,112(a5)
}
    80006346:	60e2                	ld	ra,24(sp)
    80006348:	6442                	ld	s0,16(sp)
    8000634a:	64a2                	ld	s1,8(sp)
    8000634c:	6902                	ld	s2,0(sp)
    8000634e:	6105                	addi	sp,sp,32
    80006350:	8082                	ret
    panic("could not find virtio disk");
    80006352:	00002517          	auipc	a0,0x2
    80006356:	55650513          	addi	a0,a0,1366 # 800088a8 <syscalls+0x348>
    8000635a:	ffffa097          	auipc	ra,0xffffa
    8000635e:	1e6080e7          	jalr	486(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006362:	00002517          	auipc	a0,0x2
    80006366:	56650513          	addi	a0,a0,1382 # 800088c8 <syscalls+0x368>
    8000636a:	ffffa097          	auipc	ra,0xffffa
    8000636e:	1d6080e7          	jalr	470(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006372:	00002517          	auipc	a0,0x2
    80006376:	57650513          	addi	a0,a0,1398 # 800088e8 <syscalls+0x388>
    8000637a:	ffffa097          	auipc	ra,0xffffa
    8000637e:	1c6080e7          	jalr	454(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006382:	00002517          	auipc	a0,0x2
    80006386:	58650513          	addi	a0,a0,1414 # 80008908 <syscalls+0x3a8>
    8000638a:	ffffa097          	auipc	ra,0xffffa
    8000638e:	1b6080e7          	jalr	438(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006392:	00002517          	auipc	a0,0x2
    80006396:	59650513          	addi	a0,a0,1430 # 80008928 <syscalls+0x3c8>
    8000639a:	ffffa097          	auipc	ra,0xffffa
    8000639e:	1a6080e7          	jalr	422(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800063a2:	00002517          	auipc	a0,0x2
    800063a6:	5a650513          	addi	a0,a0,1446 # 80008948 <syscalls+0x3e8>
    800063aa:	ffffa097          	auipc	ra,0xffffa
    800063ae:	196080e7          	jalr	406(ra) # 80000540 <panic>

00000000800063b2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063b2:	7119                	addi	sp,sp,-128
    800063b4:	fc86                	sd	ra,120(sp)
    800063b6:	f8a2                	sd	s0,112(sp)
    800063b8:	f4a6                	sd	s1,104(sp)
    800063ba:	f0ca                	sd	s2,96(sp)
    800063bc:	ecce                	sd	s3,88(sp)
    800063be:	e8d2                	sd	s4,80(sp)
    800063c0:	e4d6                	sd	s5,72(sp)
    800063c2:	e0da                	sd	s6,64(sp)
    800063c4:	fc5e                	sd	s7,56(sp)
    800063c6:	f862                	sd	s8,48(sp)
    800063c8:	f466                	sd	s9,40(sp)
    800063ca:	f06a                	sd	s10,32(sp)
    800063cc:	ec6e                	sd	s11,24(sp)
    800063ce:	0100                	addi	s0,sp,128
    800063d0:	8aaa                	mv	s5,a0
    800063d2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800063d4:	00c52d03          	lw	s10,12(a0)
    800063d8:	001d1d1b          	slliw	s10,s10,0x1
    800063dc:	1d02                	slli	s10,s10,0x20
    800063de:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800063e2:	0001c517          	auipc	a0,0x1c
    800063e6:	ae650513          	addi	a0,a0,-1306 # 80021ec8 <disk+0x128>
    800063ea:	ffffb097          	auipc	ra,0xffffb
    800063ee:	8b4080e7          	jalr	-1868(ra) # 80000c9e <acquire>
  for(int i = 0; i < 3; i++){
    800063f2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800063f4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800063f6:	0001cb97          	auipc	s7,0x1c
    800063fa:	9aab8b93          	addi	s7,s7,-1622 # 80021da0 <disk>
  for(int i = 0; i < 3; i++){
    800063fe:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006400:	0001cc97          	auipc	s9,0x1c
    80006404:	ac8c8c93          	addi	s9,s9,-1336 # 80021ec8 <disk+0x128>
    80006408:	a08d                	j	8000646a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000640a:	00fb8733          	add	a4,s7,a5
    8000640e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006412:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006414:	0207c563          	bltz	a5,8000643e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006418:	2905                	addiw	s2,s2,1
    8000641a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000641c:	05690c63          	beq	s2,s6,80006474 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006420:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006422:	0001c717          	auipc	a4,0x1c
    80006426:	97e70713          	addi	a4,a4,-1666 # 80021da0 <disk>
    8000642a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000642c:	01874683          	lbu	a3,24(a4)
    80006430:	fee9                	bnez	a3,8000640a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006432:	2785                	addiw	a5,a5,1
    80006434:	0705                	addi	a4,a4,1
    80006436:	fe979be3          	bne	a5,s1,8000642c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000643a:	57fd                	li	a5,-1
    8000643c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000643e:	01205d63          	blez	s2,80006458 <virtio_disk_rw+0xa6>
    80006442:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006444:	000a2503          	lw	a0,0(s4)
    80006448:	00000097          	auipc	ra,0x0
    8000644c:	cfe080e7          	jalr	-770(ra) # 80006146 <free_desc>
      for(int j = 0; j < i; j++)
    80006450:	2d85                	addiw	s11,s11,1
    80006452:	0a11                	addi	s4,s4,4
    80006454:	ff2d98e3          	bne	s11,s2,80006444 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006458:	85e6                	mv	a1,s9
    8000645a:	0001c517          	auipc	a0,0x1c
    8000645e:	95e50513          	addi	a0,a0,-1698 # 80021db8 <disk+0x18>
    80006462:	ffffc097          	auipc	ra,0xffffc
    80006466:	e78080e7          	jalr	-392(ra) # 800022da <sleep>
  for(int i = 0; i < 3; i++){
    8000646a:	f8040a13          	addi	s4,s0,-128
{
    8000646e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006470:	894e                	mv	s2,s3
    80006472:	b77d                	j	80006420 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006474:	f8042503          	lw	a0,-128(s0)
    80006478:	00a50713          	addi	a4,a0,10
    8000647c:	0712                	slli	a4,a4,0x4

  if(write)
    8000647e:	0001c797          	auipc	a5,0x1c
    80006482:	92278793          	addi	a5,a5,-1758 # 80021da0 <disk>
    80006486:	00e786b3          	add	a3,a5,a4
    8000648a:	01803633          	snez	a2,s8
    8000648e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006490:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006494:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006498:	f6070613          	addi	a2,a4,-160
    8000649c:	6394                	ld	a3,0(a5)
    8000649e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064a0:	00870593          	addi	a1,a4,8
    800064a4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064a6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064a8:	0007b803          	ld	a6,0(a5)
    800064ac:	9642                	add	a2,a2,a6
    800064ae:	46c1                	li	a3,16
    800064b0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064b2:	4585                	li	a1,1
    800064b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800064b8:	f8442683          	lw	a3,-124(s0)
    800064bc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800064c0:	0692                	slli	a3,a3,0x4
    800064c2:	9836                	add	a6,a6,a3
    800064c4:	058a8613          	addi	a2,s5,88
    800064c8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800064cc:	0007b803          	ld	a6,0(a5)
    800064d0:	96c2                	add	a3,a3,a6
    800064d2:	40000613          	li	a2,1024
    800064d6:	c690                	sw	a2,8(a3)
  if(write)
    800064d8:	001c3613          	seqz	a2,s8
    800064dc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800064e0:	00166613          	ori	a2,a2,1
    800064e4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800064e8:	f8842603          	lw	a2,-120(s0)
    800064ec:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800064f0:	00250693          	addi	a3,a0,2
    800064f4:	0692                	slli	a3,a3,0x4
    800064f6:	96be                	add	a3,a3,a5
    800064f8:	58fd                	li	a7,-1
    800064fa:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800064fe:	0612                	slli	a2,a2,0x4
    80006500:	9832                	add	a6,a6,a2
    80006502:	f9070713          	addi	a4,a4,-112
    80006506:	973e                	add	a4,a4,a5
    80006508:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000650c:	6398                	ld	a4,0(a5)
    8000650e:	9732                	add	a4,a4,a2
    80006510:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006512:	4609                	li	a2,2
    80006514:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006518:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000651c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006520:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006524:	6794                	ld	a3,8(a5)
    80006526:	0026d703          	lhu	a4,2(a3)
    8000652a:	8b1d                	andi	a4,a4,7
    8000652c:	0706                	slli	a4,a4,0x1
    8000652e:	96ba                	add	a3,a3,a4
    80006530:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006534:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006538:	6798                	ld	a4,8(a5)
    8000653a:	00275783          	lhu	a5,2(a4)
    8000653e:	2785                	addiw	a5,a5,1
    80006540:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006544:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006548:	100017b7          	lui	a5,0x10001
    8000654c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006550:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006554:	0001c917          	auipc	s2,0x1c
    80006558:	97490913          	addi	s2,s2,-1676 # 80021ec8 <disk+0x128>
  while(b->disk == 1) {
    8000655c:	4485                	li	s1,1
    8000655e:	00b79c63          	bne	a5,a1,80006576 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006562:	85ca                	mv	a1,s2
    80006564:	8556                	mv	a0,s5
    80006566:	ffffc097          	auipc	ra,0xffffc
    8000656a:	d74080e7          	jalr	-652(ra) # 800022da <sleep>
  while(b->disk == 1) {
    8000656e:	004aa783          	lw	a5,4(s5)
    80006572:	fe9788e3          	beq	a5,s1,80006562 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006576:	f8042903          	lw	s2,-128(s0)
    8000657a:	00290713          	addi	a4,s2,2
    8000657e:	0712                	slli	a4,a4,0x4
    80006580:	0001c797          	auipc	a5,0x1c
    80006584:	82078793          	addi	a5,a5,-2016 # 80021da0 <disk>
    80006588:	97ba                	add	a5,a5,a4
    8000658a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000658e:	0001c997          	auipc	s3,0x1c
    80006592:	81298993          	addi	s3,s3,-2030 # 80021da0 <disk>
    80006596:	00491713          	slli	a4,s2,0x4
    8000659a:	0009b783          	ld	a5,0(s3)
    8000659e:	97ba                	add	a5,a5,a4
    800065a0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800065a4:	854a                	mv	a0,s2
    800065a6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800065aa:	00000097          	auipc	ra,0x0
    800065ae:	b9c080e7          	jalr	-1124(ra) # 80006146 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800065b2:	8885                	andi	s1,s1,1
    800065b4:	f0ed                	bnez	s1,80006596 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800065b6:	0001c517          	auipc	a0,0x1c
    800065ba:	91250513          	addi	a0,a0,-1774 # 80021ec8 <disk+0x128>
    800065be:	ffffa097          	auipc	ra,0xffffa
    800065c2:	794080e7          	jalr	1940(ra) # 80000d52 <release>
}
    800065c6:	70e6                	ld	ra,120(sp)
    800065c8:	7446                	ld	s0,112(sp)
    800065ca:	74a6                	ld	s1,104(sp)
    800065cc:	7906                	ld	s2,96(sp)
    800065ce:	69e6                	ld	s3,88(sp)
    800065d0:	6a46                	ld	s4,80(sp)
    800065d2:	6aa6                	ld	s5,72(sp)
    800065d4:	6b06                	ld	s6,64(sp)
    800065d6:	7be2                	ld	s7,56(sp)
    800065d8:	7c42                	ld	s8,48(sp)
    800065da:	7ca2                	ld	s9,40(sp)
    800065dc:	7d02                	ld	s10,32(sp)
    800065de:	6de2                	ld	s11,24(sp)
    800065e0:	6109                	addi	sp,sp,128
    800065e2:	8082                	ret

00000000800065e4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065e4:	1101                	addi	sp,sp,-32
    800065e6:	ec06                	sd	ra,24(sp)
    800065e8:	e822                	sd	s0,16(sp)
    800065ea:	e426                	sd	s1,8(sp)
    800065ec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800065ee:	0001b497          	auipc	s1,0x1b
    800065f2:	7b248493          	addi	s1,s1,1970 # 80021da0 <disk>
    800065f6:	0001c517          	auipc	a0,0x1c
    800065fa:	8d250513          	addi	a0,a0,-1838 # 80021ec8 <disk+0x128>
    800065fe:	ffffa097          	auipc	ra,0xffffa
    80006602:	6a0080e7          	jalr	1696(ra) # 80000c9e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006606:	10001737          	lui	a4,0x10001
    8000660a:	533c                	lw	a5,96(a4)
    8000660c:	8b8d                	andi	a5,a5,3
    8000660e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006610:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006614:	689c                	ld	a5,16(s1)
    80006616:	0204d703          	lhu	a4,32(s1)
    8000661a:	0027d783          	lhu	a5,2(a5)
    8000661e:	04f70863          	beq	a4,a5,8000666e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006622:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006626:	6898                	ld	a4,16(s1)
    80006628:	0204d783          	lhu	a5,32(s1)
    8000662c:	8b9d                	andi	a5,a5,7
    8000662e:	078e                	slli	a5,a5,0x3
    80006630:	97ba                	add	a5,a5,a4
    80006632:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006634:	00278713          	addi	a4,a5,2
    80006638:	0712                	slli	a4,a4,0x4
    8000663a:	9726                	add	a4,a4,s1
    8000663c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006640:	e721                	bnez	a4,80006688 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006642:	0789                	addi	a5,a5,2
    80006644:	0792                	slli	a5,a5,0x4
    80006646:	97a6                	add	a5,a5,s1
    80006648:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000664a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000664e:	ffffc097          	auipc	ra,0xffffc
    80006652:	cf0080e7          	jalr	-784(ra) # 8000233e <wakeup>

    disk.used_idx += 1;
    80006656:	0204d783          	lhu	a5,32(s1)
    8000665a:	2785                	addiw	a5,a5,1
    8000665c:	17c2                	slli	a5,a5,0x30
    8000665e:	93c1                	srli	a5,a5,0x30
    80006660:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006664:	6898                	ld	a4,16(s1)
    80006666:	00275703          	lhu	a4,2(a4)
    8000666a:	faf71ce3          	bne	a4,a5,80006622 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000666e:	0001c517          	auipc	a0,0x1c
    80006672:	85a50513          	addi	a0,a0,-1958 # 80021ec8 <disk+0x128>
    80006676:	ffffa097          	auipc	ra,0xffffa
    8000667a:	6dc080e7          	jalr	1756(ra) # 80000d52 <release>
}
    8000667e:	60e2                	ld	ra,24(sp)
    80006680:	6442                	ld	s0,16(sp)
    80006682:	64a2                	ld	s1,8(sp)
    80006684:	6105                	addi	sp,sp,32
    80006686:	8082                	ret
      panic("virtio_disk_intr status");
    80006688:	00002517          	auipc	a0,0x2
    8000668c:	2d850513          	addi	a0,a0,728 # 80008960 <syscalls+0x400>
    80006690:	ffffa097          	auipc	ra,0xffffa
    80006694:	eb0080e7          	jalr	-336(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
