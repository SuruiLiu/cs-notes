# CHAPTER2：程序的机器级表示

## 1. 概述

程序在编译后会被转换为机器级代码。本章将介绍：

- 汇编语言的基本概念和指令系统
- 控制结构的底层实现机制
- 过程调用的运行时栈管理
- 数组和结构的内存布局
- 程序漏洞的防范措施

## 2. 程序编译过程

### 2.1 编译阶段

#### **完整流程**：
```bash
# 以hello.c为例
gcc -E hello.c -o hello.i    # 预处理
gcc -S hello.i -o hello.s    # 编译
gcc -c hello.s -o hello.o    # 汇编
gcc hello.o -o hello         # 链接
```

- 预处理（Preprocessing）：展开宏和包含文件
- 编译（Compilation）：生成汇编代码 hello.s
- 汇编（Assembly）：生成目标代码 hello.o
- 链接（Linking）：生成可执行文件 hello

### 2.2 机器级代码特点

#### x86-64 汇编基础
- 指令和数据存储在同一内存空间
- 支持多种数据大小操作
  - 字节(byte): 8位
  - 字(word): 16位
  - 双字(double word): 32位
  - 四字(quad word): 64位

#### GAS汇编格式
- 使用AT&T语法（与Intel语法不同）
- 操作数后缀
  - b: 字节操作
  - w: 字操作
  - l: 双字操作
  - q: 四字操作

## 3. 数据和控制

### 3.1 寄存器

#### 通用寄存器及用途
```nasm
# 函数调用相关
%rax: 返回值
%rdi, %rsi, %rdx, %rcx, %r8, %r9: 函数参数（按顺序）

# 被调用者保存
%rbx, %rbp, %r12-%r15: 被调用者负责保存和恢复

# 调用者保存
%r10-r11: 调用者负责保存

# 特殊用途
%rsp: 栈指针
%rip: 指令指针
```

#### 寄存器别名系统
```nasm
63      31      15      7       0
%rax    %eax    %ax     %al     # 累加器
%rbx    %ebx    %bx     %bl     # 基址
%rcx    %ecx    %cx     %cl     # 计数器
%rdx    %edx    %dx     %dl     # 数据
%rsi    %esi    %si     %sil    # 源索引
%rdi    %edi    %di     %dil    # 目标索引
%rsp    %esp    %sp     %spl    # 栈指针
%rbp    %ebp    %bp     %bpl    # 基指针
```

### 3.2 内存访问

#### 寻址模式详解
```nasm
# 格式：Imm(Rb,Ri,s)
# 有效地址：Imm + Rb + Ri * s

# 示例
movq (%rbx), %rax           # 简单间接
movq 8(%rbx), %rax         # 偏移寻址
movq (%rbx,%rcx), %rax     # 变址寻址
movq 8(%rbx,%rcx,4), %rax  # 比例变址寻址
```

## 4. 控制流

### 4.1 条件码

#### CPU条件标志位
- CF（进位标志）：无符号运算的溢出
- ZF（零标志）：结果为0
- SF（符号标志）：结果为负数
- OF（溢出标志）：有符号运算的溢出

#### 条件指令
```nasm
# 条件设置指令
sete    # 相等则设置
setne   # 不相等则设置
setg    # 大于则设置
setge   # 大于等于则设置
setl    # 小于则设置
setle   # 小于等于则设置

# 条件跳转指令
je      # 相等跳转
jne     # 不相等跳转
jg      # 大于跳转
jge     # 大于等于跳转
jl      # 小于跳转
jle     # 小于等于跳转
```

### 4.2 控制结构实现

#### if语句实现
```c
// C代码
if (test) {
    then-statement;
} else {
    else-statement;
}

// 汇编实现
  test                  # 执行测试
  je .L1               # 如果测试为假，跳转到else
  then-statement       # 执行then部分
  jmp .L2             # 跳过else部分
.L1:
  else-statement      # 执行else部分
.L2:
```

#### 循环实现
```c
// while循环
while (i < n) {
    body;
    i++;
}

// do-while循环
do {
    body;
    i++;
} while (i < n);

// for循环
for (i = 0; i < n; i++) {
    body;
}

// 汇编实现（while循环示例）
  movl $0, %eax        # i = 0
.L2:
  cmpl %edi, %eax      # 比较 i 和 n
  jge .L4              # 如果 i >= n，跳出循环
  # 循环体
  addl $1, %eax        # i++
  jmp .L2              # 继续循环
.L4:
```

## 5. 过程调用

### 5.1 运行时栈

