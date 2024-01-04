Target:
	@rm -f counter_la_mm.hex
	@riscv-none-elf-gcc -Wl,--no-warn-rwx-segments -g \
		--save-temps \
		-Xlinker -Map=output.map \
		-I../../firmware \
		-march=rv32i_zicsr -mabi=ilp32 -D__vexriscv__ \
		-Wl,-Bstatic,-T,../../firmware/sections.lds,--strip-discarded \
		-ffreestanding -nostartfiles -o counter_la_mm.elf ../../firmware/crt0_vex.S ../../firmware/isr.c matmul.c counter_la_mm.c
	@riscv-none-elf-objcopy -O verilog counter_la_mm.elf counter_la_mm.hex

	@sed -ie 's/@10/@00/g' counter_la_mm.hex

	@iverilog -Ttyp -DFUNCTIONAL -DSIM -DUNIT_DELAY=#1 \
		-f./include.rtl.list -o counter_la_mm.vvp counter_la_mm_tb.v

	@vvp counter_la_mm.vvp
	@rm -f *.vvp *.elf *.hexe *.s *.o *.i *.out *.map
clean:
	@ rm -rf ./gdb.debug ./gdbwave.debug
	@ rm -f *.vcd *.hex
	@ rm -f *.s *.o *.i *.out *.map
wv:
	@ gtkwave counter_la_mm.vcd  waveform.gtkw  --autosavename
