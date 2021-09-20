#include "vector.h"

#include "math.h"

Vector3::Vector3(float a, float b, float c){
	x = a;
	y = b;
	z = c;
}

Vector3 operator * (Vector3 const &v, float const &m){
	return Vector3(v.x * m, v.y * m, v.z * m);
}

Vector3 operator / (Vector3 const &v, float const &d){
	return Vector3(v.x / d, v.y / d, v.z / d);
}

Vector3 operator + (Vector3 const &v, Vector3 const &a){
	return Vector3(v.x + a.x, v.y + a.y, v.z + a.z);
}


Vector3 operator - (Vector3 const &v, Vector3 const &s){
	return Vector3(v.x - s.x, v.y - s.y, v.z - s.z);
}

void Vector3::normalize(){
	
	float length = sqrt(x*x + y*y + z*z);
	x /= length;
	y /= length;
	z /= length;

}

float dot(Vector3 a, Vector3 b){
	
	return a.x*b.x+a.y*b.y+a.z*b.z;

}
