+++
title = "Grub and the Multiboot Memory Map"
date = "2026-02-08"
updated = "2026-02-09"

[taxonomies]
tags=["osdev"]

[extra]
comment = true
+++

<style>.rust-playground { width: 100%; height: 420px; border: 1px solid #333; border-radius: 10px; } </style>


# Memory Map
This guide is for setting up a memory map on a i686 operating system.
If you are curious about starting your own operating system or how I got here,
check out [osdev](https://wiki.osdev.org) they have tons of tutorials on how to setup your own
operating system.

I followed the bare bones tutorial specifically, [bare bones](https://wiki.osdev.org/Bare_Bones). It details setting up your own kernel.
If you want more information on how I got started on my operating system I will make a tutorial soon

Without further ado, here's my tutorial.

# The Grub Bootloader
Currently most implemenations of kernels in 32 bit systems use either grub or limine as a bootloader.
I am in a c kernel, following the bare bones tutorial so I use grub, using the multiboot 1 standard.


Upon boot, grub gives you information about your system including a multiboot header
and the multiboot information structure.

There are several different fields that define different things that the bootloader describes about your system.


I am using the first version of the multiboot standard. which gives you a structure that looks like This.

```rust
+-------------------+
0       | flags             |    (required)
        +-------------------+
4       | mem_lower         |    (present if flags[0] is set)
8       | mem_upper         |    (present if flags[0] is set)
        +-------------------+
12      | boot_device       |    (present if flags[1] is set)
        +-------------------+
16      | cmdline           |    (present if flags[2] is set)
        +-------------------+
20      | mods_count        |    (present if flags[3] is set)
24      | mods_addr         |    (present if flags[3] is set)
        +-------------------+
28 - 40 | syms              |    (present if flags[4] or
        |                   |                flags[5] is set)
        +-------------------+
44      | mmap_length       |    (present if flags[6] is set)
48      | mmap_addr         |    (present if flags[6] is set)
        +-------------------+
52      | drives_length     |    (present if flags[7] is set)
56      | drives_addr       |    (present if flags[7] is set)
        +-------------------+
60      | config_table      |    (present if flags[8] is set)
        +-------------------+
64      | boot_loader_name  |    (present if flags[9] is set)
        +-------------------+
68      | apm_table         |    (present if flags[10] is set)
        +-------------------+
72      | vbe_control_info  |    (present if flags[11] is set)
76      | vbe_mode_info     |
80      | vbe_mode          |
82      | vbe_interface_seg |
84      | vbe_interface_off |
86      | vbe_interface_len |
        +-------------------+
88      | framebuffer_addr  |    (present if flags[12] is set)
96      | framebuffer_pitch |
100     | framebuffer_width |
104     | framebuffer_height|
108     | framebuffer_bpp   |
109     | framebuffer_type  |
110-115 | color_info        |
        +-------------------+


```
## multiboot memory map entries
This is super verbose so I condensed it down to just the memory map


```rust
Multiboot v1 — Getting the Memory Map
=====================================

On kernel entry:

EAX = 0x2BADB002        (multiboot magic)
EBX = multiboot_info*   <-- THIS is what you care about


multiboot_info structure (only relevant part):

EBX
 |
 v
+-------------------------------+
| flags                         | 0x00
+-------------------------------+
| mem_lower                     | 0x04
+-------------------------------+
| mem_upper                     | 0x08
+-------------------------------+
| ...                           |
+-------------------------------+
| mmap_length                   | 0x2C   (valid if flags bit 6 set)
+-------------------------------+
| mmap_addr  -------------------+------+
+-------------------------------+      |
                                       |
                                       v
                              Physical address of memory map list
```

{% rustplay() %}
fn align_down(addr: u64) -> u64 {
    addr & !0xfff
}

fn main() {
    let addr = 0x9fc23;
    println!("{:#x}", align_down(addr));
}
{% end %}

