# LAB-D  SDRAM

Notion Link : [Link](https://irradiated-hellebore-357.notion.site/LAB-D-SDRAM-4128635388f44d099ccf5abd650cbda2?pvs=4)

## 實驗介紹

### 實驗目的

1. 延續 [Lab4-1](https://www.notion.so/Lab-4-1-exmem-04553dc675604dcf813bbd7c72551deb?pvs=21) ，不過將BRAM 換成 SDRAM。
    - Bram 為 block SRAM ，在先前的設定上access time 為`10T`，SDRAM access time為`3T`，但是須考量 Refresh 。
2. 改善WB對 SDRAM 的操作性能。
3. 將 code execution 和 data fetch 分割至不同的 Bank，以進一步使用prefetch減少資料等待時間。
    - Code Execution：資料不會被更新，在 compile 階段就已經確定了
    - Data Fetch：有可能在運行中被更新，若存放在 Cache 須考慮 Write back 問題。
4. pipeline memory access

> SDRAM
> 
> - Page mode controller
> - The combined SDRAM controller & SDRAM device is to replace a Wishbone BRAM
> - 真實的 SDRAM 具有 inout port，但在FGPA上無法實現，因此本實驗會將inout port 分離成input port與output port。
> - Storage element 方面也無法直接用 FPGA 實現，因此會將 4 個 Bank 替換成 4 個 bram 以模擬出和 Behavior model 同樣的功能。
> - 須考量CAS Latency ( **Column Address Strobe** )

> CAS Latency
> 
> - CAS延遲（CAS Latency , CL ）是指在SDRAM中，從發送讀取命令到實際數據可用之間的時間延遲。它通常以時脈週期（Clock Cycle）的數量來表示，即以CLK的週期數來衡量。
>     
>     ![截圖 2023-12-26 下午9.40.33.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-26_%25E4%25B8%258B%25E5%258D%25889.40.33.png)
>     

---

### Reference

[](https://github.com/bol-edu/caravel-soc_fpga-lab/tree/main/lab-sdram)

### Workbook

[LabD-sdram_workbook.pdf](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/LabD-sdram_workbook.pdf)

---

# Design Overview

### 架構圖

![截圖 2023-12-22 下午5.07.25.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-22_%25E4%25B8%258B%25E5%258D%25885.07.25.png)

## Signal Converter

### 功能說明

轉換 Wishbone 和 SDRAM controller 的訊號

```verilog
assign valid = wbs_stb_i && wbs_cyc_i;
assign ctrl_in_valid = wbs_we_i ? valid : ~ctrl_in_valid_q && valid;
assign wbs_ack_o = (wbs_we_i) ? ~ctrl_busy && valid : ctrl_out_valid; 
assign bram_mask = wbs_sel_i & {4{wbs_we_i}};
assign ctrl_addr = wbs_adr_i[22:0];
```

- Wishbone address 的末 23 bits 會直接映射到 SDRAM address

```verilog
always @(posedge clk) begin
      if (rst) begin
          ctrl_in_valid_q <= 1'b0;
      end
      else begin
          if (~wbs_we_i && valid && ~ctrl_busy && ctrl_in_valid_q == 1'b0)
              ctrl_in_valid_q <= 1'b1;
          else if (ctrl_out_valid)
              ctrl_in_valid_q <= 1'b0;
      end
end
```

## SDRAM Controller

### I/O

```verilog
module sdram_controller (
        input   clk,
        input   rst,

        // these signals go directly to the IO pins
        // output  sdram_clk,
        output  sdram_cle,
        output  sdram_cs,
        output  sdram_cas,
        output  sdram_ras,
        output  sdram_we,
        output  sdram_dqm,
        output  [1:0]  sdram_ba,
        output  [12:0] sdram_a,
        // Jiin: split dq into dqi (input) dqo (output)
        // inout [7:0] sdram_dq,
        input   [31:0] sdram_dqi,
        output  [31:0] sdram_dqo,

        // User interface
        // Note: we want to remap addr (see below)
        // input [22:0] addr,       // address to read/write
        input   [22:0] user_addr,   // the address will be remap to addr later
        // Bank addr [9:8]
        // Row addr [22:10]
        // Column addr [7:0] 
        
        input   rw,                 // 1 = write, 0 = read
        input   [31:0] data_in,     // data from a read
        output  [31:0] data_out,    // data for a write
        output  busy,               // controller is busy when high
        input   in_valid,           // pulse high to initiate a read/write
        output  out_valid           // pulses high when data from read is valid
    );
```

### 功能說明

> FSM
> 

```verilog
localparam INIT = 4'd0,
           WAIT = 4'd1,
           PRECHARGE_INIT = 4'd2,
           REFRESH_INIT_1 = 4'd3,
           REFRESH_INIT_2 = 4'd4,
           LOAD_MODE_REG = 4'd5,
           IDLE = 4'd6,
           REFRESH = 4'd7,
           ACTIVATE = 4'd8,
           READ = 4'd9,
           READ_RES = 4'd10,
           WRITE = 4'd11,
           PRECHARGE = 4'd12;
```

> Re-mapping
> 

備注：若訪問不同 Row 的地址要重新 Activate

```verilog
wire [22:0] addr;
wire [12:0] Mapped_RA;
wire [1:0]  Mapped_BA;
wire [7:0]  Mapped_CA;
assign Mapped_RA = user_addr[22:10];
assign Mapped_BA = user_addr[9:8];
assign Mapped_CA = user_addr[7:0];
assign addr = {Mapped_RA, Mapped_BA, Mapped_CA};
```

![截圖 2023-12-25 下午4.20.49.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-25_%25E4%25B8%258B%25E5%258D%25884.20.49.png)

ref : 

[SDRAM - Mojo — Alchitry](https://alchitry.com/sdram-mojo)

> Waves ( Write )
> 

States switch : IDLE → ACTIVATE → WAIT → WRITE → IDLE

![截圖 2023-12-25 下午4.32.20.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-25_%25E4%25B8%258B%25E5%258D%25884.32.20.png)

> Waves ( Read )
> 

單次讀取 ( Data fetch )

![截圖 2023-12-25 下午4.49.27.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-25_%25E4%25B8%258B%25E5%258D%25884.49.27.png)

連續讀取  ( Code Execution ) 

![截圖 2023-12-25 下午8.21.15.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-25_%25E4%25B8%258B%25E5%258D%25888.21.15.png)

經觀察可發現，本實驗中會連續讀取 8 筆 code 資訊，且地址為連續，每段 Code Execution 也會讀取到相同的地址，可以確定本實驗Code Execution 之資料具有：

- temporal locality(時間的局部性): 一個記憶體位址被存取後，不久會再度被存取
    - 如: 迴圈,副程式,以及堆疊,迴圈控制變數,計算總合變數
- spatial locality (空間的局部性): 一個記憶體位址被存取後，不久其附近的記憶體位址也會被存取
    - 如: 循序指令、陣列，和相關的變數
- Add task
    - Code Execution
        
        連續訪問 `3800_0100 ~ 3800_011C` 與 `3800_0140 ~ 3800_015C`
        
    
    ![截圖 2023-12-25 下午7.50.18.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-25_%25E4%25B8%258B%25E5%258D%25887.50.18.png)
    
    ![截圖 2023-12-25 下午8.21.15.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-25_%25E4%25B8%258B%25E5%258D%25888.21.15.png)
    
- Matrix mult task
    - Code Execution
        
        連續訪問 `3800_0100 ~ 3800_011C` 、 `3800_0120 ~ 3800_013C` 、 `3800_0140 ~ 3800_015C`、 `3800_0160 ~ 3800_017C`
        
        以此類推，直到  `3800_0200 ~ 3800_021C`
        
    
    ![截圖 2023-12-26 上午11.42.20.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-26_%25E4%25B8%258A%25E5%258D%258811.42.20.png)
    

> 可優化處
> 
1. Cache ( 1T memory )
    - 將先前使用過的資料保存，當需要再次使用時，若該資料在 Cache 中 Hit ，就不需要訪問記憶體（SDRAM )。
2. Prefetch & Pipeline Memory
    - 觀察這三筆訊號之波形，可以看出將「讀取記憶體」任務增加 pipeline 功能，將能使讀取效率提升
        
        ![截圖 2023-12-25 下午8.22.26.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-25_%25E4%25B8%258B%25E5%258D%25888.22.26.png)
        
    - 可透過前一比地址資訊預測將會使用到的連續記憶體區域，提前讀取至 Cache 中。
    - 但是 Prefetch 會衍生出 Refresh issue ：
        - Refresh cycle：750T
        - CAS：3T
        - Prefetch data num：8 addresses
        
        若要連續 prefetch 多筆資料，且不想要被中斷，可能讓 Refresh 時間超出 750 T，並且不是只超出一點點。
        
        Ex : Time=749 T 時 Prefetch ，則實際 Refresh 時間為 749+24 = 773 T
        solution：將 Refresh cycle 縮短至 750- 3*8 T = 726 T
        

### 改動

- 新增 Code Cache ， 用來存放先前讀取過的 Code 指令。
- 新增 Data Cache  ，用來存放先前讀取過的 Data 資料 （ 尚未實現，Final project 再進一步優化 ）。
- 新增 Prefetch 功能，收到地址後會預先判斷該地址之資料是否為 Code 或是 Data ，若為 Code 資訊，則會用 Burst Mode 連續讀取 8 個連續記憶體資料 （ 已經為本實驗任務特化，省略 program burst length 步驟 ）。

## SDRAM Device

![截圖 2023-12-24 下午3.42.49.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25883.42.49.png)

---

# 實驗內容

### 實作將 data fetch 與 code execution 分離到不同記憶體 Bank

> 將兩種資料分開至不同的 Bank ，即可方便 prefetch 的設計，可以清楚知道哪些 address 存放的是將要 load 到 PE 做運算的資料。
> 
- 要觀察的資料

```cpp
#define COUNT 10
	int Number[COUNT] = {0x1, 0x10, 0x100, 0x1000, 0x1, 0x10, 0x100, 0x1000, 0x1, 0x10};
#endif
```

- Bank 判斷
    1. WB address 的末 22 bits 會直接斷應到 SDRAM address 。
    2. 本實驗沒有調整 mapping 方式，各 bits  代表資訊如下表所示
    
    | Bank 0  | Bank 1  | Bank 2  | Bank 3 |
    | --- | --- | --- | --- |
    | 3800_X 0 XX | 3800_X 1 XX | 3800_X 2 XX | 3800_X 3 XX |
    | 3800_X 4 XX | 3800_X 5 XX | 3800_X 6 XX | 3800_X 7 XX |
    | 3800_X 8 XX | 3800_X 9 XX | 3800_X A XX | 3800_X B XX |
    | 3800_X C XX | 3800_X D XX | 3800_X E XX | 3800_X F XX |
- 查看各區段記憶體大小
    - Add Task
        
        Data 共 40 ，需要四個記憶體地址
        
        與 adder.h 中描述相符
        
        ```cpp
        #define COUNT 10
        	int Number[COUNT] = {0x1, 0x10, 0x100, 0x1000, 0x1, 0x10, 0x100, 0x1000, 0x1, 0x10};
        #endif
        ```
        
        ![截圖 2023-12-24 下午8.55.30.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25888.55.30.png)
        
    - Matrix Mult Task
        
        Input 與 Weight 皆為 4x4 矩陣，共16 + 16 = 32 個資料。
        
        ![截圖 2023-12-30 下午10.29.38.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-30_%25E4%25B8%258B%25E5%258D%258810.29.38.png)
        
- 實驗結果 （以 Add Task 為例 ）
    - 分離前
        - sections.lds
            
            ```tsx
            MEMORY {
            	vexriscv_debug : ORIGIN = 0xf00f0000, LENGTH = 0x00000100
            	dff : ORIGIN = 0x00000000, LENGTH = 0x00000400
            	dff2 : ORIGIN = 0x00000400, LENGTH = 0x00000200
            	flash : ORIGIN = 0x10000000, LENGTH = 0x01000000
            	mprj : ORIGIN = 0x30000000, LENGTH = 0x00100000
            	mprjram : ORIGIN = 0x38000000, LENGTH = 0x00400000
            	hk : ORIGIN = 0x26000000, LENGTH = 0x00100000
            	csr : ORIGIN = 0xf0000000, LENGTH = 0x00010000
            }
            SECTIONS
            {
            	.text :
            	{
            		_ftext = .;
            		/* Make sure crt0 files come first, and they, and the isr */
            		/* don't get disposed of by greedy optimisation */
            		*crt0*(.text)
            		KEEP(*crt0*(.text))
            		KEEP(*(.text.isr))
            
            		*(.text .stub .text.* .gnu.linkonce.t.*)
            		_etext = .;
            	} > flash
            
            	.rodata :
            	{
            		. = ALIGN(8);
            		_frodata = .;
            		*(.rodata .rodata.* .gnu.linkonce.r.*)
            		*(.rodata1)
            		. = ALIGN(8);
            		_erodata = .;
            	} > flash
            
            	.data :
            	{
            		. = ALIGN(8);
            		_fdata = .;
            		*(.data .data.* .gnu.linkonce.d.*)
            		*(.data1)
            		_gp = ALIGN(16);
            		*(.sdata .sdata.* .gnu.linkonce.s.*)
            		. = ALIGN(8);
            		_edata = .;
            	} > dff AT > flash
            
            	.bss :
            	{
            		. = ALIGN(8);
            		_fbss = .;
            		*(.dynsbss)
            		*(.sbss .sbss.* .gnu.linkonce.sb.*)
            		*(.scommon)
            		*(.dynbss)
            		*(.bss .bss.* .gnu.linkonce.b.*)
            		*(COMMON)
            		. = ALIGN(8);
            		_ebss = .;
            		_end = .;
            	} > dff AT > flash
            
            	.mprjram :
            	{
            		. = ALIGN(8);
            		_fsram = .;
            
            	} > mprjram AT > flash
            }
            
            PROVIDE(_fstack = ORIGIN(dff2) + LENGTH(dff2));
            
            PROVIDE(_fdata_rom = LOADADDR(.data));
            PROVIDE(_edata_rom = LOADADDR(.data) + SIZEOF(.data));
            
            PROVIDE(_esram = ORIGIN(mprjram) + SIZEOF(.mprjram));
            PROVIDE(_esram_rom = LOADADDR(.mprjram));
            ```
            
        - Waveform
            
            > Data Fetch
            → In Bank 2
            > 
            
            `0x1` → Address at 3800_0200 (Hex)
            
            ![截圖 2023-12-24 下午3.59.26.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25883.59.26.png)
            
            `0x10` → Address at 3800_0204 (Hex)
            
            ![截圖 2023-12-24 下午4.02.05.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25884.02.05.png)
            
            `0x100` → Address at 3800_0208 (Hex)
            
            ![截圖 2023-12-24 下午4.02.51.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25884.02.51.png)
            
            `0x1000` → Address at 3800_020C (Hex)
            
            ![截圖 2023-12-24 下午4.05.04.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25884.05.04.png)
            
            > Code Execution
            → In Bank 0 ~ 3
            > 
            
            From 3800_0000 to 3800_0200 都是，後續有其他 code 會接續在 Data fetch 的記憶體之後
            
            ![截圖 2023-12-24 下午4.21.16.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25884.21.16.png)
            
            ![截圖 2023-12-24 下午4.27.43.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25884.27.43.png)
            
    - 分離後
        - sections.lds
            
            ```tsx
            MEMORY {
            	vexriscv_debug : ORIGIN = 0xf00f0000, LENGTH = 0x00000100
            	dff : ORIGIN = 0x00000000, LENGTH = 0x00000400
            	dff2 : ORIGIN = 0x00000400, LENGTH = 0x00000200
            	flash : ORIGIN = 0x10000000, LENGTH = 0x01000000
            	mprj : ORIGIN = 0x30000000, LENGTH = 0x00100000
            	/* mprjram : ORIGIN = 0x38000000, LENGTH = 0x00400000 */
            	mprjram : ORIGIN = 0x38000100, LENGTH = 0x00000300
            	add_data : ORIGIN = 0x38000000, LENGTH = 0x00000100
            	/* code_and_others : ORIGIN = 0x38000100, LENGTH = 0x00000300 */
            	hk : ORIGIN = 0x26000000, LENGTH = 0x00100000
            	csr : ORIGIN = 0xf0000000, LENGTH = 0x00010000
            }
            
            SECTIONS
            {
            	.text :
            	{
            		_ftext = .;
            		/* Make sure crt0 files come first, and they, and the isr */
            		/* don't get disposed of by greedy optimisation */
            		*crt0*(.text)
            		KEEP(*crt0*(.text))
            		KEEP(*(.text.isr))
            
            		*(.text .stub .text.* .gnu.linkonce.t.*)
            		_etext = .;
            	} > flash
            
            	.rodata :
            	{
            		. = ALIGN(8);
            		_frodata = .;
            		*(.rodata .rodata.* .gnu.linkonce.r.*)
            		*(.rodata1)
            		. = ALIGN(8);
            		_erodata = .;
            	} > flash
            
            	.data :
            	{
            		. = ALIGN(8);
            		_fdata = .;
            		*(.data .data.* .gnu.linkonce.d.*)
            		*(.data1)
            		_gp = ALIGN(16);
            		*(.sdata .sdata.* .gnu.linkonce.s.*)
            		. = ALIGN(8);
            		_edata = .;
            	} > add_data AT > flash
            
            	.bss :
            	{
            		. = ALIGN(8);
            		_fbss = .;
            		*(.dynsbss)
            		*(.sbss .sbss.* .gnu.linkonce.sb.*)
            		*(.scommon)
            		*(.dynbss)
            		*(.bss .bss.* .gnu.linkonce.b.*)
            		*(COMMON)
            		. = ALIGN(8);
            		_ebss = .;
            		_end = .;
            	} > dff AT > flash
            
            	.mprjram :
            	{
            		. = ALIGN(8);
            		_fsram = .;
            
            	} > mprjram AT > flash
            }
            
            PROVIDE(_fstack = ORIGIN(dff2) + LENGTH(dff2));
            
            PROVIDE(_fdata_rom = LOADADDR(.data));
            PROVIDE(_edata_rom = LOADADDR(.data) + SIZEOF(.data));
            
            PROVIDE(_esram = ORIGIN(mprjram) + SIZEOF(.mprjram));
            PROVIDE(_esram_rom = LOADADDR(.mprjram));
            ```
            
        - Waveform
            
            > Data Fetch
            → In Bank 0
            > 
            
            `0x1` → Address at 3800_0000 (Hex)
            
            ![截圖 2023-12-24 下午5.29.05.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25885.29.05.png)
            
            `0x10` → Address at 3800_0004 (Hex)
            
            ![截圖 2023-12-24 下午5.29.31.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25885.29.31.png)
            
            `0x100` → Address at 3800_0008 (Hex)
            
            ![截圖 2023-12-24 下午5.35.47.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25885.35.47.png)
            
            `0x1000` → Address at 3800_000C (Hex)
            
            ![截圖 2023-12-24 下午5.36.14.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25885.36.14.png)
            
            > Code Execution
            → In Bank 1~3
            > 
            
            從 From 3800_0000 to 3800_0200 
            更改到 From 3800_0100 to 3800_0400
            
            ![截圖 2023-12-24 下午5.19.43.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25885.19.43.png)
            
            ![截圖 2023-12-24 下午5.20.07.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25885.20.07.png)
            
    
    因為兩 task data  資料容量不同，無法使用同樣的配製方法。
    

### 實作  Data Prefetch 並存入 Cache

- 概述
    1. 在原先的 Controller 沒有 Burst mode ，每次讀取資料都需要一定的訪問延遲外加發送address的時間 ( 1T )，若該資料的地址已經被激活 ( activate ) 則需要 6T ，否則需要 9T 才能得到資料。
        
        ![IMG_AFEC026DA5F4-1.jpeg](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/IMG_AFEC026DA5F4-1.jpeg)
        
    2. 若預先將資料抓取，存在 1T 記憶體中，則訪問只會有 2T 延遲。
        
        sent address ( 1T ) → sent data back & ack ( 1T )
        
    3. Wishbone 輸入 address、rw、in_valid 等資訊後，controller 只會經歷 1T Busy，因此可以連續處理多筆訪問。

- FSM
    
    將原先的 read mode 調整成 Burst read  mode .
    
    - 原先的 read mode
    
    訪問地址是尚未激活的 Row
    
    $$
    IDLE >ACTIVATE>WAIT>READ>WAIT>ReadRes>IDLE
    $$
    
    訪問地址是已經激活的 Row
    
    $$
    IDLE >READ>WAIT>ReadRes>IDLE
    $$
    
    需要等待 SDRAM Device 處理，所以會經歷 Wait ，但是 burst 模式就能省略這些時間。
    
    - Burst read mode
    
    $$
    IDLE >(ACTIVAT)>READ>ReadAndOutput>ReadRes>IDLE
    $$
    
    READ：只進行資料讀取，不輸出資料。
    
    ReadAndOutput：進行資料讀取與輸出資料。
    
    ReadRes：不進行資料讀取，只輸出資料。
    
- 架構圖 （ 只有畫出讀取模式有關的訊號 ）
    - 點擊展開
        
        ![IMG_9B1600768B05-1.jpeg](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/IMG_9B1600768B05-1.jpeg)
        

- 流程說明
    
    ![LabD.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/LabD.png)
    
- Waves
    
    ![截圖 2024-01-02 下午6.45.36.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2024-01-02_%25E4%25B8%258B%25E5%258D%25886.45.36.png)
    

### 進階優化  Cache

> 此優化是針對 Add 任務進行特化，無法直接套用於 Matrix mult task
> 

觀察波形圖可以發現，同樣地址的 Code 會被重複訪問多次，若增加 Cache size 就可以加以保存，下次需要訪問時就不需要等待 9T 時間，只要 Cache Hit 僅需 2T 就能獲得資料。

- 宣告一個 2D Cache 以及對應 tag。

```verilog
reg [31:0] cache [0:8] [0:7] ;
reg hit_array [0:8] [0:7] ;
```

Cache size 是為了 Add task 特化，此任務會涉及 0100~021C 等地址，共需 9 column 與 8 row。

因為 Code 資訊在編譯後即可確定，不會有覆寫問題，Cache size 也足夠存放所有 Code 資訊，因此僅需要紀錄該地址是否為空，就能知道該地址是否存放在 Cache 中。

- FSM - saving_state ( 從 SDRAM 存取資料 ）
    
    ( 非常簡易，僅用文字敘述即可 )
    
    IDLE :
    
    若 miss ，進入 SAVING 狀態，等待 SDRAM 將該八組連續地址資訊傳送至 Cache ，並將 hit array 更新為 1’b1。
    
    若 Hit ， 維持IDLE，不做任何動作。
    
    SAVING : 
    
    接收八筆資料後會到 IDLE 狀態。
    
- FSM - output_state ( 發送資料至WB )
    
    ( 非常簡易，僅用文字敘述即可 )
    
    IDLE : 
    
    當發生有效讀取訪問，且地址為 Code 資訊，紀錄該地址。
    
    若 saving_state 處於 IDLE 狀態 :
    
    若 Hit ，進入 OUTPUT 狀態。
    
    若 ~Hit ，維持 IDLE 狀態。
    
    若 saving_state 處於 Saving 狀態 :
    
    持續比對先前紀錄之地址是否 Hit 。
    
    若 Hit ，進入 OUTPUT 狀態。
    
    若 ~Hit ，維持 IDLE 狀態。
    
    （有可能一開始 Miss ，但是 prefetch 過程發生 Hit）
    
    OUTPUT : 
    
    Output valid = 1 後回到 IDLE。
    
    並將 Output_flag 設置為 1’b1。
    
    備注：Output_flag 是為了避免所紀錄地址一再使 Hit 發生而輸出無效資料造成錯誤，Output_flag 會在每次收到有效讀取請求時重置。
    
- SDRAM address 與 Cache 地址之映射

```verilog
origin (column)
 DC:Dont care                                  DC
 user_addr                                [ 09 | 08 | 07 | 06 | 05 ]
0x3800_0100 --> 100 --> 0001_0000_0000  -->  0    1    0    0    0  --> 0
0x3800_0120 --> 120 --> 0001_0010_0000  -->  0    1    0    0    1  --> 1
0x3800_0140 --> 140 --> 0001_0100_0000  -->  0    1    0    1    0  --> 2
0x3800_0160 --> 160 --> 0001_0110_0000  -->  0    1    0    1    1  --> 3
0x3800_0180 --> 180 --> 0001_1000_0000  -->  0    1    1    0    0  --> 4
0x3800_01A0 --> 1A0 --> 0001_1010_0000  -->  0    1    1    0    1  --> 5
0x3800_01C0 --> 1C0 --> 0001_1100_0000  -->  0    1    1    1    0  --> 6
0x3800_01E0 --> 1E0 --> 0001_1110_0000  -->  0    1    1    1    1  --> 7
0x3800_0200 --> 200 --> 0010_0000_0000  -->  1    0    0    0    0  --> 8

offset (row)
          [ 4 | 3 | 2 ]
 0x00   --> 0   0   0
 0x04   --> 0   0   1
 0x08   --> 0   1   0
 0x0C   --> 0   1   1
 0x10   --> 1   0   0
 0x14   --> 1   0   1   
 0x18   --> 1   1   0
 0x1C   --> 1   1   1
```

- Wave
    
    ![截圖 2023-12-31 上午1.34.06.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-31_%25E4%25B8%258A%25E5%258D%25881.34.06.png)
    

因為先前已訪問過 0x3800_0120，並將該地址資料存在 Cache中，因此僅需要 2T 就能回傳資料。

---

# 補充資料

### Linker script

[10分鐘讀懂 linker scripts | louie_lu's blog](https://blog.louie.lu/2016/11/06/10分鐘讀懂-linker-scripts/)

### **C 語言程式的記憶體配置**

[C 語言程式的記憶體配置概念教學 - G. T. Wang](https://blog.gtwang.org/programming/memory-layout-of-c-program/)

### Wishbone bus 複習

![4a365c6e3e214.jpg](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/4a365c6e3e214.jpg)

![截圖 2023-12-26 上午11.24.05.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-26_%25E4%25B8%258A%25E5%258D%258811.24.05.png)

- Waves

![截圖 2023-12-24 下午7.59.46.png](LAB-D%20SDRAM%204128635388f44d099ccf5abd650cbda2/%25E6%2588%25AA%25E5%259C%2596_2023-12-24_%25E4%25B8%258B%25E5%258D%25887.59.46.png)

### SDRAM 工作原理

[2.2.1. 讀取協定 · 每位程式設計師都該知道的記憶體知識](https://jason2506.gitbooks.io/cpumemory/content/commodity-hardware-today/dram-access-technical-details/read-access-protocol.html)
