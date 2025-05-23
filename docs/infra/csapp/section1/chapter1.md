# CHAPTER1：信息的表示和处理

## 1. 概述

在计算机系统中，所有信息都是以二进制形式存储和处理的。本章主要介绍：

- 信息的编码方式
- 不同数据类型的表示方法
- 数据在计算机中的存储和处理规则

## 2. 信息存储

### 2.1 字节与寻址

#### **基本概念**：
  - 1字节(Byte) = 8位(Bits)
  - 字节是最小的可寻址单位
  - 虚拟内存：程序将内存视为一个巨大的字节数组
  - 每个字节都有唯一的地址标识

### 2.2 字节顺序

在多字节对象中，存在两种主要的字节排序方式：

#### 大端法（Big Endian）
- 最高有效字节存储在最低地址
- 符合人类读写习惯
- 常见于网络协议（如TCP/IP）

#### 小端法（Little Endian）
- 最低有效字节存储在最低地址
- 主流个人计算机采用（如x86架构）
- 示例：
  ```c
  int x = 0x01234567;
  // 大端法：01 23 45 67
  // 小端法：67 45 23 01
  ```

!!! note "字节顺序的重要性"
    - 在网络通信中需要考虑字节顺序的转换
    - 在二进制文件操作时需要注意字节顺序
    - 调试内存问题时需要考虑字节顺序

## 3. 数据表示

### 3.1 整数表示

#### 无符号整数
- 范围：0 ~ 2^w - 1（w为位数）
- 常用于地址计算和数组索引

#### 有符号整数
- 采用二进制补码表示
- 范围：-2^(w-1) ~ 2^(w-1) - 1
- 最高位为符号位（0正1负）

#### 负数的补码表示
- 计算方法：正数取反加1
- 示例（8位系统）：
  ```
  要表示 -5：
  1. 5的二进制：0000 0101
  2. 取反：     1111 1010
  3. 加1：      1111 1011
  因此 -5 的补码表示为：1111 1011
  ```
- 补码的优势：
  - 0只有一种表示：0000 0000（按补码算出来也是这个）
  - 加法和减法可以统一处理（减法就是加一个负数）
  - 硬件实现简单（在实现时负数的加一刚好可以用多路复用的判断位）

### 3.2 浮点数表示（IEEE 754标准）

#### 基本组成
- 符号位(1位)：0表示正数，1表示负数
- 指数(8位)：用于表示小数点的位置
- 尾数(23位)：表示实际的数值部分

#### 示例：以单精度浮点数表示 -3.75
```
-3.75 = -11.11(二进制) = -1.111 × 2^1

1. 符号位 = 1（负数）
2. 指数部分：
   - 实际指数是1
   - IEEE 754使用偏移量127
   - 1 + 127 = 128 = 1000 0000(二进制)
3. 尾数部分：
   - 1.111 中的小数部分：111
   - 补齐23位：1110 0000 0000 0000 0000 000

最终表示：
1 10000000 11100000000000000000000
```

#### 特殊值
- ±0：指数和尾数都为0
- ±∞：指数全1，尾数为0
- NaN：指数全1，尾数非0

!!! warning "精度限制"
    浮点数不能精确表示所有实数，需要注意：
    - 舍入误差
    - 精度损失
    - 特殊值的处理

## 4. 实践建议

#### **编程注意事项**：
   - 注意整数溢出
   - 避免浮点数精确相等比较
   - 考虑不同平台的字节顺序

#### **调试技巧**：
   - 使用十六进制查看内存
   - 注意变量对齐
   - 理解编译器的优化行为
