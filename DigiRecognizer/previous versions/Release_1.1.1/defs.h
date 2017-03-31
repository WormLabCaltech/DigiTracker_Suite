/* 
 * defs.h
 */
#ifndef DEFS_H_
#define DEFS_H_

/* for ANSI C and C++ compatibility */
#if defined(__STDC__) || defined(__cplusplus)
#define P_(s) s
#else
#define P_(s) ()
#endif

#if !defined FALSE && !defined TRUE
typedef enum { FALSE, TRUE } BOOLEAN;
#endif

/* status */
#define OK        0
#define ERROR    -1
#define QUIT     -2

#endif
