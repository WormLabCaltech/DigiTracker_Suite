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
	  unsigned char *data;

	  mat = (Matrix *) mxCalloc(1, sizeof(Matrix));
	  mat->m = m;
	  mat->n = n;
	  mat->data = (void *) mxCalloc(m*n, sizeof(unsigned char));

	  data = (unsigned char *) mat->data;
	  for( i = 0; i < m*n; i++ )
		data[i] = (unsigned char) 0;

	  mat->datap = (void **) mxCalloc(n, sizeof(unsigned char *));
	  for( i = 0; i < n; i++ )
		mat->datap[i] = ((unsigned char *) mat->data) + i*m;

	  mat->type = CHAR;
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

void
MatrixToArray(COleSafeArray *array, Matrix *mat)
{
  unsigned char **matp;
  long startm, startn, endm, endn;
  int i, j;
  long ind[2];
  unsigned char *valp = NULL;

  /* get dimensions of array */
  array->GetLBound((DWORD) 1, &startn);
  array->GetLBound((DWORD) 2, &startm);
  array->GetUBound((DWORD) 1, &endn);
  array->GetUBound((DWORD) 2, &endm);

  /* set up matrix for two dimensional indexing */
  matp = (unsigned char **) mxGetPr(mat);

  for( j = startm; j <= endm; j++ )
  {
	ind[0] = startn; ind[1] = j;
    array->PtrOfIndex(ind, (void **) &valp);
	for( i = startn; i <= endn; i++ )
	{
		*valp = (unsigned char) matp[i-startn][j-startm];
		valp = valp + 1;
	}
  }
}

void
ArrayToMatrix(COleSafeArray *array, Matrix *mat)
{
  long startm, startn, endm, endn;
  int i, j;
  unsigned char **matp;
  long ind[2];
  unsigned char val;
  unsigned char *valp = NULL;

  /* get dimensions of array */
  array->GetLBound((DWORD) 1, &startn);
  array->GetLBound((DWORD) 2, &startm);
  array->GetUBound((DWORD) 1, &endn);
  array->GetUBound((DWORD) 2, &endm);

  /* initialize the matrix structure */
  matp = (unsigned char **) mxGetPr(mat);

  for( j = startm; j <= endm; j++ )
  {
	ind[0] = startn; ind[1] = j;
    array->PtrOfIndex(ind, (void **) &valp);
	for( i = startn; i <= endn; i++ )
	{
		val = *valp;
		matp[i-startn][j-startm] = (unsigned char) val;
		valp = valp + 1;
	}
  }
}
