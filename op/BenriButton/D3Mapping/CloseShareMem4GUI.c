#include <windows.h>
#include "mex.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

//ret=CloseShareMem4GUI(Shmem,hShare)
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
	void *Shmem;
	HANDLE hShare;
	double ret=0.0, work1, work2;
	char buf[256];
  /* Check num of arg */
	if (nrhs!=2){
		mexErrMsgTxt("Error : 2 input parameters not specified.");
	} else if (nlhs !=1){
		mexErrMsgTxt("Error : 1 output parameters not specified.");
	}
	work1=mxGetScalar(prhs[0]);
	work2=mxGetScalar(prhs[1]);
	memcpy(&Shmem,&work1,sizeof(void *));
    memcpy(&hShare,&work2,sizeof(HANDLE));

//sprintf(buf, "hShare=%x", hShare);
//mexPrintf(buf);
//sprintf(buf, "Shmem=%x\n", Shmem);
//mexPrintf(buf);

	if (!UnmapViewOfFile(Shmem)) {
		CloseHandle(hShare);
		mexErrMsgTxt("UnmapViewOfFile failed.");
		ret = 1.0;
	}

	if (!CloseHandle(hShare)) {
		mexErrMsgTxt("CloseHandle failed.");
		ret = 1.0;
	}

	plhs[0] = mxCreateDoubleScalar((double) ret);
}
