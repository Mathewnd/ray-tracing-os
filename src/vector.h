#ifndef _VECTOR_H_INCLUDED
#define _VECTOR_H_INCLUDED




class Vector3{
	


public:

	Vector3(float a, float b, float c);

	float x, y, z;

	void normalize();
	
};

float dot(Vector3 a, Vector3 b);

Vector3 operator * (Vector3 const &v, float const &m);
Vector3 operator / (Vector3 const &v, float const &d);
Vector3 operator + (Vector3 const &v, Vector3 const &a);
Vector3 operator - (Vector3 const &v, Vector3 const &s);

#endif // _VECTOR_H_INCLUDED
