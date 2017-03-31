#include "stdafx.h"
#include "mex.h"

void *
mxCalloc(int n, int size)
{
  return( (void *) malloc(n * size) );	
}

void 
mxFree(void *mem)
{
  if( mem != NULL)	
    free(mem);
}

Matrix *
mxCreateFull(int m, int n, int type)
{
  Matrix *mat = NULL;
  int i;

  if( type == CHAR )
  {
	  mat = (Matrix *) mxCalloc(1, sizeof(Matrix));
	  mat->m = m;
	  mat->n = n;
	  mat->data = (void *) mxCalloc(m*n, sizeof(unsigned char));

	  mat->datap = (void **) mxCalloc(n, sizeof(unsigned char *));
	  for( i = 0; i < n; i++ )
		mat->datap[i] = ((unsigned char *) mat->data) + i*m;

	  mat->type = CHAR;
  }
  else if( type == SHORT )
  {
	  mat = (Matrix *) mxCalloc(1, sizeof(Matrix));
	  mat->m = m;
	  mat->n = n;
	  mat->data = (void *) mxCalloc(m*n, sizeof(unsigned short));

	  mat->datap = (void **) mxCalloc(n, sizeof(unsigned short *));
	  for( i = 0; i < n; i++ )
		mat->datap[i] = ((unsigned short *) mat->data) + i*m;

	  mat->type = SHORT;
  }
  else if( type == INT )
  {
	  mat = (Matrix *) mxCalloc(1, sizeof(Matrix));
	  mat->m = m;
	  mat->n = n;
	  mat->data = (void *) mxCalloc(m*n, sizeof(unsigned int));

	  mat->datap = (void **) mxCalloc(n, sizeof(unsigned int *));
	  for( i = 0; i < n; i++ )
		mat->datap[i] = ((unsigned int *) mat->data) + i*m;

	  mat->type = INT;
  }
  else if( type == REAL )
  {
	  mat = (Matrix *) mxCalloc(1, sizeof(Matrix));
	  mat->m = m;
	  mat->n = n;
	  mat->data = (void *) mxCalloc(m*n, sizeof(double));
	
	  mat->datap = (void **) mxCalloc(n, sizeof(double *));
	  for( i = 0; i < n; i++ )
		mat->datap[i] = ((double *) mat->data) + i*m;

	  mat->type = REAL;
  }

  return(mat);	
}

void 
mxFreeMatrix(Matrix *m)
{
  if( m != NULL )
  {
	if( m->data != NULL )
	  mxFree(m->data);

	if( m->datap != NULL )
	  mxFree(m->datap);

	mxFree(m);
  }
}

void *
mxGetP(Matrix *m)
{
  if( m == NULL )
	return(NULL);
  else
	return(m->data);	
}

void **
mxGetPr(Matrix *m)
{
  if( m == NULL )
	return(NULL);
  else
	return(m->datap);	
}

int 
mxGetM(Matrix *m)
{
  if( m == NULL )		
	return(0);
  else
	return(m->m);	
}

int 
mxGetN(Matrix *m)
{
  if( m == NULL )
	return(0);
  else
	return(m->n);
}

int
mxGetType(Matrix *m)
{
  if( m == NULL )
	return(-1);
  else
	return(m->type);
}

COleSafeArray *
MatrixToArray(Matrix *mat)
{
  double **matp;
  COleSafeArray *array = new COleSafeArray();
  int i, j;
  DWORD dim[2];

  /* allocate the array */
  dim[0] = mxGetN(mat); dim[1] = mxGetM(mat);
  array->Create(VT_I1, (DWORD) 2, dim); 

  /* set up matrix for two dimensional indexing */
  matp = (double **) mxGetPr(mat);

  /* now initialize the contents of the array */
  for( i = 0; i < mxGetN(mat); i++ )
	for( j = 0; j < mxGetM(mat); j++ )
	{
      long ind[2]; 
      unsigned char data;  
 		
	  ind[0] = i; ind[1] = j;
      data = (unsigned char) matp[i][j];
	  array->PutElement(ind, &data);
	}
   
  /* return the array */
  return(array);
}

void
ArrayToMatrix(COleSafeArray *array, Matrix *mat)
{
  long startm, startn, endm, endn;
  int i, j;
  unsigned int **matp;
  long ind[2];
  unsigned char val;
  unsigned char *valp = NULL;

  /* get dimensions of array */
  array->GetLBound((DWORD) 1, &startn);
  array->GetLBound((DWORD) 2, &startm);
  array->GetUBound((DWORD) 1, &endn);
  array->GetUBound((DWORD) 2, &endm);

  /* initialize the matrix structure */
  matp = (unsigned int **) mxGetPr(mat);

  for( j = startm; j <= endm; j++ )
  {
	ind[0] = startn; ind[1] = j;
    array->PtrOfIndex(ind, (void **) &valp);
	for( i = startn; i <= endn; i++ )
	{
		val = *valp;
		matp[i-startn][j-startm] = (unsigned int) val;
		valp = valp + 1;
	}
  }
}
