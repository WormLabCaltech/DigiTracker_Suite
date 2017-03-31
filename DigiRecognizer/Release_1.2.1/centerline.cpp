#include "stdafx.h"
#include "triangle.h"
#include "diameter.h"
#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern void triangulate(char *triswitches, struct triangulateio *in, 
						struct triangulateio *out, struct triangulateio *vorout);
extern Matrix *interpolate_linear(Matrix *y, int n);

// ***********************************************************************************
// Functions for triangulizing
// ***********************************************************************************

void
initialize_tri(struct triangulateio *in)
{
  in->pointlist = (REALTRI *) NULL;
  in->pointattributelist = (REALTRI *) NULL;
  in->pointmarkerlist = (int *) NULL;
  in->numberofpoints = 0;
  in->numberofpointattributes = 0;
  in->trianglelist = (int *) NULL;
  in->triangleattributelist = (REALTRI *) NULL;
  in->trianglearealist = (REALTRI *) NULL;
  in->neighborlist = (int *) NULL;
  in->numberoftriangles = 0;
  in->numberofcorners = 0;
  in->numberoftriangleattributes = 0;
  in->segmentlist = (int *) NULL;
  in->segmentmarkerlist = (int *) NULL;
  in->numberofsegments = 0;
  in->holelist = (REALTRI *) NULL;
  in->numberofholes = 0;
  in->regionlist = (REALTRI *) NULL;
  in->numberofregions = 0;
  in->edgelist = (int *) NULL; 
  in->edgemarkerlist = (int *) NULL;
  in->normlist = (REALTRI *) NULL;
  in->numberofedges = 0;                 
}

void
free_tri(struct triangulateio *in)
{
  if( in->pointlist ) free(in->pointlist);
  if( in->pointattributelist ) free(in->pointattributelist);
  if( in->pointmarkerlist ) free(in->pointmarkerlist);
  if( in->trianglelist ) free(in->trianglelist);
  if( in->triangleattributelist ) free(in->triangleattributelist);
  if( in->trianglearealist ) free(in->trianglearealist);
  if( in->neighborlist ) free(in->neighborlist);
  if( in->segmentlist ) free(in->segmentlist);
  if( in->segmentmarkerlist ) free(in->segmentmarkerlist);
  if( in->holelist ) free(in->holelist);
  if( in->regionlist ) free(in->regionlist);
  if( in->edgelist ) free(in->edgelist); 
  if( in->edgemarkerlist ) free(in->edgemarkerlist);
  if( in->normlist ) free(in->normlist);           	
}

Matrix * 
getTriangles(struct triangulateio *io)
{
  Matrix *triangles;
  double **trianglesp;
  int i, j;
  int ntriangles = io->numberoftriangles;
  
  /* allocate space for output */
  triangles = mxCreateFull(ntriangles, 3, REAL);

  /* set up for two dimensional indexing */
  trianglesp = (double **) mxGetPr(triangles);

  /* now get the triangles */
  for (i = 0; i < io->numberoftriangles; i++) 
    for (j = 0; j < io->numberofcorners; j++) 
      trianglesp[j][i] = io->trianglelist[i * io->numberofcorners + j] - 1;
  
  /* return the answer */
  return(triangles);
}

Matrix * 
getNeighbors(struct triangulateio *io)
{
  Matrix *neighbors;
  double **neighborsp;
  int i, j;
  int ntriangles = io->numberoftriangles;
  
  /* allocate space for output */
  neighbors = mxCreateFull(ntriangles, 3, REAL);

  /* set up for two dimensional indexing */
  neighborsp = (double **) mxGetPr(neighbors);

  /* now get the neighbors */
  for (i = 0; i < io->numberoftriangles; i++) 
    for (j = 0; j < 3; j++)
      neighborsp[j][i] = io->neighborlist[i * 3 + j] - 1;

  /* return the answer */
  return(neighbors);
}

