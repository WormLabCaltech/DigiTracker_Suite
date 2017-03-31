/*
 * TrMedian.c: contains subroutine TrMedian() and other supporting subroutines
 *             TrMedian() is implemented using two running histograms
 */
#include "stdafx.h"
#include <math.h>
#include "image.h"
#include "mdefs.h"


static void Copy_Array(int *arr1, int *arr2,int size)
     /* source: arr1; destination: arr2 */
      /* size to be copied */
{
  register int i;
    
  for(i=0; i<size; ++i)
    *arr2++ = *arr1++;
}

/* Get histogram of a window from the image */
void GetHistogram(int *hist, int nbin, IMAGE *image, int x, int y, int xsize, int ysize)
     /*int *hist;            return value 
     int nbin;             number of bins in histogram 
     IMAGE *image;
     int x, y, xsize, ysize;*/
{
  register int i, j;
  PIXVAL *row = ImageRow(image, y) + x;

  for(i=0; i<nbin; ++i)  hist[i] = 0;  /* initialization */

  for(j=0; j<ysize; ++j, row+=ImageWidth(image))
    for(i=0; i<xsize; ++i)   
	++hist[row[i]*nbin/256];
}


/* Find the median from the histogram.  The function returns the median and 
 * the number of elements less than the median (lessmdn). 
 */
static int MedianFromHist(int *hist, int nbin, int index,int *lessmdn)
     //int *hist, nbin, index, *lessmdn;   
{
  register int i, total;
    
  total = 0;
  for(i=0; i<nbin; ++i)
    if((total += hist[i]) >= index){
      *lessmdn = total - hist[i];
      return i;
    }
    
  return nbin;   /* fail to find the desired index: incorrect index */
}

/* UpdateRowHist() and UpdateColHist() are very similar in structure; it is
 * possible to write a generalized version.  But in order to maintain 
 * clarity and speed, two separate subroutines are used.  (UpdateRowHist() is
 * to be called many times in the median filter.)
 */

/* 
 * Update the row histogram (in horizontal direction), left column  
 * is removed from the histogram and right column which 
 * is length apart is added.  The height of
 * the columns are 'length'.  So hist and lessmdn are updated.
 * This is the crucial subroutine to TrMedian()
 */
static void UpdateRowHist(PIXVAL *row,int width,int length,int *hist,int median,int *lessmdn)
     //PIXVAL *row;
     //int width;      /* to next row */
     //int length;     /* height of the arrays */
     //int *hist;
     //int median, *lessmdn;  /* return values */
{
  register int j, gl;
    
  for(j=0; j<length; ++j, row += width) {
    /* delete the old ones */
    gl = row[0];
    --hist[gl];
    if(gl<median)  --(*lessmdn);
        
    /* add the new ones */
    gl = row[length];
    ++hist[gl];
    if(gl<median)  ++(*lessmdn);
  }
}

/* update histogram in vertical direction, deletion the upper row and replace
 * lower row.
 */
static void UpdateColHist(PIXVAL *row, int width, int length,int *hist,int median,int *lessmdn)
 //    PIXVAL *row;
 //    int width;
 //    int length;     /* height of the arrays */
 //    int *hist;
 //    int median, *lessmdn;  /* return values */
{
  register int i, gl;
  PIXVAL *new_row = row + length*width;

  for(i=0; i<length; ++i){
    /* delete the old ones */
    gl = row[i];
    --hist[gl];
    if(gl<median)  --(*lessmdn);
        
    /* add the new ones */
    gl = new_row[i];
    ++hist[gl];
    if(gl<median)  ++(*lessmdn);
  }
}

static void UpdateMedian(int *hist, int *median, int *lessmdn, int index)
 //    int *hist;
 //    int *median, *lessmdn, index;
{
  if(*lessmdn >= index) 
    /* the median in the current window is smaller than the one in the 
     *  previous window
     */
    do {
      --*median;
      *lessmdn -= hist[*median];
    } while(*lessmdn >= index);
    
  else 
    while((*lessmdn+hist[*median]) < index){
      *lessmdn += hist[*median];
      ++*median;
    }
}     
 

