#include "vga.h"

void Screen::putC(int x, int y, uint8_t c){
	
	//framebuffer[y*screen_X + x] = c;
	videomem[y*screen_X+x] = c;

}

void Screen::swapBuffer(){
	return;
	for(size_t i = 0; i < screen_X*screen_Y; ++i)
		videomem[i] = framebuffer[i];

}