#### 栈帧详解
```
高地址
          +------------------+
          |                  |
          |  调用者栈帧      |
          |                  |
          +------------------+ <-- 调用者的%rbp
          |  返回地址        |
          +------------------+
          |  旧%rbp         |
          +------------------+ <-- 当前%rbp
          |                  |
          |  局部变量        |
          |                  |
          +------------------+
          |                  |
          |  临时存储空间    |
          |                  |
          +------------------+ <-- 当前%rsp
低地址
```

#### 函数调用示例
```c
// C代码
int sum(int x, int y) {
    int t = x + y;
    return t;
}

// 汇编代码
sum:
    pushq   %rbp            # 保存旧的基指针
    movq    %rsp, %rbp      # 设置新的基指针
    
    movl    %edi, -4(%rbp)  # 保存参数x
    movl    %esi, -8(%rbp)  # 保存参数y
    
    movl    -4(%rbp), %edx  # 加载x
    movl    -8(%rbp), %eax  # 加载y
    addl    %edx, %eax      # t = x + y
    
    movl    %eax, -12(%rbp) # 保存结果t
    movl    -12(%rbp), %eax # 加载返回值
    
    popq    %rbp            # 恢复基指针
    ret                     # 返回
```

### 5.2 参数传递

#### x86-64参数传递规则
1. 整数/指针参数
   - 最多6个参数通过寄存器传递
   - 按顺序使用：%rdi, %rsi, %rdx, %rcx, %r8, %r9
   - 超过6个的参数通过栈传递

2. 浮点数参数
   - 使用XMM寄存器：%xmm0-%xmm7
   - 超过8个的参数通过栈传递

## 6. 数据对齐

### 6.1 内存对齐规则

#### 基本对齐要求
- 1字节数据：任意地址
- 2字节数据：2的倍数地址
- 4字节数据：4的倍数地址
- 8字节数据：8的倍数地址

#### 结构体对齐
```c
struct S1 {
    char c;    // 1字节
    int i;     // 4字节
    char d;    // 1字节
};  // 总大小：12字节（包含填充）

// 内存布局
// c _ _ _ i i i i d _ _ _
// _表示填充字节
```

### 6.2 对齐优化
```c
// 优化前
struct S2 {
    char c;    // 1字节 + 3字节填充
    int i;     // 4字节
    char d;    // 1字节 + 3字节填充
};  // 总大小：12字节

// 优化后
struct S2 {
    int i;     // 4字节
    char c;    // 1字节
    char d;    // 1字节
    // 2字节填充
};  // 总大小：8字节
```

## 7. 程序调试

### 7.1 GDB基础

#### 常用GDB命令
```bash
# 启动和运行
gdb program              # 启动GDB
run [args]              # 运行程序
break function          # 设置断点
continue               # 继续执行
next                   # 单步执行（不进入函数）
step                   # 单步执行（进入函数）

# 检查程序状态
print expr             # 打印表达式值
x/[n][f][u] addr      # 检查内存
info registers        # 显示寄存器
backtrace            # 显示调用栈

# 汇编级调试
disas function        # 显示汇编代码
stepi                # 单步执行一条指令
nexti                # 单步执行一条指令（不进入调用）
```

### 7.2 内存安全

#### 缓冲区溢出
```c
// 危险代码示例
void vulnerable() {
    char buffer[8];
    gets(buffer);  // 危险！没有长度检查
}

// 安全版本
void safe() {
    char buffer[8];
    fgets(buffer, sizeof(buffer), stdin);  // 安全：有长度限制
}
```

#### 防护机制
1. 栈保护器（Stack Canary）
   - 在栈帧中插入哨兵值
   - 函数返回前检查哨兵值是否被修改

2. 地址空间布局随机化（ASLR）
   - 随机化栈、堆、共享库的位置
   - 使攻击者难以预测内存地址

3. 不可执行栈
   - 将栈标记为不可执行
   - 防止执行注入的恶意代码

## 8. 性能优化

### 8.1 代码优化策略

#### 基本原则
- 使用寄存器变量
- 减少内存访问
- 利用条件传送指令
- 展开循环减少分支预测失败

#### 示例优化
```c
// 优化前
for (i = 0; i < n; i++) {
    if (a[i] > max)
        max = a[i];
}

// 优化后（使用条件传送）
for (i = 0; i < n; i++) {
    int t = a[i];
    max = t > max ? t : max;  // 编译器会使用条件传送指令
}
```

!!! warning "安全注意事项"
    - 始终检查缓冲区边界
    - 使用安全的字符串函数
    - 注意整数溢出
    - 避免使用危险函数（如gets, strcpy）
    - 编译时启用保护机制
      ```bash
      gcc -fstack-protector -pie -fPIC program.c
      ```
