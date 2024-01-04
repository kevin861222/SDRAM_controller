	.file	"counter_la_mm.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
.Ltext0:
	.cfi_sections	.debug_frame
	.file 0 "/home/a605/soclab/labD-sdram/testbench/counter_la_mm" "counter_la_mm.c"
	.align	2
	.type	flush_cpu_icache, @function
flush_cpu_icache:
.LFB21:
	.file 1 "../../firmware/system.h"
	.loc 1 15 1
	.cfi_startproc
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	sw	s0,12(sp)
	.cfi_offset 8, -4
	addi	s0,sp,16
	.cfi_def_cfa 8, 0
	.loc 1 26 1
	nop
	lw	s0,12(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 16
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE21:
	.size	flush_cpu_icache, .-flush_cpu_icache
	.align	2
	.type	flush_cpu_dcache, @function
flush_cpu_dcache:
.LFB22:
	.loc 1 29 1
	.cfi_startproc
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	sw	s0,12(sp)
	.cfi_offset 8, -4
	addi	s0,sp,16
	.cfi_def_cfa 8, 0
	.loc 1 33 1
	nop
	lw	s0,12(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 16
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE22:
	.size	flush_cpu_dcache, .-flush_cpu_dcache
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
.LFB316:
	.file 2 "../../firmware/stub.c"
	.loc 2 19 1
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	ra,28(sp)
	sw	s0,24(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
	mv	a5,a0
	sb	a5,-17(s0)
	.loc 2 20 5
	lbu	a4,-17(s0)
	li	a5,10
	bne	a4,a5,.L6
	.loc 2 21 3
	li	a0,13
	call	putchar
.L6:
	.loc 2 22 11
	nop
.L5:
	.loc 2 22 13 discriminator 1
	li	a5,-268410880
	addi	a5,a5,-2044
	lw	a4,0(a5)
	.loc 2 22 60 discriminator 1
	li	a5,1
	beq	a4,a5,.L5
	.loc 2 23 3
	li	a5,-268410880
	addi	a5,a5,-2048
	.loc 2 23 50
	lbu	a4,-17(s0)
	sw	a4,0(a5)
	.loc 2 24 1
	nop
	lw	ra,28(sp)
	.cfi_restore 1
	lw	s0,24(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 32
	addi	sp,sp,32
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE316:
	.size	putchar, .-putchar
	.align	2
	.globl	print
	.type	print, @function
print:
.LFB317:
	.loc 2 27 1
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	ra,28(sp)
	sw	s0,24(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
	sw	a0,-20(s0)
	.loc 2 28 8
	j	.L8
.L9:
	.loc 2 29 14
	lw	a5,-20(s0)
	addi	a4,a5,1
	sw	a4,-20(s0)
	.loc 2 29 3
	lbu	a5,0(a5)
	mv	a0,a5
	call	putchar
.L8:
	.loc 2 28 9
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	bne	a5,zero,.L9
	.loc 2 30 1
	nop
	nop
	lw	ra,28(sp)
	.cfi_restore 1
	lw	s0,24(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 32
	addi	sp,sp,32
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE317:
	.size	print, .-print
	.align	2
	.globl	main
	.type	main, @function
main:
.LFB318:
	.file 3 "counter_la_mm.c"
	.loc 3 35 1
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	ra,28(sp)
	sw	s0,24(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
	.loc 3 63 10
	li	a5,637534208
	addi	a5,a5,160
	.loc 3 63 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 64 10
	li	a5,637534208
	addi	a5,a5,156
	.loc 3 64 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 65 10
	li	a5,637534208
	addi	a5,a5,152
	.loc 3 65 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 66 10
	li	a5,637534208
	addi	a5,a5,148
	.loc 3 66 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 67 10
	li	a5,637534208
	addi	a5,a5,144
	.loc 3 67 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 68 10
	li	a5,637534208
	addi	a5,a5,140
	.loc 3 68 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 69 10
	li	a5,637534208
	addi	a5,a5,136
	.loc 3 69 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 70 10
	li	a5,637534208
	addi	a5,a5,132
	.loc 3 70 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 71 10
	li	a5,637534208
	addi	a5,a5,128
	.loc 3 71 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 72 10
	li	a5,637534208
	addi	a5,a5,124
	.loc 3 72 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 73 10
	li	a5,637534208
	addi	a5,a5,120
	.loc 3 73 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 74 10
	li	a5,637534208
	addi	a5,a5,116
	.loc 3 74 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 75 10
	li	a5,637534208
	addi	a5,a5,112
	.loc 3 75 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 76 10
	li	a5,637534208
	addi	a5,a5,108
	.loc 3 76 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 77 10
	li	a5,637534208
	addi	a5,a5,104
	.loc 3 77 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 78 10
	li	a5,637534208
	addi	a5,a5,100
	.loc 3 78 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 80 10
	li	a5,637534208
	addi	a5,a5,96
	.loc 3 80 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 81 10
	li	a5,637534208
	addi	a5,a5,92
	.loc 3 81 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 82 10
	li	a5,637534208
	addi	a5,a5,88
	.loc 3 82 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 83 10
	li	a5,637534208
	addi	a5,a5,84
	.loc 3 83 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 84 10
	li	a5,637534208
	addi	a5,a5,80
	.loc 3 84 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 85 10
	li	a5,637534208
	addi	a5,a5,76
	.loc 3 85 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 86 10
	li	a5,637534208
	addi	a5,a5,72
	.loc 3 86 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 87 10
	li	a5,637534208
	addi	a5,a5,68
	.loc 3 87 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 88 10
	li	a5,637534208
	addi	a5,a5,64
	.loc 3 88 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 89 10
	li	a5,637534208
	addi	a5,a5,56
	.loc 3 89 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 90 10
	li	a5,637534208
	addi	a5,a5,52
	.loc 3 90 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 91 10
	li	a5,637534208
	addi	a5,a5,48
	.loc 3 91 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 92 10
	li	a5,637534208
	addi	a5,a5,44
	.loc 3 92 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 93 10
	li	a5,637534208
	addi	a5,a5,40
	.loc 3 93 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 94 10
	li	a5,637534208
	addi	a5,a5,36
	.loc 3 94 43
	li	a4,8192
	addi	a4,a4,-2040
	sw	a4,0(a5)
	.loc 3 96 10
	li	a5,637534208
	addi	a5,a5,60
	.loc 3 96 43
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	.loc 3 100 3
	li	a5,-268410880
	.loc 3 100 50
	li	a4,1
	sw	a4,0(a5)
	.loc 3 103 3
	li	a5,637534208
	.loc 3 103 36
	li	a4,1
	sw	a4,0(a5)
	.loc 3 104 8
	nop
.L11:
	.loc 3 104 10 discriminator 1
	li	a5,637534208
	lw	a4,0(a5)
	.loc 3 104 43 discriminator 1
	li	a5,1
	beq	a4,a5,.L11
	.loc 3 108 60
	li	a5,-268423168
	addi	a4,a5,12
	.loc 3 108 114
	li	a5,0
	sw	a5,0(a4)
	.loc 3 108 3
	li	a4,-268423168
	addi	a4,a4,28
	.loc 3 108 57
	sw	a5,0(a4)
	.loc 3 109 59
	li	a5,-268423168
	addi	a4,a5,8
	.loc 3 109 112
	li	a5,-1
	sw	a5,0(a4)
	.loc 3 109 3
	li	a4,-268423168
	addi	a4,a4,24
	.loc 3 109 56
	sw	a5,0(a4)
	.loc 3 110 59
	li	a5,-268423168
	addi	a4,a5,4
	.loc 3 110 112
	li	a5,0
	sw	a5,0(a4)
	.loc 3 110 3
	li	a4,-268423168
	addi	a4,a4,20
	.loc 3 110 56
	sw	a5,0(a4)
	.loc 3 111 53
	li	a4,-268423168
	.loc 3 111 100
	li	a5,0
	sw	a5,0(a4)
	.loc 3 111 3
	li	a4,-268423168
	addi	a4,a4,16
	.loc 3 111 50
	sw	a5,0(a4)
	.loc 3 114 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 3 114 36
	li	a4,-1421869056
	sw	a4,0(a5)
	.loc 3 117 3
	li	a5,-268423168
	addi	a5,a5,56
	.loc 3 117 56
	sw	zero,0(a5)
	.loc 3 120 59
	li	a5,-268423168
	addi	a4,a5,8
	.loc 3 120 112
	li	a5,0
	sw	a5,0(a4)
	.loc 3 120 3
	li	a4,-268423168
	addi	a4,a4,24
	.loc 3 120 56
	sw	a5,0(a4)
	.loc 3 122 13
	call	matmul
	sw	a0,-20(s0)
	.loc 3 123 38
	lw	a5,-20(s0)
	lw	a5,0(a5)
	.loc 3 123 43
	slli	a4,a5,16
	.loc 3 123 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 3 123 36
	sw	a4,0(a5)
	.loc 3 124 43
	lw	a5,-20(s0)
	addi	a5,a5,4
	.loc 3 124 38
	lw	a5,0(a5)
	.loc 3 124 47
	slli	a4,a5,16
	.loc 3 124 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 3 124 36
	sw	a4,0(a5)
	.loc 3 125 43
	lw	a5,-20(s0)
	addi	a5,a5,8
	.loc 3 125 38
	lw	a5,0(a5)
	.loc 3 125 47
	slli	a4,a5,16
	.loc 3 125 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 3 125 36
	sw	a4,0(a5)
	.loc 3 126 43
	lw	a5,-20(s0)
	addi	a5,a5,12
	.loc 3 126 38
	lw	a5,0(a5)
	.loc 3 126 47
	slli	a4,a5,16
	.loc 3 126 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 3 126 36
	sw	a4,0(a5)
	.loc 3 127 43
	lw	a5,-20(s0)
	addi	a5,a5,36
	.loc 3 127 38
	lw	a5,0(a5)
	.loc 3 127 47
	slli	a4,a5,16
	.loc 3 127 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 3 127 36
	sw	a4,0(a5)
	.loc 3 129 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 3 129 36
	li	a4,-1420754944
	sw	a4,0(a5)
	.loc 3 130 1
	nop
	lw	ra,28(sp)
	.cfi_restore 1
	lw	s0,24(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 32
	addi	sp,sp,32
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE318:
	.size	main, .-main
.Letext0:
	.file 4 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint-gcc.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.4byte	0x12f
	.2byte	0x5
	.byte	0x1
	.byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x6
	.4byte	.LASF16
	.byte	0x1d
	.4byte	.LASF0
	.4byte	.LASF1
	.4byte	.Ltext0
	.4byte	.Letext0-.Ltext0
	.4byte	.Ldebug_line0
	.byte	0x1
	.byte	0x1
	.byte	0x6
	.4byte	.LASF2
	.byte	0x1
	.byte	0x2
	.byte	0x5
	.4byte	.LASF3
	.byte	0x1
	.byte	0x4
	.byte	0x5
	.4byte	.LASF4
	.byte	0x1
	.byte	0x8
	.byte	0x5
	.4byte	.LASF5
	.byte	0x1
	.byte	0x1
	.byte	0x8
	.4byte	.LASF6
	.byte	0x1
	.byte	0x2
	.byte	0x7
	.4byte	.LASF7
	.byte	0x7
	.4byte	.LASF17
	.byte	0x4
	.byte	0x34
	.byte	0x1b
	.4byte	0x5c
	.byte	0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF8
	.byte	0x1
	.byte	0x8
	.byte	0x7
	.4byte	.LASF9
	.byte	0x8
	.byte	0x4
	.byte	0x5
	.string	"int"
	.byte	0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF10
	.byte	0x9
	.4byte	.LASF18
	.byte	0x3
	.byte	0x16
	.byte	0xd
	.4byte	0x8a
	.4byte	0x8a
	.byte	0xa
	.byte	0
	.byte	0x2
	.4byte	0x6a
	.byte	0xb
	.4byte	.LASF19
	.byte	0x3
	.byte	0x22
	.byte	0x6
	.4byte	.LFB318
	.4byte	.LFE318-.LFB318
	.byte	0x1
	.byte	0x9c
	.4byte	0xbf
	.byte	0xc
	.string	"j"
	.byte	0x3
	.byte	0x24
	.byte	0x6
	.4byte	0x6a
	.byte	0xd
	.string	"tmp"
	.byte	0x3
	.byte	0x7a
	.byte	0x7
	.4byte	0x8a
	.byte	0x2
	.byte	0x91
	.byte	0x6c
	.byte	0
	.byte	0x3
	.4byte	.LASF12
	.byte	0x1a
	.4byte	.LFB317
	.4byte	.LFE317-.LFB317
	.byte	0x1
	.byte	0x9c
	.4byte	0xe0
	.byte	0x4
	.string	"p"
	.byte	0x1a
	.byte	0x18
	.4byte	0xe0
	.byte	0x2
	.byte	0x91
	.byte	0x6c
	.byte	0
	.byte	0x2
	.4byte	0xec
	.byte	0x1
	.byte	0x1
	.byte	0x8
	.4byte	.LASF11
	.byte	0xe
	.4byte	0xe5
	.byte	0x3
	.4byte	.LASF13
	.byte	0x12
	.4byte	.LFB316
	.4byte	.LFE316-.LFB316
	.byte	0x1
	.byte	0x9c
	.4byte	0x112
	.byte	0x4
	.string	"c"
	.byte	0x12
	.byte	0x13
	.4byte	0xe5
	.byte	0x2
	.byte	0x91
	.byte	0x6f
	.byte	0
	.byte	0x5
	.4byte	.LASF14
	.byte	0x1c
	.4byte	.LFB22
	.4byte	.LFE22-.LFB22
	.byte	0x1
	.byte	0x9c
	.byte	0x5
	.4byte	.LASF15
	.byte	0xe
	.4byte	.LFB21
	.4byte	.LFE21-.LFB21
	.byte	0x1
	.byte	0x9c
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.byte	0x1
	.byte	0x24
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x3e
	.byte	0xb
	.byte	0x3
	.byte	0xe
	.byte	0
	.byte	0
	.byte	0x2
	.byte	0xf
	.byte	0
	.byte	0xb
	.byte	0x21
	.byte	0x4
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x3
	.byte	0x2e
	.byte	0x1
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0x21
	.byte	0x2
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0x21
	.byte	0x6
	.byte	0x27
	.byte	0x19
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7c
	.byte	0x19
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x4
	.byte	0x5
	.byte	0
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0x21
	.byte	0x2
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0x5
	.byte	0x2e
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0x21
	.byte	0x1
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0x21
	.byte	0x25
	.byte	0x27
	.byte	0x19
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7a
	.byte	0x19
	.byte	0
	.byte	0
	.byte	0x6
	.byte	0x11
	.byte	0x1
	.byte	0x25
	.byte	0xe
	.byte	0x13
	.byte	0xb
	.byte	0x3
	.byte	0x1f
	.byte	0x1b
	.byte	0x1f
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x10
	.byte	0x17
	.byte	0
	.byte	0
	.byte	0x7
	.byte	0x16
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x8
	.byte	0x24
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x3e
	.byte	0xb
	.byte	0x3
	.byte	0x8
	.byte	0
	.byte	0
	.byte	0x9
	.byte	0x2e
	.byte	0x1
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x3c
	.byte	0x19
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xa
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0
	.byte	0xb
	.byte	0x2e
	.byte	0x1
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7c
	.byte	0x19
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xc
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xd
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0xe
	.byte	0x26
	.byte	0
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.4byte	0x1c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.Ltext0
	.4byte	.Letext0-.Ltext0
	.4byte	0
	.4byte	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF14:
	.string	"flush_cpu_dcache"
.LASF18:
	.string	"matmul"
.LASF6:
	.string	"unsigned char"
.LASF8:
	.string	"long unsigned int"
.LASF7:
	.string	"short unsigned int"
.LASF13:
	.string	"putchar"
.LASF16:
	.string	"GNU C17 12.1.0 -mabi=ilp32 -mtune=rocket -misa-spec=2.2 -march=rv32i -g -ffreestanding"
.LASF19:
	.string	"main"
.LASF10:
	.string	"unsigned int"
.LASF9:
	.string	"long long unsigned int"
.LASF15:
	.string	"flush_cpu_icache"
.LASF5:
	.string	"long long int"
.LASF11:
	.string	"char"
.LASF12:
	.string	"print"
.LASF3:
	.string	"short int"
.LASF17:
	.string	"uint32_t"
.LASF4:
	.string	"long int"
.LASF2:
	.string	"signed char"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"counter_la_mm.c"
.LASF1:
	.string	"/home/a605/soclab/labD-sdram/testbench/counter_la_mm"
	.ident	"GCC: (g1ea978e3066) 12.1.0"
