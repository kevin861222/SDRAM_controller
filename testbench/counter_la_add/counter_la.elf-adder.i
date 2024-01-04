# 0 "../../firmware/adder.c"
# 1 "/home/a605/soclab/labD-sdram/testbench/counter_la_add//"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "../../firmware/adder.c"
# 1 "../../firmware/adder.h" 1




 int Number[10] = {0x1, 0x10, 0x100, 0x1000, 0x1, 0x10, 0x100, 0x1000, 0x1, 0x10};
# 2 "../../firmware/adder.c" 2

int __attribute__ ( ( section ( ".mprjram" ) ) ) adder()
{
 int local_var = 0;
 int index;
 for (int index = 0; index < 10; index++)
 {
  local_var += Number[index];
 }
 return local_var;
}