/* TrMedian() is a median filter for signal smoothing.  It is particular 
 * effective for removing high frequency noise such as those caused by high
 * energy protons.  The disadvantage is edge smearing.
 * Median filtering simply replaces a pixel value with median of the 
 * neighboring pixels.
 * The following routine is adapted from Huang et al's "A fast two-dimensional
 * median filtering algorithm" 1979.
 * The major difference is histograms flow in two directions, horizontal and 
 * vertical.  Suitable for parallel processing.
 *
 * Cannot be performed in place.  src and dest are of the same dimension.
 */
void TrMedian(IMAGE *src, IMAGE *dest, int filter_size,int percentile)
     //IMAGE *src, *dest;
     //int filter_size, percentile;  /* percentile specifying the index */
{
  /* running histogram for x and y direction */
  int histx[LEVEL], histy[LEVEL]; 
  register int i, j;
  int lessmdny, lessmdnx;
  int index = Round(filter_size*filter_size*percentile/100.0);
  PIXVAL *src_row, *dest_row;
  int width = ImageWidth(src), height = ImageHeight(src), offset;
    
  offset = filter_size/2;
  dest_row = ImageRow(dest, offset)+offset;
  src_row=ImageDataPtr(src);

  /* Get the first histogram and find the median */
  GetHistogram(histy, LEVEL, src, 0, 0, filter_size, filter_size);
  dest_row[0] = MedianFromHist(histy, LEVEL, index, &lessmdny);

  /* Transition starts with the old position */
  for(j=0; j<height-filter_size+1; ++j){
        
    Copy_Array(histy, histx, LEVEL);  /* histx for row */
    lessmdnx = lessmdny;
        
    /* for each row */
    for(i=1; i<width-filter_size+1; ++i){
      dest_row[i] = dest_row[i-1];
      UpdateRowHist(src_row+i-1, width, filter_size, histx, 
                    dest_row[i], &lessmdnx);
      UpdateMedian(histx, &dest_row[i], &lessmdnx, index);
    }
        
    if(j != height-filter_size) {    /* no update for the last one */
      *(dest_row+width) = *dest_row;
      UpdateColHist(src_row, width, filter_size, histy, 
                    *(dest_row+width), &lessmdny);
      UpdateMedian(histy, dest_row+width, &lessmdny, index);
    }
        
    dest_row += width;  src_row += width;
  }

  /* copy the unchanged pixels */
  /* top */
  CopyImageRegion(src, dest, 0, 0, width, offset);        
  /* bottom */
  CopyImageRegion(src, dest, 0, height-(filter_size-offset-1), width, filter_size-offset-1);
  /* left */
  CopyImageRegion(src, dest, 0, 0, offset, height);
  /* right */
  CopyImageRegion(src, dest, width-(filter_size-offset-1), 0, filter_size-offset-1, height);
}


/*
 * Median pixels which are (strictly) below a threshold
 */

void TrSpotMedian(IMAGE *src,int filter_size,int percentile,int threshold)
  
{
  int hist[256];
  register int i, j;
  PIXVAL *pixrow;
  int lessmdn, index, width, height, offset; 

  offset = filter_size>>1;
  index = (int)(filter_size*filter_size*percentile/100.0+0.5);
  width = ImageWidth(src);
  height = ImageHeight(src);

  // Transition starts with the old position 
  for(j=0; j<height-filter_size+1; ++j){    

    pixrow = ImageRow(src, j+offset);

    for(i=0; i<width-filter_size+1; ++i){
      if(pixrow[i+offset] < threshold) {
        GetHistogram(hist, 256, src, i, j, filter_size, filter_size);
        pixrow[i+offset] = MedianFromHist(hist, 256, index, &lessmdn);
      }
    }
  }
}

