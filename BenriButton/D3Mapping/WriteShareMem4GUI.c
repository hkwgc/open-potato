#include <windows.h>
#include "mex.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

//ret=WriteShareMem4GUI(Shmem,hShare,Std_Stylus,Std_Head,Std_Brain)
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
	void *Shmem;
	HANDLE hShare;
	double ret=0.0, work1, work2;
	double *Std_Stylus, *Std_Head, *Std_Brain;
//	char buf[256];
  /* Check num of arg */
	if (nrhs!=5){
		mexErrMsgTxt("Error : 5 input parameters not specified.");
	} else if (nlhs !=1){
		mexErrMsgTxt("Error : 1 output parameters not specified.");
	}
	work1=mxGetScalar(prhs[0]);
	work2=mxGetScalar(prhs[1]);
	memcpy(&Shmem,&work1,sizeof(void *));
    memcpy(&hShare,&work2,sizeof(HANDLE));
    
    Std_Stylus = calloc(3, sizeof(double));
    Std_Head = calloc(3, sizeof(double));
    Std_Brain = calloc(3, sizeof(double));
	Std_Stylus = mxGetPr(prhs[2]);
	Std_Head = mxGetPr(prhs[3]);
	Std_Brain = mxGetPr(prhs[4]);

//sprintf(buf, "hShare=%x", hShare);
//mexPrintf(buf);
//sprintf(buf, "Shmem=%x\n", Shmem);
//mexPrintf(buf);
//	hShm = CreateFileMappingA((HANDLE) -1, NULL, PAGE_READWRITE, 0, SHM_SIZE, "ShareMem4GUI");
//	if (hShm == NULL) {
//		mexErrMsgTxt("CreateFileMappingA failed.");
//	}
//
//	p = MapViewOfFile(hShm, FILE_MAP_WRITE, 0, 0, 0);
//	if (p == NULL) {
//		mexErrMsgTxt("MapViewOfFile failed.");
//	}
//	memcpy(((char *)p+   0), Aso_size, 9*sizeof(double));

	if(Shmem==0) {
		mexErrMsgTxt("MapViewOfFile is invalid.");
		ret = 1.0;
	}
	memcpy(((char *)Shmem+    80), Std_Stylus, 3*sizeof(double));
	memcpy(((char *)Shmem+   112), Std_Head, 3*sizeof(double));
	memcpy(((char *)Shmem+   144), Std_Brain, 3*sizeof(double));

	plhs[0] = mxCreateDoubleScalar((double) ret);
}