void
triangleh(Matrix *points, Matrix **triangles, Matrix **neighbors)
{
  int i, npoints;
  unsigned int **pointsp;
  struct triangulateio in, mid; 

  /* initialize in */
  initialize_tri(&in);  

  /* set point coordinates */
  npoints = mxGetN(points) - 1; 
  pointsp = (unsigned int **) mxGetPr(points);

  in.numberofpoints = npoints;
  in.pointlist = (REALTRI *) malloc(npoints * 2 * sizeof(REALTRI));

  for( i = 0; i < npoints; i++ )
  {
	in.pointlist[2*i] = (double) pointsp[i][0];
	in.pointlist[2*i+1] = (double) pointsp[i][1];
  }

  /* set list of edge segments */
  in.numberofsegments = npoints;
  in.segmentlist = (int *) malloc(npoints * 2 * sizeof(int));
  for( i = 0; i < npoints; i++ )
  {
	in.segmentlist[2*i] = i + 1;
    if( (i + 1) < npoints ) 
      in.segmentlist[2*i+1] = i + 1 + 1;
    else
      in.segmentlist[2*i+1] = 0 + 1;
  }

  /* initialize mid */
  initialize_tri(&mid);             

  /* now do the triangulation */
  triangulate("Qpn", &in, &mid, (struct triangulateio *) NULL);

  /* now print out the result */
  *triangles = getTriangles(&mid);
  *neighbors = getNeighbors(&mid);

  /* Free all allocated arrays, including those allocated by Triangle. */
  free_tri(&in);
  free_tri(&mid);
}

void
triangle(Matrix *points, Matrix **triangles, Matrix **neighbors)
{
  *triangles = NULL;
  *neighbors = NULL;

  /* now do some error checking */
  if( points == NULL )
	return;

  if( mxGetM(points) != 2 )
	return;

  if( mxGetM(points) * mxGetN(points) < 6 )
	return;

  /* now do the computation */
  triangleh(points, triangles, neighbors);	
}

// ***********************************************************************************
// These functions are used to compute the diameter
// ***********************************************************************************

void
init_queue(queue *q)
{
  q->head = NULL;
  q->tail = NULL;
}

int
isempty(queue *q)
{
  if( q->head == NULL )
    return(1);
  else
    return(0);
}

int
head(queue *q)
{
  if( q->head == NULL )
    return(-1);
  else
    return( q->head->item );
}

void
insert(queue *q, int item)
{
  node *new_node;

  new_node = (node * ) malloc(sizeof(node));
  new_node->item = item;
  new_node->next = NULL;
  
  if( isempty(q) )
  {
    q->head = new_node;
    q->tail = new_node;
  }
  else
  {
    q->tail->next = new_node;
    q->tail = new_node;
  }
}

void
remov(queue *q)
{
  if( !isempty(q) )
  {  
    if( q->head == q->tail )
    {
      free(q->head);
      q->head = NULL;
      q->tail = NULL;
    }
    else
    {
      node *temp;
      
      temp = q->head;
      q->head = q->head->next;
      free(temp);
    }
  }
}

int
eccentricity(int start, double **adjp, int nvertices, int maxneighbors)
{
  int i;
  int *color;
  int *dist;
  queue q;
  int res;

  /* allocate color array */
  color = (int *) mxCalloc(nvertices, sizeof(int));
  dist = (int *) mxCalloc(nvertices, sizeof(int));
  for( i = 0; i < nvertices; i++ )
  {
    color[i] = 0;
    dist[i] = 0;
  }

  /* initialize the queue */
  init_queue(&q);

  /* the bfs algorithm */
  insert(&q, start);
  while( !isempty(&q) )
  {
    int cur = head(&q);
    for( i = 0; i < 3; i++ )
    {
      int neigh = (int) adjp[i][cur];
      if( neigh >= 0 )
      {
	if( color[neigh] == 0 )
	{
	  color[neigh] = 1;
	  dist[neigh] = dist[cur] + 1;
	  insert(&q, neigh);
	}
      }
    }
    remov(&q);
    color[cur] = 2;
  }

  /* compute the answer */
  res = 0;
  for( i = 0; i < nvertices; i++ )
    if( dist[i] > res )
      res = dist[i];

  /* free all allocated memory */
  mxFree(color);
  mxFree(dist);

  /* return the answer */
  return(res+1);
}

