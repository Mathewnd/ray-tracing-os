all:
	mkdir bin || echo bin already exists
	nasm -f bin src/boot.asm    -o bin/boot.o
	nasm -f bin src/boot2.asm   -o bin/boot2.bin
	nasm -f elf32 src/entry.asm   -o bin/entry.o
	i686-elf-gcc -ffreestanding -c -o bin/main.o src/main.cpp
	i686-elf-gcc -ffreestanding -c -o bin/vga.o src/vga.cpp
	i686-elf-gcc -ffreestanding -c -o bin/serial.o src/serial.cpp
	i686-elf-gcc -ffreestanding -c -o bin/vector.o src/vector.cpp
	i686-elf-gcc -ffreestanding -c -o bin/tracer.o src/tracer.cpp
	i686-elf-gcc -ffreestanding -c -o bin/math.o src/math.cpp
	i686-elf-ld -Ttext 0x20000 --oformat binary -o bin/main bin/entry.o bin/main.o bin/vga.o bin/serial.o bin/vector.o bin/tracer.o bin/math.o
	dd if=/dev/zero of=bootdisk.img bs=512 count=2880
	dd if=bin/boot.o of=bootdisk.img bs=512 conv=notrunc count=1
	cd bin; mcopy -i ../bootdisk.img {boot2.bin,main} ::/
	
test: all

	qemu-system-i386  -monitor stdio -drive file=bootdisk.img,format=raw,if=floppy -soundhw pcspk

clean:
	rm bin/*
