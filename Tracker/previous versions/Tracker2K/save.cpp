#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include "ExampleDlg.h"
#include "mex.h"

extern char pointsdir[255];
extern char pointsname[255];

void
saveh(Matrix *pts)
{
	char filename[255];
	FILE *fp;

	/* generate filename for writing */
	sprintf(filename, "%s\\%s", pointsdir, pointsname);

	/* open the file for writing */
	fp = fopen(filename, "a");

	/* save data if possible */
	if( fp != NULL )
	{
		int i, npoints = mxGetN(pts);
		double **ptsp = (double **) mxGetPr(pts);

		/* now save x coordinates */
		for( i = 0; i < npoints; i++ )
			fprintf(fp, "%lf ", ptsp[i][0]);
		fprintf(fp, "\n");
		
		/* now save y coordinates */
		for( i = 0; i < npoints; i++ )
			fprintf(fp, "%lf ", ptsp[i][1]);
		fprintf(fp, "\n");
	}

	/* close the file */
	fclose(fp);
}

void
save(Matrix *pts)
{
	if( pts == NULL )
		return;

	if( mxGetM(pts) != 2 )
		return;

	saveh(pts);
}