Matrix *
longest_path(int start, double **adjp, int nvertices, int maxneighbors)
{
  int i;
  int *color;
  int *dist;
  int *pi;
  queue q;
  Matrix *lp; double *lpp;
  int length;
  int cur;

  /* allocate color array */
  color = (int *) mxCalloc(nvertices, sizeof(int));
  dist = (int *) mxCalloc(nvertices, sizeof(int));
  pi = (int *) mxCalloc(nvertices, sizeof(int));

  for( i = 0; i < nvertices; i++ )
  {
	color[i] = 0;
	dist[i] = 0;
	pi[i] = 0;
  }

  /* initialize the queue */
  init_queue(&q);

  /* the bfs algorithm */
  insert(&q, start);
  while( !isempty(&q) )
  {
    cur = head(&q);
    for( i = 0; i < 3; i++ )
    {
      int neigh = (int) adjp[i][cur];
      if( neigh >= 0 )
      {
		if( color[neigh] == 0 )
		{
			color[neigh] = 1;
			dist[neigh] = dist[cur] + 1;
			pi[neigh] = cur;
			insert(&q, neigh);
		}
      }
    }
    remov(&q);
    color[cur] = 2;
  }

  /* now compute the length of the longest path */
  length = 0;
  for( i = 0; i < nvertices; i++ )
    if( dist[i] > length )
      length = dist[i];
  length = length + 1;
  
  /* compute the answer */
  lp = mxCreateFull(1, length, REAL);
  lpp = (double *) mxGetP(lp);
  for( i = 0; i < length; i++ )
  {
    lpp[i] = cur;
    cur = pi[cur];
  }
    
  /* free all allocated memory */
  mxFree(color);
  mxFree(dist);
  mxFree(pi);

  /* return the answer */
  return(lp);
}

Matrix *
diameterh(Matrix *adj)
{
  double **adjp;
  int nvertices, maxneighbors, i;
  int maxeccentricity, beststart;
  Matrix *lngpath;

  /* get size of the adjacency matrix */
  nvertices = mxGetM(adj);
  maxneighbors = mxGetN(adj);

  /* set up for two dimensional indexing */
  adjp = (double **) mxGetPr(adj);

  /* now find the best solution */
  maxeccentricity = 0;
  beststart = -1;
  for( i = 0; i < nvertices; i++ )
  {
    int dist = eccentricity(i, adjp, nvertices, maxneighbors);
    
    if( dist > maxeccentricity )
    {
      maxeccentricity = dist;
      beststart = i;
    }
  }
  
  /* find the longest path */
  lngpath = longest_path(beststart, adjp, nvertices, maxneighbors);

  /* return the answer */
  return(lngpath);
}

Matrix *
diameter(Matrix *adj)
{
  /* do some error checking */
  if( adj == NULL )
	  return(NULL);

  if( mxGetM(adj) * mxGetN(adj) == 0 )
	  return(NULL);

  if( mxGetN(adj) != 3 )
	  return(NULL);

  /* now do the computation */
  return(diameterh(adj));		
}

// ***********************************************************************************
// This function computes the spine 
// ***********************************************************************************

