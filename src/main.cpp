#include "stddef.h"
#include "stdint.h"

#include "serial.h"
#include "vga.h"

#include "tracer.h"

extern "C" void pmain(){
	
	Serial serial;

	Screen screen;

	if(!serial.initPort(0)){
		screen.putC(0,0,4);
		screen.swapBuffer();
		return;
	}

	serial.sendString(0, "\nSERIAL OK\n");
	
	Tracer tracer(&screen);
		

	for(;;){
		
		tracer.traceToFrameBuffer();
		screen.swapBuffer();

	}

}
