#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include "ExampleDlg.h"
#include "mex.h"

extern char outsubdir[255];
extern char pointsname[255];
extern int spnsize;

void
save(Matrix *pts)
{
	char filename[255];
	FILE *fp;

	/* generate filename for writing */
	sprintf(filename, "%s\\%s", outsubdir, pointsname);

	/* open the file for writing */
	fp = fopen(filename, "a");

	/* save data if possible */
	if( fp != NULL )
	{
		int i;
		double zero = 0;

		if( (pts == NULL) || 
			(mxGetM(pts) != 2) || 
			(mxGetN(pts) != spnsize) )
		{
			/* now save x coordinates */
			for( i = 0; i < spnsize; i++ )
				fprintf(fp, "%lf ", zero / zero);
			fprintf(fp, "\n");

			/* now save y coordinates */
			for( i = 0; i < spnsize; i++ )
				fprintf(fp, "%lf ", zero / zero);
			fprintf(fp, "\n");
		}
		else
		{
			double **ptsp = (double **) mxGetPr(pts);

			/* now save x coordinates */
			for( i = 0; i < spnsize; i++ )
				fprintf(fp, "%lf ", ptsp[i][0]);
			fprintf(fp, "\n");
			
			/* now save y coordinates */
			for( i = 0; i < spnsize; i++ )
				fprintf(fp, "%lf ", ptsp[i][1]);
			fprintf(fp, "\n");
		}
	}

	/* close the file */
	fclose(fp);
}