Matrix *
spineh(Matrix *pts, Matrix *tri, Matrix *dia)
{
  Matrix *res;
  int ntriangles, i;
  unsigned int **ptsp;
  double **trip, *diap, **resp;	

  /* compute the number of triangles */
  ntriangles = mxGetN(dia);

  /* now allocate space for the result */
  res = mxCreateFull(2, ntriangles, REAL);

  /* now set up arrays for two dimensional indexing */	
  ptsp = (unsigned int **) mxGetPr(pts);
  trip = (double **) mxGetPr(tri);
  resp = (double **) mxGetPr(res);

  diap = (double *) mxGetP(dia);

  /* go over the path */
  for( i = 0; i < ntriangles; i++ )
  {
	int v1, v2, v3;
	double x1, y1, 
		   x2, y2, 
		   x3, y3;
	double numx, numy, den, ox, oy;

	/* read in the vertices of the triangles */
	v1 = (int) trip[0][(int) diap[i]];		/* Explicitly cast result to int */
	v2 = (int) trip[1][(int) diap[i]];		/* Explicitly cast result to int */
	v3 = (int) trip[2][(int) diap[i]];		/* Explicitly cast result to int */

	/* next read in the coordinates of the vertices */
	x1 = ptsp[v1][0]; y1 = ptsp[v1][1];
	x2 = ptsp[v2][0]; y2 = ptsp[v2][1];
	x3 = ptsp[v3][0]; y3 = ptsp[v3][1];

	/* now compute the CIRCUMCENTER of each triangle              *
	 * (This was previously [incorrectly] listed as computing the *
	 * the 'orthocenter' of each triangle.  CJC verified formula  *
	 * below against Wikipedia entry for Circumcenter.)	          */
    den = x1*y2+x2*y3+x3*y1-x1*y3-x2*y1-x3*y2;
	numx = x1*x1*y2 - x1*x1*y3
		 + y1*y1*y2 - y1*y1*y3
		 - x2*x2*y1 + x2*x2*y3
		 - y2*y2*y1 + y2*y2*y3
		 + x3*x3*y1 - x3*x3*y2
		 + y3*y3*y1 - y3*y3*y2;
	numy = x1*x2*x2 + x1*y2*y2
		 - x1*x3*x3 - x1*y3*y3
		 - x2*x1*x1 - x2*y1*y1
		 + x2*x3*x3 + x2*y3*y3
		 + x3*x1*x1 + x3*y1*y1
		 - x3*x2*x2 - x3*y2*y2;

	ox = numx / (2*den);
	oy = numy / (2*den);

	/* now save the result */
	resp[i][0] = ox;
	resp[i][1] = oy;
  }

  /* return the answer */
  return(res);
}

Matrix *
spine(Matrix *pts, Matrix *tri, Matrix *dia)
{
  /* check matrix of points */
  if( pts == NULL )
	  return(NULL);

  if( mxGetM(pts) * mxGetN(pts) == 0 )
	  return(NULL);

  if( mxGetM(pts) != 2 )
	  return(NULL);

  /* check triangle list */
  if( tri == NULL )
	  return(NULL);

  if( mxGetM(tri) * mxGetN(tri) == 0 )
	  return(NULL);

  if( mxGetN(tri) != 3 )
	  return(NULL);

  /* check diameter list */
  if( dia == NULL )
	  return(NULL);

  if( mxGetM(dia) * mxGetN(dia) == 0 )
	  return(NULL);

  if( mxGetM(dia) != 1 )
	  return(NULL);

  /* now do the computation */
  return(spineh(pts, tri, dia));	
}

// ***********************************************************************************
// This is the main routine  
// ***********************************************************************************

void
centerline(Matrix *bndry, Matrix **spn, Matrix **pts, int npoints)
{
	// bndry is 50 XY coordinate pairs
	// 
  Matrix *tri = NULL;
  Matrix *ngh = NULL; 
  Matrix *dia = NULL;	
  
   /* now do the computation */
  triangle(bndry, &tri, &ngh);	// tri is list of triangles; ngh is list of neighbors for each triangle
  dia = diameter(ngh);	// dia is longest path -- list of triangles in order from end "A" to end "B" (1x # triangles, i.e. vector)
  *spn = spine(bndry, tri, dia);	// spn (2x # triangles) is coordinates of 'CIRCUMCENTER' of each triangle.  (Previously [incorrectly] listed as 'orthocenter'.)
  *pts = interpolate_linear(*spn, npoints); 	

  /* free all allocated memory */
  mxFreeMatrix(tri);
  mxFreeMatrix(ngh);
  mxFreeMatrix(dia);	
}

