---
title: "OS-Dev Notes #1"
author: "Alvan Rahimli"
date: 2021-10-01T14:19:49Z
draft: false
---

# OS-DEV notes #1

## 8086 Segment Registers:
To access memory adresses more than 16 bit (65535) we use 'Segment Registers'  
It is always appreciated to remove interrupts (`cli`), reset segment registers, then set interrupts (`sli`) before bootloader starts.  

- CS => Code Segment
- SS => Stack Segment
- DS => Data Segment
- ES => Extra Segment

Final memory address is calculated as:  
`final address = Segment Register * 16 + offset`  

In the example below, `lodsb` knows that, address it must read is `0x7c * 16 + 0x1f`, as `lodsb` uses Data Segment
```
org 0
mov ax, 0x7c
mov ds, ax
mov si, 0x1f
lodsb           ; LODSB uses Data Segment for segmentation
```

The table below demonstrates LOD__ command usage:
|Code |Mnemonic | Description|
---|---|---
|AC|LODS m8|Load byte at address DS:(E)SI into AL|
|AD|LODS m16|Load word at address DS:(E)SI into AX|
|AD|LODS m32|Load double-word at address DS:(E)SI into EAX|
|AC|LODSB | Load byte at address DS:(E)SI into AL|
|AD|LODSW | Load word at address DS:(E)SI into AX|
|AD|LODSD | Load double-word at address DS:(E)SI into EAX|

Stack Segmentation example:  
At the code below, when we __push 0xffff__ to stack, stack pointer is 
decremented by 2 (bc, we use 16 bit) and `sp == 0x7bfe`.  
Then, memory at adress __0x7bfe__ is set to __0xffff__.  

```
mov ax, 0x00    ; Set ax to 0x00
mov ss, ax      ; Move value in ax to 'stack segment'
mov ax, 0x7c00  ; Add ax to 0x7c00
mov sp, ax      ; Move AX to 'stack pointer'

push 0xffff     ; Pushes 0xffff to the stack
```

