/*
 * image.c -- subroutines which manipulates IMAGE structure
 */
#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "image.h"
#include "mdefs.h"

/*****************************************************/
int ZeroImage(IMAGE *src1)

{
 int i;
 int w = ImageWidth(src1);
 int h = ImageHeight(src1);
 PIXVAL *s1 = ImageDataPtr(src1);
 for(i=0;i<w*h;i++) *s1++ = 0;
 return 1;
}

/* return IMAGE struct width pixel array allocated */
IMAGE *AllocImage(unsigned int width, unsigned int height)

{
  IMAGE *img=(IMAGE *)malloc(sizeof(IMAGE));

  img->width=width;  img->height=height;
  img->x=0;  img->y=0;
  img->size_x=width;  img->size_y=height;
  img->min_pixel=DARK;  img->max_pixel=BRIGHT;
  img->pixel=(PIXVAL *)calloc(width*height, sizeof(PIXVAL));
  if(img->pixel == NULL)  {
    fprintf(stderr, "Out of memory!\n");
    exit(1);
  }

  return img;
}

/* free IMAGE struct and the pixel array */
void FreeImage(IMAGE *image)
    
{
  if(image==NULL) return;

  free(image->pixel);
  free(image);
}

/*
 * resize image pixel 
 */
void ResizeImage(IMAGE *img, unsigned int new_width, unsigned int new_height)
  

{
  int npixels;

  if(img->width != new_width || img->height != new_height ){
    if((npixels = new_width*new_height) != img->width*img->height)
      img->pixel = (PIXVAL *)realloc(img->pixel, npixels*sizeof(PIXVAL));
    img->width=new_width;  img->height=new_height;
    img->x=0;  img->y=0;
    img->size_x=new_width;  img->size_y=new_height;
    img->min_pixel=DARK;  img->max_pixel=BRIGHT;
  }
}

/* 
 * extract the region specified by image and place it in an array. return
 * the array.
 */
void ExtractRegion(IMAGE *image, unsigned int x,unsigned int y,unsigned int xsize,unsigned int ysize,PIXVAL * buf)

{
  register int i, j;
  register PIXVAL *pixrow;

  for(j=y; j<(int)(y+ysize); ++j) {
    pixrow = ImageRow(image, j);
    for(i=x; i<(int)(x+xsize); ++i)
      *buf++ = pixrow[i];
  }
}

/*
 * extract the region tilted at an angle theta (in degrees).  
 *
 * image: the original image
 * xc, yc: the center of rotation
 * xsize, ysize: dimension of the region
 * theta: tilted angle
 * buf: return array
 *
 * (cf TrRotate())
 */
void ExtractTiltedRegion(IMAGE *image,int xc,int yc,int xsize,int ysize,float theta, PIXVAL *buf)

{
  register int i, j, x, y, w, h;
  double sint, cost, t, xt, yt;
  PIXVAL *pixvals = ImageDataPtr(image);
  
  w = ImageWidth(image);
  h = ImageHeight(image);

  t = DEGtoRAD(theta);
  sint = sin(t);  cost = cos(t);

  for(j= -ysize/2; j<ysize-ysize/2; ++j)
    for(i=-xsize/2; i<xsize-xsize/2; ++i) {
      /* nearest neighbor */
      xt = cost*i - sint*j;
      x = Round(xt) + xc;
      if(x>=w || x<0)   /* pixel not available, set to zero */
        *buf++ = DARK;
      else{
        yt = sint*i + cost*j;
	y = Round(yt) + yc;
	if(y>=h || y<0) 
	  *buf++ = DARK;
	else
	  *buf++ = pixvals[y*w+x];
      }
    }
}

/*
 * replace the region specified by image by the array region.  size must
 * match.  complement of ExtractRegion().
 */
void ReplaceRegion(IMAGE *image,unsigned int x,unsigned int y,unsigned int xsize,unsigned int ysize,PIXVAL * region)
 
{
  register int i, j;
  register PIXVAL *pixrow;

  for(j=y; j<(int)(y+ysize); ++j) {
    pixrow = ImageRow(image, j);
    for(i=x; i<(int)(x+xsize); ++i)
      pixrow[i] = *region++;
  }
}


