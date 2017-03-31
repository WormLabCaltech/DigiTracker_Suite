/* 
 * mdefs.h
 */

#ifndef MDEFS_H_
#define MDEFS_H_

#include <math.h>

/* important constants */
#ifndef PI
#define PI                      3.14159265358979323846
#endif
#define SQRT2                   1.41421356237309504880
#define SQRT3                   1.73205080756887729353

/* common macros */
#define IsOdd(x)                ((x)%2)
#define IsEven(x)               (!(IsOdd(x)))
#define Sgn(x)                  ((x)>0.0 ? 1 : ((x)<0.0 ? -1 : 0))
#define Round(x)                ((int)((x)>0.0 ? (x)+0.5 : (x)-0.5))
#define Abs(x)                  ((x)<0.0 ? -(x) : (x))
#define Square(x)               ((x)*(x))
#define Greater(a, b)           (((a)>(b)) ? (a) : (b))
#define Smaller(a, b)           (((a)<(b)) ? (a) : (b))
#define RADtoDEG(x)             ((x)*57.295779513082320877)
#define RAD2DEG(x)              ((x)*57.295779513082320877)
#define DEGtoRAD(x)             ((x)*0.017453292519943295769)
#define DEG2RAD(x)              ((x)*0.017453292519943295769)

#endif
