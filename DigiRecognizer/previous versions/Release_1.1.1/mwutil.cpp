#include "stdafx.h"
#include "mex.h"
#include <math.h>
#include "image.h"

extern Matrix *extract(Matrix *im, int cx, int cy, int wx, int wy, int *offx, int *offy);
extern void TrMedian(IMAGE *src, IMAGE *dest, int filter_size,int percentile);
 
#define sqr(x) ((x)*(x))

#if 0
Matrix *
mw_segment(Matrix *im, int ms, double threshold)
{
	int offx, offy;
	Matrix *chip;
	unsigned int **chipp;
	Matrix *worm = NULL;	

	int m, n;
	int i, j, k, l, count;
	unsigned int **wormp;
	float ave, var;
	unsigned int **imp;

	imp=(unsigned int **) mxGetPr(im);

	/* set size of matrices */
	m = mxGetM(im);
	n = mxGetN(im);

	/* allocate space for output */
	worm = mxCreateFull(m, n, INT);

	/* setup for two dimensional indexing */
	wormp = (unsigned int **) mxGetPr(worm);

		
	IMAGE *src, *dest;

	src=(IMAGE*) AllocImage(n, m);
	dest=(IMAGE*) AllocImage(n, m);
	
	ZeroImage(src);

	/* now perform the computation */
	if( wormp != NULL )
	{
		for( i = ms/2+1; i < n-ms/2-1; i++ )
			for( j = ms/2+1; j < m-ms/2-1; j++ ) {
				chip = extract(im, i, j, ms, ms, &offx, &offy);
				chipp = (unsigned int **) mxGetPr(chip);
				ave=0;
				var=0;
				count=0;
				for (k=0; k < ms; k++)
					for(l=0; l < ms; l++) {
						ave+=chipp[k][l];
						count++;
					}
				ave/=count;
				
				if(ave > 0.0) {
					float val = imp[i][j] - ave;
					for (k=0; k < ms; k++)
						for(l=0; l < ms; l++) {
							var += (chipp[k][l]-ave)*(chipp[k][l]-ave);
						}
	 
					val /= (sqrt(var)/(double)(count-1));
					if(val < -50.0) val = -50.0;
					if(val > 25.0) val = 50.0;
					//if(val < threshold) wormp[i][j] = (int) (255.0 * (-val/50.0));
					if(val < threshold) ImageDataPtr(src)[j*n+i] = (int) (255.0 * (-val/50.0));
				}
				mxFreeMatrix(chip);
			}

	}

	// apply filter
	TrMedian(src, dest, 5, 50);

	// convert Image to Matrix
    for (i=0; i < n; i++) 
		for (j=0; j <m; j++) 
			wormp[i][j]=ImageDataPtr(dest)[j*n+i];

	/* now return the answer */
	return(worm);  	
}
#endif


Matrix *
mw_segment(Matrix *im, int ms, double threshold)
{
	Matrix *worm = NULL;	

	int m, n;
	int i, j, k, count;
	unsigned int **wormp;
	float ave, var;
	unsigned int **imp;

	imp=(unsigned int **) mxGetPr(im);

	/* set size of matrices */
	m = mxGetM(im);
	n = mxGetN(im);

	/* allocate space for output */
	worm = mxCreateFull(m, n, INT);

	/* setup for two dimensional indexing */
	wormp = (unsigned int **) mxGetPr(worm);

		
	IMAGE *src, *dest;

	src=(IMAGE*) AllocImage(n, m);
	dest=(IMAGE*) AllocImage(n, m);
	
	ZeroImage(src);

	/* now perform the computation */
	if( wormp != NULL )
	{
		int total_base, sqrtotal_base, total, sqrtotal;

		total_base=0;
		sqrtotal_base=0;
		for (i = 0 ; i < ms; i++)
			for (j =0; j < ms ; j++) {
				total_base+=imp[i][j];
				sqrtotal_base+=sqr(imp[i][j]);
			}
		count=ms*ms;
		total=total_base;
		sqrtotal=sqrtotal_base;

		for( i = ms/2+1; i < n-ms/2-1; i++ ) {
			for( j = ms/2+1; j < m-ms/2-1; j++ ) {
					
				ave=(float) total/ (float) count;

				if(ave > 0.0) {
					float val = imp[i][j] - ave;
					
					var=sqrtotal-2*total*ave+count*ave*ave;

					val /= sqrt(var/(double)(count-1));
					if(val < -5.0) val = -5.0;
					if(val < threshold) ImageDataPtr(src)[j*n+i] = (int) 255.0 ;
				}
				
				for (k=i-ms/2-1; k < i+ms/2; k++) {
					total-=imp[k][j-ms/2-1];
					sqrtotal-=sqr(imp[k][j-ms/2-1]);
				}

				for (k=i-ms/2-1; k < i+ms/2; k++) {
					total+=imp[k][j+ms/2];
					sqrtotal+=sqr(imp[k][j+ms/2]);
				}

			}
			total=total_base;
			sqrtotal=sqrtotal_base;
				
			for (k=0; k < ms; k++) {
				total-=imp[i-ms/2-1][k];
				sqrtotal-=sqr(imp[i-ms/2-1][k]);
			}

			for (k=0; k <ms; k++) {
				total+=imp[i+ms/2][k];
				sqrtotal+=sqr(imp[i+ms/2][k]);
			}
			total_base=total;
			sqrtotal_base=sqrtotal;

		}

	}

	// apply filter
	TrMedian(src, dest, 5, 50);

	// convert Image to Matrix
    for (i=0; i < n; i++) 
		for (j=0; j <m; j++) 
			wormp[i][j]=ImageDataPtr(dest)[j*n+i];
	FreeImage(dest);
	FreeImage(src);
	/* now return the answer */
	return(worm);  	
}
