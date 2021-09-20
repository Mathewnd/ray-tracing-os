# Ray tracing OS

![](https://cdn.discordapp.com/attachments/837156988668346390/889591229136904192/2021-09-20-131731_642x453_scrot.png)

A really simple 32 bit operating system designed specifically for running a very simple ray tracing renderer written in C++

It has a bare bones serial interface configured, a simple screen driver with framebuffer support,  and the ray tracing itself.

the stage 1 bootloader load a stage 2 bootloader that loads the main program and also sets up the GDT, A20 line and protected mode.

The first stage stage bootloader is copied from another prototype project so it is pretty messy and should probably be rewritten.

# Building

To build this you will need a cross compiler for the i686-elf target, nasm and mtools.
Then build it with
``make``

# Testing

To test it use qemu

``qemu-system-i386  -monitor stdio -drive file=bootdisk.img,format=raw,if=floppy -soundhw pcspk``

or build and run with
``make test``