/* 
 * Return the specified row of image 
 */
void GetImageRow(IMAGE *image,PIXVAL *buf,int y)
 //    IMAGE *image;
 //    PIXVAL *buf;          /* return */
 //    int y;               /* row */
{
  PIXVAL *pixvals=ImageRow(image, y);
  int n=image->width;

  while(n--)
    *buf++ = *pixvals++;
}

/* 
 * Duplicate image
 */
IMAGE *DupImage(IMAGE *image)

{
  IMAGE *copy=AllocImage(ImageWidth(image), ImageHeight(image));

  memcpy(ImageDataPtr(copy), ImageDataPtr(image), ImageWidth(image)*ImageHeight(image)*sizeof(PIXVAL));

  return copy;
}

/*
 * Copy image
 */
void CopyImage(IMAGE *src, IMAGE *dst)

{
  register int npixel = src->width*src->height;
  PIXVAL *psrc=src->pixel, *pdst=dst->pixel;

  while(npixel--)  *pdst++ = *psrc++;
}

/*
 * Copy the corresponding region
 */
void CopyImageRegion(IMAGE *src, IMAGE *dst, int x,int y, int xsize,int ysize)

{
    PIXVAL *psrc = ImageRow(src, y) + x;
    PIXVAL *pdst = ImageRow(dst, y) + x;
    register int i, j;

    for(j=0; j<ysize; ++j) {
        for(i=0; i<xsize; ++i)
            pdst[i] = psrc[i];

        psrc += ImageWidth(src);  pdst += ImageWidth(dst);
    }
}

/* 
 * Set the region a constant value
 */
void ConstantImageRegion(IMAGE *image, int x, int y, int xsize,int ysize,PIXVAL value)
 
{
  PIXVAL *row = ImageRow(image, y) + x;
  register int i, j;

  for(j=0; j<ysize; ++j) {
     for(i=0; i<xsize; ++i)
        row[i] = value;
     row += ImageWidth(image);
  }
}

/* 
 * Set boundary pixels to 0.  Upper boundary y:0:thickness-1, lower boundary
 * y:size_y-thickness:size_y-1, left boundary x:0:thickness-1, right 
 * boundary x:size_x-thickness:size_x-1
 */
void ClearBoundary(IMAGE *image,int thickness)

{
  register int n, x, y, width, height;
  PIXVAL *pixvals = ImageDataPtr(image);

  width = image->width;  height = image->height;
  for(n=0; n<thickness; ++n){
    /* upper edge and lower edge */
    for(x=image->x; x<(int)(image->x+image->size_x); ++x){
      pixvals[n*width+x] = 0;
      pixvals[(height-1-n)*width+x] = 0;
    }
    /* left edge and right edge */
    for(y=image->y; y<(int)(image->y+image->size_y); y++){
      pixvals[y*width+n] = 0;
      pixvals[(y+1)*width-1-n] = 0;
    }
  }
}

/*
 * ClipPixVal -- clip pixel values to [DARK, BRIGHT]
 */
void ClipPixVal(IMAGE *image)

{
  PIXVAL *pixrow;
  int i, j;

  for(j=0; j<(int)(image->size_y); ++j) {
    pixrow = SubImageRow(image, j);
    for(i=0; i<(int)(image->size_x); ++i) {
      if((pixrow[i]=Abs(pixrow[i]))>BRIGHT)  
	pixrow[i]=BRIGHT;
    }
  }
}

/* 
 * RegionPixelSum() -- sum of the pixel of a region with the upper left 
 * corner at (x, y) and size_x x size_y.
 */
int RegionPixelSum(IMAGE *image,int x,int y,int size_x,int size_y)

{
  register int sum; 
  register int i, j;
  register PIXVAL *pixvals = image->pixel+image->width*y+x;

  sum = 0;
  for(j=0; j<size_y; ++j){
    for(i=0; i<size_y; ++i)
      sum += pixvals[i];
    pixvals += image->width;
  }

  return sum;
}

