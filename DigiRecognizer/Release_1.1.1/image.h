/*
 * image.h 
 */

#ifndef IMAGE_H_
#define IMAGE_H_

#include "defs.h"

#define BRIGHT          255         /* maximum brightness */
#define DARK            0           /* minimum brightness */
#define LEVEL           256         /* default gray levels */
#define GRAYLEVEL       256

/* 
 * Fundamental image structure.
 * Subimage actually specifies the region of interest (ROI) in which the 
 * image pixels are affected in the processing.
 */
typedef int PIXVAL;      	/* pixel values */
typedef struct {
  PIXVAL *pixel;                /* pixel value */
  unsigned int width, height;   /* dimension of the image */
  int x, y;                     /* upper left corner of window */
  int spectra;			/* image spectral number */
  unsigned int size_x, size_y;  /* window dimension */
  PIXVAL min_pixel, max_pixel;  /* min and max of pixel value */
}IMAGE;

/* macros */
/* access members of image struct */
#define ImageDataPtr(image)	 ((image)->pixel)
#define ImageWidth(image)	 ((image)->width)
#define ImageHeight(image)	 ((image)->height)
#define SubImageXpos(image)	 ((image)->x)
#define SubImageYpos(image)	 ((image)->y)
#define SubImageXsize(image)	 ((image)->size_x)
#define SubImageYsize(image)	 ((image)->size_y)
#define ImageMinPixval(image)	 ((image)->min_pixel)
#define ImageMaxPixval(image)	 ((image)->max_pixel)
#define ImagePixelValue(image, i, j) \
( *((image)->pixel+(j)*((image)->width)+(i)) )

/* Assign value to image struct */
#define SetImagePixelValue(image, i, j, v) \
( *((image)->pixel+(j)*((image)->width)+(i)) = (v) )
#define SetSubImage(image, xpos, ypos, xsize, ysize) \
( (image)->x = (xpos), (image)->y = (ypos), \
  (image)->size_x = (xsize), (image)->size_y = (ysize) )
#define SetImageMinPixval(image, val) \
( (image)->min_pixel = val )
#define SetImageMaxPixval(image, val) \
( (image)->max_pixel = val )

/* row by row operation */
#define ImageRow(image, j) \
((image)->pixel + (j)*(image)->width)
#define SubImageRow(image, j)      \
((image)->pixel+((image)->y+(j))*(image)->width+(image)->x)
#define MallocPixel(width, height) 	\
((PIXVAL *)malloc((width)*(height)*sizeof(PIXVAL)))
#define CallocPixel(width, height) 	\
((PIXVAL *)calloc((width)*(height),sizeof(PIXVAL)))


/*
 * Fundamental feature data structure.  Represented by arrays of each
 * component.  Column major storage.
 */
typedef struct {
  float **elem;
  int nelem;           /* number of elements for each data */
  int ndata;           /* number of data */
} DATA;

/* Macros */
#define NData(data)             ((data)->ndata)
#define NDataField(data)        ((data)->nelem)
#define DataField(data, n)	((data)->elem[n])
#define DataElement(data, m, n) ((data)->elem[n][m]) 


/* index and coordinates conversion */
#define XYtoINDEX(x,y,width)     ((y)*(width) + (x))
#define INDEXtoX(index,width)    ((index)%(width))
#define INDEXtoY(index,width)    ((int) (index)/(width))


/* function alias */
#define ExtractSubImageRegion(image, buf) \
ExtractRegion((image), (image)->x, (image)->y, (image)->size_x, (image)->size_y, buf)
#define ReplaceSubImageRegion(image, buf) \
ReplaceRegion((image), (image)->x, (image)->y, (image)->size_x, (image)->size_y, buf)


/* functions */
extern IMAGE *AllocImage P_((unsigned int width, unsigned int height));
extern void FreeImage P_((IMAGE *image));
extern void ResizeImage P_((IMAGE *img, unsigned int new_width, unsigned int new_height));
extern void ExtractRegion P_((IMAGE *image, unsigned int x, unsigned int y, unsigned int xsize, unsigned int ysize, PIXVAL *buf));
extern void ReplaceRegion P_((IMAGE *image, unsigned int x, unsigned int y, unsigned int xsize, unsigned int ysize, PIXVAL *buf));
extern void GetImageRow P_((IMAGE *image, PIXVAL *buf, int y));
extern IMAGE *DupImage P_((IMAGE *image));
extern void CopyImage P_((IMAGE *src, IMAGE *dst));
extern void CopyImageRegion P_((IMAGE *src, IMAGE *dst, int x, int y, int xsize, int ysize));
extern void ConstantImageRegion P_((IMAGE *image, int x, int y, int xsize, int ysize, PIXVAL value));
extern void ClearBoundary P_((IMAGE *image, int thickness));
extern void ClipPixVal P_((IMAGE *image));
extern int RegionPixelSum P_((IMAGE *image, int x, int y, int size_x, int size_y));
extern void RegionPixelMinMax P_((IMAGE *image, int x, int y, int size_x, int size_y, PIXVAL *min, PIXVAL *max));
extern void ImageColumnMinMax P_((IMAGE *image, int x, int y, unsigned int length, PIXVAL *min, PIXVAL *max));
extern void ImageRowMinMax P_((IMAGE *image, int x, int y, unsigned int length,PIXVAL *min, PIXVAL *max));
extern PIXVAL PixelArrayMax P_((PIXVAL *pixels, unsigned int length));
extern PIXVAL PixelArrayMin P_((PIXVAL *pixels, unsigned int length));

extern DATA *AllocData P_((unsigned int nelem, unsigned int ndata));
extern void FreeData P_((DATA *data));

extern int ZeroImage(IMAGE *src1);

#endif
