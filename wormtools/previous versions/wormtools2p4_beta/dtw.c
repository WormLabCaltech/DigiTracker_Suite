#include <stdlib.h>
#include <stdio.h>
//  #include <math.h>
//  #include <float.h>
#include "mex.h"

#ifdef _MSC_VER
#include <float.h>  // for _isnan() on VC++
#define isnan(x) _isnan(x)  // VC++ uses _isnan() instead of isnan()
#else
#include <math.h>  // for isnan() everywhere else
#endif

int
minarg(double a, double b, double c)
{
	if( (a <= b) && (a <= c) )
		return(0);
	
	if( (b <= a) && (b <= c) )
		return(1);

	return(2);
}

double
minele(double a, double b, double c)
{
	if( (a <= b) && (a <= c) )
		return(a);
	
	if( (b <= a) && (b <= c) )
		return(b);

	return(c);
}

void
timeWarp(const mxArray *signal1, const mxArray *signal2, int Wj,
		 mxArray **path1, mxArray **path2)  
{
	int i, j;
	double *signal1p, *signal2p;
	int size1, size2;
	int tcols;
	mxArray *costmatrix, *indices, *is, *js;
	double **costmatrixp, **indicesp, **isp, **jsp;
	int npath1 = 0, npath2 = 0;
	double *path1p, *path2p;

	signal1p = mxGetPr(signal1);
	signal2p = mxGetPr(signal2);

	size1 = mxGetN(signal1);
	size2 = mxGetN(signal2);

	tcols = 1+2*(Wj+1);

	/* initialize cost matrix */
	costmatrix = mxCreateDoubleMatrix(size1, tcols, mxREAL);
	costmatrixp = (double **) mxCalloc(tcols, sizeof(double *));
	for( i = 0; i < tcols; i++ )
		costmatrixp[i] = mxGetPr(costmatrix) + i*size1;

	/* initialize index matrix */
	indices = mxCreateDoubleMatrix(size1, tcols, mxREAL);
	indicesp = (double **) mxCalloc(tcols, sizeof(double *));
	for( i = 0; i < tcols; i++ )
		indicesp[i] = mxGetPr(indices) + i*size1;

	/* initialize is matrix */
	is = mxCreateDoubleMatrix(size1, tcols, mxREAL);
	isp = (double **) mxCalloc(tcols, sizeof(double *));
	for( i = 0; i < tcols; i++ )
		isp[i] = mxGetPr(is) + i*size1;

	/* initialize js matrix */
	js = mxCreateDoubleMatrix(size1, tcols, mxREAL);
	jsp = (double **) mxCalloc(tcols, sizeof(double *));
	for( i = 0; i < tcols; i++ )
		jsp[i] = mxGetPr(js) + i*size1;

	/* now initialize all arrays */
	for( i = 0; i < tcols; i++ )
		for( j = 0; j < size1; j++ )
		{
			double dummy1 = 1, dummy2 = 0;

			costmatrixp[i][j] = (dummy1 / dummy2);
			indicesp[i][j] = -1;
			isp[i][j] = j;
			jsp[i][j] = j+i-(tcols-1)/2;
		}

	/* now compute the cost table and initialize indices*/
	for( j = 0; j < size1; j++ )
		for( i = 1; i < tcols-1; i++ )
		{
			double top, diag, left;
			double dummy1 = 1, dummy2 = 0;

			if( j>0 )
			{
				top = costmatrixp[i][j-1];
				diag = costmatrixp[i+1][j-1];
			}	
			else
			{
				top = dummy1 / dummy2;
				diag = dummy1 / dummy2;
			}
			left = costmatrixp[i-1][j];

			if( (isp[i][j] >= 0) && (isp[i][j] < size1) &&
				(jsp[i][j] >= 0) && (jsp[i][j] < size2) )
			{
				double val1, val2;

				val1 = signal1p[(int) isp[i][j]];
				val2 = signal2p[(int) jsp[i][j]];

				if( minele(top, left, diag) == (dummy1/dummy2) )
				{
					indicesp[i][j] = -1;

					if( isnan(val1) || isnan(val2) )
						costmatrixp[i][j] = 5 * (isp[i][j] - jsp[i][j]) * (isp[i][j] - jsp[i][j]);
					else
						costmatrixp[i][j] = (val1 - val2) * (val1 - val2);
				}
				else
				{
					indicesp[i][j] = minarg(top, left, diag);
					if( isnan(val1) || isnan(val2) )
						costmatrixp[i][j] = minele(top, left, diag) + 5 * (isp[i][j] - jsp[i][j]) * (isp[i][j] - jsp[i][j]);
					else
						costmatrixp[i][j] = minele(top, left, diag) + (val1 - val2) * (val1 - val2);
				}
			}

		}

	/* now backtrack to find the paths */
	i = (tcols-1)/2;	
	j = size1-1;

	while( indicesp[i][j] >= 0 )
	{
		npath1 = npath1 + 1;
		npath2 = npath2 + 1;

		if( indicesp[i][j] == 0 )
		{
			j = j - 1;
		}
		else if( indicesp[i][j] == 1 )
		{
			i = i - 1;
		}
		else
		{
			i = i + 1;
			j = j - 1;
		}
	}

	*path1 = mxCreateDoubleMatrix(1, npath1, mxREAL);
	*path2 = mxCreateDoubleMatrix(1, npath2, mxREAL);

	path1p = mxGetPr(*path1);
	path2p = mxGetPr(*path2);

	/* now backtrack to find the paths */
	i = (tcols-1)/2;	
	j = size1-1;

	while( indicesp[i][j] >= 0 )
	{
		npath1 = npath1 - 1;
		npath2 = npath2 - 1;

		path1p[npath1] = isp[i][j]+1;
		path2p[npath2] = jsp[i][j]+1;

		if( indicesp[i][j] == 0 )
		{
			j = j - 1;
		}
		else if( indicesp[i][j] == 1 )
		{
			i = i - 1;
		}
		else
		{
			i = i + 1;
			j = j - 1;
		}
	}	

	/* free all allocated memory */
	mxDestroyArray(js);
	mxDestroyArray(is);
	mxDestroyArray(indices);
	mxDestroyArray(costmatrix);
	mxFree(jsp);
	mxFree(isp);
	mxFree(indicesp);
	mxFree(costmatrixp);
}
	
void 
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if( nlhs != 2 )
		mexErrMsgTxt("Invalid number of output arguments");

	if( nrhs != 3 )
		mexErrMsgTxt("Invalid number of input arguments");

	if( (mxGetM(prhs[0]) != 1) || (mxGetM(prhs[1]) != 1 ) )
		mexErrMsgTxt("Signals must be vectors");

	if( mxGetN(prhs[0]) != mxGetN(prhs[1]) )
		mexErrMsgTxt("Signals must have the same size");
	
	if( (mxGetN(prhs[2]) != 1) || (mxGetM(prhs[2]) != 1) )
		mexErrMsgTxt("window size must be a scalar");

	timeWarp(prhs[0], prhs[1], (int) mxGetScalar(prhs[2]), &plhs[0], &plhs[1]);
}