/*
 * RegionPixelMinMax() -- return the maximum value and the minimum value of 
 * the region 
 */
void RegionPixelMinMax(IMAGE *image,int x,int y, int size_x, int size_y, PIXVAL *min,PIXVAL *max)

{
  int i, j;
  PIXVAL *pixvals = image->pixel+image->width*y+x;
  
  *min = *max = pixvals[0];
  /* Get the sum of the very first filter */
  for(j=0; j<size_y; ++j) {
    for(i=0; i<size_y; ++i) 
      if(pixvals[i] > *max)  *max = pixvals[i];
      else if(pixvals[i] < *min)  *min = pixvals[i];
    
    pixvals += image->width;
  }
}

/*
 * ImageColumnMinMax() -- return the minimum and maximum of a image column
 * of specific length.
 */
void ImageColumnMinMax(IMAGE *image, int x,int y, unsigned int length, PIXVAL *min,PIXVAL *max)
 //    IMAGE *image;
 //    int x, y;                     /* the top of the column */
 //    unsigned int length;          /* length of the column */
 //    PIXVAL *min, *max;            /* return */
{
  PIXVAL *pixvals = image->pixel+image->width*y+x;
  register int n;

  *min = *max = *pixvals;
  n = length - 1;
  while(n--) {     /* first pixel has already assigned */
    pixvals += image->width;
    if(*pixvals > *max)  *max = *pixvals;
    else if(*pixvals < *min)  *min = *pixvals;
  }
}

/*
 * ImageRowMinMax() -- return the minimum and maximum of a image row 
 */
void ImageRowMinMax(IMAGE *image, int x, int y, unsigned int length, PIXVAL *min, PIXVAL *max)
 //    IMAGE *image;
 //    int x, y;                     /* the top of the column */
 //    unsigned int length;          /* length of the column */
 //    PIXVAL *min, *max;            /* return */
{
  PIXVAL *pixvals = image->pixel+image->width*y+x;
  register int n;

  *min = *max = *pixvals;
  n = length - 1;
  while(n--) {     /* first pixel has already assigned */
    pixvals++;
    if(*pixvals > *max)  *max = *pixvals;
    else if(*pixvals < *min)  *min = *pixvals;
  }
}

/* 
 * PixelArrayMax() -- return the maximum of a pixel array 
 */
PIXVAL PixelArrayMax(PIXVAL *pixels, unsigned int length)
 //    PIXVAL *pixels;
 //    unsigned int length;
{
  PIXVAL max;

  max = *pixels;
  while(--length) 
    if(*(++pixels)>max)  max = *pixels;

  return max;
}

/* 
 * PixelArrayMin() -- return the minimum of a pixel array 
 */
PIXVAL PixelArrayMin(PIXVAL *pixels, unsigned int length)
 
{
  PIXVAL min;

  min = *pixels;
  while(--length) 
    if(*(++pixels)<min)  min = *pixels;

  return min;
}


/*
 *  subroutines which manipulate DATA structure
 */

/*
 * allocate memory for DATA structure.  
 */
DATA *AllocData(unsigned int nelem, unsigned int ndata)
 
{
  DATA *data;
  int n;

  if((data = (DATA *)malloc(sizeof(DATA))) != NULL) {
    data->nelem = nelem;  data->ndata = ndata;

    if(nelem != 0) {
      data->elem = (float **)malloc(nelem*sizeof(float*));
      if(ndata != 0) {
        for(n=0; n<(int)(nelem); ++n)
          data->elem[n] = (float *)malloc(ndata*sizeof(float));
      } else {
        for(n=0; n<(int)(nelem); ++n)
          data->elem[n] = NULL;
      }
    } 
    else  data->elem = NULL;
  }

  return data;
}

/* free all memory associated with DATA structure */
void FreeData(DATA *data)
 
{
  int n;

  if(data == NULL)  return;

  if(data->elem != NULL) {
    for(n=0; n<data->nelem; ++n) {
      if(data->elem[n]!=NULL)  free(data->elem[n]);
    }
    free(data->elem);
  }
  free(data);
}
