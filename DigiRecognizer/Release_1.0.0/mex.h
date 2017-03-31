#ifndef MEX_H
#define MEX_H

#define CHAR  0
#define SHORT 1
#define INT   2
#define REAL  3

typedef struct  
{
	int m;
	int n;
	int type;
	void *data;
	void **datap;
} Matrix;

Matrix *mxCreateFull(int m, int n, int type);
void mxFreeMatrix(Matrix *m);
void *mxCalloc(int n, int size);
void mxFree(void *mem);

void *mxGetP(Matrix *m);
void **mxGetPr(Matrix *m);

int mxGetM(Matrix *m);
int mxGetN(Matrix *m);
int mxGetType(Matrix *m);

COleSafeArray *MatrixToArray(Matrix *mat);
void ArrayToMatrix(COleSafeArray *array, Matrix *mat);
void MatrixToArray(COleSafeArray *array, Matrix *mat);

#endif