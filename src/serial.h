#ifndef _SERIAL_H_INCLUDE
#define _SERIAL_H_INCLUDE


class Serial{
	
	



public:

	bool initPort(int port);
	void sendChar(int port, char c);
	void sendString(int port, char* s);
	
};


#endif
